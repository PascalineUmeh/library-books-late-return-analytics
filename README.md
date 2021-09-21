# Library Book Late Return Analytics
A library data analysis and model to predict the likelihood of a late return of any book at every checkout time.

# Step by Step Guide to the files:
- Library_Book_Checkout_and_Late_Return_Analysis.sql and Library_Book_Checkout_and_Late_Return_Analysis.R:
This file contains the sql script showing the steps by step queries executed for the analysis. The script shows a breakdown of executed queries from the library data set used for the dashboard in LIBRARY_BOOKS_LATE_RETURN_ANALYTICS_REPORT.pptx file. This file serves same purpose as the Library_Book_Checkout_and_Late_Return_Analysis.R file. Information on each chart in the slides has corresponding scripts provided in this file for your review.

- LIBRARY_BOOK_LATE_RETURN_ANALYTICS_REPORT.pptx:
This a dashboard that data analyzes the ibrary data and shows the different factors in each table that are connected with late returns of books at checkout time.
The report gave a clear knowleged of which factor in the provided data, like age, education, pages, etc are related to why books are returned late in the libraries.
The analysis informed the choice of variables used to develop the features used in the building the predictive model as shown in Book_Late_Return_Predictive_Model_Script.R.

- BillUps_model.rds:
The BillUps_model.rds file is the saved model. This is the best model (random forest) out of the four models that was considered in this analysis.

- The Late_Return_Predictive_Model_Markdown_Script.Rmd file is the Markdown that has the script for the model. Each step in the file has comments that explains the purpose of each code and the process follwed in building the model. The four models considered in this excercise are: Logistic regression, Random forest, XG Bosst and SVM.

- The Book_Late_Return_Predictive_Model.html file holds the analysis of the predictive model in html format.
