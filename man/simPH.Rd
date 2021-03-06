\name{simPH}
\alias{simPH}
\encoding{UTF-8}

\title{
Generate counts under a variant of a 'phenomenological model' 
}
\description{
Function generates (insect) counts under a variant of a 'phenomenological model' of Dennis et al. (2016). Interannual population model is exponential population growth, with Poisson initial abundance governed by initial.lambda and annually varying growth rate (or productivity parameter) gamma. Within-year dynamics is described by a Gaussian curve with date of mean flight period mu (site- and year-specific) and length of flight period sigma (only year-specific). Counts are made subject to a detection probability (p), which varies randomly according to a uniform distribution for every single count. Counts are plotted for up to 16 populations only.
}
\usage{
simPH(npop = 18, nyear = 17, nrep = 10, date.range = 1:150, initial.lambda = 300, 
  gamma.parms = c(0, 0.3), mu.range = c(50, 80),  sigma.range = c(10, 20),
  p.range = c(0.4, 0.6), show.plot = TRUE)
}
\arguments{
  \item{npop}{
The number of populations.
}
  \item{nyear}{
The number of years (seasons).
}
  \item{nrep}{
The number of surveys per year.
}
  \item{date.range}{
The dates over which surveys may be conducted.
}
  \item{initial.lambda}{
The Poisson mean of initial population size.
}
  \item{gamma.parms}{
The mean and SD of lognormal interannual productivity.
}
  \item{mu.range}{
The range of date of peak flight period (varies by site and year).
}
  \item{sigma.range}{
The range of sigma of Gaussian phenology curve (varies by year only).
}
  \item{p.range}{
The range of detection probabilities (varies by site, year and visit).
}
  \item{show.plot}{
Choose whether to show plots or not. Set to FALSE when using function in simulations.
}
}
\value{
A list with the values of the arguments entered and the following additional elements:

\item{gamma }{(nyear-1) vector, change in abundance for each interval between years.}
\item{N }{site x year matrix, true abundance.}
\item{mu }{site x year matrix, mean date of the flight period.}
\item{sigma }{nyear vector, half-length of flight period.}
\item{date }{site x year x reps array, dates of the surveys.}
\item{a }{site x year x reps array, phenology term.}
\item{lambda }{site x year x reps array, expected counts.}
\item{p }{site x year x reps array, probability of detection.}
\item{C }{site x year x reps array, simulated counts.}
}
\references{
Kéry & Royle (2019) \emph{Applied Hierarachical Modeling in Ecology} Section 12.8.1

Dennis et al (2016) Dynamic models for longitudinal butterfly data, \emph{Journal of Agricultural, Biological and Environmental Statistics} 21, 1-21
}
\author{
Marc Kéry
}

\examples{
# Run with the default arguments and look at the structure of the output:
set.seed(123)
tmp <- simPH()
str(tmp)
summary(tmp$C)
}
