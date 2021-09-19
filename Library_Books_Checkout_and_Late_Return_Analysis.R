
# LIBRARY BOOKS CHECKOUT AND LATE RETURN ANALYSIS

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


## Slide 1
### Distinct number of Libraries
libraries %>% 
  select(Library_ID) %>% 
  count()

### Distinct number of books
books %>% 
  select(Book_ID) %>% 
  count()

### Distinct no of customers
customers %>% 
  select(ID) %>% 
  count()

### Customers distribution by Level of Education
customers %>% 
  mutate(EDUCATION = case_when(EDUCATION == '' ~ 'Undefined',
                               T ~ as.character(EDUCATION))
  ) %>% 
  count(EDUCATION) %>% 
  mutate(Count = n, percent = n*100/sum(n))

### Customers distribution by State
customers %>% 
  mutate(STATE = str_squish(STATE)) %>% 
  mutate(STATE = case_when(STATE == '' ~ 'Undefined',
                           T ~ as.character(STATE))
  ) %>% 
  count(STATE) %>% 
  mutate(Count = n, percent = n*100/sum(n))

### Customers distribution by Gender
customers %>% 
  mutate(GENDER = str_squish(GENDER)) %>% 
  mutate(GENDER = case_when(GENDER == '' ~ 'Undefined',
                            T ~ as.character(GENDER))
  ) %>% 
  count(GENDER) %>% 
  mutate(Count = n, percent = n*100/sum(n))

### Customers distribution by Age band
merged_data %>% 
  mutate(Age = round((DATE_RETURNED - BIRTH_DATE)/365)) %>% 
  mutate(Age = as.numeric(Age)) %>% 
  mutate(Age_range = case_when(Age >= 1 & Age <= 29 ~ '<30 Years',
                               Age >= 30 & Age <= 50 ~ '30-50 Years',
                               Age >= 51 & Age <= 100 ~ '>50 Years',
                               T ~ 'Undefined')
  ) %>% 
  count(Age_range)

### Distribution by Age band and Late return status
merged_data %>% 
  mutate(Duration = DATE_RETURNED - DATE_CHECKOUT,
         Age = round((DATE_RETURNED - BIRTH_DATE)/365)
  ) %>% 
  mutate(Duration = as.numeric(Duration),
         Age = as.numeric(Age)
  ) %>% 
  mutate(Duration = case_when(Duration >= 1 & Duration <= 28 ~ '<=28 Days',
                              Duration > 28 ~ '>28 Days',
                              T ~ 'Undefined'),
         Age_range = case_when(Age >= 1 & Age <= 29 ~ '<30 Years',
                               Age >= 30 & Age <= 50 ~ '30-50 Years',
                               Age >= 51 & Age <= 100 ~ '>50 Years',
                               T ~ 'Undefined')
  ) %>% 
  group_by(Duration, Age_range) %>% 
  count(Age_range)

### Distribution of Late return status by Gender
merged_data %>% 
  mutate(Duration = DATE_RETURNED - DATE_CHECKOUT
  ) %>% 
  mutate(Duration = as.numeric(Duration)
  ) %>% 
  mutate(Duration = case_when(Duration >= 1 & Duration <= 28 ~ '<28 Days',
                              Duration >= 28 ~ '>28 Days',
                              T ~ 'Undefined'),
         GENDER = case_when(GENDER == '' ~ 'Undefined',
                            T ~ as.character(GENDER))
  ) %>% 
  group_by(Duration, GENDER) %>% 
  count(GENDER)

## SLIDE 2
### Distribution of late returns by city
merged_data %>% 
  mutate(Duration = DATE_RETURNED - DATE_CHECKOUT,
         CUST_CITY = str_squish(CUST_CITY)
  ) %>% 
  mutate(Duration = as.numeric(Duration)
  ) %>% 
  mutate(Duration = case_when(Duration >= 1 & Duration <= 28 ~ '<28 Days',
                              Duration >= 28 ~ '>28 Days',
                              T ~ 'Undefined')
  ) %>% 
  group_by(Duration, CUST_CITY) %>% 
  count(CUST_CITY)

### Distribution of late returns by book price range
merged_data %>% 
  mutate(Duration = DATE_RETURNED - DATE_CHECKOUT
  ) %>% 
  mutate(Duration = as.numeric(Duration)
  ) %>% 
  mutate(Duration = case_when(Duration >= 1 & Duration <= 28 ~ '<28 Days',
                              Duration >= 28 ~ '>28 Days',
                              T ~ 'Undefined'),
         PRICE_RANGE = case_when(PRICE < 100 ~ '<100.00',
                                 PRICE <= 500 ~ '100.00 - 500.00',
                                 PRICE > 500 ~ '>500.00',
                                 T ~ 'Undefined')
  ) %>% 
  group_by(Duration, PRICE_RANGE) %>% 
  count(PRICE_RANGE)

### Distribution of late returns by book page range
merged_data %>% 
  mutate(Duration = DATE_RETURNED - DATE_CHECKOUT
  ) %>% 
  mutate(Duration = as.numeric(Duration)
  ) %>% 
  mutate(Duration = case_when(Duration >= 1 & Duration <= 28 ~ '<28 Days',
                              Duration >= 28 ~ '>28 Days',
                              T ~ 'Undefined'),
         PAGE_RANGE = case_when(PAGES <= 500 ~ '<=500.00',
                                PAGES > 500 ~ '>500.00',
                                T ~ 'Undefined')
  ) %>% 
  group_by(Duration, PAGE_RANGE) %>% 
  count(PAGE_RANGE)

### Distribution of late returns by State
merged_data %>% 
  mutate(Duration = DATE_RETURNED - DATE_CHECKOUT,
         CUST_STATE = str_squish(CUST_STATE)
  ) %>% 
  mutate(Duration = as.numeric(Duration)
  ) %>% 
  mutate(Duration = case_when(Duration >= 1 & Duration <= 28 ~ '<28 Days',
                              Duration >= 28 ~ '>28 Days',
                              T ~ 'Undefined')
  ) %>% 
  group_by(Duration, CUST_STATE) %>% 
  count(CUST_STATE)

### Distribution of late returns by Level of Education
merged_data %>% 
  mutate(Duration = DATE_RETURNED - DATE_CHECKOUT,
         EDUCATION = str_squish(EDUCATION)
  ) %>% 
  mutate(Duration = as.numeric(Duration),
         EDUCATION = case_when(EDUCATION == '' ~ 'Undefined',
                               T ~ as.character(EDUCATION))
  ) %>% 
  mutate(Duration = case_when(Duration >= 1 & Duration <= 28 ~ '<28 Days',
                              Duration >= 28 ~ '>28 Days',
                              T ~ 'Undefined')
  ) %>% 
  group_by(Duration, EDUCATION) %>% 
  count(EDUCATION)

### Distribution of late returns by Level of Occupation
merged_data %>% 
  mutate(Duration = DATE_RETURNED - DATE_CHECKOUT,
         OCCUPATION = str_squish(OCCUPATION)
  ) %>% 
  mutate(Duration = as.numeric(Duration),
         OCCUPATION = case_when(OCCUPATION == '' ~ 'Undefined',
                                T ~ as.character(OCCUPATION))
  ) %>% 
  mutate(Duration = case_when(Duration >= 1 & Duration <= 28 ~ '<28 Days',
                              Duration >= 28 ~ '>28 Days',
                              T ~ 'Undefined')
  ) %>% 
  group_by(Duration, OCCUPATION) %>% 
  count(OCCUPATION)
