\name{UKmarbledWhite}
\alias{UKmarbledWhite}
\encoding{UTF-8}
\docType{data}
\title{
Data for UK Marbled White butterflies
}
\description{
Data from the UK Butterfly Monitoring Scheme (UKBMS) for the Marbled White butterfly (\emph{Melanargia galathea}), a fairly widespread species that flies in a single generation per year in the UK.

Most survey sites are chosen opportunistically and represent fixed transects of variable and often unknown length, which are walked between two and 26 times per year starting in early April. Butterflies are counted within an imaginary 5m x 5m 'moving box' along the transects.

We restrict the data to sites where the marbled white was ever recorded, the years 1991–2015 and those 80 sites where counts took place in at least 20 of these 25 years.
}

\usage{data("UKmarbledWhite")}

\format{
A data frame with 9651 rows and the following columns:

\describe{
  \item{C }{count, the number of butterflies recorded}
  \item{site }{identification number for site}
  \item{year }{the year of the record}
  \item{north }{approximate northing of the site in the British National Grid, in metres}
   \item{date }{Julian date of the survey, 1 = 1st January}
  }
}

\source{
UK Butterfly Monitoring Scheme (UKBMS) data © copyright and database right Butterfly Conservation, the Centre for Ecology and Hydrology, British Trust for Ornithology, and the Joint Nature Conservation Committee, 2018. The UKBMS is indebted to all volunteers who contribute data to the scheme.

 \url{https://www.ceh.ac.uk/our-science/projects/uk-butterfly-monitoring-scheme}
}
\references{
Kéry & Royle (2019) \emph{Applied Hierarchical Modeling in Ecology} Section 12.8.2.
}
\seealso{
\code{\link{SwissMarbledWhite}}.
}
\examples{
data(UKmarbledWhite)
str(UKmarbledWhite)
}
\keyword{datasets}
