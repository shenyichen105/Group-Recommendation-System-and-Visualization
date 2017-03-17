setwd("/Users/yichenshen/Documents/CS6242/yelp_dataset_challenge_academic_dataset")
library(jsonlite)

json_file <- 'yelp_academic_dataset_user.json'

dat <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
dat_sub <- dat[dat$review_count >= 20,]

# samples <- sample(1:nrow(dat_sub),20000)
# dat_sub = dat_sub[samples, ]

ID <- dat_sub$user_id
name <- dat_sub$name
review <- dat_sub$review_count
stars <- dat_sub$average_stars

#create some unique fake usernames like A A_1 Jeremy_2 Eddie_3 (can also serve as key)
count <- 0
name_last <- ""
name <- sort(name)
name_new <- character(nrow(dat_sub))

for (i in 1:nrow(dat_sub)){
  if(name[[i]] == name_last){
    count <- count+1
    name_new[[i]] <- paste0(name[[i]], "_", as.character(count))
  }else{
    count <- 0
    name_new[[i]] <- name[[i]]
  }
  name_last <-name[[i]]
}

user <- data.frame('UserID'=ID,'Name'=name_new,'Review_count'=review,'Avg_stars'=stars)
write.csv(user, file = "user.csv")