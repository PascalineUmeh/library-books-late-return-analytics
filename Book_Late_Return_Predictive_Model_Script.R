###Setting work directory
getwd()
setwd('../Downloads')

###Installation and Importation of needed packages and libraries.
#install.packages(c('tidyverse','tidymodels'))
#install.packages('lubridate')
library(lubridate)
library(tidyverse)
library(tidymodels)

list.files()

books <- read.csv('books.csv')
checkout <- read.csv("checkouts.csv")
customers <- read.csv("customers.csv")
libraries <- read.csv("libraries.csv")

glimpse(books)
books <- books %>% 
  select(-X)

checkout %>% glimpse()
checkout %>% 
  select(-starts_with('X')) -> checkout

customers %>% glimpse()
customers %>% 
  select(-starts_with('X')) -> customers

libraries %>% glimpse()
libraries %>% 
  select(-starts_with('X')) -> libraries

View(books)
view(customers)
View(checkout)
View(libraries)

# Data cleaning
# Converting book Published date to date
books %>% 
  mutate(PUBLISHEDDATE = mdy(PUBLISHEDDATE)) -> books

names(books) <- c('Book_ID',names(books)[-1])
names(libraries) <- c('Library_ID',names(libraries)[-1])
# Formatting columns in Customers
customers %>% 
  mutate(GENDER = str_squish(GENDER),
         BIRTH_DATE = mdy(BIRTH_DATE),
         EDUCATION=str_squish(str_to_title(EDUCATION)),
         OCCUPATION=str_squish(str_to_title(OCCUPATION))
         ) -> customers

customers %>% view()

# Formatting columns in Checkout data
checkout %>% 
  mutate(DATE_CHECKOUT = mdy(DATE_CHECKOUT), 
         DATE_RETURNED = mdy(DATE_RETURNED)
         ) -> checkout

customers %>% 
  left_join(checkout, c('ID'='PATRON_ID..CUSTOMERS_ID.')) %>% 
  left_join(books, c('BOOKS_ID'='Book_ID')) %>% 
  left_join(libraries, c('LIBRARY_ID'='Library_ID')) %>% 
  rename(CUST_NAME = NAME.x, CUST_ADDR=STREET_ADDRESS.x,
         CUST_CITY = CITY.x,
         LIB_NAME = NAME.y, LIB_ADDR = STREET_ADDRESS.y,
         LIB_CITY = CITY.y, CUST_STATE=STATE) %>% 
  select(ID, CUST_NAME, CUST_CITY, CUST_STATE, CUST_CITY,
         BIRTH_DATE, GENDER, EDUCATION, OCCUPATION, BOOKS_ID,
         LIBRARY_ID, DATE_CHECKOUT, DATE_RETURNED, AUTHORS,
         PUBLISHER, PUBLISHEDDATE, CATEGORIES, PRICE, PAGES) -> merged_data

dim(merged_data)

View(merged_data)

## Data preparation and Feature engineering
# Creating duration for borrowing period and Customer's age as at today
merged_data %>% 
  mutate(Duration = DATE_RETURNED - DATE_CHECKOUT,
         Age = floor((Sys.Date() - BIRTH_DATE)/365)) -> merged_data

# Formatting the Age and Duration column
merged_data %>% 
  mutate(Duration=as.numeric(Duration),
         Age = as.numeric(Age)) -> merged_data

# Filling NA with 0
merged_data %>% 
  mutate(Duration = case_when(is.na(Duration) ~ 0, T ~ Duration),
         Age = case_when(is.na(Age) ~ 0, T ~ Age)) -> merged_data

# Excluding negative durations and negative age
merged_data %>% 
  mutate(Duration = case_when(Duration < 0 ~ 0, T ~ Duration),
         Age = case_when(Age < 0 ~ 0, T ~ Age)) -> merged_data

# Replacing Duration greater than 365 as 365
# Excluding negative durations and negative age
merged_data %>% 
  mutate(Duration = case_when(Duration > 365 ~ 365, T ~ Duration)
  ) -> merged_data

# Creating late return status variable
merged_data %>% 
  mutate(Duration = case_when(Duration == 0 ~ 1/NA, 
                              T ~ Duration)
  ) -> merged_data

merged_data %>% 
  mutate(LATE_RETURN = case_when(Duration > 28 ~ 1, 
                                 is.na(Duration) ~ 1/NA, T ~ 0)
  ) -> merged_data

# Creating age of book in years
merged_data %>% 
  mutate(BOOK_AGE = (Sys.Date()-PUBLISHEDDATE)/365) %>% 
  mutate(BOOK_AGE = as.numeric(BOOK_AGE)) -> merged_data

## Building the model
df <- merged_data
df$LATE_RETURN <- as.factor(df$LATE_RETURN )

## lets tidy the column format
df <- df %>%
  mutate_if(is.character, factor)
summary(df)
df <- df %>%
  select(-ID,-CUST_NAME,-BIRTH_DATE,-BOOKS_ID,
         -PUBLISHEDDATE, -LIBRARY_ID, -DATE_CHECKOUT,
         -DATE_RETURNED, -Duration)

# Filling missing values
#Loading the mice package
install.packages('mice')
library(mice)

#Imputing missing values using mice
mice_imputes = mice(df, m=5, maxit = 5)

mice_imputes$method

#Imputed dataset
Imputed_data=complete(mice_imputes,5)

#make a density plot
windows(25,20)
densityplot(mice_imputes)

new_df <- Imputed_data
  
new_df$LATE_RETURN <- ifelse(new_df$LATE_RETURN == 1, "Yes","No")
new_df$LATE_RETURN <- as.factor(new_df$LATE_RETURN)

## Data Partitioning
splits <- initial_split(new_df, prop = 0.75, strata = LATE_RETURN)
train <- training(splits)
test <- testing(splits)

## Creating CV folds
folds <- vfold_cv(train, 2)

## Creating recipe

tidy_rec <- 
  recipe(formula = LATE_RETURN ~ ., data = train) %>% 
  step_range(all_numeric()) %>%
  step_other(CUST_CITY,CUST_STATE,EDUCATION,
             OCCUPATION,AUTHORS,PUBLISHER,CATEGORIES,
             threshold = 0.1) %>%
  step_dummy(all_nominal(),-LATE_RETURN) %>%
  step_impute_knn(all_predictors()) 

tidy_rec %>% prep() %>% juice() -> keras_df

tidy_rec %>% prep() %>% bake(test) -> keras_test

## Creating a baseline model - logistic regression
baseline_spec <- 
  logistic_reg() %>% 
  set_mode("classification") %>% 
  set_engine("glm") 

## Creating its workflow
baseline_workflow <- 
  workflow() %>% 
  add_recipe(tidy_rec) %>% 
  add_model(baseline_spec) 

## fitting it on the folds
baseline_oc <- 
  fit_resamples(baseline_workflow, resamples = folds)

## exploring results
baseline_oc %>% show_best("roc_auc")


## creating the randomforest model
ranger_spec <- 
  rand_forest(mtry = tune(), min_n = tune(), trees = 1000) %>% 
  set_mode("classification") %>% 
  set_engine("ranger") 

## randomforest workflow
ranger_workflow <- 
  workflow() %>% 
  add_recipe(tidy_rec) %>% 
  add_model(ranger_spec) 

## tuning the randomforest model
set.seed(72829)
#doParallel::registerDoParallel()
ranger_tune <-
  tune_grid(ranger_workflow, 
            resamples = folds, 
            grid = 10,
            control = control_grid(save_pred = TRUE, 
                                   allow_par = TRUE))

#doParallel::stopImplicitCluster()

## exploring tuned results
ranger_tune %>% unnest(.metrics)
ranger_tune %>% show_best("roc_auc")

autoplot(ranger_tune)

## Compiling results
best_tune_ranger <- ranger_tune %>% select_best("roc_auc")

final_ranger_wf <- finalize_workflow(ranger_workflow,
                                     best_tune_ranger)

## Creating a recipe for xgboost model
xgboost_recipe <- 
  recipe(formula = LATE_RETURN ~ ., data = train) %>% 
  step_normalize(all_numeric()) %>%
  step_other(CUST_CITY,CUST_STATE,EDUCATION,
             OCCUPATION,AUTHORS,PUBLISHER,CATEGORIES, 
             threshold = 0.1) %>%
  step_dummy(all_nominal(),-LATE_RETURN, one_hot = TRUE) %>%
  #step_downsample(LATE_RETURN) %>%
  step_impute_knn(all_predictors())

## Creating the model
xgboost_spec <- 
  boost_tree(trees = tune(), min_n = tune(), tree_depth = tune(), 
             learn_rate = tune(), 
             loss_reduction = tune(), sample_size = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("xgboost") 

## Creating its workflow
xgboost_workflow <- 
  workflow() %>% 
  add_recipe(xgboost_recipe) %>% 
  add_model(xgboost_spec) 

## Tuning the model
set.seed(75238)
#doParallel::registerDoParallel()
xgboost_tune <-
  tune_grid(xgboost_workflow,
            resamples = folds,
            grid = 7,
            control = control_grid(save_pred = TRUE, 
                                   allow_par = TRUE))
# doParallel::stopImplicitCluster()

## Exploring results
xgboost_tune %>% show_best("roc_auc") %>% glimpse()

## Finalizing model
best_tune_xgb <- xgboost_tune %>% select_best("roc_auc")
final_model <- finalize_workflow(xgboost_workflow, best_tune_xgb)

## creating a support vector (svm) model
tidy_svm <- svm_rbf(cost = tune(),rbf_sigma = tune()) %>%
  set_mode("classification") %>%
  set_engine("kernlab")

# Creating a workflow for the svm model
svm_wf <- workflow() %>%
  add_recipe(xgboost_recipe) %>%
  add_model(tidy_svm)

## tuning the svm model
set.seed(3242)
#doParallel::registerDoParallel()
svm_tune <- tune_grid(
  svm_wf,
  resamples = folds,
  grid = 10,
  control = control_grid(allow_par = TRUE, 
                         save_pred = TRUE)
)
#doParallel::stopImplicitCluster()

## exploring results
svm_tune %>% unnest(.metrics)
svm_tune %>% show_best("accuracy")

# finalizing model
# the svm model doesnt seem to perform well(0.79), lets check the svm_rbf
# the accuracy level for the svm radial is better than others
# lets compare 

best_tune_svm <- svm_tune %>% select_best("accuracy")
final_svm_model <- finalize_workflow(svm_wf, best_tune_svm)

## we are going to be evaluating our three models
## Note after tuning with parallel processing i had to reset rstudio to fit_resample

## creating a tibble of our models.
model_res <- tibble(model = list(baseline_oc, 
                                 ranger_tune, 
                                 xgboost_tune, svm_tune),
                    model_name = c("logistic","ranger","xgboost","svm"))

## a function to extract metrics
collect_metrics <- function(model){
  model %>%
    select(id, .metrics) %>%
    unnest(.metrics)
}

## Extracting metrices
model_res <- model_res %>%
  mutate(metric = map(model, collect_metrics))

## Visualizing metrics
model_res %>% 
  select(model_name,metric) %>%
  unnest(metric) %>%
  ggplot(aes(model_name, .estimate))+
  geom_boxplot(alpha = 0.8, fill = "midnightblue", col = "black")+
  facet_wrap(~.metric, scales = "free_y")

## Visualizing metrics by folds

model_res %>% 
  select(model_name,metric) %>%
  unnest(metric) %>%
  ggplot(aes(model_name, .estimate, col = id, group = id))+
  geom_line(alpha = 0.8)+
  facet_wrap(~.metric, scales = "free_y")

## density plots of metrics
model_res %>% 
  select(model_name,metric) %>%
  unnest(metric) %>%
  ggplot(aes(.estimate, col = model_name, fill = model_name))+
  geom_density(alpha = 0.1)+
  facet_wrap(~.metric, scales = "free_y")

## getting a table summary of the metrics
model_res <- model_res %>% 
  select(model_name,metric) %>%
  unnest(metric)

model_res %>%
  group_by(model_name, .metric) %>%
  summarise(mean = mean(.estimate))%>%
  arrange(desc(mean))

## lets use tidyposterior to pick the model to use
#install.packages('tidyposterior')
library(tidyposterior)

## tidy model results
model_pos <- model_res %>%
  filter(.metric == "roc_auc") %>%
  select(model_name, id, .estimate) %>%
  pivot_wider(names_from = "model_name", 
              values_from = ".estimate")

roc_auc_model <- perf_mod(model_pos, seed = 40)

## visualizing results

roc_auc_model %>% tidy() %>%
  ggplot()

## Creating a comparison plot

contrast_models(roc_auc_model) %>%
  ggplot()

## we can now say that the random forest model is the best performing model among the three

## random forest model seems to be the best model
## this fits the model on the entire training set and evaluates on the test set
final_fit <- last_fit(final_ranger_wf, splits)

final_fit %>%
  collect_predictions() %>%
  conf_mat(LATE_RETURN, .pred_class)

final_fit %>% unnest(.metrics)


svm_fit <- last_fit(final_svm_model, splits)
svm_fit %>%
  collect_predictions() %>%
  conf_mat(LATE_RETURN, .pred_class)

## SVM model didnt do a good job at predicting Yes, so we stick with the random forest as our final model

## to save our final model
final_model <- fit(final_ranger_wf, new_df)

saveRDS(final_model, "BillUps_model.rds")

sample_test <- slice_sample(new_df, n=10)

#predict(final_model,sample_test)

data.frame(prep =predict(final_model,sample_test), 
           actual = sample_test$LATE_RETURN )


names(books)

# Book analysis
# Number of available books
books %>% 
  select(ID) %>% 
  distinct() %>% 
  count()

# Number of books by category
books %>% 
  select(CATEGORIES) %>% 
  mutate(CATEGORIES=case_when(CATEGORIES == '' ~ 'Others', 
                              T ~ CATEGORIES)
         ) %>% 
  count(CATEGORIES) %>% 
  arrange(desc(n))

# Average price of books by category
books %>% 
  select(CATEGORIES, PRICE) %>% 
  mutate(CATEGORIES=case_when(CATEGORIES == '' ~ 'Others', 
                              T ~ CATEGORIES)
  ) %>% 
  group_by(CATEGORIES) %>% 
  summarize(Avg_price = mean(PRICE, na.rm=T))

# Customer analysis
customers %>% 
  select(ID) %>% 
  distinct() %>% 
  count()

# Distribution by gender
customers %>% 
  select(GENDER) %>% 
  count(GENDER)

str(books)
customers %>% View()
