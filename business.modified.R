setwd("/Users/yichenshen/Documents/CS6242/yelp_dataset_challenge_academic_dataset")
library(jsonlite)
library(reshape2)
json_file<-"yelp_academic_dataset_business.json"

dat <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
subdat <- dat[grep('Restaurants', dat$categories),]
subdat<-subset(subdat, subdat$review_count>10)

ID <- subdat$business_id
name <- subdat$name
add<-subdat$full_address
city <- subdat$city
state <- subdat$state
stars <- subdat$stars
latitude <- subdat$latitude
longitude <- subdat$longitude
cat <- subdat$categories

att<-subdat$attributes

hours <-subdat$hours
open <-subdat$open

#create a matrix with different categories as columns 
len_id <- lapply(cat, length)
col1 <- rep(ID, len_id)
col2 <- unlist(cat)
col3 <- rep(TRUE, length(col2))
new_cat_1 <- data.frame("business_id" = col1, "category" = col2, "value" = col3)

business.category<-dcast(new_cat_1, business_id~category)
business.category[is.na(business.category)] <- FALSE

business.main <- data.frame('BusinessID'=ID,'Name'=name,
                       'City'=city,'State'=state,
                       'Stars'=stars,'Latitude'=latitude,
                       'Longitude'=longitude)

#preserve hours and attributes data for future use
hours<-flatten(hours)
att <-flatten(att)

business.hours <- data.frame('BusinessID'=ID,hours,"open" = open)
business.attributes <- data.frame('BusinessID'=ID, att)[,-grep("Music*|Hair*", names(att))]

write.csv(business.main, file = "business_main.csv")
write.csv(business.category, file = "business_category.csv")
write.csv(business.hours, file = "business_hours.csv")
write.csv(business.attributes, file = "business_attributes.csv")







