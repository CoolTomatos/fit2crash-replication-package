# Created by: Shang Xiang
# Created on: 23/02/2020

source('Results/R scripts/csvFileProcessing.R')

printOddsRatioTable <- function(results) {
  forFrame <- getOddsRatioReproductionForFrame(results)
  forCase  <- getOddsRatioReproductionForCase(results)

  print(xtable(forFrame,
               align  = c('l', 'l', 'l', 'l', 'r', 'r', 'r', 'r'),
               digits = c(0, 0, 0, 0, 0, 0, 4, 5)),
        type = 'latex',
        file = 'or-frame.tex'
  )

  print(xtable(forCase,
               align  = c('l', 'l', 'c', 'l', 'l', 'r', 'r', 'r', 'r'),
               digits = c(0, 0, 0, 0, 0, 0, 0, 4, 5)),
        type = 'latex',
        file = 'or-case.tex'
  )
}

## Only use it with getIndexedAccessResults() as it will only compare the effectivenss after reaching fitness value of 1.0
printOddsRatioTableAfterReachingLine <- function(results) {
  forFrame <- getOddsRatioReproductionForFrameAfterReachingLine(results)
  forCase  <- getOddsRatioReproductionForCaseAfterReachingLine(results)

  print(xtable(forFrame,
               aligh  = c('l', 'l', 'r', 'r', 'r', 'r', 'r', 'r'),
               digits = c(0, 0, 0, 0, 0, 0, 4, 5)),
        type = 'latex',
        file = 'or-frame.tex'
  )

  print(xtable(forCase,
               align  = c('l', 'l', 'c', 'r', 'r', 'r', 'r', 'r', 'r'),
               digits = c(0, 0, 0, 0, 0, 0, 0, 4, 5)),
        type = 'latex',
        file = 'or-case.tex'
  )
}

printFitnessEvalTable <- function(results) {
  forFrame <- getFitnessEvaluationForFrame(results)
  forCase  <- getFitnessEvaluationForCase(results)

  print(xtable(forFrame,
               align  = c('l', 'l', 'r', 'r', 'l'),
               digits = c(0, 0, 4, 5, 0)),
        type = 'latex',
        file = 'FitnessEvalForFrame.tex')

  print(xtable(forCase,
               align  = c('l', 'l', 'c', 'r', 'r', 'l'),
               digits = c(0, 0, 0, 4, 5, 0)),
        type = 'latex',
        file = 'FitnessEvalForCase.tex')
}

## Only use it with getIndexedAccessResults() as it will only compare the efficiency after reaching fitness value of 1.0
printFitnessEvalTableAfterReachingLine <- function(results) {
  forFrame <- getFitnessEvaluationForFrameAfterReachingLine(results)
  forCase  <- getFitnessEvaluationForCaseAfterReachingLine(results)

  print(xtable(forFrame,
               align  = c('l', 'l', 'r', 'r', 'l'),
               digits = c(0, 0, 4, 5, 0)),
        type = 'latex',
        file = 'FitnessEvalForFrame.tex')

  print(xtable(forCase,
               align  = c('l', 'l', 'c', 'r', 'r', 'l'),
               digits = c(0, 0, 0, 4, 5, 0)),
        type = 'latex',
        file = 'FitnessEvalForCase.tex')
}