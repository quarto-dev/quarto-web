set.seed(100)
point_count <- 1000000
a <- data.frame(x = rnorm(point_count / 4, 10, 1.9), y = rnorm(point_count / 4, 10, 1.2))
b <- data.frame(x = rnorm(point_count / 2, 14.5, 1.9), y = rnorm(point_count / 2, 14.5, 1.9))
c <- data.frame(x = rnorm(point_count / 4, 9.5, 1.9), y = rnorm(point_count / 4, 15.5, 1.9))
data <- rbind(a,b,c)

write.csv(data, "points.csv", row.names = FALSE)
message("Wrote ", nrow(data), " data points to points.csv")
