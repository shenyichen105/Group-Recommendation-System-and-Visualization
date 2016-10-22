library(jsonlite)

json_file <- 'yelp_academic_dataset_user.json'

dat <- fromJSON(sprintf("[%s]", paste(readLines(json_file)[1:20000], collapse=",")))
dat_sub <- dat[dat$review_count >= 20,]

ID <- dat_sub$user_id
name <- dat_sub$name
review <- dat_sub$review_count
stars <- dat_sub$average_stars

user <- data.frame('UserID'=ID,'Name'=name,'Review_count'=review,'Avg_stars'=stars)
write.csv(user, file = "user.csv")
read.table("user.csv")
