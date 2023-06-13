# April Vang
# This script gets the summary statistics to create a supplementary table 1 overview of the dataset

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# load libraries
library(Hmisc) # for histogram
library(writexl)
library(ggplot2)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Load dataset
df = read.csv("E:/S23/STA_208/Project/bank_additional/bank-additional-full.csv", sep=";", header = T)


# Let's make a categorical variable for pdays
df$previously_contacted = as.factor(ifelse(df$pdays == "999", "no", "yes"))
df$pdays[df$pdays == 999] = NA

# Determine the categorical and continuous predictors
categorical_predictors = c("job", "marital", "education", 
                           "default", "housing", "loan", 
                        
                           "contact", "month", "day_of_week",
                           "poutcome", 
                           "previously_contacted") # Variables I made 
continuous_predictors = c("age", "duration", "campaign","previous", 
                          "emp.var.rate", "cons.price.idx", "cons.conf.idx",
                          "euribor3m", "nr.employed")

# Fix the factors
df[c(categorical_predictors,"y")] = lapply(df[c(categorical_predictors,"y")], 
                                           function(x) as.factor(x))

# Need to fix the levels of the categorical variables
df$marital = factor(df$marital, levels = c("single", "married", "divorced", "unknown"))
df$day_of_week = factor(df$day_of_week, levels = c("mon", "tue", "wed", "thu", "fri"))
df$default = factor(df$default, levels = c("no", "yes", "unknown"))
df$housing = factor(df$housing, levels = c("no", "yes", "unknown"))
df$loan = factor(df$loan, levels = c("no", "yes", "unknown"))
df$month = factor(df$month, levels = c("mar", "apr", "may", "jun", 
                                       "jul", "aug", "sep", "oct", "nov", "dec"))
df$poutcome = factor(df$poutcome, levels = c("failure", "success", "nonexistent"))

# Let's look at the histograms for the continuous variables
integer_predictors = names(df)[sapply(df, class) %in% c("integer")]
df[integer_predictors] = lapply(df[integer_predictors], as.numeric)
hist.data.frame(df[continuous_predictors])

# Function to get the proportion counts and percentages
# It does so through by the variable name and will split by the subscription status
GET_N_PROP = function(variable_name) {
  n_count_all = table(df[[variable_name]])
  all_prop = round(prop.table(n_count_all)*100, 2)
  n_count = table(df[[variable_name]], df$y)
  no_prop = round(prop.table(n_count[,1])*100, 2)
  yes_prop = round(prop.table(n_count[,2])*100, 2)
  
  var_p = round(chisq.test(n_count)$p.value,4)
  var_p = ifelse(var_p < 0.0001, "<0.0001", var_p)
  
  tab_info = cbind(rownames(n_count), paste0(n_count_all, " (", all_prop, "%)"),
                   paste0(n_count[,1], " (",no_prop, "%)"),
                   paste0(n_count[,2], " (",yes_prop, "%)"),
                   rep("", nrow(n_count_all)))
  
  tab_info = data.frame(rbind(c(variable_name, "", "", "", var_p), tab_info))

  names(tab_info) = c("Variable", "Overall (n=41188)", "No (n=36548)", "Yes (n=4640)", "P-value")
  tab_info = 
  return(tab_info)
}

# Make the table first for job and then bind the table together
table1 = GET_N_PROP("job")
for (i in categorical_predictors[-1]){ # since i already did job above
  table1 = rbind(table1, GET_N_PROP(i))
}

# Let's write a function to retrieve the mean and sd's
GET_MEAN_SD = function(variable_name){
  the_var = df[[variable_name]]
  mean_sd = paste0(round(mean(the_var), 2), 
                   " (", round(sd(the_var), 2), ")")
  mean_sd_no = paste0(round(mean(df[df$y %in% "no",variable_name]), 2), 
                   " (", round(sd(df[df$y %in% "no",variable_name]), 2), ")")
  mean_sd_yes = paste0(round(mean(df[df$y %in% "yes",variable_name]), 2), 
                      " (", round(sd(df[df$y %in% "yes",variable_name]), 2), ")")
  
  # We perfrom the wilcoxon rank sum test to override model assumptions since
  # normality is not met for features
  wilcox_p = round(wilcox.test(the_var~ df$y)$p.value, 4)
  wilcox_p = ifelse(wilcox_p < 0.0001, "<0.0001", wilcox_p)
  
  mean_sd_p = data.frame(cbind(variable_name, mean_sd, mean_sd_no, mean_sd_yes, wilcox_p))
  names(mean_sd_p) = c("Variable", "Overall (n=41188)", "No (n=36548)", "Yes (n=4640)", "P-value")

  return(mean_sd_p)
}

# Begin the table with the first continuous and then bind the data together
table1_continuous = GET_MEAN_SD("age")
for (i in continuous_predictors[-1]){
  table1_continuous = rbind(table1_continuous, GET_MEAN_SD(i))
}
table1_out = rbind(table1, table1_continuous)

# Preview resutls
table1_out

# Finally, write results to excel
write_xlsx(table1_out, "supplementary_table1_draft052923.xlsx")
