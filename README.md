# Classification-Analysis-of-Customer-Subscriptions

For Table_Data_Characteristics.R, note that we run the script and an excel will be outputted of which we additianly did minor formating fixes.

BART
For BART Classifier.R script, please have or install the following packages: mlbench, rJava, bartMachine, pROC.
Potential errors for loeading bartMachine may be due to Java memory allocations so please try running options(java.parameters = "-Xmx50g") in the console.
Please follow guide here if additional issues loading the package persists:
# https://www.r-statistics.com/2012/08/how-to-load-the-rjava-package-after-the-error-java_home-cannot-be-determined-from-the-registry/
