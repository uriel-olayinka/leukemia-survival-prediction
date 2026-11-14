# Predicting Survival in Children with Acute Lymphoblastic Leukemia

DS 5110, Fall 2026, Northeastern University

Authors: Jonathan Buwembo, Priamos Koumas, Shang-Yun Hsieh, Uriel Olayinka, Vivian Onyejiaka

## Abstract (draft, results to be added)

Acute lymphoblastic leukemia (ALL) is the most common cancer in children. This project asks which is more useful for predicting whether a child will survive: their background and clinical presentation at diagnosis, or how their leukemia responds to the first month of treatment. We use clinical data from the TARGET ALL Phase II study (accessed through cBioPortal), covering 1,541 children with a recorded outcome, of whom 254 (16.5%) died. We build models from three sets of information (baseline characteristics, early treatment response, and both combined) using logistic regression with and without Lasso, random forests, and time-to-event models. All models are tested on children they have not seen, using the same fixed 5-fold cross-validation. Because most children survived, we report precision, recall, and F1 rather than accuracy alone.

## Repository layout

- `data/`: how to get the raw data and the cleaned files (see `data/README.md`)
- `scripts/`: data cleaning, folds, imputation, and data dictionary scripts, plus the shared feature sets
- `eda/`, `logistic/`, `forest/`, `survival/`: each analysis in its own folder
- `report/`, `slides/`: final report and presentation

## Reproducing the data

See `data/README.md` for step-by-step instructions.
