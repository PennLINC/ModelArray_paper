# analyze results from myMemoryProfiler.sh and plot

list.of.packages <- c("R.utils", "ggplot2", "stringr", "dplyr", "tibble")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(list.of.packages, require, character.only = TRUE)   # or library

# library(R.utils)   # for countLines
# 
# 
# library(ggplot2)
# library(stringr)
# library(dplyr)
# library(tibble)

#' Read one wss output text file
#' @description 
#' Will check if actual sampling freq (extracted from log message of 1st line of txt file) matches argument sample_sec
#' 
#' @param fn A character string, filename of the wss output text file
#' @param sample_sec Numeric, it was sampled every ___ sec
#' @return A data.frame, a table of loaded wss output text file
readWssText <- function(fn, sample_sec) {
  # check if matching with sample_sec
  fp <- file(fn, "r")
  oneline <- readLines(fp, n=1)
  close(fp)
  
  sample_sec_actual <- as.numeric(str_match(oneline, "every \\s*(.*?)\\s*second")[2])
  
  if (sample_sec != sample_sec_actual) {
    stop(paste0("the sampling frequency in this file is not ", toString(sample_sec), "!"))
  }
  
  
  # read in
  df <- tryCatch(
    {
      df <- read.table(fn, skip=1, header=TRUE)
      return(df)
    },
    error=function(cond) {
      df <- read.table(fn, skip=1, header=TRUE, 
                       nrow = R.utils::countLines(fn) -3 )
      return(df)
    }
  )
  
  df
}

#' Read wss profiling data of single parent (without any child process), e.g. wss_SingleCoreStarts_parent.txt file
#' @description 
#' Designed for MRtrix's results, including checking for the log of finishing (fixelcfestats: Outputting final results)
#' Limitations:
#' - The file name is fixed: wss_SingleCoreStarts_parent.txt
#' @folder A character string, name of the folder including 1) wss_SingleCoreStarts_parent.txt; 2) output.txt from MRtrix's fixelcfestats printed messages
#' @return A data.frame, the table of loaded wss_SingleCoreStarts_parent.txt
readWssSingleParent <- function(folder) {
  fn.parent.single <- paste0(folder, "/", "wss_SingleCoreStarts_parent.txt")
  
  sample_sec <- as.numeric(str_match(folder, "runMemProfiler.s-\\s*(.*?)\\s*sec.")[2])
  
  df.parent.single <- readWssText(fn.parent.single, sample_sec)
  
  
  # check if finished:
  fn.output.txt <- paste0(folder, "/", "output.txt")
  flag.permutation <- !grepl("notest", folder, fixed = TRUE)   # if did not find "notest" in folder name, then permutation was done
  if ( flag.permutation == TRUE ) {
    # check out if saved the output.mif after permutation:
    
    output.txt <- readLines(fn.output.txt)
    
    flag.finished <- grep("fixelcfestats: Outputting final results", 
                          output.txt, fixed = TRUE)
    
    if (length(flag.finished) == 0) {   # did not find any line
      warning("did not finish permutation...")
    }
    
    
  }
  
  
  df.parent.single
}



#' time series plot for one data.frame
#' @param df A data.frame, e.g. returned from  readWssSingleParent()
#' @param unit.time A character string, the unit of time when plotting
#' @param unit.memory A character string, the unit of computer memory when plotting
#' @param str.title A character string, the title of plot
#' @return a ggplot object
timeSeriesPlot <- function(df, unit.time = "second", unit.memory = "MB",str.title = NULL) {
  if (unit.time == "hour") {
    df$Est.h. <- df$Est.s. / 3600
    str.aes.x <- "Est.h."
  } else if (unit.time == "second") {
    str.aes.x <- "Est.s."
  }
  
  
  if (unit.memory == "GB") {
    df$RSS.GB. <-df$RSS.MB. / 1024
    str.aes.y <- "RSS.GB."
  } else if (unit.memory == "MB") {
    str.aes.y <- "RSS.MB."
  }
  
  
  f <- ggplot(df, aes_string(x = str.aes.x)) +   # [1:1000,]
    geom_line(aes_string(y = str.aes.y), color="black") +
    theme_bw()+ 
    xlab(paste0("Time (",unit.time,")")) + 
    ylab(paste0("Memory (",unit.memory,")")) + 
    ggtitle(str.title)
  
  f
  
}


#' Summarize the memory profiling from wss. Support multiple child processes.
#' @description
#' Under the hood,
#' First, it generates data.frame called `df.multi` with time at each second.
  #' For single process (one parent, no child): approx() at each second
  #' For multiple processes (one parent, several child): only use multiCoreStarts*.txt and calculate after child processes begin (i.e. ignoring single parent period, as it couldn't be higher than total of parent + child <- it checks if max of SingleCoreStarts_parent is <= beginning of MultiCoreStarts_parent):
  #'    approx() multiCoreStarts_parent and _child<i> at each second
#' Second, it generates data.frame called `when.max`  with info when the max total memory is reached
#' Finally, it generates plot of `df.multi`: total memory (and parent's memory) across time
#'
#' Limitations:
#' Currently tailors for profiling R, including checking key log messages from it.
#' Notes: assuming the configs are consistent between all wss output text files: column names are: Est(s) and RSS(MB) <- pay attention to the unit in wss.txt file; the function auto extract from parent's txt, and assuming child uses the same setup.
#' 
#' @param folder A character string, foldername for storing memory profiling results (wss*.txt) and Routput.txt (printed messages from R)
#' @param profiling.setup The expected setup when profiling: "devtools" or "source_library"
#' @param roof.num.child The maximum number of child processes expected (useful when summarizing different number of cores). The actual number of cores will be automatically detected from filename.
#' @param sample_sec Sampling every _ seconds; if the folder name includes it, please assign "NULL" or not to assign value!

summaryMemProfiling <- function(folder, profiling.setup = "devtools", roof.num.child =4, sample_sec=NULL, output_df_dim = c(602229,9)) {
    
  
  
  #!/usr/bin/env Rscript
  #args = commandArgs(trailingOnly=TRUE)
  
  #folder <- args[1] 
  
  temp <- str_match(folder, "ncore-\\s*(.*?)\\s*.")[1]
  num.cores <- as.integer(substr(temp, 7, 20))
  
  if (is.null(sample_sec)) {
    sample_sec <- as.numeric(str_match(folder, "s-\\s*(.*?)\\s*sec.")[2])
  }
  
  
  
  # CHECK IF USING DEVTOOLS::INSTALL_GITHUB() in Routput.txt
  fn.Routput <- paste0(folder, "/Routput.txt")
  
  Routput <- readLines(fn.Routput)
  temp <- grep("run: devtools::install_github() to install ModelArray package", Routput, fixed=TRUE)
  if (length(temp) == 0) {
    if (profiling.setup == "devtools") {
      stop("the profiling was not set up by devtools::install()!")
    } else if (profiling.setup == "source_library") {
      warning("the profiling was not set up by devtools::install()!")
    } else {
      stop("invalid 'profiling.setup'!")
    }
    
  } 
  
  
  # CHECK IF THE OUTPUT DIMENSION IS AS EXPECTED:   # NOTE: assumption: there is not other (same) dimension outputs....
  #tempstr <- paste0("dimension of lm.outputs:\n[1] ",toString(output_df_dim[1]),"\t",toString(output_df_dim[2]))
  tempstr <- paste0("[1] ",toString(output_df_dim[1]),"      ",toString(output_df_dim[2]))
  temp <- grep(tempstr,
               Routput, fixed = TRUE)
  if (length(temp) == 0) {
   stop("The output dataframe's dimension is not as expected, or the memory profiling was not as expected")
    
  } 
  
  
  
  # fp <- file(fn.Routput, "r")
  # flag_devtoolsInstall <- FALSE
  # while (TRUE) {    # reading one by one - if not exists, it will take a while to finish reading the whole file...
  #   oneline <- readLines(fp, n=1)
  #   
  #   if (length(oneline) == 0) {
  #     next
  #   }
  #   
  #   if (grepl("run: devtools::install() to install ModelArray package", 
  #             oneline, fixed = TRUE)) {
  #     flag_devtoolsInstall <- TRUE
  #     break
  #   }
  #   
  # }
  # close(fp)
  
  # if (flag_devtoolsInstall == FALSE) {
  #   stop("the profiling was not set up by devtools::install()")
  # }
  
  
  # check if the profiling was finished:
  temp <- intersect(grep("R running: ", Routput, fixed=TRUE),
                    grep(" sec elapsed", Routput, fixed=TRUE))
  if (length(temp) == 0) {
    stop("The profiling was not successfully done!")
  }
  
  # check if num.cores <= roof.num.child:
  if (num.cores > roof.num.child) {
    stop(paste0("num.cores = ",toString(num.cores)," > roof.num.child = ", toString(roof.num.child)))
  }
  
  
  # extract the sleep length in R:
  
  oneline <- Routput[intersect(grep("sleep", Routput, fixed=TRUE),
                  grep("sec to capture the current memory before existing", Routput, fixed=TRUE))]
  final_sleep_sec <- as.numeric(str_match(oneline, "for \\s*(.*?)\\s* sec ")[2])
  
  
  
  ### combine files #####
  fn.parent.single <- paste0(folder,"/","wss_SingleCoreStarts_parent.txt")
  df.parent.single <- readWssText(fn.parent.single, sample_sec)
  
  
  
  # NOTE: assuming the configs (following parameters) are consistent between all wss output text files...
  
  
  unit.Est <- unlist(strsplit(colnames(df.parent.single)[1], "\\."))[2]    # e.g. "s" - default of wss.pl
  unit.RSS <- unlist(strsplit(colnames(df.parent.single)[2], "\\."))[2]    # e.g. "MB" - default of wss.pl
  
  # multi = after ModelArray.lm() starts
  
  if (num.cores == 1) {
    
    max.time.parent.multi <- max(df.parent.single$Est.s.)   # in sec
    
    xout <- seq((2*sample_sec), 
                max.time.parent.multi, 
                by=sample_sec)  # >= min, <= max
    
    df.multi <- data.frame(Est.s. = xout)
    
    df.multi$parent.RSS.MB. <- approx(x = df.parent.single$Est.s.,
                                      y = df.parent.single$RSS.MB.,
                                      xout = xout)$y
    
    df.multi$total.RSS.MB. <- df.multi$parent.RSS.MB.
    
    
  } else if (num.cores >1) {
    fn.parent.multi <- paste0(folder,"/","wss_MultiCoreStarts_parent.txt")
    
    df.parent.multi <- readWssText(fn.parent.multi, sample_sec)
    df.parent.multi <- df.parent.multi[ -c(3,4)]   # only keep Est.s. and RSS.MB.
    # df.parent.multi <- df.parent.multi[ , !(names(df.parent.multi) %in% c("PSS.MB.", "Ref.MB."))] 
    
    if (unit.Est != unlist(strsplit(colnames(df.parent.single)[1], "\\."))[2] ) {
      stop("unit Est is different between parent single and parent multi!")
    }
    
    if ("s" != unlist(strsplit(colnames(df.parent.single)[1], "\\."))[2]) {
      stop("currently not supporting Est with different than second (s)...")
    }
    
    if (max(df.parent.single$RSS.MB.) > df.parent.multi$RSS.MB.[1]) {
      stop("The max value in single parent process is larger than first recorded value in parent process after child processes start!")
    }
    
    max.time.parent.multi <- max(df.parent.multi$Est.s.)   # in sec
    
    xout <- seq((2*sample_sec), 
                max.time.parent.multi, 
                by=sample_sec)  # >= min, <= max
    
    df.multi <- data.frame(Est.s. = xout)
    
    df.multi$parent.RSS.MB. <- approx(x = df.parent.multi$Est.s.,
                                      y = df.parent.multi$RSS.MB.,
                                      xout = xout)$y
    
    for (i in 0:(num.cores-1)) {
      
      fn.child.multi <- paste0(folder,"/","wss_MultiCoreStarts_child",toString(i),".txt")
      df.child.multi <- readWssText(fn.child.multi, sample_sec)
      df.child.multi <- df.child.multi[ -c(3,4)]   # only keep Est.s. and RSS.MB.
      # df.child.multi <- df.child.multi[ , !(names(df.child.multi) %in% c("PSS.MB.", "Ref.MB."))]
      
      max.time.child.multi <- max(df.child.multi$Est.s.)
      
      yout <- approx(x = df.child.multi$Est.s.,
                     y = df.child.multi$RSS.MB.,
                     xout = xout)$y   # using the same xout across parent process + child processes, to align time across all processes
      if (xout[is.na(yout)][1] <= max.time.child.multi) {
        stop(paste0("child #", toString(i), ": first NA in interpolation is before wss ends!"))
      }
      
      yout[is.na(yout)] = 0   # else, replace NAs with 0, as child already ends then
      df.multi[[paste0("child",toString(i), ".RSS.MB.")]] <- yout
    }
    
    df.multi$total.child.RSS.MB. <- df.multi %>% select(matches('child') & matches('RSS')) %>% rowSums()
    
    df.multi$total.RSS.MB. <- (df.multi$parent.RSS.MB. + df.multi %>% select(matches('total.child.RSS'))) %>% unlist()
    
    
  } else {
    stop(paste0("invalid num.cores = ", toString(num.cores)))
  }
  
  
  
  # if (num.cores > 1) {
  #   fn.parent.multi <- paste0(folder,"/","wss_MultiCoreStarts_parent.txt")
  #   
  #   df.parent.multi <- readWssText(fn.parent.multi)
  #   df.parent.multi <- df.parent.multi[ -c(3,4)]   # only keep Est.s. and RSS.MB.
  #   # df.parent.multi <- df.parent.multi[ , !(names(df.parent.multi) %in% c("PSS.MB.", "Ref.MB."))]   
  #   nrow.df.parent.multi <- nrow(df.parent.multi)
  #   df.multi <- df.parent.multi
  #   colnames(df.multi) <- paste("parent.", colnames(df.multi), sep="")
  #   nrow.df.multi <- nrow(df.multi)
  #     
  #   for (i in 0:(num.cores-1)) {
  #     fn.child.multi <- paste0(folder,"/","wss_MultiCoreStarts_child",toString(i),".txt")
  #     df.child.multi <- readWssText(fn.child.multi)
  #     df.child.multi <- df.child.multi[ -c(3,4)]   # only keep Est.s. and RSS.MB.
  #     # df.child.multi <- df.child.multi[ , !(names(df.child.multi) %in% c("PSS.MB.", "Ref.MB."))]
  #     
  #     nrow.df.child.multi <- nrow(df.child.multi)
  #     
  #     nrow.diff <- nrow.df.parent.multi - nrow.df.child.multi
  #     df.toadd <- data.frame(Est.s. = rep(0, nrow.diff),
  #                            RSS.MB. = rep(0, nrow.diff))
  #     
  #     df.child.multi <- tibble::add_row(df.child.multi, df.toadd)
  #     
  #     colnames(df.child.multi) <- paste("child",toString(i), ".",colnames(df.child.multi), sep="")
  #     
  #     # check the differences in time stamp: (assuming the start time of wss is almost the same)
  #     max.diff.Est <- max(abs(df.parent.multi[1:(nrow.df.multi-nrow.diff),1] - df.child.multi[1:(nrow.df.multi-nrow.diff),1]))
  #     message("max difference in ", colnames(df.parent.multi)[1], " between parent and child #",toString(i)," = " , 
  #             toString(max.diff.Est))
  #     if ((unit.Est == "s") && (max.diff.Est >1)) {
  #       stop("this is bigger than 1 sec!")
  #     }
  # 
  #     # add to df.multi:
  #     df.multi <- cbind(df.multi, df.child.multi)
  #     
  #     
  #   }
  #   
  #   df.multi[[paste0("total.child.RSS.",unit.RSS,".")]] <- df.multi %>% select(matches('child') & matches('RSS')) %>% rowSums()
  #   
  #   df.multi[[paste0("total.RSS.",unit.RSS,".")]] <- (df.multi[[paste0("parent.RSS.",unit.RSS,".")]] + df.multi %>% select(matches('total.child.RSS'))) %>% unlist()
  #   
  #   
  # } else {  # num.cores == 1
  #   
  # }
  
  
  
  ### print necessary values ######
  
  #tail(df.multi, 100)
  #max(df.multi$total.RSS.MB.)
  which_max <- which.max(df.multi$total.RSS.MB.)
  
  when.max <- df.multi[which_max,]
  
  if (num.cores == 1) {
    
    if (max.time.parent.multi - df.multi$Est.s.[which_max] > final_sleep_sec) {   # all in sec
      warning("the maximum of total RSS of this num.cores=1 profiling did not happen at the end!")
    } 
    
    #tail(df.multi)
    
    
  } else if (num.cores>1) {
    #df.multi[(which_max-50):(which_max+50),]
    
  }
  
  
  
  
  if (num.cores < roof.num.child) {  # add additional columns with 0
    if (num.cores == 1) {
      
      for (i in seq(0, roof.num.child-1, by=1)) {
        when.max[[paste0("child", toString(i), ".RSS.MB.")]] <- 0
      }
      
      when.max$total.child.RSS.MB. <- 0
      
    } else if (num.cores > 1) {
      
      for (i in seq(num.cores, roof.num.child-1, by=1)) {
        when.max[[paste0("child", toString(i), ".RSS.MB.")]] <- 0
      }
      
    }
    
    
    
  }
  
  
  #df.multi[(which_max-50):(which_max+50),]
  
  
  
  ### plot #####
  if (num.cores ==1) {
    
    f <- ggplot(df.multi, aes_string(x = paste0("Est.",unit.Est,"."))) + 
      geom_line(aes_string(y = paste0("parent.RSS.",unit.RSS,".")), color="gray") +
      geom_line(aes_string(y = paste0("total.RSS.",unit.RSS,".")), color="darkred")
    
  } else if (num.cores > 1) {
    f <- ggplot(df.multi, aes_string(x = paste0("Est.",unit.Est,"."))) + 
      geom_line(aes_string(y = paste0("parent.RSS.",unit.RSS,".")), color="gray") +
      geom_line(aes_string(y = paste0("total.child.RSS.",unit.RSS,".")), color="darkgreen") +
      geom_line(aes_string(y = paste0("total.RSS.",unit.RSS,".")), color="darkred")
    
  }
  
   
  
  
  
  
  ### for memrec #####
  
  
  # step 1: change memroyProfiling_ModelArray.lm.R; 
  # step 2: run in terminal: memory profiling of CUBIC
  
  # which_dataset <- "test_n50"
  # nfixel <- 1000
  # ncore <- 4
  # mem.unit <- "MB"
  # sample.interval <- 0.01
  
  # folder_memoryProfiling = "/root/ModelArray/notebooks"
  # filename_memoryProfiling <- paste0("memprofile.lm.",which_dataset, 
  #                                    ".nfixel=",toString(nfixel),
  #                                    ".ncore=",toString(ncore),
  #                                    ".in",mem.unit,
  #                                    ".every",toString(sample.interval), "sec")   # "memprofile.lm.test_n50.nfixel=1000.ncore=4.inKB.every0.01sec"
  # fn_memoryProfiling <- paste0(folder_memoryProfiling, "/", filename_memoryProfiling)
  # 
  # df <- read.table(fn_memoryProfiling, header = FALSE)
  # df
  # print(paste0("max ChildMemory = ", toString(max(df$V3))))
  # print(paste0("max ProcessMemory = ", toString(max(df$V2))))
  # print(paste0("max ProcessMemory + ChildMemory = ", toString(max(df$V3) + max(df$V2)  )))
  
  # ggplot(df, aes(x=V1, y=V3)) +
  #   geom_line() + 
  #   ggtitle(paste0("memory usage: dataset "), which_dataset) +
  #   xlab("time (sec)") + 
  #   ylab(mem.unit)
  
  
  toreturn = list(when.max = when.max,
                  df.multi = df.multi,
                  f = f)
  
  return(toreturn)


}  #  entire file