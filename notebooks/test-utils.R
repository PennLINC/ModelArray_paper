# test on functions
# 
# rm(list=ls())
# library(mgcv)
# library(testthat) # for testing


test_that("partial R squared calculation works as expected", {
  source("utils.R")
  
  ### set up: make random data #####
  set.seed(5)
  nsubj = 10
  
  all.data <- data.frame(age = rnorm(nsubj, mean = 20, sd=10),
                         sex = sample(1:2, nsubj, replace=TRUE),
                         motion = rnorm(nsubj, mean = 0.5, sd=0.3),
                         FDC = rnorm(nsubj, mean = 1, sd = 0.5))
  # create a missing value in age # age is of interest for partial R2
  all.data$age[1] <- NA
  
  formula.full <- FDC ~ s(age, k=4, fx=TRUE) + sex + motion
  formula.red <- FDC ~ sex + motion
    
  # full model
  onemodel <- mgcv::gam(formula.full, data = all.data)   # first observation should be excluded because of age=NA
  expect_equal(onemodel$model %>% rownames(),
               (2:nsubj) %>% as.character() )   # first subject should be excluded
  
  # reduced model
  redmodel <- mgcv::gam(formula.red, 
                        data = onemodel$model)   
    # above: using data from full model's $model, so that only using (nsubj - 1) observations (although all nsubj have data for sex and motion, first one was not used in full model because its age is missing)
  expect_equal(onemodel$model %>% rownames(),
               redmodel$model %>% rownames())    # expect the used subjects in full and reduced models are the same
  
  ### test on partial R2 #####
  " test purpose: 
  1. Even if there is NA in original y, we won't get NA for the sse
  2. In addition, in even rare case, some observations are missing data for a variable in the full model but not in the reduced model (e.g. age is missing in one of the subjects).
    Make sure sse is not NA either in this rare case.
  "
  
  results <- partialRsq(onemodel, redmodel)
  partialRsq <- results$partialRsq
  sse.full <- results$sse.full
  sse.red <- results$sse.red
  
  expect_false(is.na(sse.full))
  expect_false(is.na(sse.red))

})