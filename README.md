This repository contains a R script that generated data for course project for "Getting and cleaning data", and the generated data itself

tthe scripts works on the human activity data. find more details at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

To run the script, you need to

1. unpack the data into current working directory
2. need to have library reshape2 installed

to executed the script, run the following in R

# suppose script is downloaded in current working directory
source("run_analysis.R")

the script will generate 3 objects

1. merged. the data merged from training and testing datasets. in addition, subject and activity/label (name) was join with the dataset to form a complete dataset. column names were also cleaned up with special character removed
2. extracted. data with only columns for mean and std, as well as subject and label,  extracted from merged
3. meanPerSubjectAndActivity. the aggregated result with mean value for each variables (column) from extracted that is group by {subject, activity}. the column name all have "_mean" appended.
