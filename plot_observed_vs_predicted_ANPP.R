#!/usr/bin/Rscript

# Plot the predicted ANPP vs. the observed ANPP
#
# Author: Martin De Kauwe
# Email: mdekauwe@gmail.com
# Date: 01.03.2018

library(ggplot2)
library(cowplot)

error_bar <- function(x, y, upper, lower, length=0.1,...) {
  if( length(x) != length(y) | length(y) !=length(lower) |
      length(lower) != length(upper))
    stop("vectors must be same length")
  arrows(x,y+upper, x, y-lower, angle=90, code=3, length=length, ...)
}


wd <- getwd()
setwd(wd)

samples <- 50000 # samples to be kept after burn in
thin <- 10
N <- samples / thin


chain1 <- read.csv(file=paste("outputs/chain_iter_1_to_", samples,
                     "_chain1.csv", sep=""), header=TRUE)
chain2 <- read.csv(file=paste("outputs/chain_iter_1_to_", samples,
                     "_chain2.csv", sep=""), header=TRUE)
chain3 <- read.csv(file=paste("outputs/chain_iter_1_to_", samples,
                     "_chain3.csv", sep=""), header=TRUE)
chain4 <- read.csv(file=paste("outputs/chain_iter_1_to_", samples,
                     "_chain4.csv", sep=""), header=TRUE)

chain1 <- as.matrix(chain1)
chain2 <- as.matrix(chain2)
chain3 <- as.matrix(chain3)
chain4 <- as.matrix(chain4)

en <- end(chain1)[1]
st <- en - N

# To use the MCMC samples for prediction, we combine the 4 chains into one.
mu_post <- rbind(chain1[st:en,9:60], chain2[st:en,9:60],
                 chain3[st:en,9:60], chain4[st:en,9:60])

mu_post_mean <- apply(mu_post, 2, mean)
mu_post_95CI <- apply(mu_post, 2, quantile, probs=c(0.025, 0.975))

lower <- mu_post_mean - mu_post_95CI[1,]
upper <-mu_post_95CI[2,] - mu_post_mean

# ANPP and precipitation event data for each year, extracted from Lauenroth
# and Sala (1992).
df2 = read.table("data/dataset2.csv", na.strings="NA", skip=1, sep=" ",
                 stringsAsFactors=FALSE, header=TRUE)
YearID <- df2$YearID
NPP <- df2$NPP

png(filename="plots/observed_ANPP_vs_predicted.png")

plot(df2$Year, mu_post_mean, col="salmon", xlim=range(c(1940, 1990)),
     ylim=range(c(0, 150)), xlab='Year', ylab='NPP (units)',
     main='Predicted (red) with 95% Cred. Int. vs Observed (blue) NPP')
error_bar(df2$Year, mu_post_mean, upper,lower, col="salmon")
points(df2$Year, df2$NPP, col="royalblue")

dev.off()