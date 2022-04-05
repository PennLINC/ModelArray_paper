# test on functions
# TO RUN: click "Run Tests" at top right in Rstudio
# 
# rm(list=ls())
# library(mgcv)
# library(testthat) # for testing


test_that("partial R squared calculation works as expected", {
  
  ### test on partial R2 #####
  " test purpose: 
  1. Even if there is NA in original y, we won't get NA for the sse. 
    THIS IS DONE by: to grab y.obs and y.pred from the actual model object: sum((full_mod$y-full_mod$fitted.values)^2)
    This is shown in case 2. In this case we also want to test if we don't need full.model for reduced model fitting (i.e. not using full.model$model as input data for reduced model)
  2. In addition, in even rare case, some observations are missing data for a variable in the full model but not in the reduced model (e.g. age is missing in one of the subjects).
    Make sure sse is not NA either in this rare case. 
    THIS IS DONE by: when fitting reduced model, using data from full model: full.model$model
    This is shown in case 1.
  "
  
  source("utils.R")
  ### set up: make random data #####
  set.seed(5)
  nsubj = 10
  
  all.data.orig <- data.frame(age = rnorm(nsubj, mean = 20, sd=10),
                         sex = sample(1:2, nsubj, replace=TRUE),
                         motion = rnorm(nsubj, mean = 0.5, sd=0.3),
                         FDC = rnorm(nsubj, mean = 1, sd = 0.5))
  ### test: if an observation is = NA:
  # case 1: create a missing value in age # age is of interest for partial R2
  all.data.missingAge <- all.data.orig
  all.data.missingAge$age[1] <- NA
  
  # case 2: create a missing value in y:
  all.data.missingY <-  all.data.orig
  all.data.missingY$FDC[1] <- NA
  
  
  formula.full <- FDC ~ s(age, k=4, fx=TRUE) + sex + motion
  formula.red <- FDC ~ sex + motion
    
  for (i_case in 1:2) {
    if (i_case == 1) {all.data <- all.data.missingAge}
    else if (i_case == 2) {all.data <- all.data.missingY}
  
  
    # full model
    onemodel <- mgcv::gam(formula.full, data = all.data)   # first observation should be excluded because of age=NA
    expect_equal(onemodel$model %>% rownames(),
                 (2:nsubj) %>% as.character() )   # first subject should be excluded
      # key elements in partial Rsq: length should be nsubj-1, and without na
    expect_equal(onemodel$y %>% length(), nsubj-1)  
    expect_equal(onemodel$fitted.values %>% length(), nsubj-1)
    expect_false(onemodel$y %>% is.na() %>% any())  # any of them is na
    expect_false(onemodel$fitted.values %>% is.na() %>% any()) 
    
    # reduced model
    if (i_case == 1) {
      redmodel <- mgcv::gam(formula.red, 
                            data = onemodel$model)   
      # above: using data from full model's $model, so that only using (nsubj - 1) observations (although all nsubj have data for sex and motion, first one was not used in full model because one value is missing)
      
    } else if (i_case == 2) {
      redmodel <- mgcv::gam(formula.red, 
                            data = all.data)   # let's see if we don't need to depend on full.model (i.e. not getting data from full.model$model) to meet the goal of case 2
      
    }
    
    expect_equal(onemodel$model %>% rownames(),
                 redmodel$model %>% rownames())    # expect the used subjects in full and reduced models are the same
    
    # key elements in partial Rsq: length should be nsubj-1, and without na
    expect_equal(onemodel$y %>% length(), nsubj-1)  
    expect_equal(onemodel$fitted.values %>% length(), nsubj-1)  
    expect_equal(redmodel$y %>% length(), nsubj-1)  
    expect_equal(redmodel$fitted.values %>% length(), nsubj-1)
    expect_false(redmodel$y %>% is.na() %>% any())  # any of them is na
    expect_false(redmodel$fitted.values %>% is.na() %>% any()) 
    
    
    results <- partialRsq(onemodel, redmodel)
    partialRsq <- results$partialRsq
    sse.full <- results$sse.full
    sse.red <- results$sse.red
    
    expect_false(is.na(sse.full))
    expect_false(is.na(sse.red))
  
  }
  
  

})


