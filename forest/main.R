library(here)
library(dyplr)

patient_data <- readRDS(here("data", "clean", "patients_clean.rds"))

folds <- read_csv(here("data", "clean", "cv_folds.csv"))

# apply the folds to the model data.
model_data <- patient_data |>
    left_join(folds, by = "patient_id") |>
    filter(complete_case)

# load the feature sets
source(here("scripts", "feature_sets.R"))

# individual files for forest
source(here("forest", "01_baseline.R"))
source(here("forest", "02_early_response.R"))
source(here("forest", "03_combined.R"))
source(here("forest", "04_evaluation.R"))