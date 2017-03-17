library(recommenderlab)

matrix_reduced<- read.csv("reduced_matrix.csv", header = T)

c_names <- matrix_reduced[,1]
matrix_clean <- t(matrix_reduced[,-1])

#na<- apply(matrix_clean, 1, function(x){return(sum(is.na(x)))})
#non_na <- 45 - na
#summary(non_na)

r_1 <- as.matrix(matrix_clean)
r <- as(r_1, "realRatingMatrix")
rec <- Recommender(r, method = "UBCF")
recom <- predict(rec,r, type="ratingMatrix")

#e <- evaluationScheme(r, method="split", train=0.9, given = -2)
#r1 <- Recommender(getData(e, "train"), "UBCF")
#p1 <- predict(r1, getData(e, "known"), type="ratings")
#error <- calcPredictionAccuracy(p1, getData(e, "unknown"))

#return to unnormalized matrix
result <-as(recom, "matrix")
user_mean <- read.csv("user_mean.csv")[,-1]
result_final <- apply(result, 2, function(x){return(x+user_mean$avg_rating)}) 
#floor and cap the ratings
result_final[which(result_final>5)] = 5
result_final[which(result_final<0)] = 0

rownames(result_final) = as.character(gsub("X","",rownames(result_final)))
colnames(result_final) = as.character(c(1:45))

write.csv(result_final, "User_by_cat_ratings.csv")


