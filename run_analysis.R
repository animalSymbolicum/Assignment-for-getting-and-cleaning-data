### GETTING AND CLEANING DATA COURSE PROJECT

# clean workspace
rm(list = ls())

# load packages neccesary for analysis
library(magrittr)
library(dplyr)
library(stringr)

# set working directory to directory containong UCIHAR dataset
setwd("")

### READ DATA AND MERGE TRAIN AND TEST DATA

# read name scheme from features.txt
read.table("UCI HAR Dataset/features.txt", sep = " ") %>% 
  set_names(c("index", "name")) ->
nameScheme

# read training data
read.table("UCI HAR Dataset/train/subject_train.txt", sep = "") %>% 
  set_names("ID") -> 
subject_train
read.table("UCI HAR Dataset/train/X_train.txt", sep = "") %>% 
  set_names(nameScheme$name) -> 
X_train
read.table("UCI HAR Dataset/train/y_train.txt", sep = "") %>%
  set_names("Activity") -> 
y_train

# read test data
read.table("UCI HAR Dataset/test/subject_test.txt", sep = "") %>% 
  set_names("ID") ->  
subject_test
read.table("UCI HAR Dataset/test/X_test.txt", sep = "") %>% 
  set_names(nameScheme$name) -> 
X_test
read.table("UCI HAR Dataset/test/y_test.txt", sep = "")  %>%
  set_names("Activity") -> 
y_test

# merge data
# first combine columns of training and test data
cbind(subject_train, X_train, y_train) -> trainingData
cbind(subject_test, X_test, y_test) -> testData

# combine rows of training and test data
rbind(trainingData, testData) -> data

### EXTRACT ONLY MEANS AND STDs

data[, c("ID", "Activity", grep("[Mm]ean.*[(][)]|[Ss]td", names(data), value = TRUE))] ->
  subsetData
  
### SET ACTIVITY LEVELS
subsetData$Activity %>%
  sapply(function(singleActivity) {
    c(
      "walking",
      "walkingUp",
      "walkingDown",
      "sitting",
      "standing",
      "laying"
    )[singleActivity]
  }) ->
subsetData$Activity

### RENAME VARIABLES 
subsetData %<>%
  set_names(
    names(.) %>% 
      str_replace_all("-", ".") %>% 
      str_replace_all("[()]", "") %>%
      str_replace("X$", "x") %>%
      str_replace("Y$", "y") %>%
      str_replace("Z$", "z") %>%
      str_replace("^f", "frequency") %>%
      str_replace("^t", "time")
  ) 
  
### CREATE SECOND SUMMARISING DATASET
subsetData %>%
  group_by(ID, Activity) %>%
  summarise_each(funs(mean)) ->
summerizedData 

### EXPORT DATA
write.table(summerizedData, "meanByAcitivityandIDSummary.txt", row.name = FALSE) 


