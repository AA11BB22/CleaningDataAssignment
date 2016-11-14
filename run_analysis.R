file <- "UCI HAR Dataset"

if (!file.exists(file)){
    
    #Check if the zip exists
    if (!file.exists(paste(file, "zip", sep = "."))){
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(url, paste(file, "zip", sep = "."))
    }
    
    #unzip the zip file
    unzip(paste(file, "zip", sep = "."))
}

# categories of activity (factors)
activity <- read.table("UCI HAR Dataset/activity_labels.txt")
activity <- as.vector(as.character(activity[, 2]))

# features (columns)
features <- read.table("UCI HAR Dataset/features.txt")
features <- as.vector(as.character(features[, 2]))

# training set
train <- read.table("UCI HAR Dataset/train/X_train.txt")
train[, ncol(train)+1] <- read.table("UCI HAR Dataset/train/Y_train.txt")
train[, ncol(train)+1] <- read.table("UCI HAR Dataset/train/subject_train.txt")

# test set
test <- read.table("UCI HAR Dataset/test/X_test.txt")
test[, ncol(test)+1] <- read.table("UCI HAR Dataset/test/Y_test.txt")
test[, ncol(test)+1] <- read.table("UCI HAR Dataset/test/subject_test.txt")

# merge both sets
merged_data <- rbind(train, test)
features <- c(features, "activity", "subject")
colnames(merged_data) <- features

# filter out columns
filter <- grep("[Mm]ean[(][)]|[Ss]td[(][)]", features)
filter <- c(filter, ncol(train)-1, ncol(train))

filtered_data <- merged_data[, filter]

# naming
colnames(filtered_data) <- colnames(merged_data[, filter])
filtered_data$activity <- factor(filtered_data$activity, levels = 1:length(activity), labels = activity)
filtered_data$activity <- as.factor(filtered_data$activity)
filtered_data$subject <- as.factor(filtered_data$subject)

# group by activity and subject, then perform average on all columns except "activity" and "subject"
tidy <- aggregate(filtered_data[-which(names(filtered_data) %in% c("activity", "subject"))], by=list(activity=filtered_data$activity, subject=filtered_data$subject), FUN=mean)

write.table(tidy, "tidy.txt", row.name=FALSE)
