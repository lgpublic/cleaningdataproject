# merge the sumsung training and test dataset
# the dataset needs to be unpacked already in 
# current working directory
merge<-function() {
  baseDir <- getwd()
  # all the paths to useful files in given directory
  x_test_file <- paste(baseDir, "test/X_test.txt", sep="/")
  y_test_file <- paste(baseDir, "test/y_test.txt", sep="/")
  subject_test_file <- paste(baseDir, "test/subject_test.txt", sep="/")
  x_train_file <- paste(baseDir, "train/X_train.txt", sep="/")
  y_train_file <- paste(baseDir, "train/y_train.txt", sep="/")
  subject_train_file <- paste(baseDir, "train/subject_train.txt", sep="/")
  labels_file <- paste(baseDir, "activity_labels.txt", sep="/")
  features_file <- paste(baseDir, "features.txt", sep="/")
  
  # read feature list and rename columns
  features <- read.csv(features_file, header=FALSE, sep="")
  names(features) <- c("feature_id", "feature_name")
  # cleanup the values a bit removing the special characters
  features$feature_name<-gsub(",", "_", gsub("\\(|\\)", "", features$feature_name))
  
  # loading train data
  train_x <- read.csv(x_train_file, header=FALSE, sep="")
  # rename the columns
  names(train_x) <- features$feature_name
  # load subject and y(labels) and add them as extra columns
  train_subject <- scan(subject_train_file)
  train_y <- scan(y_train_file)
  train_x$subject <- train_subject
  train_x$label_id <- train_y
  
  # convert label IDs into label names 
  labels_train <- sapply(train_y, getLabelFromID)
  train_x$label_name <- labels_train
  
  # loading test data
  test_x <- read.csv(x_test_file, header=FALSE, sep="")
  # rename the columns
  names(test_x) <- features$feature_name
  # load subject and y(labels) and add them as extra columns
  test_subject <- scan(subject_test_file)
  test_y <- scan(y_test_file)
  test_x$subject <- test_subject
  test_x$label_id <- test_y
  
  # convert label IDs into label names 
  labels_test <- sapply(test_y, getLabelFromID)
  test_x$label_name <- labels_test
  
  # merge data
  merged <- rbind(train_x, test_x)
}

# convert a label ID into label name
# this is "hard-coded" as there are only 6 pairs
getLabelFromID <- function(id) {
  if (id == 1) {
    return("WALKING")
  }
  else if (id==2) {
    return("WALKING_UPSTAIRS")
  }
  else if (id == 3) {
    return("WALKING_DOWNSTAIRS")
  }
  else if (id == 4) {
    return("SITTING")
  }
  else if (id == 5) {
    return("STANDING")
  }
  else if (id == 6) {
    return("LAYING")
  }
}

# extract columns for mean and std only
# argument should be a merged dataset 
# returned by function merge
extractMeanAndStd <- function(merged) {
  mean_list<-grep("mean", names(merged))
  std_list<-grep("std",names(merged))
  union_list <- c(mean_list, std_list)
  mean_std<-merged[,union_list]
  # keep label_name and subject also
  extra_col_filter<-names(merged) == "label_name" | names(merged) == "subject"
  extra_col<-merged[,extra_col_filter]
  cbind(mean_std, extra_col)
  
}

# group by subject and activity(label) and calculate the mean 
# for each group for each variable in given dataframe
# the given dataframe is supposed to be extrated for step4
# this needs to load reshape2
getMeanPerSubjectAndActivity <- function(extracted) {
  vars <- c(grep("mean", names(extracted), value=TRUE ), grep("std", names(extracted), value=TRUE ))
  mt<-melt(extracted, id=c("subject", "label_name"), measure.vars=vars)
  m <- dcast(mt, subject+label_name ~ variable, mean)
  # rename the column by appending mean
  names(m) <- gsub("$", "_mean", names(m))
  m
}


library(reshape2)
# gets merged dataset with variables names cleanup
merged<-merge()
# extract variables for mean/std
extracted <- extractMeanAndStd(merged)
# group and get mean per group per measure
meanPerSubjectAndActivity <- getMeanPerSubjectAndActivity(extracted)
