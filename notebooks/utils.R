### partial R2 #####

#' @param fullmodel The full model object returned by e.g. mgcv::gam() with full formula
#' @param redmodel The reduced model object returned by e.g. mgcv::gam() with reduced formula
#' @return A list including: partial R squared, sse for full and reduced models
partialRsq <- function(fullmodel, redmodel) {
  sse.full <- sum( (fullmodel$y - fullmodel$fitted.values)^2 )
  sse.red <- sum( (redmodel$y - redmodel$fitted.values)^2 )
  
  partialRsq <- (sse.red - sse.full) / sse.red
  
  toReturn <- list(partialRsq = partialRsq,
                   sse.full = sse.full,
                   sse.red = sse.red)
  return(toReturn)
}