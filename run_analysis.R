# Read all of the necessary data files.
#test <- read.table("UCI HAR Dataset/test/X_test.txt", header=FALSE)
#train <- read.table("UCI HAR Dataset/train/X_train.txt", header=FALSE)
#subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header=FALSE)
#subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header=FALSE)
#features <- read.table("UCI HAR Dataset/features.txt", header=FALSE)
#activity_test <- read.table("UCI HAR Dataset/test/y_test.txt", header=FALSE)
#activity_train <- read.table("UCI HAR Dataset/train/y_train.txt", header=FALSE)
#activity_lables <- read.table("UCI HAR Dataset/activity_labels.txt", header=FALSE)

# Combine training and test sets.
data <- rbind(test, train)
subject <- rbind(subject_test, subject_train)$V1
activity <- factor(rbind(activity_test, activity_train)$V1, labels=activity_lables$V2)

# Name the variables
names(data) <- features$V2

# Select only those columns with variable names containing "mean()" or "std()", and also the subject and activity variables
data <- data[,grepl("mean\\(\\)|std\\(\\)", names(data))]

# Replace abbreviations with longer, more descriptive names.
names(data) <- sub("Acc", "Accelerometer", names(data))
names(data) <- sub("Gyro", "Gyroscope", names(data))
names(data) <- sub("Mag", "Magnitude", names(data))
names(data) <- sub("^t", "Time", names(data))
names(data) <- sub("^f", "Frequency", names(data))


# Fix double "BodyBody" text in variable names
names(data)<-sub("BodyBody", "Body", names(data))

# Split the data up into groups of subject X activity combination, then take the mean of each variable for each group
summaryData <- t(sapply(split(data, list(subject, activity)), function(x) colMeans(x)))
groups <- rownames(summaryData)
summaryData <- data.frame(summaryData)
names(summaryData) <- names(data)

# Attach "subject" and "activity" variables to the data frame
summaryData$subject <- sapply(groups, function(x) strsplit(x, split=".", fixed=TRUE)[[1]][1])
summaryData$activity <- sapply(groups, function(x) strsplit(x, split=".", fixed=TRUE)[[1]][2])

# Write the data set to a file
write.table(summaryData, file = "summaryData.csv", sep=",", row.names=F)