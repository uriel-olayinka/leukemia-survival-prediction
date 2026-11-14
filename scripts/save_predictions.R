library(tidyverse)
library(here)

# checks a table of out-of-fold predictions and saves it in results/predictions/
save_predictions <- function(preds, model, feature_set, data_version, score_type = "probability") {
  clean <- readRDS(here("data", "clean", "patients_clean.rds"))
  folds <- read_csv(here("data", "clean", "cv_folds.csv"), show_col_types = FALSE)
  
  expected <- clean |> left_join(folds, by = "patient_id")
  if (data_version == "complete_case") expected <- filter(expected, complete_case)
  if (score_type == "risk_score") expected <- filter(expected, !is.na(os_days))
  
  stopifnot(
    "feature_set must be baseline, response or combined" = feature_set %in% c("baseline", "response", "combined"),
    "data_version must be complete_case or imputed" = data_version %in% c("complete_case", "imputed"),
    "score_type must be probability or risk_score" = score_type %in% c("probability", "risk_score"),
    "preds needs the columns patient_id, fold, score" = all(c("patient_id", "fold", "score") %in% names(preds)),
    "a child appears more than once" = !anyDuplicated(preds$patient_id),
    "wrong set of children (check the complete_case or os_days filtering)" = setequal(preds$patient_id, expected$patient_id),
    "scores contain NA" = !anyNA(preds$score),
    "probabilities must be between 0 and 1" = score_type != "probability" || all(preds$score >= 0 & preds$score <= 1)
  )
  
  check <- inner_join(preds, expected, by = "patient_id", suffix = c("", "_official"))
  stopifnot("fold numbers do not match data/clean/cv_folds.csv" = all(check$fold == check$fold_official))
  
  out <- tibble(
    patient_id = preds$patient_id, fold = preds$fold, model = model,
    feature_set = feature_set, data_version = data_version,
    score_type = score_type, score = preds$score
  )
  dir.create(here("results", "predictions"), recursive = TRUE, showWarnings = FALSE)
  write_csv(out, here("results", "predictions", paste0(model, "_", feature_set, "_", data_version, ".csv")))
}