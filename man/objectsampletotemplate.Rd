\name{objectsampletotemplate}
\alias{objectsampletotemplate}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Converts data of a sample in a QDNAseq-object to a template for ACE functions
}
\description{
\code{objectsampletotemplate} parses QDNAseq-objects into the data frame structure used by various ACE functions. These functions call objectsampletotemplate itself when necessary, but it might be convenient to make a template if you expect some repeated use of the functions or if you want to make manual adjustments to the template.
}
\usage{
objectsampletotemplate(copyNumbersSegmented, index = 1)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{copyNumbersSegmented}{QDNAseqCopyNumbers object with segmented data}
  \item{index}{Integer. Specifies the index of the sample}
}

\value{
Returns a template data frame with the columns bin, chromosome, copynumbers, and segments (when available)
}

\author{
Jos B. Poell
}
\note{
If segment values are missing, the function will still return a data frame, but only containing the copynumbers column, not the segments column
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{singlemodel}}, \code{\link{squaremodel}}, \code{\link{singleplot}}
}
\examples{
data("copyNumbersSegmented")
template <- objectsampletotemplate(copyNumbersSegmented, index = 1)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
