# This R script include functions for reading results from time profiling and returning useful data

#' return the time used recorded by tictoc
#' 
#' TODO: 1) check ModelArray has done (via output.txt)
#' 
#' @param folder The character of the folder that includes the time profiling results
#' @param tictoc_name The character for recording time using tictoc. Example: "Running ModelArray.lm()"
#' @return the time reported by tictoc, in seconds
#' @importFrom stringr str_match
time_used <- function(folder, tictoc_name = "Running ModelArray.lm()") {
  fn.Routput <- paste0(folder, "/Routput.txt")
  fn.output <- paste0(folder, "/output.txt")
  
  Routput <- readLines(fn.Routput)
  
  
  # e.g., "Running ModelArray.lm(): 0.32 sec elapsed"
  tempstr <- paste0(tictoc_name, ": ")
  oneline <- Routput[intersect(grep(tictoc_name, Routput, fixed=TRUE),
                               grep("sec elapsed", Routput, fixed=TRUE))]
  time_used <- as.numeric(stringr::str_match(oneline, ": \\s*(.*?)\\s* sec ")[2])
  
  if (is.na(time_used)) {   # did not finish the one we wanted to profile
    stop(paste0("this time profiling did not finish (did not have tictoc time yet): ", folder))
  }
  
  return(time_used)
}

valid_foldername_timeProfiling <- function(foldername, MAsha, nsubj, ncores, nfixels) {
  
  
  # TODO: expect "noMemProfiling" is in the foldername:
  
}

#' @param fn.csv filename of csv file of time profiling foldernames
#' @param main.folder The path to the folder where the profiling results locate
#' @return a table of time usage, corresponding to the table in the input csv file
#' @importFrom dplyr %>%
#' @importFrom stringr str_remove
table_timeResults <- function(fn.csv, main.folder) {
  csv <- read.csv(fn.csv)
  
  # TODO: check if there is repeated foldernames
  
  
  t <- matrix(ncol = ncol(csv),
              nrow = nrow(csv)) %>% data.frame()
  
  colnames(t) <- colnames(csv)
  # now, rows are repeats, columns are num of subjects

  # extract nsubj numbers:
  list.nsubj <- stringr::str_remove(colnames(t), "nsubj") %>% as.integer()

  for (i_subj in 1:length(list.nsubj)) {
    for (i_repeat in 1:nrow(t)) {
      folder <- file.path(main.folder, 
                          csv[i_repeat, i_subj])
      t[i_repeat, i_subj] <- time_used(folder)
      
    }
  }
  
  return(t)
}