# 1. Introduction

This repository consists of 2 parts: __Evaluation__ and __Results__. 
* __Evaluation__ may be used to replicate the evaluation process presented in the thesis project ___Fit2Crash: Specialising Fitness Functions for Crash Reproduction___.
* __Results__ presents complete results of the project that the thesis report is based on, including information of the manual analyses performed.

# 2. Replicate the Evaluation

## 2.1 The `Evaluation` folder
- Sub-folder `bins` contains all the jar packages for the crash cases we have selected.
- Sub-folder `crashes` contains all the corresponding stack traces.  
  The above two are provided by [JCrashPack](https://github.com/STAMP-project/JCrashPack).
- Sub-folder `lib` contains the extended version of [Botsing](https://github.com/STAMP-project/Botsing) that we have used in our evaluation.
- There are other four sub-folders, `configuration-IA`, `configuration-IA-control`, `configuration-BV` and `configuration-BV-control`, each corresponds to a configuration described in the thesis report.
    For each configuration:
    + The `inputs.csv` file contains all the crashes related to that configuration with 30 repetitions.  
        Add or remove rows to adjust the number of repetitions and crashes to evaluate.
    + The `observer.sh`, `parsing.sh` and 4 scripts within the `python` sub-folder are based on [ExRunner-bash](https://github.com/STAMP-project/ExRunner-bash), which has been used to evaluate Botsing.
    + Parameters have already been setup in the `main.sh` script.
  
## 2.2 Run a Configuration
Make sure __Java 1.8__ and __Python 2.7__ are installed:
1. `cd` to the specific sub-folder  
   ``` zsh
   $ cd Evaluation/configuration-IA
   ```
2. give `main.sh` permission to access and execution  
   ``` zsh
   $ chmod +x main.sh
   ```
3. run `main.sh`
   ``` zsh
   $ ./main.sh 50 > consoleLog/consoleOut.txt 2> consoleLog/consoleErr.txt &
   ```
   As ExRunner-bash is parallelised, parameter `50` specifies to run 50 Botsing instances simultaneously.
   This can be changed according to the machine you want to run your evaluation on.
   Console output is redirected to file `consoleLog/consoleOut.txt` and error messages are redirected to `consoleLog/consoleErr.txt`

## 2.3 Outcome 
- The `logs` sub-folder contains all the console outputs of each execution of Botsing.
- The `results` sub-folder contains all the generated test cases, if there is any.
- The `results/results.csv` file contains all information about each execution, including execution index, crash case, type of exception, final fitness value, number of fitness evaluations and the evolution of fitness values.
  For configuration-BV, final number of covered goals and the evolution of number of covered goals are also included.

# 3. Evaluate the Results

Under the `Results` folder:
- Sub-folder `Output` contains the csv files of results of our evaluation, that the thesis report is based on.
- Sub-folder `Tables` contains the statistics we presented in the thesis report in csv format.
- Sub-folder `Manual Analyses` contains descriptions of the manual analyses that we have performed.
- Sub-folder `R scripts` provides functionality to compute reproduction rates, odds ratios, and VD.A measures. It also provides functions to output figures to pdf and tables to tex files.  
  To make use of the provided scripts, make sure `R 3.6`, and R packages `dplyr`, `questionr`, `ggplot2`, `effsize` and `xtable` are installed.