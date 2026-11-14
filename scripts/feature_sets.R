baseline_vars <- c("age", "sex", "race", "ethnicity", "wbc", "cell_origin", "cns_status", "bcr_abl1")
response_vars <- c("blasts_day8", "blasts_day29", "mrd_day29")
combined_vars <- c(baseline_vars, response_vars)

forbidden_vars <- c("patient_id", "cohorts", "deceased", "outcome", "os_days", "time_to_event_days")

# stops with an error if any feature set contains an outcome, time, or ID column
stopifnot(!any(combined_vars %in% forbidden_vars))