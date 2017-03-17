library(reshape2)

category <- read.csv("business_category.csv")

new <- sapply(category, as.numeric)
sum1<- tail(data.frame("freq" = sort(colSums(new), decreasing = T)), -2)

#getting only categories with 200 appearances
potentiallist <- rownames(subset(sum1, sum1$freq > 200))
#deleting those categories that are too general,form a data frame
potentiallist_2 <- data.frame(label = 1:length(potentiallist[-c(1,2,4,9)]), name = potentiallist[-c(1,2,3,8)])

#only keeping rows that are in potential list
category_clean <- category[ ,colnames(category)%in%potentiallist_2$name]
category_clean$business_id <- category$business_id
#finding max categories that business have

max_cates <- max(rowSums(category_clean[,!colnames(category_clean)%in%c("business_id")]))
category_row <- numeric(max_cates)

#create a table that records the categories of the busniess
names <- colnames(category_clean)

for (i in 1:nrow(category_clean)){
  new_row <- numeric(max_cates)
  cates <- names[as.vector(category_clean[i,] == T)]
  
  if (length(cates) >0) {
    for (j in 1:length(cates)){
      new_row[j] = which(potentiallist_2$name == cates[j])
    }
  }
  category_row = rbind(category_row, new_row)
}
rownames(category_row) <- c()
category_data = data.frame(tail(category_row, -1))
category_data$business_id = category$business_id
 

#to get the simplified B_id by mergeing business_main
business_main <- read.csv("business_main.csv")
id_pairs <- business_main[,c(1,2)]
colnames(id_pairs) <- c("B_id", "business_id")
category_data_final <- merge(category_data, id_pairs, by = "business_id")

#save the table that records categories to number conversion and business-category info

write.csv(category_data_final, "business_category1")
write.csv(potentiallist_2, "category_id")

#ready to merge to the matrix
matrix <- read.table("matrix.txt")
col <- as.numeric(gsub("X","",colnames(matrix)))

#transpose and normalizing matrix. Setting "0s" to NA. The matrix is 99.7% sparse
matrix_t <- as.matrix(t(matrix))
matrix_t[matrix_t == 0] <- NA

user_mean <- numeric(2)

for (j in 1:ncol(matrix_t)){
  non_na_index <- !is.na(matrix_t[,j])
  mean <- sum(matrix_t[,j], na.rm = T)/length(matrix_t[non_na_index,j])
  matrix_t[non_na_index,j]<- matrix_t[non_na_index,j]- mean
  print(mean)
  user_mean <- rbind(user_mean, c(rownames(matrix)[[j]],mean))
}

rownames(matrix_t) <- col
colnames(matrix_t) <- rownames(matrix)

user_mean <- user_mean[-1,]
colnames(user_mean) <- c("u_id", "avg_rating")

#code to check whether there are users that doesn't have any review after all the filtering
#c<- apply(matrix_t, 2, function(x){return(sum(!is.na(x)))})
#which(c == 0)

write.csv(matrix_t, "matrix_normalized_b*u.csv")
write.csv(user_mean,"user_mean.csv")

#find the business_id value in category_final that are in the sample
match_col  <- match(col, category_data_final$B_id)
category_data_sub <- category_data_final[match_col,2:9]
matrix_w_cat <- cbind(matrix_t, category_data_sub[,c(1:7)])

#collapse the category_sub data
category_sub_melt <- melt(category_data_sub, id.vars = "B_id")
category_sub_melt <- category_sub_melt[order(category_sub_melt$B_id),]
#remove all 0
category_sub_melt <- category_sub_melt[category_sub_melt$value != 0,]


#mode function for knn
Mode <- function(x) {
  ux <- unique(x)
  return (ux[which.max(tabulate(match(x, ux)))])
}

Cosdist<- function(x,y){
  product <- x*y
  non_na_part <- which(!is.na(product))
  return (sum(product, na.rm =T)/sqrt(sum(x[non_na_part]^2)*sum(y[non_na_part]^2)))
}

#knn to assign unlabeled vectors (now 15 is used, need cross validation to choose best k)
unassigned_id <- category_data_sub$B_id[rowSums(category_data_sub[,c(1:7)])==0]
unassigned_matrix <- matrix_t[rownames(matrix_t)%in%unassigned_id,]
assigned_matrix <- matrix_t[!rownames(matrix_t)%in%unassigned_id,]

for (i in 1:nrow(unassigned_matrix)){
  vector_i <- as.vector(unassigned_matrix[i,])
  dist <- numeric(nrow(assigned_matrix))
  names(dist) <- rownames(assigned_matrix)
    
  for (j in 1:nrow(assigned_matrix)){
    vector_j <- as.vector(assigned_matrix[j,]) 
    cos_dist <- Cosdist(vector_i,vector_j)
    dist[j] = cos_dist 
  }
  
  dist_sorted <- sort(dist, decreasing = T)[1:15]
  neigbours <- names(dist_sorted)
  #need to look at all categories in its neighbours
  labels <- category_sub_melt$value[category_sub_melt$B_id %in% neigbours]
  matrix_w_cat[rownames(unassigned_matrix)[i],"X1"] <- Mode(labels)
  
  print(i)
}


write.csv(matrix_w_cat, "matrix_w_cluster_labels.csv")
#melting the matrix
#aggregate the ratings via cluster assigment 
#run knn by user 









