" This script is to analyze the fixel cluster of significance.
Steps:
  // python file = ModelArray_paper/notebooks/analyze_signi_cluster.py
0. Preparation: 
0.1. Convert results from .h5 to .mif
0.2. View in mrview, set a threshold, then draw an ROI as mask, save it;
  
1. [python]: function: convert_voxelMask_to_fixelIndex()
  This will generate the list of fixel's ids that included in manually drawn mask (ROI.mif)
  
2. [R] All significant fixels: the list 
    - load in the .h5 file (with output such as p.value after bonferroni correction)
    - threshold, get the list of all significant fixels
3. [R] take the intersect of 1 and 2; save it.

4. [python]: function: save_selectedFixel_mask()
  This is to verify that the intersect list we saved is visually correct. 
  The function will save a 'mask' of intersected fixels we just saved.
  You should visually verify it in mrview. See instructions at the end of the function.
  
5. [R] Analyze the intersect


"



rm(list=ls())
# set up
library("dplyr")  # for %>%
library("mgcv")
library("broom")
library("testthat")
library("gratia")
library("ggplot2")
library("devtools")
library("patchwork")

# install ModelArray package:

#ModelArray_commitSHA = "9e735b93f2d6b756f8ef18aadc14e2d10c6cc191" # +++++++++++++++
ModelArray_commitSHA = "0911c4ffbcc737ea9a615f7a663f57bb0b4e174d"   # ++++++++++++++++=

devtools::install_github(paste0("PennLINC/ModelArray@", ModelArray_commitSHA),   # install_github("username/repository@commitSHA")
                         upgrade = "never",  # not to upgrade package dependencies
                         force=TRUE)   # force re-install ModelArray again
library(ModelArray)

source("notebooks/GAMM_plotting.R")   # Bart Larsen's function for visualizing gam results
source("notebooks/utils.R")   # source partialRsq()

step2_thresholding <- function(fn.h5.results, scalar_name, analysis_name, stat_name_thr, thr, flag_compare, folder.h5.results,
                               results_matrix,
                               flag_run_step2) {
  fn.fixel_id_list_thr <- paste0(folder.h5.results, "/", analysis_name, "_", stat_name_thr, "_",
                                 flag_compare, "_", toString(thr),
                                 "_fixelIdList.txt")
  
  if (flag_run_step2 == TRUE) {
    # after thresholding, the fixel_id list:
    if (flag_compare == "gt") {
      fixel_id_list_thr <- results_matrix[(results_matrix[,stat_name_thr] > thr), "element_id"]  
    } else if (flag_compare == "lt") {
      fixel_id_list_thr <- results_matrix[(results_matrix[,stat_name_thr] < thr), "element_id"]  
    } else {
      stop("invalid flag_compare!")
    }
    
    message(paste0("found ", toString(length(fixel_id_list_thr)), " fixels after thresholding"))   # number of fixels  
    
    # save the list of fixel_id that reaches the threshold
    write.table(fixel_id_list_thr, fn.fixel_id_list_thr, row.names=FALSE, col.names=FALSE, quote = FALSE)
  } 
  
  return(fn.fixel_id_list_thr)
}

step3_intersect <- function(folder.h5.results, 
                           filename.fixelIdListMask, fn.fixel_id_list_thr,
                           flag_flipFixel_roi, flag_flipFixel_signi, num_fixel_total,
                           flag_run_step3){
  # filename for saving the list of fixel ids of the intersection:
  fn.fixel_id_list_intersect <- gsub("_fixelIdList.txt",
                                     paste0("__Intersect__", filename.fixelIdListMask),
                                     fn.fixel_id_list_thr)
  
  if (flag_run_step3 == TRUE) {
    # load: list of fixels' ids after thresholding (without manually drawn mask)
    fixel_id_list_thr <- scan(fn.fixel_id_list_thr, what="", sep="\n") %>% as.integer()
    if (flag_flipFixel_signi == TRUE) {
      fixel_id_list_thr <- num_fixel_total - 1 - fixel_id_list_thr  # "-1": because the fixel id starts from 0
    }
    
    # load: list of fixels' ids within manually drawn mask:
    fn.fixelIdListMask <- file.path(folder.h5.results, filename.fixelIdListMask)
    fixel_id_list_mask <- scan(fn.fixelIdListMask, what = "", sep = "\n") %>% as.integer()
    if (flag_flipFixel_roi == TRUE) {
      fixel_id_list_mask <- num_fixel_total - 1 - fixel_id_list_mask  # "-1": because the fixel id starts from 0
    }
    
    # get the intersection:
    
    fixel_id_list_intersect <- intersect(fixel_id_list_thr, fixel_id_list_mask)
    length(fixel_id_list_intersect)
    
    # save the intersection:
    
    if (fn.fixel_id_list_intersect == fn.fixel_id_list_thr) {
      stop("The filename for fixel intersection is not correct and will overwrite another file!")
    }
    write.table(fixel_id_list_intersect, fn.fixel_id_list_intersect, row.names=FALSE, col.names=FALSE, quote = FALSE)
  } 
  
  return(fn.fixel_id_list_intersect)
}
  
  
### inputs: #####
num.subj <- 938
fn.h5.results <- paste0("/home/chenying/Desktop/fixel_project/data/data_from_josiane/results/ltn_FDC_n",toString(num.subj),"_wResults_nfixels-0_20220109-183909.h5")
fn_csv <- paste0("../data/data_from_josiane/df_example_n", toString(num.subj), ".csv")
scalar_name <- c("FDC")

analysis_name <- "gam_allOutputs"

# stat_name_thr <- "s_Age.p.value.bonferroni"   # the stat name for thresholding
# flag_compare <- "lt"
# thr <- 1e-20

stat_name_thr <- "s_Age.p.value"  # the stat name for thresholding
flag_compare <- "lt"
thr <- 1e-15

# stat_name_thr <- "s_Age.eff.size"
# flag_compare <- "gt"
# thr <- 0.2

## step 2: 
flag_run_step2 <- FALSE   # run once is enough; independent from python's output

flag_flipFixel_roi <- TRUE
flag_flipFixel_signi <- FALSE

## step 3:
flag_run_step3 <- FALSE
# filename.fixelIdListMask <- "ROI_x65_sage_p_bonfer_lt_1e-20_fixelIdList.txt"  # for step 3
filename.fixelIdListMask <- "ROI_x69_sage_p_lt_1e-15_fixelIdList.txt"  # for step 3

## step 5:
stat_toPlot <- "s_Age.eff.size"
formula <- FDC ~ s(Age, k=4, fx=TRUE) + sex + dti64MeanRelRMS
method.gam.refit <- "REML"   # +++++++++++++++
main.folder.figures <- "/home/chenying/Desktop/fixel_project/ModelArray_paper/figures"

### load data #####
folder.h5.results <- gsub(".h5", "", fn.h5.results, fixed=TRUE)
modelarray <- ModelArray(fn.h5.results, scalar_types = scalar_name, analysis_names = analysis_name)
num_fixel_total <- numElementsTotal(modelarray, scalar_name = "FDC")
if (num.subj != modelarray@sources[[scalar_name]] %>% length()) {
  stop("number of subjects in modelarray is not equal to requested one!")  # this is probably not necessary after adding sanity check of source file in .h5 and .csv
}
results_matrix <- modelarray@results[[analysis_name]]$results_matrix 
# colnames(modelarray@results$gam_allOutputs$results_matrix )

phenotypes <- read.csv(fn_csv)
# check # subjects matches:
if (nrow(phenotypes) != num.subj) {
  stop(paste0("number of subjects in .csv = ", toString(nrow(phenotypes)), ", is not equal to entered number = ", toString(num.subj)))
}

### Step 2: Thresholding #####

fn.fixel_id_list_thr <- step2_thresholding(fn.h5.results, scalar_name, analysis_name, stat_name_thr, thr, flag_compare, folder.h5.results, 
                     results_matrix, flag_run = flag_run_step2)



### Step 3: get intersection #####
fn.fixel_id_list_intersect <- step3_intersect(folder.h5.results, 
                           filename.fixelIdListMask, fn.fixel_id_list_thr,
                           flag_flipFixel_roi, flag_flipFixel_signi, num_fixel_total,
                           flag_run_step3)

### Step 4: Please verify selected fixel ids! See python file. #####

### Step 5: Average and plot #####
# load the final list:
fixel_id_list_intersect <- scan(fn.fixel_id_list_intersect, what="", sep="\n") %>% as.integer()

# avg
scalar_matrix <- scalars(modelarray)[[scalar_name]]
if (nrow(scalar_matrix) != num_fixel_total) {
  stop("scalar_matrix does not contain full list of fixels!")
}
matrix_selected <- scalar_matrix[fixel_id_list_intersect+1, ]    # # of selected fixels x # of subjects | !! fixel_id starts from 0 so need to +1 !!!


# double check they are the "selected" fixels: meeting the criteria when selecting
dat_selectedFixels_metric <- data.frame(fixel_id = fixel_id_list_intersect,
                                        selecting_metric = numeric(length(fixel_id_list_intersect)),
                                        s_Age_p.value = numeric(length(fixel_id_list_intersect)))   # all zeros
for (i_fixel_selected in 1:length(fixel_id_list_intersect)) {
  # re-fit:
  fixel_id <- fixel_id_list_intersect[i_fixel_selected]
  
  values <- scalars(modelarray)[[scalar_name]][(fixel_id + 1),]    # fixel_id starts from 0
  
  dat <- phenotypes
  dat[[scalar_name]] <- values
  
  onemodel <- mgcv::gam(formula = formula, data = dat,
                        method = method.gam.refit)
  onemodel.tidy.smoothTerms <- onemodel %>% broom::tidy(parametric = FALSE)
  onemodel.tidy.parametricTerms <- onemodel %>% broom::tidy(parametric = TRUE)
  onemodel.glance <- onemodel %>% broom::glance()
  onemodel.summary <- onemodel %>% summary()
  
  temp <- results_matrix[fixel_id + 1, stat_name_thr]   # fixel_id starts from 0
  dat_selectedFixels_metric[i_fixel_selected, "selecting_metric"] <- temp   # from results_matrix
  
  dat_selectedFixels_metric[i_fixel_selected, "s_Age_p.value"] <- onemodel.tidy.smoothTerms$p.value
}


print("max p.value after bonferroni:")
dat_selectedFixels_metric$s_Age_p.value %>% max() * num_fixel_total
if (flag_compare == "lt") {
  expect_true(max(dat_selectedFixels_metric$selecting_metric) < thr)
} else if (flag_compare == "gt") {
  expect_true(min(dat_selectedFixels_metric$selecting_metric) > thr)
}
  
# # if selecting_metric == s_Age.p.value.bonferroni
# testthat::expect_equal(dat_selectedFixels_metric$s_Age_p.value * num_fixel_total,
#                        dat_selectedFixels_metric$selecting_metric)   


### take the average within the cluster (selected fixels) ########
# # averaged across fixels x # of subjects:
#avgFixel_subj = list of number of subjects
# then loop across subjects (columns), get the avg 

avgFixel_subj <- numeric(num.subj)
for (i_subj in 1:num.subj) {
  # take the average:
  avgFixel_subj[i_subj] <- mean(matrix_selected[,i_subj])
}
df_avgFixel <- phenotypes
df_avgFixel[[scalar_name]] <- avgFixel_subj

### plot ######

#' @param fixel_id starting from 0!
plot_oneFixel <- function(modelarray, fixel_id, scalar_name,
                          formula, method.gam.refit,
                          phenotypes, dat = NULL,
                          return_else = FALSE) {
  if (is.null(dat)) {
    values <- scalars(modelarray)[[scalar_name]][(fixel_id + 1),]    # fixel_id starts from 0
    
    dat <- phenotypes
    dat[[scalar_name]] <- values
    
  } else {
    # directly using dat
    
  }
  
  onemodel <- mgcv::gam(formula = formula, data = dat,
                        method = method.gam.refit)
  
  
  #f <- vis.gam(onemodel)
    
  f <- visualize_model(onemodel, smooth_var = 'Age')
  
  ## below: tried but there is an offset in y (Bart: y is centered at 0)
  #f <- gratia::draw(onemodel, select = "s(Age)", residuals=TRUE, rug = FALSE)   # rug is at the bottom - for displaying the data density on x-axis
  #f + theme_classic()
  
  if (return_else == FALSE) {
    return(f)
  } else {
    results = list(f = f,
                   onemodel = onemodel)
    return(results)
  }
  
  
}

# plot one fixel:
# f_1 <- plot_oneFixel(modelarray, fixel_id_list_intersect[1], scalar_name, 
#                      formula = formula, method.gam.refit = method.gam.refit, phenotypes = phenotypes)
# f_last <- plot_oneFixel(modelarray, fixel_id_list_intersect[length(fixel_id_list_intersect)], scalar_name, 
#                         formula = formula, method.gam.refit = method.gam.refit, phenotypes = phenotypes)

results <- plot_oneFixel(modelarray=NULL, NULL, scalar_name, 
                         formula = formula, method.gam.refit = method.gam.refit, 
                         phenotypes = phenotypes, dat=df_avgFixel, return_else = TRUE)
f_avgFixel_orig <- results$f
onemodel_avgFixel <- results$onemodel

onemodel_avgFixel.summary <- summary(onemodel_avgFixel)
onemodel_avgFixel.smoothTerm <- broom::tidy(onemodel_avgFixel, parametric=FALSE)
onemodel_avgFixel.parametricTerm <- broom::tidy(onemodel_avgFixel, parametric=TRUE) 
onemodel_avgFixel.model <- broom::glance(onemodel_avgFixel)

red.formula <- formula(drop.terms(terms(formula, keep.order = TRUE), 
                                  c(1), keep.response = TRUE))   # drop the first term, i.e. smooth of age
# redmodel_avgFixel <- mgcv::gam(formula=red.formula, data = df_avgFixel,
#                                method = method.gam.refit)  # same as below
results_red <- plot_oneFixel(modelarray=NULL, NULL, scalar_name, 
                             formula = red.formula, method.gam.refit = method.gam.refit, 
                             phenotypes = phenotypes, dat=onemodel_avgFixel$model, return_else = TRUE)  # now using the used data in full model, to be consistent | previous: dat=df_avgFixel
redmodel_avgFixel <- results_red$onemodel
  
redmodel_avgFixel.summary <- summary(redmodel_avgFixel)
eff.size.avgFixel <- onemodel_avgFixel.summary$r.sq - redmodel_avgFixel.summary$r.sq  

s_Age.p.value_avgFixel <- onemodel_avgFixel.smoothTerm[onemodel_avgFixel.smoothTerm$term=="s(Age)","p.value"]

onemodel_avgFixel.summary
print(paste0("s(Age)'s p.value of re-fit after avg in this cluster = ", toString(s_Age.p.value_avgFixel)))  # if =0, it means <1e-16
print(paste0("s(Age)'s effect size of re-fit after avg in this cluster = ", sprintf("%.3f",eff.size.avgFixel)))  

# ### get the partial R2:
# temp <- partialRsq(onemodel_avgFixel, redmodel_avgFixel)
# partial.rsq.avgFixel <- temp$partialRsq
# print(paste0("s(Age)'s partial R2 of re-fit after avg in this cluster = ", sprintf("%.3f",partial.rsq.avgFixel)))  

# and add to the plot!
# x = 12; y = 1.65
x = 18; y = 0.55; fontsize_text <- 5; fontsize_theme <- 9  # p.value + delta adj Rsq
#x = 20; y = 0.6  # p.value + delta adj Rsq + partial Rsq
if (s_Age.p.value_avgFixel < 0.001) {
  txt.s_Age.p.value_avgFixel = "s(Age)'s p.value < 0.001"
} else {
  txt.s_Age.p.value_avgFixel = paste0("s(Age)'s p.value = ", sprintf("%.3f",s_Age.p.value_avgFixel))
}

label_text <-  paste0(txt.s_Age.p.value_avgFixel, "\n",
                      "s(Age)'s delta adj Rsq = ", sprintf("%.3f",eff.size.avgFixel) )      #  ,"\n",
  #"s(Age)'s partial Rsq = ", sprintf("%.3f",partial.rsq.avgFixel))) 

f_avgFixel <- f_avgFixel_orig + 
  # geom_text(x=x, y=y, size = fontsize_text, family = "Arial", label=label_text) + 
                  theme_classic() +
                  theme(text = element_text(size = fontsize_theme, family="Arial")) +
                  xlab("Age (years)")
                              

p_avgFixel <- f_avgFixel + plot_layout(heights = unit(c(70), c('mm')), widths = unit(c(70), c('mm'))) 
p_avgFixel

### save the figure:
final_width <- 90
final_height <- 85

list_ext_figure <- c("jpeg", "svg")
for (ext_figure in list_ext_figure) {
  ggsave(file.path(main.folder.figures,
                   paste0("figure_gam_showcase_panelB.", ext_figure) ),
         plot = p_avgFixel, device = ext_figure, dpi = 300, width = final_width, height = final_height, units = "mm")   # 
}

### save the figure - for graphic abstract:
f_avgFixel_abs <- f_avgFixel_orig + 
                    # geom_text(x=x, y=y, size = fontsize_text, family = "Arial", label=label_text) + 
                    theme_classic() +
                    theme(text = element_text(size = 15, family="Arial")) +
                    xlab("Age (years)")
p_avgFixel_abs <- f_avgFixel_abs + plot_layout(heights = unit(c(70), c('mm')), widths = unit(c(70), c('mm'))) 
p_avgFixel_abs
final_width <- 90
final_height <- 85
for (ext_figure in list_ext_figure) {
  ggsave(file.path(main.folder.figures,
                   paste0("figure_gam_showcase_abs.", ext_figure) ),
         plot = p_avgFixel_abs, device = ext_figure, dpi = 300, width = final_width, height = final_height, units = "mm")   # 
}
# NOTE: as there is more sex=2 than sex=1, and sex is numeric, so the median(df[,sex]) = 2, the gam curve is fitted upon sex=2, i.e. female (2)
# TODO: check how many fixels' model: sex is significant

