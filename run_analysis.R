library(reshape2)

## Download and unzip the dataset:
filename <- "getdata_dataset.zip"
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

# Load activity labels + feat
actlab <- read.table("UCI HAR Dataset/activity_labels.txt")
actlab[,2] <- as.character(actlab[,2])
feat <- read.table("UCI HAR Dataset/features.txt")
feat[,2] <- as.character(feat[,2])

# Extract only the data on mean and standard deviation
featWanted <- grep(".*mean.*|.*std.*", feat[,2])
featWanted.names <- feat[featWanted,2]
featWanted.names = gsub('-mean', 'Mean', featWanted.names)
featWanted.names = gsub('-std', 'Std', featWanted.names)
featWanted.names <- gsub('[-()]', '', featWanted.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featWanted.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = actlab[,1], labels = actlab[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.final <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.final, "tidy.txt", row.names = FALSE, quote = FALSE)
