library(tidyverse)
library(here)

clean <- readRDS(here("data", "clean", "patients_clean.rds"))

set.seed(5110)

folds <- clean |>
  group_by(outcome) |>
  mutate(fold = sample(rep(1:5, length.out = n()))) |>
  ungroup() |>
  select(patient_id, fold)

write_csv(folds, here("data", "clean", "cv_folds.csv"))