# Classification-Analysis-of-Customer-Subscriptions

This ReadMe file provides an overview of the different code files used for the analysis in our report. We make specific notes for these code files which will help with running them to recreate our results. This folder also includes the dataset used for our analysis.

## Table_Data_Characteristics.R
We run the script which outputs an Excel file. We make some additional formating fixes to the Excel file and then used it for various tables in the report.

## EDA_208_final.ipynb

logistic regressio - dummy variable data

## BART Classifier.R
In order to run the script, please have or install the following packages: mlbench, rJava, bartMachine, pROC.
Potential errors for loeading bartMachine may be due to Java memory allocations so please try running options(java.parameters = "-Xmx50g") in the console.
Please follow guide here if additional issues loading the package persists: https://www.r-statistics.com/2012/08/how-to-load-the-rjava-package-after-the-error-java_home-cannot-be-determined-from-the-registry/
