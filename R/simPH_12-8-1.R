
## AHM2 section 12.8.1

simPH <- function(
  # --- Sample sizes and design stuff ---
  npop = 18,               # Number of populations
  nyear = 17,              # Number of years (seasons)
  nrep = 10,               # Number of surveys per year (season)
  date.range = 1:150,      # Dates over which surveys may be conducted
  # --- Parameters of among-year dynamics ---
  initial.lambda = 300,    # Poisson mean of initial population size
  gamma.parms = c(0, 0.3), # mean and sd of lognormal interannual productivity
  # --- Parameters of within-year dynamics ---
  mu.range = c(50, 80),    # Range of date of peak flight period
                           #   (varies by site and year)
  sigma.range = c(10, 20), # Range of sigma of normal phenology curve
                           #   (varies by year only)
  # --- Parameters of observation process ---
  p.range = c(0.4, 0.6),   # Range of detection probabilities
                           #   (varies by site, year and visit)
  # --- Switch for plotting ---
  show.plot = TRUE)        # whether to browse plots or not
                           #   (should be set to FALSE when running sims)
  {  # -------------------- Start of function code -----------------

  # Function generates (insect) counts under a variant of a
  # 'phenomenological model' of Dennis et al. (JABES 2016).
  #
  # Interannual population model is exponential population growth,
  # with Poisson initial abundance governed by initial.lambda and
  # annually varying growth rate (or productivity parameter) gamma
  #
  # Within-year dynamics is described by a Gaussian curve with date of
  # mean flight period mu (site- and year-specific) and
  # length of flight period sigma (only year-specific).
  #
  # Counts are made subject to a detection probability (p), which varies
  # randomly according to a uniform distribution for every single count.
  #
  # Counts are plotted for up to 16 populations only.

  # Checks and fixes for input data -----------------------------
  npop <- round(npop[1])
  nyear <- round(nyear[1])
  nrep <- round(nrep[1])
  stopifnotInteger(date.range)
  stopifnotInteger(initial.lambda)
  stopifnotLength(gamma.parms, 2)
  # ---------------------------------------------------------------

  # Simulate among-year population dynamics: exponential model for N
  N <- array(NA, dim = c(npop, nyear))  # Array for site-year abundance
  N[,1] <- rpois(npop, initial.lambda)
  gamma <- rlnorm(nyear-1, meanlog=gamma.parms[1], sdlog=gamma.parms[2])
  for(t in 2:nyear){
    N[,t] <- rpois(npop, N[,t-1] * gamma[t-1])
  }

  # Simulate within-year population dynamics: Normal curve for counts
  C <- date <- lambda <- a <- array(NA, dim = c(npop, nyear, nrep))  # Arrays for
  # site-year-visit counts, survey dates, relative pop. size and detection probability
  mu <- array(NA, dim = c(npop, nyear))  # Array for value of peak flight period date

  # Select survey dates, peak flight period (mu_it),
  # length of flight period sigma(t) and compute relative pop. size (a),
  # expected population size (lambda) and realized counts (C)

  # Draw annual value of flight period length (sigma)
  sigma <- runif(nyear, min(sigma.range), max(sigma.range))

  # Draw values of detection probability (p)
  p <- array(runif(prod(c(npop, nyear, nrep)), min(p.range), max(p.range)),
    dim = c(npop, nyear, nrep))

  # Compute and assemble stuff at the scale of the individual visit
  for(i in 1:npop){
    for(t in 1:nyear){
      # Survey dates for this yr and pop:
      survey.dates <- sort(round(
        runif(nrep, min(date.range), max(date.range))))
      date[i,t,] <- survey.dates     # Save these survey dates
      mu[i,t] <- runif(1, min(mu.range), max(mu.range)) # Flight peak
      for(k in 1:nrep){
        # a[i,t,k] <- (1 / (sigma[t] * sqrt(2 * pi)) ) * exp( -((date[i,t,k] - mu[i,t])^2) / (2 * sigma[t]^2) )             # Rel. population size
        a[i,t,k] <- dnorm(date[i,t,k], mu[i,t], sigma[t])
               # Rel. population size
        lambda[i,t,k] <- N[i,t] * a[i,t,k] * p[i,t,k] # Expected counts
        C[i,t,k] <- rpois(1, lambda[i,t,k])       # Realized counts
      }
    }
  }

  if(show.plot) {
    # Restore graphical settings on exit -------------------------
    oldpar <- par(no.readonly = TRUE)
    oldAsk <- devAskNewPage(ask = dev.interactive(orNone=TRUE))
    on.exit({par(oldpar); devAskNewPage(oldAsk)})
    # ------------------------------------------------------------

    # Simulate nice smooth normal curve for the plots
    nday <- length(date.range)
    aa <- ll <- array(NA, dim = c(npop, nyear, nday))  # Arrays
    pp <- array(runif(prod(c(npop, nyear, nday)), min(p.range), max(p.range)),
      dim = c(npop, nyear, nday))
    for(i in 1:npop){
      for(t in 1:nyear){
        for(k in 1:nday){
          # aa[i,t,k] <- (1 / (sigma[t] * sqrt(2 * pi)) ) * exp( -((date.range[k] - mu[i,t])^2) / (2 * sigma[t]^2) )       # Relative population size
          aa[i,t,k] <- dnorm(date.range[k], mu[i,t], sigma[t])
            # Relative population size
          ll[i,t,k] <- N[i,t] * aa[i,t,k] * pp[i,t,k] # Expected counts
        }
      }
    }

    # Graphical output
    # Plot population dynamics and plot of all population sizes
    par(mfrow = c(2,1), mar = c(5,4,3,1))
    matplot(1:nyear, t(N), type = "l", lwd = 2, lty = 1, main = "Population size (N) for each population and year", ylab = "N", xlab = "Year", frame = FALSE, xaxt='n')
    tmp <- pretty(1:nyear)
    tmp[1] <- 1
    axis(1, at=tmp)
    plot(table(N), xlab = 'Population size', ylab = 'Frequency', main = 'Frequency distribution of population size for all sites and years', frame = FALSE)

    # Plot time-series of relative expected abundance for up to 16 populations
    par(mfrow = c(4,4), mar = c(5,4,3,1))
    limit <- ifelse(npop < 17, npop, 16)
    for(i in 1:limit){     # Plot only for 4x4 populations
      matplot(date.range, t(aa[i,,]), type = "l", lty = 1, lwd = 2, ylim = c(0, max(aa[i,,])), xlab = "Date", ylab = "Rel. abundance", main = paste("Phenology in pop ", i, sep = ''), frame = FALSE)
    }

    # Plot time-series of relative expected abundance for up to 16 populations
    par(mfrow = c(4,4), mar = c(5,4,3,1))
    limit <- ifelse(npop<17, npop, 16)
    for(i in 1:limit){     # Plot only for 4x4 populations
      matplot(date.range, t(ll[i,,]), type = "l", lty = 1, lwd = 2, ylim = c(0, max(ll[i,,])), xlab = "Date", ylab = "Exp. abundance", main = paste("Rel. exp. N in pop ", i, sep = ''), frame = FALSE)
    }

    # Plot time-series of counts (= relative, realized abundance) for up to 16 populations
    par(mfrow = c(4,4), mar = c(5,4,3,1))
    limit <- ifelse(npop<17, npop, 16)
    for(i in 1:limit){     # Plot only for 4x4 populations
      matplot(t(date[i,,]), t(C[i,,]), type = "b", lty = 1, lwd = 2, ylim = c(0, max(C[i,,])), xlab = "Date", ylab = "Counts", main = paste("Pop ", i, "(meanN =", round(mean(N[i,])), ")"), frame = FALSE)
    }
  }
  # Numerical output
  return(list(
    # ---------- arguments input --------------------------
    npop = npop, nyear = nyear, nrep = nrep, date.range = date.range,
    initial.lambda = initial.lambda, gamma.parms = gamma.parms,
    mu.range = mu.range, sigma.range = sigma.range, p.range = p.range,
    # ------------ generated values -----------------------
    # abundance
    gamma = gamma,   # nyear-1 vector, change in abundance
    N = N,           # site x year matrix, true abundance
    # phenology
    mu = mu,         # site x year matrix, mean of the flight period
    sigma = sigma,   # nyear vector, half-length of flight period
    # detection
    date = date,     # site x year x nreps, dates of the surveys
    a = a,           # site x year x nreps, phenology term
    lambda = lambda, # site x year x nreps, expected counts
    p = p,           # site x year x nreps, probability of detection
    C = C))          # site x year x nreps, simulated counts
}
# -------------------- End of function definition -----------------

