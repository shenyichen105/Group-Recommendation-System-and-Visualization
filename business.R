library(jsonlite)

json_file <- 'yelp_academic_dataset_business.json'

dat <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))
subdat <- dat[grep('Restaurants', dat$categories),]

ID <- subdat$business_id
name <- subdat$name
city <- subdat$city
state <- subdat$state
stars <- subdat$stars
latitude <- subdat$latitude
longitude <- subdat$longitude
cat <- subdat$categories
#fill with NA in cat
max.length <- max(sapply(cat, length))
new_cat <- lapply(cat, function(v) { c(v, rep(NA, max.length-length(v)))})
cat_mt <- matrix(unlist(new_cat),nrow = nrow(subdat), byrow=T)
business <- data.frame('BusinessID'=ID,'Name'=name,
                   'City'=city,'State'=state,
                   'Stars'=stars,'Latitude'=latitude,
                   'Longitude'=longitude,
                    cat_mt)
colnames(business)[8:17] <- c("Category1", "Category2","Category3","Category4",
                              "Category5","Category6","Category7","Category8",
                              "Category9","Category10")
write.csv(business, file = "business.csv")
