# Created by: Shang Xiang
# Created on: 23/02/2020

library(dplyr)
library(questionr)
library(ggplot2)
library(effsize)
library(xtable)

getCleanBenchmark <- function () {
  df <- read.csv('Results/benchmark.csv', stringsAsFactors = FALSE)
  df <- addExceptionType(df)

  return(df)
}

addExceptionType <- function(df) {
  df$exception_type[df$exception_class=='ArrayIndexOutOfBoundsException'] <- "indexed_access"
  df$exception_type[df$exception_class=='StringIndexOutOfBoundsException'] <- "indexed_access"
  df$exception_type[df$exception_class=='IllegalArgumentException'] <- "branching_variable"
  df$exception_type[df$exception_class=='IllegalStateException'] <- "branching_variable"
  return(df)
}

getBenchmarkStatistics <- function (df, type) {
  allCases <- df[df$exception_type==type,] %>%
    group_by(case) %>%
    summarise(
      application = max(application),
      avg_ccn = max (avg_ccn),
      application_ncss = max(application_ncss),
      frm = n()
    )
  statistics <- allCases %>%
    group_by(application) %>%
    summarise(
      Cr = n(),
      frm_avg = mean(frm),
      ccn_avg = mean(avg_ccn),
      ncss_avg= mean(application_ncss)
    )
  total <- allCases %>%
    summarise(
    application = 'Total',
    Cr = n(),
    frm_avg = mean(frm),
    ccn_avg = mean(avg_ccn),
    ncss_avg = mean(application_ncss)
    )

  return(rbind(statistics, total))
}

printBenchmarkStatisticTable <- function() {
  benchmark <- getCleanBenchmark()
  IA <- getBenchmarkStatistics(benchmark, 'indexed_access')
  BV <- getBenchmarkStatistics(benchmark, 'branching_variable')
  print(
    xtable(
      IA,
      align = c('l','l','r','r','r','r'),
      digits = c(0, 0, 0, 2, 2, 0),
      display = c('s','s','d','f','f','d')
    ),
    type='latex',
    file ='statistics IA vs IA-control.tex'
  )
  print(
    xtable(
      BV,
      align = c('l','l','r','r','r','r'),
      digits = c(0, 0, 0, 2, 2, 0),
      display = c('s','s','d','f','f','d')
    ),
    type='latex',
    file ='statistics BV vs BV-control.tex'
  )
}
