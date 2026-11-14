library(tidyverse)
library(here)
library(mice)

source(here("scripts", "feature_sets.R"))

clean <- readRDS(here("data", "clean", "patients_clean.rds"))
folds <- read_csv(here("data", "clean", "cv_folds.csv"), show_col_types = FALSE)
model_data <- clean |> left_join(folds, by = "patient_id")

# fills missing features using only children outside fold k, returns all 5 filled copies
impute_one_fold <- function(k) {
  imp <- mice(
    model_data[combined_vars],
    m = 5,
    ignore = model_data$fold == k,
    seed = 5110 + k,
    printFlag = FALSE
  )
  rows <- complete(imp, action = "long")
  idx <- as.integer(rows$.id)
  rows |>
    mutate(
      heldout_fold = k,
      imputation = .imp,
      patient_id = model_data$patient_id[idx],
      fold = model_data$fold[idx],
      deceased = model_data$deceased[idx],
      outcome = model_data$outcome[idx],
      os_days = model_data$os_days[idx]
    ) |>
    select(heldout_fold, imputation, patient_id, fold, deceased, outcome, os_days, all_of(combined_vars))
}

imputed <- map(1:5, impute_one_fold) |> list_rbind()

saveRDS(imputed, here("data", "clean", "patients_imputed.rds"))