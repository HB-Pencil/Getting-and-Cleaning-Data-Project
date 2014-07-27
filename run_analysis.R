## load data
if(!file.exists("./data")) {dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./data/activityrec.zip", method="curl")
## read training set
xtrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
## read test set
xtest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")

## step 1: merging the training and the test sets
total <- rbind(xtrain, xtest)

## step 2: extracting only the measurements on the mean and standard deviation
## read features.txt
feature <- read.table("./data/UCI HAR Dataset/features.txt")
## grab mean() and std()
newfea <- grep("*-mean|-std*", feature[, 2])
## extract mean and std
newdata <- total[newfea]

## step 3: using descriptive activity names to name the activities
## read activity lables
ytrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
ytest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
activity <- rbind(ytrain, ytest)
## replace labels with activity names
## make a vector
vactivity <- activity$V1
## factor()
factivity <- factor(vactivity, labels=c("Walking", "WalkingUp", "WalkingDown", "Sitting",
                                       "Standing", "Laying"))
newdata$Activity <- factivity

## step 4: labeling the data set with descriptive variable names
newvariable <- feature[newfea, 2]
## convert newvariable from factor to vector
newvariable <- as.character(newvariable)
colnames(newdata)[1:79] <- newvariable

## step 5: creating a tidy data set with the average of each variable for each activity and each subject
## after reading forums, I decided to exclude meanFreq
drop <- grep("meanFreq", names(newdata), value=TRUE)
myvars <- names(newdata) %in% drop
mydata <- newdata[!myvars]
## add subject ID
strain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
stest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
subject <- rbind(strain, stest)
mydata$SubjectID <- subject[, 1]
## create a new tidy data
attach(mydata)
tidydata <- aggregate(mydata, by=list(Activity, SubjectID), FUN=mean, na.rm=TRUE)
detach(mydata)
## exclude the the column of average on Activity and SubjectID
tidydata <- tidydata[1:68]
## rename Group.1 and Group.2 for Activity and SubjectID
colnames(tidydata)[1:2] <- c("Activity", "SubjectID")
## export tidydata
write.table(tidydata, "./data/tidydata.txt", sep="\t", row.names=FALSE)





