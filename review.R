library(ndjson)
json_file <- 'yelp_academic_dataset_review.json'
dat<-ndjson::stream_in(json_file)
subdat <- subset(dat,select = c("business_id", "stars", "user_id"))
colnames(subdat)[1:3] = c("BusinessID", "Stars", "UserID")


write.csv(subdat, file = "review.csv")
