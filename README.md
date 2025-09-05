# Master Project – Liquid Variation Analysis

![R Version](https://img.shields.io/badge/R-%3E%3D4.0-blue)
[![Code License: MIT](https://img.shields.io/github/license/leeannvidal/dissertation_data_analysis)](LICENSE)
[![Docs License: CC BY-NC-ND 4.0](https://img.shields.io/badge/Docs%20License-CC%20BY--NC--ND%204.0-lightgrey.svg)](LICENSE-docs.md)
![Last Updated](https://img.shields.io/github/last-commit/leeannvidal/dissertation_data_analysis)

> **Data availability:** The datasets used in this project are **not** included and are **not** public.  
> See [DATA_NOTICE.md](DATA_NOTICE.md) for details.  
> **Licensing:** Code → [MIT](LICENSE). Docs & figures → [CC BY-NC-ND 4.0](LICENSE-docs.md).


This project analyzes **liquid variation** along with five other linguistic variables to uncover patterns of covariation.  
It includes **data preprocessing**, **exploratory analysis**, **modeling**, and **result visualization**.  

The repo is designed so that:
- A new user (or *future me*) can quickly reproduce the analysis.
- Each stage of the workflow is modular and easy to maintain.
- Sensitive or large data are excluded from version control.

---

## Project Structure

```text
.
├── .gitignore                        # Git ignore rules
├── LICENSE                           # MIT License for code
├── LICENSE-docs.md                   # CC BY-NC-ND 4.0 license for docs/figures
├── DATA_NOTICE.md                    # Data availability & restrictions
├── README.md                         # Project overview & usage
├── LVC_Dissertation_Master.Rproj     # Local RStudio project file (ignored)
│
├── data/                              # (ignored) Raw & processed data
│   ├── cleaned_data/                  # Cleaned .rds dataframes
│   ├── regressions/                   # Saved model objects
│   └── token_counts/                  # LaTeX .tex files with token counts
│
├── docs/                              # Documentation & R Markdown
│   ├── Coding_Manual_Liquids.pdf      # Methodology and coding manual
│   └── project_overview.Rmd           # Orchestrates the analysis workflow
│
├── functions/                         # Custom R functions for analysis & plotting
│   ├── add_name_stat.R
│   ├── model_summary_labels_for_visuals.R
│   └── ... (other helper functions)
│
├── output/                            # (ignored) Generated outputs
│   ├── plots/                         # PDF figures by variable type
│   ├── presentation_visuals/          # Plots for presentations
│   └── tables/                        # LaTeX tables (descriptive/statistical)
│
├── scripts/                           # Analysis scripts
│   ├── data_preprocessing/            # Load, clean, and prepare raw data
│   ├── descriptive_tables/            # Generate descriptive tables
│   ├── statistical_analysis/           # Statistical models
│   ├── visuals/                        # Plotting scripts
│   ├── load_packages.R                 # Install & load required packages
│   ├── load_cleaned_dataframes.R       # Load cleaned datasets
│   └── initialize_fonts.R              # Load fonts for consistent plotting
```

> **Note:** `data/` and `output/` are excluded from GitHub for privacy and reproducibility purposes.  
> An anonymized sample dataset can be provided in `data-sample/` for demonstration.

---

## How to Reproduce the Analysis

### Prerequisites
- **R** ≥ 4.0
- **RStudio** (optional, recommended)
- Required R packages are loaded via `scripts/load_packages.R`

### Steps
  1. Clone this repository:
     ```bash
     git clone https://github.com/leeannvidal/dissertation_data_analysis.git
     ```
  2. Open the project in RStudio (`.Rproj` file is local-only and not tracked in Git).
  3. Load required packages:
  ```r 
  source("scripts/load_packages.R")
  ```
  4. Run data preprocessing scripts in `scripts/data_preprocessing/` to clean and prepare data.
  5. Optionally, run:
  ```r 
  source("scripts/generate_counts.R")
  ```
  - to create token count `.tex` files for LaTeX.
  6. Load cleaned data for analysis:
  ```r 
  source("scripts/load_cleaned_dataframes.R")
  ```
  
  7. Open `docs/project_overview.Rmd` in RStudio and run it section-by-section to reproduce the analysis and visuals.  
  
> Note: The file is organized as a **build** —each section represents a step in the analysis pipeline that was developed incrementally while working on the dissertation.  
> This allows you to execute and inspect results at each stage rather than rendering the entire file in one pass.

# Workflow Overview
  1. Data Loading & Cleaning
  - `project_overview.Rmd` orchestrates the workflow.
  2. Cleaning scripts standardize and process each dataset.
  - Cleaned `.rds` files are stored in `data/cleaned_data/`.
  3. Token Count Generation
  - `generate_counts.R` calculates counts and saves `.tex` files in `data/token_counts/`.
  4. Function Loading
  - All custom functions live in `functions/` and are sourced at the start of analysis.
  5. Data Wrangling for Stats/Visuals
  - Wrangling scripts ensure transformations are centralized and reproducible.
  6. Descriptive Visuals
  - Includes methodology figures and basic descriptive statistics for each variable.
  7. Data Analysis & Results
  - Chapter-specific visuals and statistical outputs.
  
# Notes for Future Development
  - Create an anonymized sample dataset in `data-sample/` for reproducible demos.
  - Consider adding `renv` for dependency management.
  - Tag major milestones using GitHub Releases.