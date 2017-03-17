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

count_u <- count(mg2, 'Uid_int')
count_b <- count(mg2, 'Bid_int')
b_qualified <- count_b[count_b$freq>20,1]

mg3<- mg2[mg2$Bid_int %in% b_qualified, ]

count_u <- count(mg3, 'Uid_int')
u_qualified <- count_u[count_u$freq>10,1]
mg4<- mg3[mg3$Uid_int %in% u_qualified, ]

count_u2 <- count(mg4, 'Uid_int')
count_b2 <- count(mg4, 'Bid_int')

business_list <- unique(mg4$Bid_int)
user_list <- unique(mg4$Uid_int)
write.csv(mg4, "merged_all_reviews.csv")


mg4_subset <- mg4[,c("Uid_int","Bid_int", "rating")]


matrix <- matrix(data = 0, nrow = length(user_list), ncol = length(business_list),dimnames = list(user_list, business_list))

for (i in 1:nrow(mg4_subset)){
  u_id <- as.character(mg4_subset$Uid_int[[i]])
  b_id <- as.character(mg4_subset$Bid_int[[i]])
  rating <- as.integer(mg4_subset$rating[[i]])
  matrix[u_id, b_id] <- rating
}

write.table(matrix,file="matrix.txt") # keeps the rownames
# read.table("test.txt",header=TRUE,row.names=1)








