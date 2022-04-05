### This is to compare delta.adj.rsq vs partial.rsq

rm(list=ls())

library(ModelArray)
library(testthat)
library(mgcv)
library(broom)
library(ggplot2)
source("notebooks/utils.R")

#' @param flag_effsize Whether delta.adj.rsq is called eff.size
read_results <- function(fn.h5, fn.csv, analysis_name, flag_effsize=TRUE) {
  
  modelarray <- ModelArray(fn.h5, scalar_types="FDC",analysis_name = analysis_name)
  resultsmat <- results(modelarray)[[analysis_name]]$results_matrix
  
  num.fixels <- numElementsTotal(modelarray, scalar_name = "FDC")
  
  #resultsmat <- DelayedArray::realize(resultsmat)
  colnames <- colnames(resultsmat)
  
  if (flag_effsize == FALSE) {
    i_temp_1 <- match("s_Age.delta.adj.rsq", colnames)
    delta.adj.rsq <- resultsmat[, i_temp_1]
    
    i_temp_2 <- match("s_Age.partial.rsq", colnames)
    partial.rsq <- resultsmat[, i_temp_2]
    
    expect_equal(length(delta.adj.rsq), num.fixels)
    expect_equal(length(partial.rsq), num.fixels)
    
    toreturn <- list(delta.adj.rsq = delta.adj.rsq,
                     partial.rsq = partial.rsq,
                     modelarray = modelarray,
                     resultsmat = resultsmat)
    
    
  } else {
    i_temp <- match("s_Age.eff.size", colnames)
    eff.size <- resultsmat[, i_temp]
    
    expect_equal(length(eff.size), num.fixels)
    
    toreturn <- list(eff.size = eff.size,
                     modelarray = modelarray,
                     resultsmat = resultsmat)
    
  }

  return(toreturn)
}

return_metric_vec <- function(resultsmat, col_name) {
  i_temp <- match(col_name, colnames(resultsmat))
  metric_vec <- resultsmat[, i_temp]
  
  return(metric_vec)
}

# most recent data:
fn.h5 <- "/home/chenying/Desktop/fixel_project/data/data_from_josiane/results/ltn_FDC_n938_wResults_nfixels-0_20220204-140019.h5"
fn.csv <- "/home/chenying/Desktop/fixel_project/data/data_from_josiane/df_example_n938.csv"

results.list <- read_results(fn.h5, fn.csv, "gam_allOutputs", flag_effsize = FALSE)
modelarray <- results.list$modelarray
delta.adj.rsq <- results.list$delta.adj.rsq
partial.rsq <- results.list$partial.rsq
resultsmat <- results.list$resultsmat

s_Age.p.value <- return_metric_vec(resultsmat, "s_Age.p.value")

# correlation coefficient, ranging -1 to 1
r <- cor(delta.adj.rsq, partial.rsq)

## plot:
df <- data.frame(delta.adj.rsq = delta.adj.rsq,
                 partial.rsq = partial.rsq)
f <- ggplot(df, aes(x = delta.adj.rsq,    # aes_string()
                           y = partial.rsq)) +
  #geom_point()  +
  geom_bin2d(bins = 100) + 
  #geom_smooth(method = "lm", se = FALSE) +   # fitting
  theme_bw() +
  theme(aspect.ratio = 1,
        text = element_text(size=15)) + 
  xlab("delta.adj.rsq") + 
  ylab("partial.rsq") + 
  ggtitle(paste0("corr = ",toString(r)))

f

### manually compute to confirm the calculation is correct #####
phenotypes <- read.csv(fn.csv)
formula <- FDC ~ s(Age, k = 4, fx = TRUE) + sex + dti64MeanRelRMS 
reduced.formula <- FDC ~sex + dti64MeanRelRMS

i_fixel <- 6
dat <- phenotypes
dat[["FDC"]] <- scalars(modelarray)[["FDC"]][i_fixel,]

full.model <- mgcv::gam(formula=formula, data=dat,
                        method="REML")
fullmodel.adj.rsq <- summary(full.model)$r.sq


reduced.model <- mgcv::gam(formula = reduced.formula, data = dat,
                           method="REML")  
redmodel.adj.rsq <- summary(reduced.model)$r.sq

true.delta.adj.rsq <- fullmodel.adj.rsq - redmodel.adj.rsq
expect_equal(true.delta.adj.rsq, delta.adj.rsq[i_fixel])

true.partial.rsq <- partialRsq(full.model, reduced.model)$partialRsq
expect_equal(true.partial.rsq, partial.rsq[i_fixel])

### confirm that the results = previous one #####
fn.h5.old <- "/home/chenying/Desktop/fixel_project/data/data_from_josiane/results/ltn_FDC_n938_wResults_nfixels-0_20220109-183909.h5"
results.list.old <- read_results(fn.h5.old, fn.csv, "gam_allOutputs")
modelarray.old <- results.list.old$modelarray
resultsmat.old <- results.list.old$resultsmat
eff.size.old <- results.list.old$eff.size
s_Age.p.value.old <- return_metric_vec(resultsmat.old, "s_Age.p.value")



expect_equal(eff.size.old, delta.adj.rsq)   # expect the delta.adj.rsq won't change
expect_equal(s_Age.p.value.old, s_Age.p.value)   # expect the p.value for s_Age won't change
expect_equal(return_metric_vec(resultsmat.old, "s_Age.p.value.fdr"),  # expect the fdr p.value for s_Age won't change
             return_metric_vec(resultsmat, "s_Age.p.value.fdr"))
expect_equal(return_metric_vec(resultsmat.old, "s_Age.p.value.bonferroni"),  # expect the bonferroni p.value for s_Age won't change
             return_metric_vec(resultsmat, "s_Age.p.value.bonferroni"))
