# memory profiling for ModelArray.lm()

library(tictoc)
tic.clearlog()
tic("R running")

tic("time before ModelArray.lm()")

### input arguments #####
#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

flag_whichdataset <- args[1]   # "test_n50" or "josiane"
num.fixels <- as.integer(args[2])  # if ==0, set as full set
num.subj <- as.integer(args[3])  
num.cores <- as.integer(args[4])
ModelArray_commitSHA <- as.character(args[5])   # github commit SHA for installing ModelArray
ModelArrayPaper_commitSHA <- as.character(args[6])  # record for commit SHA for ModelArray_paper

flag_library_what <- "automatically"   # "automatically" or "manually"
# TODO: different variables and formula!

# checkers:
message(paste0("which dataset: ", flag_whichdataset))
message(paste0("number of fixels = "), toString(num.fixels))
message(paste0("number of subjects = "), toString(num.subj))
message(paste0("number of cores = "), toString(num.cores))
message(paste0("ModelArray_paper's commitSHA = ", ModelArrayPaper_commitSHA))
# message(paste0("class of arguments: ",class(flag_whichdataset), "; ", class(num.fixels), "; ", class(num.subj), "; ", class(num.cores)))




### basics #####
flag_where <- "vmware"   # "CUBIC" or "vmware"
if (flag_where =="CUBIC") {
  setwd("/cbica/projects/fixel_db/ModelArray_paper/benchmarks")

} else if (flag_where == "vmware") {

  setwd("/home/chenying/Desktop/fixel_project/ModelArray_paper/benchmarks")
}

if (flag_library_what == "automatically") {
  message("Please make sure that github repository 'ModelArray' has been updated: local files have been pushed! And commitSHA is up-to-date!")
  message("run: devtools::install_github() to install ModelArray package")
  library(devtools)
  message(paste0("ModelArray's commitSHA: ", ModelArray_commitSHA))

  devtools::install_github(paste0("PennLINC/ModelArray@", ModelArray_commitSHA),   # install_github("username/repository@commitSHA")
                           upgrade = "never",  # not to upgrade package dependencies
                           force=TRUE)   # force re-install ModelArray again
  library(ModelArray)
  
} else if (flag_library_what == "manually") {
  message("run: source several R scripts and library some R packages...")
  source("../../ModelArray/R/ModelArray_Constructor.R")
  source("../../ModelArray/R/ModelArray_S4Methods.R")
  source("../../ModelArray/R/utils.R")
  source("../../ModelArray/R/analyse.R")

  # library(DelayedArray)
  # suppressMessages(library(doParallel))
  # library(rhdf5)
  suppressMessages(library(dplyr))
  library(broom)
  library(hdf5r)

  # library(lobstr)   # for using "mem_used"
} else {
  message(paste0("flag_library_what = ", flag_library_what, " is not supported...."))
}


# save the config in R:
message("sessionInfo() as below:")
sessionInfo()  # including R versoin, attached packages version
message(" ")


# prev_m <- 0; m <- mem_used(); m - prev_m

# flag_whichdataset <- "test_n50"   # "test_n50" or "josiane"
# print(paste0("this is dataset: ", flag_whichdataset))

flag_which_subset <- ""


### filenames #####
if (flag_whichdataset == "test_n50") {
  fn <- "../inst/extdata/n50_fixels.h5"

  if (flag_where == "CUBIC") {
    fn.output <- "../../dropbox/data_forCircleCI_n50/n50_fixels_output.h5"
  } else if (flag_where == "vmware") {
    fn.output <- "../../data/data_forCircleCI_n50/n50_fixels_output.h5"  # absolute path: "/home/chenying/Desktop/fixel_project/data/data_forCircleCI_n50/n50_fixels_output.h5"
  }

  fn_csv <- "../inst/extdata/n50_cohort.csv"
  
  scalar = c("FD")

} else if (flag_whichdataset == "josiane") {
  if (flag_where == "CUBIC") {
    fn <- paste0("../../dropbox/data_from_josiane/ltn_FDC_n", toString(num.subj), ".h5")
    fn.output <- fn  # same as input (to avoid copying)
    fn_csv <- paste0("../../dropbox/data_from_josiane/df_example_n", toString(num.subj), ".csv")
  } else if (flag_where == "vmware") {
    fn <- paste0("../../data/data_from_josiane/ltn_FDC_n", toString(num.subj), ".h5")
    fn.output <- fn  # same as input (to avoid copying)
    fn_csv <- paste0("../../data/data_from_josiane/df_example_n", toString(num.subj), ".csv")
  }
  
  scalar = c("FDC")
}

# check if file exists:
if (file.exists(fn) == FALSE) {
  stop(paste0("input .h5 file does not exist: "), fn)
}
if (file.exists(fn_csv) == FALSE) {
  stop(paste0("input .csv file does not exist: "), fn_csv)
}

# generate fn.output:
if (fn != fn.output) {
  file.copy(from=fn, to=fn.output, overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE)   # , recursive = TRUE
}

# h5closeAll()

tic("Running ModelArray()")
modelarray <- ModelArray(fn.output, scalar_types = scalar)
toc(log=TRUE)    # pairing tic of "Running ModelArray()"

# check # subjects matches:
if (dim(scalars(modelarray)[[scalar]])[2] != num.subj) {
  stop(paste0("number of subjects in .h5 = ", dim(scalars(modelarray)[[scalar]])[2], ", is not equal to entered number = ", toString(num.subj)))
}


### set up #####
phenotypes <- read.csv(fn_csv)
# print(paste0("number of subjects = ", toString(nrow(phenotypes))))

# check # subjects matches:
if (nrow(phenotypes) != num.subj) {
  stop(paste0("number of subjects in .csv = ", toString(nrow(phenotypes)), ", is not equal to entered number = ", toString(num.subj)))
}



if (flag_whichdataset == "test_n50") {
  formula <- FD ~ age
} else if (flag_whichdataset == "josiane") {
  formula <- FDC ~ Age
}

full.outputs <- FALSE  # default: FALSE  
# var.terms <- c("estimate", "statistic", "p.value")   # list of columns to keep  | , "std.error","statistic"
# var.model <- c("adj.r.squared", "p.value")

analysis_name <- "lm"

if (num.fixels == 0) {
  num.fixels <- dim(scalars(modelarray)[[scalar]])[1]
}

element.subset <- 1:num.fixels   # full: dim(scalars(modelarray)[[scalar]])[1]


toc(log=TRUE)   # pair tic of "time before ModelArray.lm()"

### Run ModelArray.lm() ####

tic("Running ModelArray.lm()")

lm.outputs <- ModelArray.lm(formula, modelarray, phenotypes, scalar = scalar, element.subset = element.subset,
                             full.outputs = full.outputs,  
                             # var.terms = var.terms, var.model = var.model,
                             #correct.p.value.terms = "fdr",   # also save any fdr correction
                             #correct.p.value.model = c("fdr"),
                             verbose = TRUE, pbar = FALSE, n_cores = num.cores)  # , na.action="na.fail"

toc(log = TRUE)  # pairing tic of "Running ModelArray.lm()"
# lg <- toc(log = TRUE, quiet = TRUE)
# log.lst <- tic.log(format = FALSE)
# log.lst[[1]]$toc - log.lst[[1]]$tic    # in sec

message("head of lm.outputs:")
head(lm.outputs)

message("dimension of lm.outputs:")
dim(lm.outputs)

sleep_sec <- 5
message(paste0("sleep for ",toString(sleep_sec)," sec to capture the current memory before existing..."))
Sys.sleep(sleep_sec)


# ### save results #####
# tic("Running writeResults()")
# 
# writeResults(fn.output, df.output = lm.outputs, analysis_name=analysis_name, overwrite=TRUE)
# 
# toc(log=TRUE)   # pairing tic of "Running writeResults()"

# prev_m <- m; m <- mem_used(); m - prev_m
# delta_m <- m - prev_m
# delta_m
# delta_m / 1024 / 1024   # MB

toc(log=TRUE)    # pairing tic of "R running"
