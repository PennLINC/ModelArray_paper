
# HOW TO RUN:
# in bash, same folder as this current file:
# $ Rscript ./memoryProfiling_ModelArray.gam.R  > xxx.txt 2>&1 &
# or, using "call_showCase_ModelArray.gam.sh"

# set ups
rm(list = ls())


library(tictoc)
tic.clearlog()
tic("R running")

tic("time before ModelArray.gam()")


### input arguments #####
#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

flag_whichdataset <- args[1]   # "test_n50" or "josiane"
num.fixels <- as.integer(args[2])  # if ==0, set as full set
num.subj <- as.integer(args[3])  
num.cores <- as.integer(args[4])
filename_output_body <- as.character(args[5])  # output filename (without extension)
commitSHA <- as.character(args[6])   # github commit SHA for installing ModelArray
which_model <- as.character(args[7])   # "lm" or "gam"
folder.main <- as.character(args[8])    # the main folder

flag_library_what <- "automatically"   # "automatically" or "manually"

# checkers:
message(paste0("which dataset: ", flag_whichdataset))
message(paste0("number of fixels = ", toString(num.fixels)))
message(paste0("number of subjects = ", toString(num.subj)))
message(paste0("number of cores = ", toString(num.cores)))
message(paste0("output filename: ", filename_output_body))
message(paste0("ModelArray commitSHA = ", commitSHA))

message(".libPaths():")
.libPaths()   # expect: a folder in conda env

## print ModelArray_paper's commitSHA:
cmd <- "git rev-parse HEAD"
message("ModelArray_paper commit SHA ($ git rev-parse HEAD): ")
system(cmd)

## install ModelArray:

if (flag_library_what == "automatically") {
  message("Please make sure that github repository 'ModelArray' has been updated: local files have been pushed! And commitSHA is up-to-date!")
  message("run: devtools::install_github() to install ModelArray package")
  library(devtools)
  message(paste0("commitSHA: ", commitSHA))
  
  devtools::install_github(paste0("PennLINC/ModelArray@", commitSHA),   # install_github("username/repository@commitSHA")
                           upgrade = "never",   # not to upgrade package dependencies
                           force=FALSE)   # force re-install ModelArray again or not
  library(ModelArray)
  
} else if (flag_library_what == "manually") {
  
  message("run: source several R scripts and library some R packages...")
  
  source("../R/ModelArray_Constructor.R")
  source("../R/ModelArray_S4Methods.R")
  source("../R/utils.R")
  source("../R/analyse.R")
  # library(ModelArray)
  suppressMessages(library(dplyr))
  library(broom)
  library(hdf5r)
  library(tictoc)
  library(mgcv)
  # library(lineprof)
  # library(profvis)
  # library(peakRAM)
  suppressMessages(library(doParallel))
}

# save the config in R:
message("sessionInfo() as below:")
sessionInfo()  # including R versoin, attached packages version
message(" ")

# flag_whichdataset <- "josiane"   # "test_n50" or "josiane"
# num.subj <- 938  # [integer]   
# num.fixels <- 0  # 0 = full 
# flag_which_subset <- ""

flag_where <- "vmware"   # "CUBIC" or "vmware"


#####
now_str <- format(Sys.time(), "%Y%m%d-%H%M%S")

if (flag_whichdataset == "test_n50") {
  fn <- "../inst/extdata/n50_fixels.h5"
  
  if (flag_where == "CUBIC") {
    fn.output <- "../../dropbox/data_forCircleCI_n50/n50_fixels_output.h5"
  } else if (flag_where == "vmware") {
    fn.output <- "/home/chenying/Desktop/fixel_project/data/data_forCircleCI_n50/n50_fixels_output.h5"  
    # absoluate path: "/home/chenying/Desktop/fixel_project/data/data_forCircleCI_n50/n50_fixels_output.h5";  
    # relative path: "../../data/data_forCircleCI_n50/n50_fixels_output.h5"
  }
  
  fn_csv <- "../inst/extdata/n50_cohort.csv"
  
  scalar = c("FD")
  
} else if (flag_whichdataset == "josiane") {
  if (flag_where == "vmware") {
    fn <- paste0(folder.main, "/demo_FDC_n", toString(num.subj), ".h5")
    fn.output <- file.path(folder.main,
                           paste0(filename_output_body,".h5"))
    fn_csv <- paste0(folder.main, "/cohort_FDC_n", toString(num.subj), ".csv")
    
  }
  
  scalar <- c("FDC")
}


# generate fn.output:
if (fn != fn.output) {
  file.copy(from=fn, to=fn.output, overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE)   # , recursive = TRUE
}

# h5closeAll()

tic("Running ModelArray()")
modelarray <- ModelArray(fn.output, scalar_types = scalar)
toc(log=TRUE)   # pairing tic("Running ModelArray()")

#modelarray
#scalars(modelarray)[[scalar]]

#####
# check # subjects matches:
if (dim(scalars(modelarray)[[scalar]])[2] != num.subj) {
  stop(paste0("number of subjects in .h5 = ", dim(scalars(modelarray)[[scalar]])[2], ", is not equal to entered number = ", toString(num.subj)))
}  

phenotypes <- read.csv(fn_csv)
# check # subjects matches:
if (nrow(phenotypes) != num.subj) {
  stop(paste0("number of subjects in .csv = ", toString(nrow(phenotypes)), ", is not equal to entered number = ", toString(num.subj)))
}

# formula and other arguments:
if (flag_whichdataset == "test_n50") {
  formula <- FD ~ s(age, k=4, fx=TRUE) + s(factorA)      
  
} else if (flag_whichdataset == "josiane") {
  
  if (which_model == "lm") {
    formula <- FDC ~ Age + sex + dti64MeanRelRMS
    flag.full.outputs <- FALSE
    analysis_name <- "results_lm"
    
  } else if (which_model == "gam") {
    formula <- FDC ~ s(Age, k=4, fx = TRUE) + sex + dti64MeanRelRMS  # added motion quantification   # FD ~ s(age, k=4) + sex  # FD ~ s(age) + sex
    gam.method = "REML"   # "GCV.Cp", "REML"  # any other methods usually used?
    flag.full.outputs <- TRUE
    analysis_name <- "results_gam_allOutputs"
    
  }

}


if (num.fixels == 0) {
  num.fixels <- dim(scalars(modelarray)[[scalar]])[1]
}
element.subset <- 1:num.fixels  

print(formula)

toc(log=TRUE)    # pairing tic of "time before ModelArray.gam()"



### running on real data #####
tic("Running ModelArray.*()")
if (which_model == "lm") {
  mymodel <- ModelArray.lm(formula, modelarray, phenotypes, scalar = scalar, element.subset = element.subset,
                              full.outputs = flag.full.outputs,  
                              n_cores = num.cores)  # , na.action="na.fail"
  
  
  
} else if (which_model == "gam") {
  mymodel <- ModelArray.gam(formula = formula, data = modelarray, phenotypes = phenotypes, scalar = scalar, 
                            element.subset = element.subset, full.outputs = flag.full.outputs,
                            changed.rsq.term.index = c(1),
                            correct.p.value.smoothTerms = c("fdr", "bonferroni"),
                            correct.p.value.parametricTerms = c("fdr", "bonferroni"),
                            n_cores=num.cores, pbar = TRUE,
                            method=gam.method)
}


toc(log = TRUE)   # pairing tic of "Running ModelArray.*()"
message("")

message("head of results data frame:")
head(mymodel)
# write:
writeResults(fn.output, df.output = mymodel, analysis_name=analysis_name, overwrite=TRUE)

# # also write to a .csv file just in case...   # this is not a good idea; this .csv will take 4KB * 602229/10 = 200+MB
# fn.output.csv <- gsub(".h5",".csv",fn.output)
# write.csv(mymodel, file = fn.output.csv, row.names = FALSE)

# read and see
modelarray_new <- ModelArray(fn.output, scalar_types = scalar, analysis_names = analysis_name)
message("after saving to .h5:")
modelarray_new@results[[analysis_name]]


toc(log=TRUE)   # pairing tic of "R running"