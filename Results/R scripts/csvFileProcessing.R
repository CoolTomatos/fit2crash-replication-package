# Created by: Shang Xiang
# Created on: 01/02/2020

library(dplyr)
library(questionr)
library(ggplot2)
library(effsize)
library(xtable)

APPLICATION_LEVELS <- c("lang", "math", "mockito", "time", "chart", "es", "xwiki")

EXCEPTION_LEVELS <- c("IAE", "AIOOBE", "SIOOBE", "ISE", "Oth.")

CONFIGURATION_LEVELS <- c("IA", "IA-control", "BV", "BV-control")

EXTRA_CONFIGURATION_LEVELS <- NULL

RESULT_LEVELS <- c("not started", "location not reached", "location reached reached", "reproduced", "unsatisfactory")

TOTAL_RUNS <- 30

SIGNIFICANCE_LEVEL <- 0.05

MAX_NUMBER_OF_EVALUATION <- 62328

# Adds full name for applications
addApplicationName <- function(df) {
  df$application_name[df$application == "lang"] <- APPLICATION_LEVELS[1]
  df$application_name[df$application == "math"] <- APPLICATION_LEVELS[2]
  df$application_name[df$application == "mockito"] <- APPLICATION_LEVELS[3]
  df$application_name[df$application == "time"] <- APPLICATION_LEVELS[4]
  df$application_name[df$application == "chart"] <- APPLICATION_LEVELS[5]
  df$application_name[df$application == "elasticsearch"] <- APPLICATION_LEVELS[6]
  df$application_name[df$application == "xwiki"] <- APPLICATION_LEVELS[7]

  df$application_factor <- factor(df$application_name, levels = APPLICATION_LEVELS, ordered = TRUE)
  return(df)
}

# Adds accronyms for exceptions
addExceptionShortName <- function(df) {
  df$exception <- tail(EXCEPTION_LEVELS, n = 1)

  df$exception[df$exception_name == "java.lang.IllegalArgumentException"] <- EXCEPTION_LEVELS[1]
  df$exception[df$exception_name == "java.lang.ArrayIndexOutOfBoundsException"] <- EXCEPTION_LEVELS[2]
  df$exception[df$exception_name == "java.lang.StringIndexOutOfBoundsException"] <- EXCEPTION_LEVELS[3]
  df$exception[df$exception_name == "java.lang.IllegalStateException"] <- EXCEPTION_LEVELS[4]

  df$exception_factor <- factor(df$exception, levels = EXCEPTION_LEVELS, ordered = TRUE)
  return(df)
}

# Produces an easy to process dataframe from the given results csv file.
getCleanResultsDf <- function(csvFile) {
  df <- read.csv(csvFile, stringsAsFactors = FALSE)
  # Restrict on population
  # df <- df %>%
  # 	filter(population == 100)
  # Add name of the applications
  df <- addApplicationName(df)
  # Add short name for exceptions
  df <- addExceptionShortName(df)
  # Add id for the frame
  df$case_frame <- paste0(df$case, '-', df$frame)
  # Set the global result of the execution
  df$result[is.numeric(df$fitness_function_value) & df$fitness_function_value == -2] <- RESULT_LEVELS[5] #
  # unsatisfactory
  df$result[is.na(df$fitness_function_value) |
    !is.numeric(df$fitness_function_value) |
    ((df$fitness_function_value == -1) & (df$number_of_fitness_evaluation == 0))] <- RESULT_LEVELS[1] # not started
  df$result[is.numeric(df$fitness_function_value) & df$fitness_function_value > 1 |
    (is.numeric(df$fitness_function_value) &
      df$fitness_function_value == -1 &
      df$number_of_fitness_evaluation > 0)] <- RESULT_LEVELS[2] # line not
  # reached
  df$result[is.numeric(df$fitness_function_value) &
    df$fitness_function_value <= 1 &
    df$fitness_function_value > 0] <- RESULT_LEVELS[3] # line reached
  df$result[is.numeric(df$fitness_function_value) & df$fitness_function_value == 0] <- RESULT_LEVELS[4] # reproduced
  # Set the order of exceptions
  df$result_factor <- factor(df$result, levels = RESULT_LEVELS, ordered = TRUE)
  return(df)
}

# Returns a dataframe with the results of the evaluation for indexed-access
getConfig1Results <- function() {
  indexed_access <- getCleanResultsDf('Results/Output/indexed-access.csv') %>%
    mutate(configuration = CONFIGURATION_LEVELS[1])

  indexed_access$configuration_factor = factor(indexed_access$configuration, levels = CONFIGURATION_LEVELS, ordered =
    TRUE)
  return(indexed_access)
}

# Returns a dataframe with the results of the evaluation for indexed-access-control-group
getConfig2Results <- function() {
  indexed_access_control <- getCleanResultsDf('Results/Output/indexed-access-control-group.csv') %>%
    mutate(configuration = CONFIGURATION_LEVELS[2])

  indexed_access_control$configuration_factor = factor(indexed_access_control$configuration, levels =
    CONFIGURATION_LEVELS, ordered = TRUE)
  return(indexed_access_control)
}

# Returns a dataframe with the results of the evaluation for branching-variable
getConfig3Results <- function() {
  branching_variable <- getCleanResultsDf('Results/Output/branching-variable.csv') %>%
    mutate(configuration = CONFIGURATION_LEVELS[3])

  branching_variable$configuration_factor = factor(branching_variable$configuration, levels = CONFIGURATION_LEVELS,
                                                   ordered =
                                                     TRUE)
  return(branching_variable)
}

# Returns a dataframe with the results of the evaluation for branching-variable-control-group
getConfig4Results <- function() {
  branching_variable_control <- getCleanResultsDf('Results/Output/branching-variable-control-group.csv') %>%
    mutate(configuration = CONFIGURATION_LEVELS[4])

  branching_variable_control$configuration_factor = factor(branching_variable_control$configuration, levels =
    CONFIGURATION_LEVELS, ordered = TRUE)
  return(branching_variable_control)
}

# Returns a dataframe with all the results of the evaluation.
#
getAllResults <- function() {
  indexed_access <- getConfig1Results()
  indexed_access_control <- getConfig2Results()
  branching_variable <- getConfig3Results()
  branching_variable_control <- getConfig4Results()
  # Bind results together
  results <- indexed_access %>%
    bind_rows(indexed_access_control) %>%
    bind_rows(branching_variable) %>%
    bind_rows(branching_variable_control)
  # Add configuration factor
  #results$configuration_factor = factor(results$configuration, levels = CONFIGURATION_LEVELS, ordered = TRUE)
  return(results)
}

# Returns a dataframe with the results of the indexed-access evaluation.
#
getIndexedAccessResults <- function() {
  indexed_access <- getConfig1Results()
  indexed_access_control <- getConfig2Results()
  # Bind results together
  results <- indexed_access %>%
    bind_rows(indexed_access_control)
  return(results)
}

calculateAfterReachingLine <- function(fitness_function_evolution) {
  pairs <- substr(fitness_function_evolution, 2, nchar(fitness_function_evolution) - 1) %>%
    strsplit("][", fixed = TRUE)
  start <- 0
  for (pair in pairs[[1]]) {
    p <- strsplit(pair, ',')[[1]] %>%
      as.numeric()
    if (p[1] >= 1) {
      start <- p[2]
    } else if (p[1] == 0) {
      end <- p[2]
    }
  }
  if (is.double(end)) {
    return(as.integer(end - start))
  } else {
    return(NA)
  }
}

# Returns a dataframe with the results of the branching-variable evaluation.
#
getBranchingVariableResults <- function() {
  branching_variable <- getConfig3Results()
  branching_variable_control <- getConfig4Results()
  # Bind results together
  results <- branching_variable %>%
    bind_rows(branching_variable_control)
  # Add configuration factor
  #results$configuration_factor = factor(results$configuration, levels = CONFIGURATION_LEVELS, ordered = TRUE)
  return(results)
}

getReproductionRateForFrame <- function(results) {
  reproducedFrames <- distinct(results[results$result == "reproduced",], case_frame)
  df <- inner_join(results, reproducedFrames, by = "case_frame")
  df <- df %>%
    group_by(configuration, case_frame) %>%
    summarise(count = table(result_factor)[4],
              reproduction_rate = count / TOTAL_RUNS,
              avg_ff_evals = mean(number_of_fitness_evaluations[result == 'reproduced']),
              sd_ff_evals = sd(number_of_fitness_evaluations[result == 'reproduced'])) %>%
    data.frame()
  return(df)
}

getReproductionRateForCase <- function(results) {
  reproducedFrames <- distinct(results[results$result == "reproduced",], case, frame_level)
  highestFrames <- reproducedFrames %>%
    group_by(case) %>%
    mutate(highest = max(frame_level)) %>%
    filter(frame_level == highest) %>%
    select(case, frame_level)
  df <- inner_join(results, highestFrames, by = c("case", "frame_level"))

  df <- df %>%
    group_by(configuration, case, frame_level) %>%
    summarise(count = table(result_factor)[4],
              reproduction_rate = count / TOTAL_RUNS,
              avg_ff_evals = mean(number_of_fitness_evaluations[result == 'reproduced']),
              sd_ff_evals = sd(number_of_fitness_evaluations[result == 'reproduced'])) %>%
    data.frame()
  return(df)
}

getReproductionRateForFrameAfterReachingLine <- function(results) {
  reproducedFrames <- distinct(results[results$result == "reproduced",], case_frame)
  df <- inner_join(results, reproducedFrames, by = "case_frame")
  df <- df %>%
    group_by(configuration, case_frame) %>%
    summarise(count = table(result_factor)[4],
              total = table(result_factor)[3] +
                table(result_factor)[4] +
                table(result_factor)[5],
              reproduction_rate = count / total,
              avg_ff_evals = mean(number_of_fitness_evaluations[result == 'reproduced']),
              sd_ff_evals = sd(number_of_fitness_evaluations[result == 'reproduced'])) %>%
    data.frame()
  return(df)
}

getReproductionRateForCaseAfterReachingLine <- function(results) {
  reproducedFrames <- distinct(results[results$result == "reproduced",], case, frame_level)
  highestFrames <- reproducedFrames %>%
    group_by(case) %>%
    mutate(highest = max(frame_level)) %>%
    filter(frame_level == highest) %>%
    select(case, frame_level)
  df <- inner_join(results, highestFrames, by = c("case", "frame_level"))

  df <- df %>%
    group_by(configuration, case, frame_level) %>%
    summarise(count = table(result_factor)[4],
              total = table(result_factor)[3] +
                table(result_factor)[4] +
                table(result_factor)[5],
              reproduction_rate = count / total,
              avg_ff_evals = mean(number_of_fitness_evaluations[result == 'reproduced']),
              sd_ff_evals = sd(number_of_fitness_evaluations[result == 'reproduced'])) %>%
    data.frame()
  return(df)
}

getReproductionRateForOneCaseAfterReachingLine <- function(results, casee) {
  df <- results %>%
    filter(case == casee) %>%
    group_by(configuration) %>%
    summarise(case = casee,
              count = table(result_factor)[4],
              total = table(result_factor)[3] +
                table(result_factor)[4] +
                table(result_factor)[5],
              reproduction_rate = count / total,
              avg_ff_evals = mean(number_of_fitness_evaluations[result == 'reproduced']),
              sd_ff_evals = sd(number_of_fitness_evaluations[result == 'reproduced'])) %>%
    data.frame()
  return(df)
}

# Returns the offs ratio for the cases and configurations in results.
#
getOddsRatioReproductionForFrame <- function(results) {
  computeReproductionOddsRatio <- Vectorize(function(count1, count2) {
    m <- matrix(c(count1, TOTAL_RUNS - count1,
                  count2, TOTAL_RUNS - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- oddsratio(m)
    return(or)
  })

  getPValue <- Vectorize(function(count1, count2) {
    m <- matrix(c(count1, TOTAL_RUNS - count1,
                  count2, TOTAL_RUNS - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- fisher.test(m)
    return(or$p.value)
  })

  df <- getReproductionRateForFrame(results)
  df <- df %>%
    inner_join(df, by = 'case_frame', suffix = c('.conf1', '.conf2')) %>%
    filter(configuration.conf1 != configuration.conf2) %>%
    mutate(oddsratio = computeReproductionOddsRatio(count.conf1, count.conf2)) %>%
    mutate(pValue = getPValue(count.conf1, count.conf2)) %>%
    select(case_frame, configuration.conf1, configuration.conf2, count.conf1, count.conf2, oddsratio, pValue) %>%
    filter(grepl("control", configuration.conf2))
  return(df[order(df$oddsratio, decreasing = TRUE),])
}

getOddsRatioReproductionForCase <- function(results) {
  computeReproductionOddsRatio <- Vectorize(function(count1, count2) {
    m <- matrix(c(count1, TOTAL_RUNS - count1,
                  count2, TOTAL_RUNS - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- oddsratio(m)
    return(or)
  })

  getPValue <- Vectorize(function(count1, count2) {
    m <- matrix(c(count1, TOTAL_RUNS - count1,
                  count2, TOTAL_RUNS - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- fisher.test(m)
    return(or$p.value)
  })

  df <- getReproductionRateForCase(results)
  df <- df %>%
    inner_join(df, by = c('case', 'frame_level'), suffix = c('.conf1', '.conf2')) %>%
    filter(configuration.conf1 != configuration.conf2) %>%
    mutate(oddsratio = computeReproductionOddsRatio(count.conf1, count.conf2)) %>%
    mutate(pValue = getPValue(count.conf1, count.conf2)) %>%
    select(case, frame_level, configuration.conf1, configuration.conf2, count.conf1, count.conf2, oddsratio, pValue) %>%
    filter(grepl("control", configuration.conf2))
  return(df[order(df$oddsratio, decreasing = TRUE),])
}

oddsratio <- function(matrix) {
  rho <- 0.5
  od <- ((matrix[1, 1] + rho) / (matrix[1, 2] + rho)) / ((matrix[2, 1] + rho) / (matrix[2, 2] + rho))
  return(od)
}

getOddsRatioReproductionForFrameAfterReachingLine <- function(results) {
  computeReproductionOddsRatio <- Vectorize(function(count1, count2, total1, total2) {
    m <- matrix(c(count1, total1 - count1,
                  count2, total2 - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- oddsratio(m)
    return(or)
  })

  getPValue <- Vectorize(function(count1, count2, total1, total2) {
    m <- matrix(c(count1, total1 - count1,
                  count2, total2 - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- fisher.test(m)
    return(or$p.value)
  })

  df <- getReproductionRateForFrameAfterReachingLine(results)
  df <- df %>%
    inner_join(df, by = 'case_frame', suffix = c('.conf1', '.conf2')) %>%
    filter(configuration.conf1 != configuration.conf2) %>%
    mutate(oddsratio = computeReproductionOddsRatio(count.conf1, count.conf2, total.conf1, total.conf2)) %>%
    mutate(pValue = getPValue(count.conf1, count.conf2, total.conf1, total.conf2)) %>%
    filter(grepl("control", configuration.conf2)) %>%
    select(case_frame, count.conf1, total.conf1, count.conf2, total.conf2, oddsratio, pValue)
  return(df[order(df$oddsratio, decreasing = TRUE),])
}

getOddsRatioReproductionForCaseAfterReachingLine <- function(results) {
  computeReproductionOddsRatio <- Vectorize(function(count1, count2, total1, total2) {
    m <- matrix(c(count1, total1 - count1,
                  count2, total2 - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- oddsratio(m)
    return(or)
  })

  getPValue <- Vectorize(function(count1, count2, total1, total2) {
    m <- matrix(c(count1, total1 - count1,
                  count2, total2 - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- fisher.test(m)
    return(or$p.value)
  })

  df <- getReproductionRateForCaseAfterReachingLine(results)
  df <- df %>%
    inner_join(df, by = c('case', 'frame_level'), suffix = c('.conf1', '.conf2')) %>%
    filter(configuration.conf1 != configuration.conf2) %>%
    mutate(oddsratio = computeReproductionOddsRatio(count.conf1, count.conf2, total.conf1, total.conf2)) %>%
    mutate(pValue = getPValue(count.conf1, count.conf2, total.conf1, total.conf2)) %>%
    filter(grepl("control", configuration.conf2)) %>%
    select(case, frame_level, count.conf1, total.conf1, count.conf2, total.conf2, oddsratio, pValue)
  return(df[order(df$oddsratio, decreasing = TRUE),])
}

getOddsRatioReproductionForOneCaseAfterReachingLine <- function(results, case) {
  computeReproductionOddsRatio <- Vectorize(function(count1, count2, total1, total2) {
    m <- matrix(c(count1, total1 - count1,
                  count2, total2 - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- oddsratio(m)
    return(or)
  })

  getPValue <- Vectorize(function(count1, count2, total1, total2) {
    m <- matrix(c(count1, total1 - count1,
                  count2, total2 - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- fisher.test(m)
    return(or$p.value)
  })
  df <- getReproductionRateForOneCaseAfterReachingLine(results, case)
  df <- df %>%
    inner_join(df, by = 'case', suffix = c('.x', '.y')) %>%
    filter(configuration.x != configuration.y, grepl('control', configuration.y)) %>%
    mutate(oddsratio = computeReproductionOddsRatio(count.x, count.y, total.x, total.y)) %>%
    mutate(pValue = getPValue(count.x, count.y, total.x, total.y)) %>%
    select(case, count.x, total.x, count.y, total.y, oddsratio, pValue)
  return(df)
}

########################################################################################################################

getFitnessEvaluationForFrame <- function(results) {
  reproducedFrames <- distinct(results[results$result == "reproduced",], case_frame, configuration) %>%
    group_by(case_frame) %>%
    summarise(both = n() > 1) %>%
    filter(both == TRUE) %>%
    select(case_frame)

  df <- data.frame(
    case_frame = character(),
    A = numeric(),
    p_value = numeric(),
    Magnitude = character())
  i <- 0
  for (frame in reproducedFrames$case_frame) {
    i <- i + 1
    x <- results %>%
      filter(result == 'reproduced', !grepl('control', configuration), case_frame == frame) %>%
      select(number_of_fitness_evaluations)
    y <- results %>%
      filter(result == 'reproduced', grepl('control', configuration), case_frame == frame) %>%
      select(number_of_fitness_evaluations)
    a <- VD.A(x$number_of_fitness_evaluations, y$number_of_fitness_evaluations)
    row <- data.frame(
      case_frame = frame,
      A = a$estimate,
      p_value = wilcox.test(x$number_of_fitness_evaluations, y$number_of_fitness_evaluations)$p.value,
      Magnitude = a$magnitude)
    df <- rbind(df, row)
  }
  return(df[order(df$A, df$p_value, decreasing = FALSE),])
}

getFitnessEvaluationForCase <- function(results) {
  reproducedFrames <- distinct(results[results$result == "reproduced",], case, frame_level, configuration) %>%
    group_by(case, frame_level) %>%
    summarise(both = n() > 1) %>%
    filter(both == TRUE) %>%
    select(case, frame_level)
  highestFrames <- reproducedFrames %>%
    group_by(case) %>%
    mutate(highest = max(frame_level)) %>%
    filter(frame_level == highest) %>%
    select(case, frame_level)

  df <- data.frame(
    Case = character(),
    Frame = numeric(),
    A = numeric(),
    p_value = numeric(),
    Magnitude = character())
  i <- 0
  for (frame in highestFrames$case) {
    i <- i + 1
    x <- results %>%
      filter(result == 'reproduced', !grepl('control', configuration), case == highestFrames$case[i], frame_level ==
        highestFrames$frame_level[i]) %>%
      select(number_of_fitness_evaluations)
    y <- results %>%
      filter(result == 'reproduced', grepl('control', configuration), case == highestFrames$case[i], frame_level ==
        highestFrames$frame_level[i]) %>%
      select(number_of_fitness_evaluations)
    a <- VD.A(x$number_of_fitness_evaluations, y$number_of_fitness_evaluations)

    row <- data.frame(
      Case = highestFrames$case[i],
      Frame = highestFrames$frame_level[i],
      A = a$estimate,
      p_value = wilcox.test(x$number_of_fitness_evaluations, y$number_of_fitness_evaluations)$p.value,
      Magnitude = a$magnitude)
    df <- rbind(df, row)
  }
  return(df[order(df$A, df$p_value, decreasing = FALSE),])
}

getFitnessEvaluationForFrameAfterReachingLine <- function(results) {
  reproducedFrames <- distinct(results[results$result == "reproduced",], case_frame, configuration) %>%
    group_by(case_frame) %>%
    summarise(both = n() > 1) %>%
    filter(both == TRUE) %>%
    select(case_frame)

  df <- data.frame(
    case_frame = character(),
    A = numeric(),
    p_value = numeric(),
    Magnitude = character())
  for (frame in reproducedFrames$case_frame) {
    xFE <- NULL
    yFE <- NULL
    x <- results %>%
      filter(result == 'reproduced', !grepl('control', configuration), case_frame == frame)
    for (i in seq_len(nrow(x))) {
      xFE <- append(xFE, calculateAfterReachingLine(x[i,]$fitness_function_evolution))
    }

    y <- results %>%
      filter(result == 'reproduced', grepl('control', configuration), case_frame == frame)
    for (i in seq_len(nrow(y))) {
      yFE <- append(yFE, calculateAfterReachingLine(y[i,]$fitness_function_evolution))
    }
    a <- VD.A(xFE, yFE)
    row <- data.frame(
      case_frame = frame,
      A = a$estimate,
      p_value = wilcox.test(xFE, yFE)$p.value,
      Magnitude = a$magnitude)
    df <- rbind(df, row)
  }
  return(df[order(df$A, df$p_value, decreasing = FALSE),])
}

getFitnessEvaluationForCaseAfterReachingLine <- function(results) {
  reproducedFrames <- distinct(results[results$result == "reproduced",], case, frame_level, configuration) %>%
    group_by(case, frame_level) %>%
    summarise(both = n() > 1) %>%
    filter(both == TRUE) %>%
    select(case, frame_level)
  highestFrames <- reproducedFrames %>%
    group_by(case) %>%
    mutate(highest = max(frame_level)) %>%
    filter(frame_level == highest) %>%
    select(case, frame_level)

  df <- data.frame(
    Case = character(),
    Frame = numeric(),
    A = numeric(),
    p_value = numeric(),
    Magnitude = character())
  i <- 0
  for (frame in highestFrames$case) {
    i <- i + 1
    xFE <- NULL
    yFE <- NULL
    x <- results %>%
      filter(result == 'reproduced', !grepl('control', configuration), case == highestFrames$case[i], frame_level ==
        highestFrames$frame_level[i])
    for (j in seq_len(nrow(x))) {
      xFE <- append(xFE, calculateAfterReachingLine(x[j,]$fitness_function_evolution))
    }
    y <- results %>%
      filter(result == 'reproduced', grepl('control', configuration), case == highestFrames$case[i], frame_level ==
        highestFrames$frame_level[i])
    for (j in seq_len(nrow(y))) {
      yFE <- append(yFE, calculateAfterReachingLine(y[j,]$fitness_function_evolution))
    }
    a <- VD.A(xFE, yFE)

    row <- data.frame(
      Case = highestFrames$case[i],
      Frame = highestFrames$frame_level[i],
      A = a$estimate,
      p_value = wilcox.test(xFE, yFE)$p.value,
      Magnitude = a$magnitude)
    df <- rbind(df, row)
  }
  return(df[order(df$A, df$p_value, decreasing = FALSE),])
}

getFitnessEvaluationForOneCaseAfterReachingLine <- function(results, casee) {
  xFE <- NULL
  yFE <- NULL

  x <- results %>%
    filter(result == 'reproduced', !grepl('control', configuration), case == casee)
  for (i in seq_len(nrow(x))) {
    xFE <- append(xFE, calculateAfterReachingLine(x[i,]$fitness_function_evolution))
  }
  y <- results %>%
    filter(result == 'reproduced', grepl('control', configuration), case == casee)
  for (i in seq_len(nrow(y))) {
    yFE <- append(yFE, calculateAfterReachingLine(y[i,]$fitness_function_evolution))
  }
  a <- VD.A(xFE, yFE)

  row <- data.frame(Case = casee,
                    A = a$estimate,
                    p_value = wilcox.test(xFE, yFE)$p.value,
                    Magnitude = a$magnitude)
  return(row)
}
