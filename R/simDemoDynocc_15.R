
# Another function for Chapter 15 in AHM2

simDemoDynocc<- function(nsite = 100, nyear = 10, nvisit = 5, psi1 = 0.6,
    range.phi = c(0.2, 0.9), range.r = c(0, 0.4), range.p = c(0.1, 0.9),
    show.plot=TRUE) {
  #
  # Function simulates data under a variant of the demographic occupancy
  #  (or 'local survival') model of Roth & Amrhein (J. Appl. Ecol., 2010).
  #  Data are simulated in an 'unconditional' manner, i.e., for each site from first to last year.
  #  All parameter can be made year-dependent by specification of a range,
  #  within which annual values will be drawn from uniform distributions.
  #
  # What the function arguments mean:
  #   psi1 = probability a territory is occupied at t=1
  #   nsite = number of territories
  #   nyear = number of study years
  #   nvisit = number of replicate visits per site and year
  #   range.phi = lower and upper limit of uniform distribution, from which
  #     annual local survival probability is drawn
  #   range.r = lower and upper limit of uniform distribution, from which
  #     annual recruitment probability is drawn
  #   range.p = lower and upper limit of uniform distribution, from which
  #     annual detection probability is drawn

  # Checks and fixes for input data -----------------------------
  nsite <- round(nsite[1])
  nyear <- round(nyear[1])
  nvisit <- round(nvisit[1])
  stopifnotProbability(psi1)
  stopifnotProbability(range.phi) # bounds
  stopifnotProbability(range.r) # bounds
  stopifnotProbability(range.p) # bounds
  # ----------------------------------------------------------------

  # Define true territory occupancy state matrix z
  z <- matrix(rep(NA, nyear*nsite), ncol=nyear)

  # Define the 3-dimensional matrix y that contains the observations
  y <- array(NA, dim = c(nsite, nvisit, nyear))

  # Simulate the annual local survival (nyear - 1 intervals)
  phi <- runif(nyear-1, min(range.phi), max(range.phi))

  # Simulate the annual colonization (nyear - 1 intervals)
  r <- runif(nyear-1, min(range.r), max(range.r))

  # Simulate the annual detection (includes year 1)
  p <- runif(nyear, min(range.p), max(range.p))

  # Simulate true state z from t=1:nyear
  persistence <- new.colonization <- z  # Provide intermediate structures
  for(i in 1:nsite) {
    # Initial year (t=1)
    z[i,1] <- rbinom(1, 1, psi1)
    for(t in 2:nyear) {
      persistence[i,t] <- z[i,t-1] * phi[t-1] +
        z[i,t-1] * (1-phi[t-1]) * r[t-1]  # survival or a 'rescue process'
      new.colonization[i,t] <- (1-z[i,t-1]) * r[t-1]
      z[i,t] <- rbinom(1, 1, persistence[i,t] + new.colonization[i,t])
    }
  }

  # Observations from t=1:nyear
  for(i in 1:nsite) {
    for(t in 1:nyear) {
      for(j in 1:nvisit) {
        y[i,j,t] <- rbinom(1, 1, z[i,t] * p[t])
      }
    }
  }

  # Create vector with 'occasion of marking' (for observed data)
  obsz <- apply(y, c(1,3), max)
  f <- suppressWarnings(apply(obsz, 1, function(x) min(which(x!=0))))
  f[f == 'Inf'] <- nyear

  # Derived quantities
  nocc.true <- apply(z, 2, sum)   # True ...
  nocc.obs <- apply(obsz, 2, sum) # ... and observed number of pairs

  if(show.plot) {
    # Visualization by two graphs
    oldpar <- par(mfrow = c(1, 2), mar = c(5, 5, 4, 2), cex.lab = 1.5)
      on.exit(par(oldpar))
    plot(1, 0, type = 'n', ylim = c(0,1), frame = FALSE,
      xlab = "Year", ylab = "Probability", xlim = c(1, nyear), las = 1,
      main = 'Local survival, recruitment and detection', xaxt='n')
    axis(1, 1:nyear)
    lines(1:(nyear-1), phi, type = 'o', pch=16, lwd = 2, col = 4, lty=2)
    lines(1:(nyear-1), r, type = 'o', pch=16, lwd = 2, col = 2, lty=3)
    lines(1:nyear, p, type = 'o', pch=16, lwd = 2, col = 1)
    legend('top', c("survival", "recruitment", "detection"),
      lty=c(2,3,1), lwd=2, col=c(4,2,1), #pch=16,
      inset=c(0, -0.05), bty='n', xpd=NA, horiz=TRUE)

    plot(1:nyear, nocc.true, type = 'n', frame = FALSE, xlab = "Year",
      ylab = "Population size", xlim = c(1, nyear), ylim = c(0, nsite), las = 1,
      main = 'True and observed population size', xaxt='n')
    axis(1, 1:nyear)
    lines(1:nyear, nocc.true, type = 'o', pch=16, lwd = 2, col = 2, lty=1)
    lines(1:nyear, nocc.obs, type = 'o', pch=16, lwd = 2, col = 4, lty=2)
    legend('top', c("true", "observed"),
      lty=c(1,2), lwd=2, col=c(2,4),
      inset=c(0, -0.05), bty='n', xpd=NA, horiz=TRUE)
  }

  # Return stuff
  return(list(
    # ----------- arguments supplied -----------------------
    psi1 = psi1, nsite = nsite, nyear = nyear, nvisit = nvisit,
    range.phi = range.phi, range.r = range.r, range.p = range.p,
    # ----------- generated values ---------------------------
    phi = phi,
    r = r,
    p = p,
    z = z,
    y = y,
    f = f,
    nocc.true = nocc.true,
    nocc.obs = nocc.obs))
}

