# Created by: Shang Xiang
# Created on: 23/02/2020

source('Results/R scripts/csvFileProcessing.R')

COLOR_PALETTE <- "Blues" # Use photocopy friendly colors (http://colorbrewer2.org/)

printReproductionStatusForEachApplication <- function(results, widthhh = 5, heighttt) {
  df <- results %>%
    group_by(application_factor, configuration_factor, result_factor) %>%
    summarise(n = n()) %>%
    mutate(Frequency = n / sum(n), label = paste0(n))
  p  <- ggplot(df, aes(x = configuration_factor, y = Frequency, fill = result_factor)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 3) +
    scale_fill_brewer(palette = COLOR_PALETTE) +
    scale_y_continuous(labels = scales::percent) +
    xlab(NULL) +
    ylab(NULL) +
    guides(fill = guide_legend(title = NULL, nrow = 2, byrow = TRUE)) +
    theme(legend.position = "bottom") +
    coord_flip() +
    facet_grid(application_factor ~ .)
  pdf("ggplot.pdf", width = widthhh, height = heighttt)
  print(p)
  dev.off()
  return(p)
}

printReproductionStatusForOneCase <- function(results, caseName, widthhh = 5, heighttt = 1.55) {
  # Add count label and frequency
  df <- results %>%
    group_by(case, configuration_factor, result_factor) %>%
    filter(case == caseName) %>%
    summarise(n = n()) %>%
    mutate(Frequency = n / sum(n), label = paste0(n))
  p  <- ggplot(df, aes(x = configuration_factor, y = Frequency, fill = result_factor)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 3) +
    scale_fill_brewer(palette = COLOR_PALETTE) +
    scale_y_continuous(labels = scales::percent) +
    xlab(NULL) +
    ylab(NULL) +
    guides(fill = guide_legend(title = NULL)) +
    theme(legend.position = "bottom") +
    coord_flip() +
    facet_grid(case ~ .)
  pdf("ggplot.pdf", width = widthhh, height = heighttt)
  print(p)
  dev.off()
  return(p)
}

printReproductionStatusForEachFramesInOneCase <- function(results, caseName, widthhh = 5, heighttt) {
  # Add count label and frequency
  df <- results %>%
    group_by(case, frame_level, configuration_factor, result_factor) %>%
    filter(case == caseName) %>%
    summarise(n = n()) %>%
    mutate(Frequency = n / sum(n), label = paste0(n))
  p  <- ggplot(df, aes(x = configuration_factor, y = Frequency, fill = result_factor)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 3) +
    scale_fill_brewer(palette = COLOR_PALETTE) +
    scale_y_continuous(labels = scales::percent) +
    xlab(NULL) +
    ylab(NULL) +
    guides(fill = guide_legend(title = NULL)) +
    theme(legend.position = "bottom") +
    coord_flip() +
    facet_grid(frame_level ~ .)
  pdf("ggplot.pdf", width = widthhh, height = heighttt)
  print(p)
  dev.off()
  return(p)
}

printReproductionStatusForAllCases <- function(results, widthhh = 5, heightttt = 1.25) {
  reproducedCases               <- distinct(results[results$result == "reproduced",], case, configuration_factor)
  reproducedCases$status_factor = "reproduced"

  allCases <- distinct(results, case, configuration_factor)
  allCases <- merge(allCases, reproducedCases, by = c("case", "configuration_factor"), all = TRUE)

  allCases[is.na(allCases)] <- "not reproduced"

  # Add count label and frequency
  df <- allCases %>%
    group_by(configuration_factor, status_factor) %>%
    summarise(n = n()) %>%
    mutate(Frequency = n / sum(n), label = paste0(n))
  p  <- ggplot(df, aes(x = configuration_factor, y = Frequency, fill = status_factor)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5)) +
    scale_fill_brewer(palette = COLOR_PALETTE) +
    scale_y_continuous(labels = scales::percent) +
    xlab(NULL) +
    ylab(NULL) +
    guides(fill = guide_legend(title = NULL)) +
    theme(legend.position = "bottom") +
    coord_flip()
  pdf("ggplot.pdf", width = widthhh, height = heightttt)
  print(p)
  dev.off()
  return(p)
}