# Supplementary Material

**What are we measuring in anatomy education? An exploratory mapping from anatomical learning to clinical competence**

Oscar Andrés Alzate-Mejia, Claudia Milena Garizábalo-Dávila, Indiana Luz Rojas Torres, Andy A. Acosta-Monterrosa

## Contents
* [Supplementary Appendix 1. Complete Scopus search strategy](#supplementary-appendix-1-complete-scopus-search-strategy)
* [Supplementary Dataset 1. Raw Scopus metadata](#supplementary-dataset-1-raw-scopus-metadata)
* [Supplementary Dataset 2. Refined and outcome-classified dataset](#supplementary-dataset-2-refined-and-outcome-classified-dataset)
* [Supplementary Code 1. Corpus processing and metadata-based classification](#supplementary-code-1-corpus-processing-and-metadata-based-classification)
* [Supplementary Code 2. Statistical analysis and figure generation](#supplementary-code-2-statistical-analysis-and-figure-generation)
* [Supplementary Note 1. Interpretation of missing values and not-applicable fields](#supplementary-note-1-interpretation-of-missing-values-and-not-applicable-fields)

---

## Supplementary Appendix 1. Complete Scopus search strategy

### Database and search date
* **Database**: Scopus
* **Search date**: 2 June 2026
* **Coverage period**: 2000 to 2 June 2026

The search strategy was constructed from two conceptual domains derived from Medical Subject Headings, one related to anatomy and anatomical sciences and another related to medical education.

### Domain #1. Anatomy and anatomical sciences
MeSH Unique ID: D000715
* Anatom*
* Visible Human Project*
* Osteolog*
* Embryolog*
* Teratolog*
* Histolog*
* Neuroanatom*

**Final**: `TITLE-ABS ( "Anatom*" OR "Visible Human Project" OR "Osteolog*" OR "Embryolog*" OR "Teratolog*" OR "Histolog*" OR "Neuroanatom*" )` = 1,574,250 documents found.

### Domain #2. Medical education
MeSH Unique ID: D004501
* Medical Education*
* Internship and Residency
* Medical Internship*
* Internship
* House Staff
* Residenc*
* Medical Residenc*
* Teaching Round*
* Clinical Round*
* Morning Report*
* Education
* Educational Activit*
* Literacy Program*
* Workshop*
* Training Program*
* Teaching
* Computer User Training*
* Educational Model*
* Problem-Based Learning*
* Remedial Teaching*
* Self-Directed Learning as Topic
* Simulation Training
* Study Guides as Topic

**Final**: `TITLE-ABS ( "Medical Education*" OR "Internship and Residency" OR "Medical Internship*" OR "Internship" OR "House Staff" OR "Residenc*" OR "Medical Residenc*" OR "Teaching Round*" OR "Clinical Round*" OR "Morning Report*" OR "Education" OR "Educational Activit*" OR "Literacy Program*" OR "Workshop*" OR "Training Program*" OR "Teaching" OR "Computer User Training*" OR "Educational Model*" OR "Problem-Based Learning*" OR "Remedial Teaching*" OR "Self-Directed Learning as Topic" OR "Simulation Training" OR "Study Guides as Topic" )` = 3,116,616 documents found.

### Final
**#1 + #2**: 27,743 documents found.

#### Excluded documents
* Conference paper: 1,589
* Book chapter: 1,036
* Letter: 519
* Book: 382
* Conference review: 302
* Note: 184
* Editorial: 136
* Short survey: 108
* Erratum: 51
* Retracted: 15
* Data paper: 12
* Article in press: 272
* Year of publication: 3,181 

**Documents finally included**: 19,956 documents found.

**Final query**: `TITLE-ABS ( "Anatom*" OR "Visible Human Project" OR "Osteolog*" OR "Embryolog*" OR "Teratolog*" OR "Histolog*" OR "Neuroanatom*" ) AND TITLE-ABS ( "Medical Education*" OR "Internship and Residency" OR "Medical Internship*" OR "Internship" OR "House Staff" OR "Residenc*" OR "Medical Residenc*" OR "Teaching Round*" OR "Clinical Round*" OR "Morning Report*" OR "Education" OR "Educational Activit*" OR "Literacy Program*" OR "Workshop*" OR "Training Program*" OR "Teaching" OR "Computer User Training*" OR "Educational Model*" OR "Problem-Based Learning*" OR "Remedial Teaching*" OR "Self-Directed Learning as Topic" OR "Study Guides as Topic" ) AND PUBYEAR > 1999 AND ( LIMIT-TO ( PUBSTAGE , "final" ) ) AND ( LIMIT-TO ( DOCTYPE , "ar" ) OR LIMIT-TO ( DOCTYPE , "re" ) )`.

---

## Supplementary Dataset 1. Raw Scopus metadata

### File identification
**Description**: This dataset contains the complete bibliographic metadata exported from Scopus using the final search strategy described in Supplementary Appendix 1.
The dataset contains 19,956 records and 27 variables.

### Variables included
The raw Scopus export contains the following fields:
1. Authors 
2. Author full names 
3. Author(s) ID 
4. Title 
5. Year 
6. Source title 
7. Volume 
8. Issue 
9. Article number 
10. Page start 
11. Page end 
12. Cited by 
13. DOI 
14. Link 
15. Affiliations 
16. Authors with affiliations 
17. Abstract 
18. Author keywords 
19. Index keywords 
20. Correspondence address 
21. Publisher 
22. PubMed ID 
23. Document type 
24. Publication stage 
25. Open access status 
26. Source 
27. Electronic Identifier 

The Electronic Identifier field was used to identify and remove duplicate records during corpus processing.
The complete dataset is available in CSV format through the repository identified in the Data Sharing Statement of the main manuscript.

---

## Supplementary Dataset 2. Refined and outcome-classified dataset

### File identification
**Description**: This dataset contains the refined anatomy education corpus used for the descriptive and statistical analyses.
The dataset contains 8,088 original articles and 57 variables. It includes bibliographic metadata, normalized text fields, corpus-refinement indicators, outcome-classification indicators, translational-depth variables, and classification evidence.

### Corpus refinement variables
The dataset includes variables indicating whether each record contained:
* A predefined anatomy education phrase 
* Anatomy terminology near education terminology 
* Anatomy terminology near learner terminology 
* Evidence meeting the anatomy education corpus definition 
* A predefined non-educational noise context 

These variables were used to distinguish anatomy education research from records in which anatomy-related or education-related terms appeared in unrelated clinical, epidemiological, demographic, or computational contexts.

### Outcome-classification variables
The dataset includes indicators corresponding to:
* Perception or descriptive outcomes 
* Anatomical knowledge outcomes 
* Applied anatomical skills 
* Clinical reasoning or professional behavior 
* Patient or healthcare impact 
* Unclear or not classified records 

The classification followed a hierarchical structure in which the highest qualifying outcome category identified in the available metadata was assigned.

The outcome categories were interpreted as follows:
* **Level 0. Perception or descriptive outcomes**: This category includes satisfaction, attitudes, perceived usefulness, preferences, motivation, self-confidence, feedback, and descriptive reports of educational experiences.
* **Level 1. Anatomical knowledge**: This category includes anatomical knowledge, knowledge retention, test scores, examination performance, quizzes, multiple-choice questions, structure identification, and related measures of anatomical learning.
* **Level 2. Applied anatomical skills**: This category includes surface anatomy, imaging interpretation, ultrasound training, spatial ability, dissection skills, procedural skills, simulation-based performance, virtual reality, augmented reality, three-dimensional models, three-dimensional printing, and related applied tasks.
* **Level 3. Clinical reasoning or professional behavior**: This category includes clinical reasoning, diagnostic reasoning, clinical decision-making, clinical competence, OSCE performance, workplace-based assessment, clinical performance, professional behavior, and transfer to clinical practice.
* **Level 4. Patient or healthcare impact**: This category includes patient safety, diagnostic errors, medical or procedural errors, complication rates, adverse events, quality of care, patient outcomes, and healthcare outcomes linked to an educational context.
* **Unclear or not classified**: This category includes records for which the title, abstract, and available keywords did not contain sufficiently explicit information to support a reliable outcome-level assignment. This category should not be interpreted as evidence that the study lacked an educational outcome. It indicates that the available bibliographic metadata did not provide enough information for classification using the predefined rules.

### Translational-depth variables
The five outcome levels were grouped into three translational-depth categories:
* **Low translational depth**: Levels 0 and 1 
* **Intermediate translational depth**: Level 2 
* **High translational depth**: Levels 3 and 4 

Records without sufficient classification evidence were retained as unclear or not classified.

### Missing metadata
All records in the refined dataset contained a title and an abstract.
Author keywords were unavailable for 1,132 records, corresponding to 14.00% of the refined corpus.
Index keywords were unavailable for 1,954 records, corresponding to 24.16% of the refined corpus.
The absence of author or index keywords did not automatically exclude a record or determine its outcome category because titles and abstracts were also used during corpus processing and classification.
The complete refined dataset is available in CSV format through the repository identified in the Data Sharing Statement of the main manuscript.

---

## Supplementary Code 1. Corpus processing and metadata-based classification

### Purpose
This script performs:
1. Package installation and loading 
2. Importation of the raw Scopus CSV file 
3. Standardization of column names 
4. Replacement of missing text fields with empty strings for rule execution 
5. Duplicate removal using the Scopus Electronic Identifier 
6. Restriction by publication year, publication stage, and document type 
7. Restriction of outcome classification to original articles 
8. Construction of normalized text fields 
9. Application of phrase and proximity rules 
10. Exclusion of predefined non-educational noise contexts 
11. Application of outcome-level term dictionaries 
12. Hierarchical outcome classification 
13. Exportation of the classified corpus 

### Software requirements
The script was developed in R and uses the following packages:
* tidyverse 
* janitor 
* stringr 

### Input file
The expected input file is the raw Scopus export described in Supplementary Dataset 1.

### Output
The script exports the classified corpus to the outputs directory.
The complete executable script is available through the repository identified in the Data Sharing Statement of the main manuscript.

---

## Supplementary Code 2. Statistical analysis and figure generation

### Purpose
This script performs:
1. Importation of the refined and classified dataset 
2. Verification of required variables 
3. Construction of final outcome-level variables 
4. Construction of translational-depth variables 
5. Calculation of descriptive corpus summaries 
6. Calculation of outcome-level distributions 
7. Calculation of translational-depth distributions 
8. Temporal analyses 
9. Conservative logistic regression analysis 
10. Sensitivity analysis restricted to classified records 
11. Exportation of model results 
12. Generation of the multipanel outcome and translational-depth figure 

### Software requirements
The script was developed in R and uses the following packages:
* tidyverse 
* janitor 
* broom 
* scales 
* patchwork 

### Input file
The expected input file is the refined and outcome-classified dataset described in Supplementary Dataset 2.

### Statistical models
The script estimates two logistic regression models examining temporal changes in high-translational outcomes.
* **Conservative model**: In the conservative model, records assigned to Levels 3 or 4 were coded as high-translational outcomes. Records assigned to Levels 0, 1, or 2 and unclear or not classified records were coded as non-high-translational outcomes. The publication-year variable was expressed in decades from the year 2000.
* **Sensitivity model**: The sensitivity model was restricted to records assigned to one of the five outcome levels. Records assigned to Levels 3 or 4 were coded as high-translational outcomes, while records assigned to Levels 0, 1, or 2 were coded as non-high-translational outcomes.

### Temporal restriction
Because the search was conducted on 2 June 2026, the year 2026 represented an incomplete publication year. Temporal analyses were therefore restricted to records published from 2000 to 2025.

### Figure generation
The script generates a multipanel figure containing:
* Distribution of articles across outcome levels 
* Distribution according to translational depth 
* Proportional outcome-level distribution across publication periods 
* Annual number of articles according to translational depth 

The complete executable script is available through the repository identified in the Data Sharing Statement of the main manuscript.

---

## Note: Interpretation of missing values and not-applicable fields

Blank cells or NA values in bibliographic fields indicate that the corresponding information was unavailable in the Scopus export or was not applicable to the individual record.
These values should not be interpreted as evidence that the corresponding study characteristic was absent unless the variable was specifically constructed as a binary classification indicator.
For descriptive outputs in which statistical significance was not evaluated, NA in a significance field indicates that an inferential significance test was not applicable to that output. It does not represent an omitted p value from a statistical test that was performed.
