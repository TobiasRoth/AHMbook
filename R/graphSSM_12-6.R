
# AHM2 section 12.6, old name graph.ssm2

# To plot the observed time-series and the estimated population trajectories, we have adapted the SSM graphing function graph.ssm from chapter 5 in Kery & Schaub (2012) to multivariate SSMs and call this new function graph.ssm2. When browsing through the graphs for each site, we see that the estimated states (i.e., the latent relative abundance) represent a greatly smoothed picture with respect to the more jagged observed data (Fig. 12-11).

# Define function to draw a graph to summarize results
# for multivariate time series of counts 

graphSSM<- function(ssm, C){
  par(cex.main = 0.8)
  fitted <- lower <- upper <- numeric()
  nsite <- nrow(ssm$mean$n)
  T <- ncol(ssm$mean$n)
  oldAsk <- devAskNewPage(ask = dev.interactive(orNone=TRUE))
      on.exit(devAskNewPage(oldAsk)) # Restore previous setting
  for(j in 1:nsite){
    for (i in 1:T){
      fitted[i] <- mean(ssm$sims.list$n[,j,i])
      lower[i] <- quantile(ssm$sims.list$n[,j,i], 0.025)
      upper[i] <- quantile(ssm$sims.list$n[,j,i], 0.975)
    }
    m1 <- min(c(C[j,], fitted, lower), na.rm = TRUE)
    m2 <- 1.2*max(c(C[j,], fitted, upper), na.rm = TRUE)
    oldpar <- par(mar = c(4.5, 4, 1, 1), cex = 1.2)
       on.exit(par(oldpar), add=TRUE)
    plot(0, 0, ylim = c(m1, m2), xlim = c(0.5, T), main = paste('Site', j),
      ylab = "Population size", xlab = "Year", las = 1, col = "black",
      type = "l", lwd = 2, frame = FALSE, axes = FALSE)
    axis(2, las = 1)
    axis(1, at = seq(0, T, 1), labels = seq(0, T, 1))
    axis(1, at = 0:T, labels = rep("", T + 1), tcl = -0.25)
    polygon(x = c(1:T, T:1), y = c(lower, upper[T:1]), col = "gray90", border = "gray90")
    points(C[j,], type = "l", col = "black", lwd = 2)
    points(fitted, type = "l", col = "blue", lwd = 2)
    legend(x = 1, y = m2, legend = c("Observeddata (C)", "Estimatedlatent states (n) with 95% CRI"), lty = c(1, 1), lwd = c(2, 2), col = c("black", "blue"), bty = "n", cex = 0.6)
  }
}
