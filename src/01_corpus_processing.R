############################################################
# 01_corpus_processing.R
# Translational gap in anatomy education research
# Cleaning, filtering, and classification pipeline
############################################################

# 1. Setup and Packages
packages <- c(
  "tidyverse",
  "janitor",
  "stringr"
)

installed <- rownames(installed.packages())

for (pkg in packages) {
  if (!pkg %in% installed) install.packages(pkg)
}

library(tidyverse)
library(janitor)
library(stringr)

############################################################
# 2. Paths
############################################################

# Assuming this script is run from the 'src' folder
input_file <- "../Supplementary Material #2.csv"
output_dir <- "../outputs"

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

############################################################
# 3. Import and Clean Data
############################################################

df_raw <- read_csv(input_file, show_col_types = FALSE)

df <- df_raw %>%
  clean_names()

needed_cols <- c(
  "eid", "title", "year", "abstract", "author_keywords",
  "index_keywords", "document_type", "publication_stage"
)

for (col in needed_cols) {
  if (!col %in% names(df)) df[[col]] <- NA_character_
}

df <- df %>%
  mutate(
    year = as.integer(year),
    title = replace_na(title, ""),
    abstract = replace_na(abstract, ""),
    author_keywords = replace_na(author_keywords, ""),
    index_keywords = replace_na(index_keywords, ""),
    document_type = replace_na(document_type, ""),
    publication_stage = replace_na(publication_stage, "")
  )

############################################################
# 4. Initial Filtering
############################################################

df_clean <- df %>%
  distinct(eid, .keep_all = TRUE) %>%
  filter(
    year > 1999,
    publication_stage == "Final",
    document_type %in% c("Article", "Review")
  )

df_articles <- df_clean %>%
  filter(document_type == "Article")

############################################################
# 5. Text Preparation
############################################################

df_articles <- df_articles %>%
  mutate(
    text_core = str_to_lower(
      paste(title, abstract, author_keywords, sep = " ")
    ),
    text_core = str_squish(text_core),
    
    text_filter = str_to_lower(
      paste(title, abstract, author_keywords, index_keywords, sep = " ")
    ),
    text_filter = str_squish(text_filter)
  )

############################################################
# 6. Proximity Function
############################################################

near_regex <- function(a, b, n = 8) {
  paste0(
    "\\b(", a, ")\\b(?:\\W+\\w+){0,", n, "}\\W+\\b(", b, ")\\b|",
    "\\b(", b, ")\\b(?:\\W+\\w+){0,", n, "}\\W+\\b(", a, ")\\b"
  )
}

############################################################
# 7. Anatomy Education Specific Filter
############################################################

anatomy_terms <- paste(
  c(
    "anatom\\w*", "gross anatomy", "clinical anatomy",
    "neuroanatom\\w*", "histolog\\w*", "embryolog\\w*",
    "osteolog\\w*", "cadaver\\w*", "dissection\\w*",
    "prosection\\w*"
  ),
  collapse = "|"
)

education_terms <- paste(
  c(
    "educat\\w*", "teach\\w*", "learn\\w*", "pedagog\\w*",
    "curricul\\w*", "course\\w*", "classroom\\w*",
    "laborator\\w*", "training", "workshop\\w*"
  ),
  collapse = "|"
)

learner_terms <- paste(
  c(
    "student\\w*", "undergraduate\\w*", "medical student\\w*",
    "dental student\\w*", "resident\\w*", "trainee\\w*",
    "learner\\w*", "novice\\w*"
  ),
  collapse = "|"
)

specific_phrases <- paste(
  c(
    "anatomy education", "anatomical education",
    "medical anatomy education", "gross anatomy education",
    "gross anatomy course", "gross anatomy laboratory",
    "teaching anatomy", "learning anatomy",
    "anatomy teaching", "anatomy learning",
    "clinical anatomy teaching", "clinical anatomy education",
    "histology education", "histology teaching",
    "embryology education", "embryology teaching",
    "neuroanatomy education", "neuroanatomy teaching",
    "cadaveric dissection", "cadaver dissection",
    "dissection laboratory", "dissection course",
    "surface anatomy teaching", "radiological anatomy teaching",
    "radiologic anatomy teaching"
  ),
  collapse = "|"
)

noise_terms <- paste(
  c(
    "teaching hospital", "teaching and referral hospital",
    "patient education", "health literacy",
    "education level", "educational level", "level of education",
    "training dataset", "training data set", "training set",
    "training cohort", "validation cohort",
    "machine learning model", "deep learning algorithm",
    "convolutional neural network", "retrospective cohort",
    "case-control study", "case control study",
    "survival analysis", "hazard ratio", "odds ratio",
    "confidence interval", "95% ci"
  ),
  collapse = "|"
)

df_edu <- df_articles %>%
  mutate(
    has_specific_phrase = str_detect(
      text_filter,
      regex(specific_phrases, ignore_case = TRUE)
    ),
    has_anatomy_near_education = str_detect(
      text_filter,
      regex(near_regex(anatomy_terms, education_terms, 10), ignore_case = TRUE)
    ),
    has_anatomy_near_learner = str_detect(
      text_filter,
      regex(near_regex(anatomy_terms, learner_terms, 12), ignore_case = TRUE)
    ),
    anatomy_education_core = has_specific_phrase |
      has_anatomy_near_education |
      has_anatomy_near_learner,
    noise_context = str_detect(
      text_filter,
      regex(noise_terms, ignore_case = TRUE)
    )
  ) %>%
  filter(
    anatomy_education_core == TRUE,
    noise_context == FALSE
  )

############################################################
# 8. Strict Dictionary Classification
############################################################

perception_terms <- paste(
  c(
    "perception\\w*", "perceived", "satisfaction", "satisfied",
    "attitude\\w*", "opinion\\w*", "feedback", "acceptability",
    "self-confidence", "student confidence", "confidence in anatomy",
    "confidence in learning", "motivation\\w*", "preference\\w*",
    "student experience\\w*", "learner experience\\w*",
    "survey", "questionnaire", "likert"
  ),
  collapse = "|"
)

knowledge_terms <- paste(
  c(
    "anatomical knowledge", "anatomy knowledge", "knowledge of anatomy",
    "knowledge retention", "retention of knowledge",
    "learning gain\\w*", "learning outcome\\w*",
    "test score\\w*", "exam score\\w*", "examination score\\w*",
    "quiz\\w*", "multiple choice", "\\bmcq\\b",
    "written test", "written examination", "academic performance",
    "structure identification", "anatomical identification",
    "identify anatomical structures",
    "identification of anatomical structures"
  ),
  collapse = "|"
)

skills_terms <- paste(
  c(
    "practical skill\\w*", "procedural skill\\w*", "technical skill\\w*",
    "psychomotor skill\\w*", "spatial ability", "spatial visualization",
    "spatial reasoning", "three-dimensional understanding",
    "3d understanding", "imaging interpretation", "image interpretation",
    "radiological anatomy", "radiologic anatomy", "radiographic anatomy",
    "ultrasound training", "ultrasound teaching",
    "sonography training", "sonography teaching",
    "surface anatomy", "palpation", "dissection skill\\w*",
    "dissection performance", "simulation-based", "simulator",
    "virtual reality", "augmented reality", "three-dimensional model",
    "3d model", "3d printing", "laparoscopy training",
    "laparoscopic training", "surgical simulation",
    "procedural performance"
  ),
  collapse = "|"
)

clinical_terms <- paste(
  c(
    "clinical reasoning", "diagnostic reasoning",
    "clinical decision-making", "clinical decision making",
    "diagnostic decision-making", "diagnostic decision making",
    "clinical competence", "clinical competency", "clinical performance",
    "objective structured clinical examination", "\\bosce\\b",
    "workplace-based assessment", "workplace performance",
    "transfer to clinical practice", "transfer into clinical practice",
    "diagnostic performance", "case-based reasoning",
    "clinical case reasoning", "professional behavior",
    "professional behaviour"
  ),
  collapse = "|"
)

patient_terms <- paste(
  c(
    "patient outcome\\w*", "patient safety",
    "adverse event\\w*", "diagnostic error\\w*",
    "medical error\\w*", "surgical error\\w*",
    "procedural error\\w*", "complication rate\\w*",
    "reduction in complications", "reduced complications",
    "quality of care", "healthcare outcome\\w*"
  ),
  collapse = "|"
)

education_context <- paste(
  c(
    "student\\w*", "learner\\w*", "trainee\\w*", "resident\\w*",
    "undergraduate\\w*", "medical education", "dental education",
    "anatomy education", "teaching", "learning", "training",
    "course", "curriculum", "workshop", "simulation", "intervention"
  ),
  collapse = "|"
)

############################################################
# 9. Automatic Classification Execution
############################################################

df_auto <- df_edu %>%
  mutate(
    perception_flag = str_detect(
      text_core,
      regex(perception_terms, ignore_case = TRUE)
    ),
    knowledge_flag_raw = str_detect(
      text_core,
      regex(knowledge_terms, ignore_case = TRUE)
    ),
    knowledge_near_anatomy_flag = str_detect(
      text_core,
      regex(
        near_regex(
          "anatom\\w*|histolog\\w*|embryolog\\w*|neuroanatom\\w*",
          "knowledge|retention|test|exam|quiz|score|identification",
          8
        ),
        ignore_case = TRUE
      )
    ),
    knowledge_flag = knowledge_flag_raw | knowledge_near_anatomy_flag,
    skills_flag = str_detect(
      text_core,
      regex(skills_terms, ignore_case = TRUE)
    ),
    clinical_flag = str_detect(
      text_core,
      regex(clinical_terms, ignore_case = TRUE)
    ),
    patient_flag_raw = str_detect(
      text_core,
      regex(patient_terms, ignore_case = TRUE)
    ),
    education_context_flag = str_detect(
      text_core,
      regex(education_context, ignore_case = TRUE)
    ),
    patient_flag = patient_flag_raw & education_context_flag,
    
    auto_outcome_level_num = case_when(
      patient_flag ~ 4,
      clinical_flag ~ 3,
      skills_flag ~ 2,
      knowledge_flag ~ 1,
      perception_flag ~ 0,
      TRUE ~ NA_real_
    ),
    auto_outcome_level = case_when(
      auto_outcome_level_num == 4 ~ "Level 4: Patient/healthcare impact",
      auto_outcome_level_num == 3 ~ "Level 3: Clinical reasoning/professional behavior",
      auto_outcome_level_num == 2 ~ "Level 2: Applied anatomical skills",
      auto_outcome_level_num == 1 ~ "Level 1: Anatomical knowledge",
      auto_outcome_level_num == 0 ~ "Level 0: Perception/descriptive",
      TRUE ~ "Unclear/not classified"
    )
  )

############################################################
# 10. Export Classified Corpus
############################################################

# We create a single export file containing the relevant variables 
# and empty columns for manual adjudication if needed.

classified_corpus <- df_auto %>%
  select(
    eid, year, title, abstract, author_keywords, text_core,
    auto_outcome_level_num, auto_outcome_level,
    patient_flag, clinical_flag, skills_flag, knowledge_flag, perception_flag
  ) %>%
  mutate(
    final_outcome_level_num = NA_real_,
    final_outcome_level = NA_character_,
    adjudication_notes = NA_character_
  )

write_csv(
  classified_corpus,
  file.path(output_dir, "01_classified_corpus.csv")
)

# Print a quick summary to the console
auto_summary <- df_auto %>%
  count(auto_outcome_level, sort = TRUE) %>%
  mutate(percent = round(100 * n / sum(n), 2))

cat("\n==============================\n")
cat("AUTOMATIC CLASSIFICATION SUMMARY\n")
cat("==============================\n")
print(auto_summary)
cat("\nResults successfully saved to:", file.path(output_dir, "01_classified_corpus.csv"), "\n")
