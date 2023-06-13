# Notes: 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Let's load our libraries
{
  library(mlbench)
  #options(java.parameters = "-Xmx50000g")
  library(rJava)
  options(java.parameters = "-Xmx50g")
  library(bartMachine)
  library(caret)
  library(pROC)
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Read in the regular dataset to get the names updated
{
  train = read.csv("E:/S23/STA_208/Project/Cleaned Datasets/train_categ_vars_one_column.csv", row.names = 1)
  test = read.csv("E:/S23/STA_208/Project/Cleaned Datasets/test_categ_vars_one_column.csv", row.names = 1)
  
  # Review the classes
  sapply(train, class)
  
  # Fix the classes
  categorical_predictors = c("job", "marital", "education", # notice we are not using default
                             "housing", "loan",
                             "contact", "month", "day_of_week",
                             "poutcome",
                             "pdays")
  continuous_predictors = c("age", "duration", "campaign","previous",
                            "emp.var.rate", "cons.price.idx", "cons.conf.idx",
                            "euribor3m", "nr.employed")
  train[c(categorical_predictors,"y")] = lapply(train[c(categorical_predictors,"y")],
                                                function(x) as.factor(x))
  test[c(categorical_predictors,"y")] = lapply(test[c(categorical_predictors,"y")],
                                               function(x) as.factor(x))
  
  categoricals = c("y", paste0("month_", levels(train$month)),
                   paste0("pdays_", c("no", "yes")),
                   paste0("job_", levels(train$job)),
                   paste0("day_of_week_", levels(train$day_of_week)),
                   paste0("contact_", levels(train$contact))  ,
                   paste0("marital_", levels(train$marital)),
                   paste0("housing_", levels(train$housing)),
                   paste0("poutcome_", levels(train$poutcome)),
                   paste0("education_", levels(train$education)),
                   paste0("loan_", levels(train$loan)))
  
  categoricals
}
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Read in the train test set ONE HOT ENCODING
{
  
  train= read.csv("E:/S23/STA_208/Project/Cleaned Datasets/train_one_hot.csv", row.names = 1)
  test= read.csv("E:/S23/STA_208/Project/Cleaned Datasets/test_one_hot.csv", row.names = 1)
  train$y =  factor(train$y)
  test$y = factor(test$y)
  
  # let's update the categorical names
  names(train)[1:53] = categoricals
  names(test)[1:53] = categoricals
  
  # Get X and y
  df_test = test[,names(test)  != "y"]
  y_test = test$y
  df_train = train[,names(train)  != "y"]
  y_train = train$y
  rm(train)
  rm(test)
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Perform a small grid search and use BART-CV model by cross-validating over a grid of hyperparameter choices.
# mybartmodel = bartMachineCV(df_train, y_train,
#                             num_tree_cvs = c(15, 20, 30, 175, 200, 225, 300),
#                             k_cvs = c(1),
#                             k_folds = 2,
#                             verbose = TRUE)
# mybartmodel$confusion_matrix

# We will use 200 trees for the optimal model
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# In case errors, reset memory allocation try
# options(java.parameters = "-Xmx50g")

# Takes ~60 minutes to run
start_time <- Sys.time()
bart_machine <- bartMachine(df_train, y_train, num_trees=200, seed=1)
end_time <- Sys.time()
end_time - start_time

# Let's plot the MCMC convergence
plot_convergence_diagnostics(bart_machine)

# Let's make a function to retrieve our model comparison criteria
COMPARISON_CRITERIA = function(my_model, my_threshold = 0.6){
  y_pred = predict(my_model, df_test)
  y_test = factor(y_test, levels = c("yes", "no"))
  predictedy = ifelse(y_pred >= my_threshold, "no", "yes")
  predictedy = factor(predictedy, levels = c("yes", "no"))
  
  mytab = table(predictedy, y_test)
  metric = 15 # Confusion matrix adjustment results..
  
  # Let's get our criteria for comparison to other models
  tp = mytab[1,1] # metric
  fp = mytab[1,2]
  fn = mytab[2,1] # metric
  tn = mytab[2,2]
  n = sum(mytab)
  
  # Set our metrics
  my_metrics = c("Classification Rate","Specificity", "Sensitivity/Recall", "Precision", "F1")
  cr = (tp+tn)/n
  spec = tn/(tn+fp)
  sens = tp/(tp+fn)
  precision = tp/(tp+fp)
  recall = tp/(tp+fn)
  f1 = 2*(precision*recall)/(precision+recall)
  
  # Put results together and bind it for review
  print(cbind(my_metrics, round(c(cr, spec, sens, precision, f1)*100, 3)))
  
  # Next get the area under the curve and the 95% CI using DeLong. pROC library uses a bootstrapping technique
  y_numerical = ifelse(y_test == "no", 0, 1)
  the_predicted =  y_pred
  my_roc = roc(y_numerical, y_pred, ci=T)
  print(my_roc)
}

COMPARISON_CRITERIA(my_model = bart_machine)

# Let's plot the feature importance
feature_importance20 = investigate_var_importance(bart_machine, 
                                                  num_trees_bottleneck = 20)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Next, run under the new model under the change in tree number and change in seed and review results
{
  start_time <- Sys.time()
  bart_machine_15_1 <- bartMachine(df_train, y_train, num_trees=15, seed=1)
  end_time <- Sys.time()
  end_time - start_time

  start_time <- Sys.time()
  bart_machine_15_208 <- bartMachine(df_train, y_train, num_trees=15, seed=208)
  end_time <- Sys.time()
  end_time - start_time

  start_time <- Sys.time()
  bart_machine_50_1 <- bartMachine(df_train, y_train, num_trees=50, seed=1)
  end_time <- Sys.time()
  end_time - start_time

  start_time <- Sys.time()
  bart_machine_50_208 <- bartMachine(df_train, y_train, num_trees=50, seed=208)
  end_time <- Sys.time()
  end_time - start_time

  start_time <- Sys.time()
  bart_machine_200_208 <- bartMachine(df_train, y_train, num_trees=200, seed=208)
  end_time <- Sys.time()
  end_time - start_time
}

# Review results
COMPARISON_CRITERIA(my_model = bart_machine_15_1)
COMPARISON_CRITERIA(my_model = bart_machine_15_208)
COMPARISON_CRITERIA(my_model = bart_machine_50_1)
COMPARISON_CRITERIA(my_model = bart_machine_50_208)
COMPARISON_CRITERIA(my_model = bart_machine_200_208)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Plot for the top 10 -> used in the presentation slides
feature_importance15 = investigate_var_importance(bart_machine,
                                                  num_trees_bottleneck = 15,
                                                  num_var_plot = 20)
fi = data.frame(cbind(names(feature_importance15$avg_var_props),
                      feature_importance15$avg_var_props))
str(fi)
fi$X2=as.numeric(fi$X2)
topf = fi$X2[1:10]
barplot(topf, names = fi$X1[1:10], las = 2, col = 'skyblue', ylab = "BART Inclusion Proportion")

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Sources
# Learning and applying Bart Package
# https://towardsdatascience.com/a-primer-to-bayesian-additive-regression-tree-with-r-b9d0dbf704d
# https://rstudio-pubs-static.s3.amazonaws.com/347011_c995dede7ed84fa78af6337be856e543.html#introduction
# https://search.r-project.org/CRAN/refmans/bartMachine/html/bartMachineCV.html
# 
# Next up  page 38 from 
# https://cran.r-project.org/web/packages/BART/BART.pdf

# Other notes
# In case errors with rJava follow instructions on:
# https://www.r-statistics.com/2012/08/how-to-load-the-rjava-package-after-the-error-java_home-cannot-be-determined-from-the-registry/
