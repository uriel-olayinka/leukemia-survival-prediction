library(tidyverse)
library(here)

source(here("scripts", "feature_sets.R"))

clean <- readRDS(here("data", "clean", "patients_clean.rds"))

# describes the allowed values of one column in short text
describe_values <- function(x) {
  if (is.factor(x)) return(paste(levels(x), collapse = "; "))
  if (is.logical(x)) return("TRUE; FALSE")
  if (is.numeric(x)) return(paste(min(x, na.rm = TRUE), "to", max(x, na.rm = TRUE)))
  if (n_distinct(x) <= 10) return(paste(sort(unique(x)), collapse = "; "))
  "unique text, one per child"
}

auto <- tibble(
  column = names(clean),
  type = unname(map_chr(clean, ~ class(.x)[1])),
  allowed_values = unname(map_chr(clean, describe_values)),
  n_missing = unname(map_int(clean, ~ sum(is.na(.x))))
)

meanings <- tribble(
  ~column, ~meaning,
  "patient_id", "Child's unique TARGET ID. One row per child.",
  "cohorts", "TARGET study group(s) the child's samples came from. Reference only, tangled up with cell type, do not use as a predictor.",
  "deceased", "Outcome as a number: 1 = died, 0 = alive at last follow-up.",
  "outcome", "Same outcome as a labelled factor. Living is the first level and Deceased the second, so models predict death.",
  "os_days", "Days from diagnosis to death or last follow-up. Use with deceased for survival models. Missing for 6 children.",
  "time_to_event_days", "Days from diagnosis to the first setback (relapse, second cancer, death, etc.) or last follow-up. NOT the survival time, do not pair with deceased.",
  "age", "Age at diagnosis, in years.",
  "sex", "Sex as recorded.",
  "race", "Race category as recorded. Unknown is kept as its own group.",
  "ethnicity", "Ethnicity category as recorded. Unknown is kept as its own group.",
  "wbc", "White blood cell count at diagnosis. Units are not stated in the file.",
  "cell_origin", "Type of leukemia cell: B (B-cell, includes the B-Precursor label) or T (T-cell).",
  "cns_status", "Leukemia involvement of the central nervous system at diagnosis. CNS 1 = none found, CNS 2 and 3 = increasing involvement, letters are sub-types.",
  "bcr_abl1", "Whether the leukemia cells carry the BCR-ABL1 gene fusion. Unknown is kept as its own group.",
  "blasts_day8", "Percent of leukemia cells (blasts) left in the bone marrow on day 8 of treatment.",
  "blasts_day29", "Percent of leukemia cells (blasts) left in the bone marrow on day 29 of treatment.",
  "mrd_day29", "Minimal residual disease: percent of leukemia cells still detectable on day 29 of treatment.",
  "complete_case", "TRUE if all 11 features are filled in. Use filter(complete_case) for complete-case models."
)

extra <- tribble(
  ~column, ~type, ~allowed_values, ~n_missing, ~meaning,
  "fold", "numeric", "1 to 5", 0, "Cross-validation fold. In cv_folds.csv and patients_imputed.rds. Stratified by outcome.",
  "heldout_fold", "numeric", "1 to 5", 0, "In patients_imputed.rds only. Which fold was held out when this block's blanks were filled in.",
  "imputation", "numeric", "1 to 5", 0, "In patients_imputed.rds only. Which of the 5 filled-in copies this row is from."
)

dictionary <- auto |>
  left_join(meanings, by = "column") |>
  bind_rows(extra) |>
  mutate(role = case_when(
    column %in% baseline_vars ~ "baseline feature",
    column %in% response_vars ~ "early-response feature",
    column %in% c("deceased", "outcome") ~ "outcome",
    column %in% c("os_days", "time_to_event_days") ~ "survival time (not a predictor)",
    TRUE ~ "bookkeeping (not a predictor)"
  )) |>
  select(column, role, meaning, type, allowed_values, n_missing)

write_csv(dictionary, here("data", "clean", "data_dictionary.csv"))