#test the recommendation using the full matrix

#split testing and training data
library(reshape2)
full_matrix <- read.csv("matrix_w_cluster_labels.csv")

#pre-processing the matrix
row_name <- full_matrix$X
matrix_w_cat2 <- full_matrix[,2:ncol(full_matrix)]
rownames(matrix_w_cat2) = row_name

colnames(matrix_w_cat2)[(ncol(matrix_w_cat2)-6):ncol(matrix_w_cat2)] =  c("C1","C2","C3","C4","C5","C6","C7")
col2 <- sub("X", "", colnames(matrix_w_cat2))

colnames(matrix_w_cat2) = col2
matrix_no_cat <- subset(matrix_w_cat2, select = -c(C1,C2,C3,C4,C5,C6,C7))
category <- subset(matrix_w_cat2, select = c(C1,C2,C3,C4,C5,C6,C7))




#---------------------------------------start testing --------------------------------------------------#
  
testing <- function(alg = "UBCF"){
  #getting random 3 rating out from testing set
  rate_tested <- numeric(3)
  for (i in test){
    rated_b <- which(!is.na(testing_set[,i]))
    take_out_b <- sample(rated_b, 3)
    rating <- testing_set[take_out_b,i]
    testing_set[take_out_b,i] <- NA
    #recording the ratings to be tested in "rate tested" data set
    rate_temp <- cbind(u_id = rep(i,3),b_id = rownames(testing_set)[take_out_b],rating)
    rate_tested <- rbind(rate_tested,rate_temp)
  }
  
  #combine training set and testing set with test ratings taken out
  
  train_set_combine <- cbind(testing_set, training_set)
  
  #melt the matrix with multiple categories
  train_mt<- melt(train_set_combine, measure.vars = c("C1","C2","C3","C4","C5","C6","C7"))
  train_melted <- train_mt[!train_mt$value == 0, !colnames(train_mt)%in%c("variable")]
  
  #aggregate by mean, exclude "0s" , create the reduced form of b*u matrix (45*18772)
  matrix_aggregated <- aggregate(train_melted, list(train_melted$value), function(x){return(mean(x, na.rm = T))})
  rownames(matrix_aggregated) = matrix_aggregated[,"value"]
  matrix_aggregated <- matrix_aggregated[,2:(ncol(matrix_aggregated)-1)]
  
  #next, use recommendation lab to predict
  library(recommenderlab)
  r_1 <- as.matrix(matrix_aggregated)
  r <- as(t(r_1), "realRatingMatrix")
  rec <- Recommender(r, method = alg)
  recom <- predict(rec,r[test,], type="ratingMatrix")
  result <- as(recom,"matrix")
  rownames(result) = test
  #evaluate the testing set 
  rate_predicted <- apply(rate_tested[-1,],2,as.character)
  rate_predicted <-data.frame(rate_predicted,stringsAsFactors=FALSE)
  
  for (i in 1:nrow(rate_predicted)){
    u <- rate_predicted$u_id[i]
    b <- rate_predicted$b_id[i]
    cate <- category[rownames(category) == b, ]
    cate <- cate[which(cate != 0)]
    rate_predicted$predict[i] <- mean(result[u, as.numeric(cate)])
  }
  
  rate_predicted_no_na <- rate_predicted[!is.na(rate_predicted$predict) & abs(rate_predicted$predict)<3,]
  rate_predicted_no_na$predict[which(rate_predicted_no_na$predict>5)] = 5
  rate_predicted_no_na$predict[which(rate_predicted_no_na$predict<0)] = 0
  mean((rate_predicted_no_na$predict - as.numeric(rate_predicted_no_na$rating))^2)
}

#------------------------testing by random splitting 10 times -------------------------
#set.seed(2)
#random splitting
test<-sample(colnames(matrix_no_cat), ncol(matrix_no_cat)*0.1)
#preserving categories for training
training_set <- matrix_w_cat2[,!colnames(matrix_w_cat2)%in%test]
testing_set <-  matrix_no_cat[,test]


RSME <- numeric(10)
for (i in 1:10){
  r <- testing(alg = "UBCF")
  print(r)
  RSME[i] <- r
}

RSME2 <- numeric(10)
for (i in 1:10){
  r <- testing(alg ="SVD")
  print(r)
  RSME2[i] <- r
}

RSME3 <- numeric(10)
for (i in 1:10){
  r <- testing(alg = "POPULAR")
  print(r)
  RSME3[i] <- r
}

#---------------------------------------------10 fold cross validation ----------------------------------------------
require(caret)
RSME1_2 <- numeric(10)
RSME2_2 <- numeric(10)
RSME3_2 <- numeric(10)
RSME4_2 <- numeric(10)

flds <- createFolds(1:ncol(matrix_no_cat), k = 10, list = TRUE, returnTrain = FALSE)

for (i in 1:10){
  id <- flds[[i]]
  test<-colnames(matrix_no_cat)[id]
  training_set <- matrix_w_cat2[,-flds[[i]]]
  testing_set <-  matrix_no_cat[,flds[[i]]]
  r <- testing(alg = "UBCF")
  print(r)
  RSME1_2[i] <- r
}


for (i in 1:10){
  id <- flds[[i]]
  test<-colnames(matrix_no_cat)[id]
  training_set <- matrix_w_cat2[,-flds[[i]]]
  testing_set <-  matrix_no_cat[,flds[[i]]]
  r <- testing(alg = "SVD")
  print(r)
  RSME2_2[i] <- r
}

for (i in 1:10){
  id <- flds[[i]]
  test<-colnames(matrix_no_cat)[id]
  training_set <- matrix_w_cat2[,-flds[[i]]]
  testing_set <-  matrix_no_cat[,flds[[i]]]
  r <- testing(alg = "POPULAR")
  print(r)
  RSME3_2[i] <- r
}

for (i in 1:10){
  id <- flds[[i]]
  test<-colnames(matrix_no_cat)[id]
  training_set <- matrix_w_cat2[,-flds[[i]]]
  testing_set <-  matrix_no_cat[,flds[[i]]]
  r <- testing(alg = "ALS")
  print(r)
  RSME4_2[i] <- r
}


Results <- data.frame("UCBF" = RSME1_2, "SVD" = RSME2_2, "POPULAR"=RSME3_2)
write.csv(Results,"CF_results.csv")