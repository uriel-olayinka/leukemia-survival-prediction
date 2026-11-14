library(tidyverse)
library(here)

source(here("scripts", "feature_sets.R"))

raw <- read_tsv(
  here("data", "raw", "all_phase2_target_2018_pub_clinical_data.tsv"),
  guess_max = Inf,
  show_col_types = FALSE
)

# returns the first non-empty value, or NA if there is none
first_value <- function(x) x[!is.na(x)][1]

patients <- raw |>
  group_by(`Patient ID`) |>
  summarise(
    cohorts = paste(sort(unique(`Analysis Cohort`)), collapse = " + "),
    n_rows = n(),
    across(-c(`Analysis Cohort`, `Sample ID`, `Study ID`), first_value),
    .groups = "drop"
  )

clean <- patients |>
  filter(!is.na(`Overall Survival Status`)) |>
  transmute(
    patient_id = `Patient ID`,
    cohorts = cohorts,
    deceased = if_else(`Overall Survival Status` == "1:DECEASED", 1, 0),
    outcome = factor(deceased, levels = c(0, 1), labels = c("Living", "Deceased")),
    os_days = `Overall Survival Days`,
    time_to_event_days = `Time To Event (days)`,
    age = `Diagnosis Age`,
    sex = Sex,
    race = `Race Category`,
    ethnicity = `Ethnicity Category`,
    wbc = WBC,
    cell_origin = case_when(
      `Cell of tumor origin` %in% c("B Cell ALL", "B-Precursor") ~ "B",
      `Cell of tumor origin` == "T Cell ALL" ~ "T"
    ),
    cns_status = na_if(`CNS Status`, "."),
    bcr_abl1 = `BCR ABL1 Status`,
    blasts_day8 = `Bone Marrow Blasts Day 8`,
    blasts_day29 = `Bone Marrow Blasts Day 29`,
    mrd_day29 = `MRD Percentage Day 29`
  ) |>
  mutate(across(c(sex, race, ethnicity, cell_origin, cns_status, bcr_abl1), fct_infreq)) |>
  mutate(complete_case = if_all(all_of(combined_vars), ~ !is.na(.x)))

saveRDS(clean, here("data", "clean", "patients_clean.rds"))
write_csv(clean, here("data", "clean", "patients_clean.csv"))