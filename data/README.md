# Data

## Getting the raw data

Download the TARGET ALL Phase II (2018) clinical data from cBioPortal: <https://www.cbioportal.org/study/summary?id=all_phase2_target_2018_pub>

Save the file as `data/raw/all_phase2_target_2018_pub_clinical_data.tsv`. This folder is not tracked by Git, so each person downloads their own copy.

## Rebuilding the clean files

Open the `.Rproj` file in RStudio, install the packages (`install.packages(c("tidyverse", "here", "mice"))`), then run the scripts in `scripts/` in this order:

1.  `01_clean.R`: one row per child, outcome, selected columns, complete-case flag
2.  `02_folds.R`: fixed cross-validation folds
3.  `03_impute.R`: multiple imputation, done separately for each held-out fold
4.  `04_data_dictionary.R`: writes the data dictionary

`feature_sets.R` defines the shared feature lists and is loaded automatically by the other scripts.

## Files in `data/clean/`

- `patients_clean.rds` (and a plain `.csv` backup): 1,541 children, one row each. Load the `.rds`, because it keeps the category order.
- `cv_folds.csv`: each child's fold number (1 to 5), stratified by outcome.
- `patients_imputed.rds`: blanks filled in, 5 copies for each held-out fold. Stay within one `heldout_fold` block.
- `data_dictionary.csv`: every column, its meaning, type, allowed values, and number of blanks.

## How to use the files

- Load the data with `readRDS(here("data", "clean", "patients_clean.rds"))` and join the folds with `left_join(folds, by = "patient_id")`.
- Feature lists are in `scripts/feature_sets.R`: `baseline_vars`, `response_vars`, `combined_vars`. Use `forbidden_vars` to check that no outcome, survival time, ID, or bookkeeping column is used as a predictor.
- For complete-case models, use `filter(complete_case)` (1,492 children) so all three feature sets see the same children.
- `os_days` with `deceased` is the survival time and outcome. `time_to_event_days` is the time to the first setback (such as a relapse), not the survival time.

## Cleaning decisions

- The raw file has one row per tumor sample (1,978 rows for 1,551 children). We checked that no child's rows disagree, then kept one row per child.
- Only the 1,541 children with a recorded survival outcome are kept (1,287 living, 254 deceased). Children from the XENOGRAFT group who have outcomes are kept, because they are real patients with clinical data.
- The two spellings "B-Precursor" and "B Cell ALL" are merged into B. They appeared in different cohorts and mean the same thing.
- "Unknown" in race, ethnicity, and BCR-ABL1 is kept as its own category, not treated as missing. A stray "." in CNS status was turned into a blank.
- Day 43 blasts, mutation count, and the genomic and other columns we are not using are not in the clean file.
- Complete-case: 1,492 children have all 11 features filled in. The 49 left out are more often deceased (30.6% vs 16.0%), so complete-case results may be slightly optimistic.
- Imputation uses only the 11 features (not the outcome) and learns from the training children of each fold, so test children never influence how blanks are filled.
