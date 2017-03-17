library(reshape2)
matrix_w_cat<- read.csv("matrix_w_cluster_labels.csv")

cat <- matrix_w_cat[,c("X","X1", "X2", "X3","X4","X5","X6","X7")]
colnames(cat) <- c("b_id", "Category1", "Category2", "Category3","Category4","Category5","Category6","Category7")
#write.csv(cat,"business_cat_after_KNN.csv")


#correct col and row names
row_name <- matrix_w_cat$X
matrix_w_cat2 <- matrix_w_cat[,2:ncol(matrix_w_cat)]
rownames(matrix_w_cat2) = row_name

colnames(matrix_w_cat2)[(ncol(matrix_w_cat2)-6):ncol(matrix_w_cat2)] =  c("C1","C2","C3","C4","C5","C6","C7")
col2 <- sub("X", "", colnames(matrix_w_cat2))

colnames(matrix_w_cat2) = col2

#remove users with no ratings, should be none
na<- apply(matrix_w_cat2, 2, function(x){return(sum(is.na(x)))})
nr<-which(na == nrow(matrix_w_cat2))
#matrix_w_cat2 = matrix_w_cat2[-nr,]

#melt the matrix with multiple categories
matrix_mt<- melt(matrix_w_cat2, measure.vars = c("C1","C2","C3","C4","C5","C6","C7"))
matrix_melted <- matrix_mt[!matrix_mt$value == 0, !colnames(matrix_mt)%in%c("variable")]

#aggregate by mean, exclude "0s" , create the reduced form of b*u matrix
matrix_aggregated <- aggregate(matrix_melted, list(matrix_melted$value), function(x){return(mean(x, na.rm = T))})
rownames(matrix_aggregated) = matrix_aggregated[,"value"]
matrix_aggregated <- matrix_aggregated[,2:(ncol(matrix_aggregated)-1)]

write.csv(matrix_aggregated,"reduced_matrix.csv")

