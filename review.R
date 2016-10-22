library(jsonlite)
json_file <- 'yelp_academic_dataset_review.json'
dat <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
subdat <- dat[c('business_id','stars','user_id')]

write.csv(business, file = "business.csv")