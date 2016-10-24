library(plyr)

user<-read.csv("user.csv")
review <- read.csv("review.csv")
business <- read.csv("business_main.csv")

colnames(user)[which(colnames(user) == "X")] = "Uid_int"
colnames(user)[which(colnames(user) == "Name")] = "UserName"
colnames(user)[which(colnames(user) == "Avg_stars")] = "Avg_user_rating"

colnames(business)[which(colnames(business) == "X")] = "Bid_int"
colnames(business)[which(colnames(business) == "Name")] = "BusinessName"
colnames(business)[which(colnames(business) == "Stars")] = "Avg_business_rating"

colnames(review)[which(colnames(review) == "X")] = "review_id"
colnames(review)[which(colnames(review) == "Stars")] = "rating"


mg1 <- merge(user, review, by = "UserID")
mg2 <- merge(mg1, business, by = "BusinessID")

business_list <- unique(mg2$Bid_int)

#big_matrix <- matrix(nrow = length(user_list), ncol = length(business_list)) #10GB!
#Ok now first sample 5000 business, then choose user rated them at least 10 times. then get rid of business that has not rated by those users
#we get 4818 business and 4002 users with business being at least rated once.
set.seed(2)

business_sample <- data.frame( "Bid_int" = sample(business_list, 5000))
rated_sample <- merge(business_sample, mg2, by="Bid_int")

count <- count(rated_sample, 'Uid_int')
user_sample_id <-count[count$freq>10, ]$Uid_int
user_sample <- data.frame("Uid_int"=user_sample_id)


rated_sample_final <- merge(user_sample, rated_sample, by = 'Uid_int')
business_sample_id <- unique(rated_sample_final$Bid_int)

matrix <- matrix(data = 0, nrow = length(user_sample_id), ncol = length(business_sample_id),dimnames = list(user_sample_id, business_sample_id))

for (i in 1:nrow(rated_sample_final)){
  u_id <- as.character(rated_sample_final$Uid_int[[i]])
  b_id <- as.character(rated_sample_final$Bid_int[[i]])
  rating <- as.integer(rated_sample_final$rating[[i]])
  matrix[u_id, b_id] <- rating
}

write.table(matrix,file="matrix.txt") # keeps the rownames
# read.table("test.txt",header=TRUE,row.names=1)

write.csv(mg2, "merged_all_reviews.csv")
write.csv(rated_sample_final, "sample_reviews.csv")






