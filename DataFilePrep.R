library(utils)
library(readr)
library(dplyr)
library(RWeka)
library(stringr)

# function to read all the files in a directory into a dataframe
createDataFrame <- function(directory){
  wd <- getwd()
  setwd(directory)
  file_list <- list.files()
  print(getwd())
  t <- lapply(file_list,read_file)
  setwd(wd)
  t<-do.call(rbind.data.frame, t)
  colnames(t) <- c("text")
  t$text <- str_trim(as.character(t$text))
  t
}

setMetaData <- function(df, domain, sentiment, type, spam){
  df$domain <- domain
  df$sentiment <- sentiment
  df$type <- type
  df$spam <- spam
  select(df,text,domain,sentiment,type,spam)
}

# create directory for data if we need to
if("rawData"%in%dir()==FALSE) dir.create("rawData")

# download data if we need to
if(!file.exists("rawData/deception_dataset.zip")){
  download.file("http://web.stanford.edu/~jiweil/data/deception_dataset.zip",
                "rawData/deception_dataset.zip")
}

# extract data if we need to
if("deception_dataset"%in%dir("rawData")==FALSE){
  unzip("rawData/deception_dataset.zip",exdir="rawData")
}

# now we will construct our full dataset

# Doctor

# deceptive_MTurk

# For some reasone the 1.txt file is corrupt
if(file.exists("rawData/deception_dataset/doctor/deceptive_MTurk/1.txt")){
  file.remove("rawData/deception_dataset/doctor/deceptive_MTurk/1.txt")
}

# get our data
t <- createDataFrame("rawData/deception_dataset/doctor/deceptive_MTurk")
t <- setMetaData(t,"doctor","positive","turker","Y")

fulldf <- t

# truthfull customer
# For some reasone the 1.txt file is corrupt
if(file.exists("rawData/deception_dataset/doctor/truthful/1.txt")){
  file.remove("rawData/deception_dataset/doctor/truthful/1.txt")
}
t <- createDataFrame("rawData/deception_dataset/doctor/truthful")
t <- setMetaData(t,"doctor","positive","customer","N")

fulldf <- rbind(fulldf,t)

# hotel negative deceptive expert

t <- createDataFrame("rawData/deception_dataset/hotel/negative/deceptive_expert")
t <- setMetaData(t,"hotel","negative","expert","Y")
fulldf <- rbind(fulldf,t)

# hotel negative deceptive turker

t <- createDataFrame("rawData/deception_dataset/hotel/negative/deceptive_turker")
t <- setMetaData(t,"hotel","negative","turker","Y")
fulldf <- rbind(fulldf,t)

# hotel negative truthful customer

t <- createDataFrame("rawData/deception_dataset/hotel/negative/truthful")
t <- setMetaData(t,"hotel","negative","customer","N")
fulldf <- rbind(fulldf,t)

# hotel positive deceptive expert

if(file.exists("rawData/deception_dataset/hotel/positive/deceptive_expert/.DS_Store")){
  file.remove("rawData/deception_dataset/hotel/positive/deceptive_expert/.DS_Store")
}
t <- createDataFrame("rawData/deception_dataset/hotel/positive/deceptive_expert")
t <- setMetaData(t,"hotel","positive","expert","Y")
fulldf <- rbind(fulldf,t)

# hotel positive deceptive turker

if(file.exists("rawData/deception_dataset/hotel/positive/deceptive_turker/.DS_Store")){
  file.remove("rawData/deception_dataset/hotel/positive/deceptive_turker/.DS_Store")
}
t <- createDataFrame("rawData/deception_dataset/hotel/positive/deceptive_turker")
t <- setMetaData(t,"hotel","positive","turker","Y")
fulldf <- rbind(fulldf,t)

# hotel positive truthful customer

if(file.exists("rawData/deception_dataset/hotel/positive/truthful/.DS_Store")){
  file.remove("rawData/deception_dataset/hotel/positive/truthful/.DS_Store")
}
t <- createDataFrame("rawData/deception_dataset/hotel/positive/truthful")
t <- setMetaData(t,"hotel","positive","customer","N")
fulldf <- rbind(fulldf,t)

# restaurant positive deceptive turker

if(file.exists("rawData/deception_dataset/restaurant/deceptive_MTurk/.DS_Store")){
  file.remove("rawData/deception_dataset/restaurant/deceptive_MTurk/.DS_Store")
}
if(file.exists("rawData/deception_dataset/restaurant/deceptive_MTurk/1.txt")){
  file.remove("rawData/deception_dataset/restaurant/deceptive_MTurk/1.txt")
}
if(file.exists("rawData/deception_dataset/restaurant/deceptive_MTurk/42.txt")){
  file.remove("rawData/deception_dataset/restaurant/deceptive_MTurk/42.txt")
}
t <- createDataFrame("rawData/deception_dataset/restaurant/deceptive_MTurk")
t <- setMetaData(t,"restaurant","positive","turker","Y")
fulldf <- rbind(fulldf,t)

# restaurant positive truthful customer
t <- createDataFrame("rawData/deception_dataset/restaurant/truthful")
t <- setMetaData(t,"restaurant","positive","customer","N")
fulldf <- rbind(fulldf,t)


# convert our categorical stuff to factors
fulldf$domain <- as.factor(fulldf$domain)
fulldf$sentiment <- as.factor(fulldf$sentiment)
fulldf$type <- as.factor(fulldf$type)
fulldf$spam <- as.factor(fulldf$spam)

write.arff(fulldf, "reviewSpamData.arff")
