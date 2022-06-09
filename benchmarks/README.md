This is the README file for benchmarking ModelArray.

# Run memory benchmarking
## setup
* Linux system
* Download [WSS Tools](https://github.com/brendangregg/wss)

## scripts
* Core script for memory profiling: [myMemoryProfiler.sh](myMemoryProfiler.sh)
    * This is to profile memory usage of a process and its child(ren)
    * This uses [WSS Tools](https://github.com/brendangregg/wss)
* The R script used for memory profiling ModelArray:
    * [memoryProfiling_ModelArray.lm.R](memoryProfiling_ModelArray.lm.R)
    * this requires a ModelArray commit SHA in [config.txt](config.txt)
* Directly use the scripts to run memory profiling: 
    * [run_wrapper_benchmark_ModelArray.lm.sh](run_wrapper_benchmark_ModelArray.lm.sh)
    * [run_wrapper_benchmark_fixelcfestats.sh](run_wrapper_benchmark_fixelcfestats.sh)
* which calls:
    * [wrapper_benchmark_ModelArray.lm.sh](wrapper_benchmark_ModelArray.lm.sh)
    * [wrapper_benchmark_fixelcfestats.sh](wrapper_benchmark_fixelcfestats.sh)
* which calls:
    * [benchmark_ModelArray.lm.sh](benchmark_ModelArray.lm.sh)
    * [benchmark_fixelcfestats.sh](benchmark_fixelcfestats.sh)


# Analyze memory benchmarking results and make plots
## setup
* After memory profilings are done, fill out csv files benchmarks_memory_foldernames_*.csv

## scripts
* Directly knit this .Rmd file to generate plots: [figures_memoryProfiling.Rmd](figures_memoryProfiling.Rmd)
    * which calls [memoryProfiling_plot.R](memoryProfiling_plot.R), which provides functions for retrieving max total memory
    * after knitting, it will generate figures and .html