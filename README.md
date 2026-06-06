# Anatomy Education Translational Gap Pipeline

This repository contains the data processing pipeline and statistical analysis for the research project investigating the translational gap in anatomy education. The project analyzes a large bibliometric dataset to classify educational literature based on its translational depth (from anatomical knowledge to clinical competence and patient healthcare impact).

## Repository Structure

### Data & Supplementary Materials
*   **`Supplementary Material #1.docx`**: Details the search strategy used in Scopus to extract the initial raw metadata.
*   **`Supplementary Material #2.csv`**: The raw bibliometric metadata extracted directly from Scopus using the search strategy (~19,900 records).
*   **`Supplementary Material #3.csv`**: The refined, filtered, and fully classified dataset focusing strictly on anatomy education (~8,000 records). This is the core dataset used for final statistical modeling.

### Source Code (`src/`)
The analytical pipeline is built in R and split into two main scripts:

*   **`01_corpus_processing.R`**: This script handles the initial data cleaning. It imports the raw data (`Supplementary Material #2.csv`), applies strict regex-based filters to remove noise, and isolates articles specifically related to anatomy education. It then automatically classifies each article into one of five hierarchical outcome levels based on its title, abstract, and keywords.
*   **`02_statistical_analysis.R`**: This script takes the classified dataset (`Supplementary Material #3.csv`) and performs the final statistical analysis. It calculates the translational depth distributions, analyzes temporal trends across publication years, and runs logistic regression models to determine if high-translational outcomes are increasing over time. It also generates the final, publication-ready multi-panel figure.

## How to Run
1. Ensure you have R installed with the following packages: `tidyverse`, `janitor`, `stringr`, `broom`, `scales`, and `patchwork`. The scripts will attempt to install any missing packages automatically.
2. Clone this repository.
3. Open your R environment and set the working directory to the `src/` folder.
4. Run `01_corpus_processing.R` to process the raw data.
5. Run `02_statistical_analysis.R` to generate the final statistics, regression models, and visualizations. Output files and figures will be automatically saved in an `outputs/` directory.
