library(tidyverse)
library(here)

raw <- read_tsv(
  here("data", "raw", "all_phase2_target_2018_pub_clinical_data.tsv"),
  guess_max = Inf,
  show_col_types = FALSE
)

first_value <- function(x) x[!is.na(x)][1] # first non-empty value, or NA if none

patients <- raw |>
  group_by(`Patient ID`) |>
  summarise(
    cohorts = paste(sort(unique(`Analysis Cohort`)), collapse = " + "),
    n_rows = n(),
    across(-c(`Analysis Cohort`, `Sample ID`, `Study ID`), first_value),
    .groups = "drop"
  )
