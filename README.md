# Classification-Analysis-of-Customer-Subscriptions

This ReadMe file provides an overview of the different code files used for the analysis in our report. We make specific notes for these code files which will help with running them to recreate our results. This folder also includes the dataset used for our analysis.

## Table_Data_Characteristics.R
This code is used to produce summary statistics of our data, which are included in our appendix. It relies on the raw data file 'bank-additional-full.csv'. We run the script which outputs an Excel file. We make some additional formating fixes to the Excel file after it is outputted.

## EDA_208_final.ipynb
This code is used to produce the box plots and bar charts in the exploratory analysis section of our report. It relies on the raw data file 'bank-additional-full.csv'.

## Process Banking Data.ipynb
This code is used to standardize the numerical variables, conduct some data processing steps, and split the data into training and test sets. It imports the raw data file 'bank-additional-full.csv' and outputs train and test datasets formatted in three different ways, different based on how categorical variables are treated. First it outputs a dataset where categorical variables are kept as single columns with string values. Then it outputs a dataset that is formatted as a design matrix (i.e. a categorical variable with p levels will be transformed to p-1 dummy variables). Then it ouput a one-hot encoded dataset (i.e. a categorical variable with p levels will be transformed to p dummy variables).

## Logistic_Regression_Classifier.ipynb
This code is used to produce the logistic regression results contained in Table 1. It relies on the design matrix-like data outputted by the data processing code.

## SVM classifier_208_final.ipynb
This code is used to produce the SVM results contained in Table 1. It relies on the one-hot encoded data outputted by the data processing code.

## Random Forest Classifier.ipynb
This code is used to produce the random forest results contained in Table 1. It relies on the one-hot encoded data outputted by the data processing code.

## BART Classifier.R
This code is used to produce all BART results contained in the report. It relies on both the original single column categorical variable data and the one-hot encoded data outputted by the data processing code.
In order to run the script, please have or install the following packages: mlbench, rJava, bartMachine, pROC.
Potential errors for loeading bartMachine may be due to Java memory allocations so please try running options(java.parameters = "-Xmx50g") in the console.
Please follow guide here if additional issues loading the package persists: https://www.r-statistics.com/2012/08/how-to-load-the-rjava-package-after-the-error-java_home-cannot-be-determined-from-the-registry/
