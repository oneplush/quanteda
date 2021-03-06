% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/corpus-addsummary-metadata.R
\name{summary_metadata}
\alias{summary_metadata}
\alias{add_summary_metadata}
\alias{get_summary_metadata}
\title{Functions to add or retrieve corpus summary metadata}
\usage{
add_summary_metadata(x, ...)

get_summary_metadata(x, ...)
}
\arguments{
\item{x}{\link{corpus} object}

\item{...}{additional arguments passed to \code{\link[=tokens]{tokens()}} when computing the
summary information}
}
\value{
\code{add_summary_metadata()} returns a corpus with summary metadata added
as a data.frame, with the top-level list element names \code{summary}.

\code{get_summary_metadata()} returns the summary metadata as a data.frame.
}
\description{
Functions to add or retrieve corpus summary metadata
}
\details{
This is provided so that a \link{corpus} object can be stored with
summary information to avoid having to compute this every time
\verb{[summary.corpus()]} is called.

So in future calls, if \verb{!is.null(meta(x, "summary", type = "system") && !length(list(...))}, then \code{summary.corpus()} will simply return
\code{get_system_meta()} rather than compute the summary statistics on the fly,
which requires tokenizing the text.
}
\examples{
corp <- corpus(data_char_ukimmig2010)
corp <- quanteda:::add_summary_metadata(corp)
quanteda:::get_summary_metadata(corp)
}
\keyword{corpus}
\keyword{internal}
