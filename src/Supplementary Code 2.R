############################################################
# 02_statistical_analysis.R
# Translational Gap in Anatomy Education Research
# Final analysis and figure generation
############################################################

# 1. Setup and Packages
packages <- c(
  "tidyverse",
  "janitor",
  "broom",
  "scales",
  "patchwork"
)

installed_packages <- rownames(installed.packages())

for (pkg in packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg)
  }
}

library(tidyverse)
library(janitor)
library(broom)
library(scales)
library(patchwork)

############################
# 2. Paths
############################

# Ensure the input is pointing to the final classified file
input_final <- "../Supplementary Material #3.csv"
output_dir <- "../outputs"

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

############################
# 3. Import Data
############################

df_final <- read_csv(
  input_final,
  show_col_types = FALSE
) %>%
  clean_names()

############################
# 4. Check Required Columns
############################

required_cols <- c(
  "eid",
  "year",
  "title",
  "abstract",
  "suggested_outcome_level_num",
  "suggested_outcome_level"
)

missing_cols <- setdiff(required_cols, names(df_final))

if (length(missing_cols) > 0) {
  stop(
    paste(
      "The following required columns are missing:",
      paste(missing_cols, collapse = ", ")
    )
  )
}

############################
# 5. Create Final Variables
############################

# Using suggested_outcome_level_num as the final classification.
# If manual adjudication was performed in a final_outcome_level_num column, it will use that instead.
if ("final_outcome_level_num" %in% names(df_final)) {
  df_final <- df_final %>%
    mutate(
      final_outcome_level_num = as.numeric(final_outcome_level_num)
    )
} else {
  df_final <- df_final %>%
    mutate(
      final_outcome_level_num = as.numeric(suggested_outcome_level_num)
    )
}

df_final <- df_final %>%
  mutate(
    year = as.integer(year),
    
    final_outcome_level = case_when(
      final_outcome_level_num == 4 ~ "Level 4: Patient/healthcare impact",
      final_outcome_level_num == 3 ~ "Level 3: Clinical reasoning/professional behavior",
      final_outcome_level_num == 2 ~ "Level 2: Applied anatomical skills",
      final_outcome_level_num == 1 ~ "Level 1: Anatomical knowledge",
      final_outcome_level_num == 0 ~ "Level 0: Perception/descriptive",
      TRUE ~ "Unclear/not classified"
    ),
    
    final_translational_depth = case_when(
      final_outcome_level_num %in% c(0, 1) ~ "Low translational depth",
      final_outcome_level_num == 2 ~ "Intermediate translational depth",
      final_outcome_level_num %in% c(3, 4) ~ "High translational depth",
      TRUE ~ "Unclear/not classified"
    ),
    
    high_translational = if_else(
      final_outcome_level_num %in% c(3, 4),
      1,
      0
    ),
    
    applied_or_clinical = if_else(
      final_outcome_level_num %in% c(2, 3, 4),
      1,
      0
    )
  )

############################
# 6. Generate Summary Tables
############################

corpus_summary <- df_final %>%
  summarise(
    total_articles = n(),
    min_year = min(year, na.rm = TRUE),
    max_year = max(year, na.rm = TRUE),
    classified_articles = sum(final_outcome_level != "Unclear/not classified"),
    unclear_articles = sum(final_outcome_level == "Unclear/not classified"),
    high_translational_articles = sum(high_translational, na.rm = TRUE),
    high_translational_percent_total = round(100 * mean(high_translational, na.rm = TRUE), 2)
  )

outcome_table_final <- df_final %>%
  count(final_outcome_level, sort = TRUE) %>%
  mutate(percent_total = round(100 * n / sum(n), 2))

outcome_table_classified_only <- df_final %>%
  filter(final_outcome_level != "Unclear/not classified") %>%
  count(final_outcome_level, sort = TRUE) %>%
  mutate(percent_classified = round(100 * n / sum(n), 2))

depth_table_final <- df_final %>%
  count(final_translational_depth, sort = TRUE) %>%
  mutate(percent_total = round(100 * n / sum(n), 2))

depth_table_classified_only <- df_final %>%
  filter(final_translational_depth != "Unclear/not classified") %>%
  count(final_translational_depth, sort = TRUE) %>%
  mutate(percent_classified = round(100 * n / sum(n), 2))

############################
# 7. Temporal Trends Data
############################

# Exclude current year (e.g. 2026) if incomplete
df_trend <- df_final %>%
  filter(!is.na(year), year <= 2025)

trend_high <- df_trend %>%
  group_by(year) %>%
  summarise(
    total_articles = n(),
    high_n = sum(high_translational, na.rm = TRUE),
    high_percent = round(100 * mean(high_translational, na.rm = TRUE), 2),
    applied_or_clinical_n = sum(applied_or_clinical, na.rm = TRUE),
    applied_or_clinical_percent = round(100 * mean(applied_or_clinical, na.rm = TRUE), 2),
    unclear_n = sum(final_outcome_level == "Unclear/not classified"),
    unclear_percent = round(100 * mean(final_outcome_level == "Unclear/not classified"), 2),
    .groups = "drop"
  )

############################
# 8. Logistic Regressions
############################

# Model 1: Conservative (1 = Level 3 or 4; 0 = Level 0, 1, 2, or Unclear)
# OR interpreted per decade
df_model_conservative <- df_final %>%
  filter(!is.na(year), year <= 2025) %>%
  mutate(
    year_decade = (year - 2000) / 10,
    high_translational_conservative = if_else(final_outcome_level_num %in% c(3, 4), 1, 0)
  )

model_high_conservative <- glm(
  high_translational_conservative ~ year_decade,
  data = df_model_conservative,
  family = binomial()
)

model_high_conservative_results <- tidy(model_high_conservative) %>%
  mutate(
    odds_ratio = exp(estimate),
    conf_low = exp(estimate - 1.96 * std.error),
    conf_high = exp(estimate + 1.96 * std.error)
  )

# Model 2: Sensitivity (Excluded Unclear/not classified)
df_model_classified_only <- df_final %>%
  filter(!is.na(year), year <= 2025, final_outcome_level != "Unclear/not classified") %>%
  mutate(
    year_decade = (year - 2000) / 10,
    high_translational_classified = if_else(final_outcome_level_num %in% c(3, 4), 1, 0)
  )

model_high_classified <- glm(
  high_translational_classified ~ year_decade,
  data = df_model_classified_only,
  family = binomial()
)

model_high_classified_results <- tidy(model_high_classified) %>%
  mutate(
    odds_ratio = exp(estimate),
    conf_low = exp(estimate - 1.96 * std.error),
    conf_high = exp(estimate + 1.96 * std.error)
  )

# Export essential model data
write_csv(
  bind_rows(
    model_high_conservative_results %>% mutate(model = "Conservative (All data)"),
    model_high_classified_results %>% mutate(model = "Sensitivity (Classified only)")
  ),
  file.path(output_dir, "02_logistic_regression_models.csv")
)

############################################################
# 9. Master Figure Generation
############################################################

outcome_order <- c(
  "Level 0: Perception/descriptive",
  "Level 1: Anatomical knowledge",
  "Level 2: Applied anatomical skills",
  "Level 3: Clinical reasoning/professional behavior",
  "Level 4: Patient/healthcare impact",
  "Unclear/not classified"
)

depth_order <- c(
  "Low translational depth",
  "Intermediate translational depth",
  "High translational depth",
  "Unclear/not classified"
)

outcome_labels_short <- c(
  "Level 0: Perception/descriptive" = "Level 0",
  "Level 1: Anatomical knowledge" = "Level 1",
  "Level 2: Applied anatomical skills" = "Level 2",
  "Level 3: Clinical reasoning/professional behavior" = "Level 3",
  "Level 4: Patient/healthcare impact" = "Level 4",
  "Unclear/not classified" = "Unclear"
)

depth_labels_short <- c(
  "Low translational depth" = "Low",
  "Intermediate translational depth" = "Intermediate",
  "High translational depth" = "High",
  "Unclear/not classified" = "Unclear"
)

outcome_colors <- c(
  "Level 0: Perception/descriptive" = "#D7EAF7",
  "Level 1: Anatomical knowledge" = "#A9D6E5",
  "Level 2: Applied anatomical skills" = "#61A5C2",
  "Level 3: Clinical reasoning/professional behavior" = "#2C7DA0",
  "Level 4: Patient/healthcare impact" = "#014F86",
  "Unclear/not classified" = "#B8BDC6"
)

depth_colors <- c(
  "Low translational depth" = "#CDEFE3",
  "Intermediate translational depth" = "#52B788",
  "High translational depth" = "#1B4332",
  "Unclear/not classified" = "#B8BDC6"
)

theme_q1 <- theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold", size = 17, hjust = 0, color = "gray10"),
    plot.subtitle = element_text(size = 14, color = "gray30"),
    axis.title = element_text(size = 15, face = "bold", color = "gray15"),
    axis.text = element_text(size = 14, color = "gray20"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = "gray88", linewidth = 0.35),
    legend.position = "bottom",
    legend.title = element_text(size = 14, face = "bold"),
    legend.text = element_text(size = 13),
    plot.margin = margin(12, 18, 12, 12)
  )

# Panel A: Outcome level distribution
panel_a_data <- outcome_table_final %>%
  mutate(
    final_outcome_level = factor(final_outcome_level, levels = rev(outcome_order)),
    label = paste0(round(percent_total, 1), "%")
  )

panel_a <- ggplot(panel_a_data, aes(x = final_outcome_level, y = percent_total, fill = final_outcome_level)) +
  geom_col(width = 0.72, show.legend = FALSE) +
  geom_text(aes(label = label), hjust = -0.12, size = 5, color = "gray10", fontface = "bold") +
  coord_flip(clip = "off") +
  scale_fill_manual(values = outcome_colors) +
  scale_x_discrete(labels = outcome_labels_short) +
  scale_y_continuous(limits = c(0, max(panel_a_data$percent_total) * 1.24), expand = expansion(mult = c(0, 0.02))) +
  labs(title = "Outcome level distribution", x = NULL, y = "Articles (%)") +
  theme_q1

# Panel B: Translational depth distribution
panel_b_data <- depth_table_final %>%
  mutate(
    final_translational_depth = factor(final_translational_depth, levels = rev(depth_order)),
    label = paste0(round(percent_total, 1), "%")
  )

panel_b <- ggplot(panel_b_data, aes(x = final_translational_depth, y = percent_total, fill = final_translational_depth)) +
  geom_col(width = 0.72, show.legend = FALSE) +
  geom_text(aes(label = label), hjust = -0.12, size = 5, color = "gray10", fontface = "bold") +
  coord_flip(clip = "off") +
  scale_fill_manual(values = depth_colors) +
  scale_x_discrete(labels = depth_labels_short) +
  scale_y_continuous(limits = c(0, max(panel_b_data$percent_total) * 1.24), expand = expansion(mult = c(0, 0.02))) +
  labs(title = "Translational depth distribution", x = NULL, y = "Articles (%)") +
  theme_q1

# Panel C: Outcome levels across periods
panel_c_data <- df_trend %>%
  mutate(
    period = cut(year, breaks = c(1999, 2004, 2009, 2014, 2019, 2025),
                 labels = c("2000–2004", "2005–2009", "2010–2014", "2015–2019", "2020–2025"),
                 include.lowest = TRUE),
    final_outcome_level = factor(final_outcome_level, levels = outcome_order)
  ) %>%
  filter(!is.na(period)) %>%
  count(period, final_outcome_level) %>%
  group_by(period) %>%
  mutate(
    percent = 100 * n / sum(n),
    label = if_else(percent >= 8, paste0(round(percent, 0), "%"), ""),
    label_color = if_else(final_outcome_level %in% c("Level 3: Clinical reasoning/professional behavior", "Level 4: Patient/healthcare impact"), "white", "gray10")
  ) %>%
  ungroup()

panel_c <- ggplot(panel_c_data, aes(x = period, y = percent, fill = final_outcome_level)) +
  geom_col(width = 0.78, color = "white", linewidth = 0.35) +
  geom_text(aes(label = label, color = label_color), position = position_stack(vjust = 0.5), size = 4.2, fontface = "bold", show.legend = FALSE) +
  scale_color_identity() +
  scale_fill_manual(values = outcome_colors, labels = outcome_labels_short) +
  scale_y_continuous(labels = function(x) paste0(x, "%"), limits = c(0, 100), expand = expansion(mult = c(0, 0))) +
  labs(title = "Outcome levels across publication periods", x = "Publication period", y = "Articles (%)", fill = "Outcome level") +
  theme_q1 +
  theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 13), panel.grid.major.y = element_line(color = "gray88", linewidth = 0.35))

# Panel D: Annual articles by translational depth
panel_d_data <- df_trend %>%
  count(year, final_translational_depth) %>%
  group_by(final_translational_depth) %>%
  complete(year = 2000:2025, fill = list(n = 0)) %>%
  ungroup() %>%
  mutate(final_translational_depth = factor(final_translational_depth, levels = depth_order))

panel_d <- ggplot(panel_d_data, aes(x = year, y = n, color = final_translational_depth)) +
  geom_line(linewidth = 1.25) +
  geom_point(size = 2.6) +
  scale_color_manual(values = depth_colors, labels = depth_labels_short) +
  scale_x_continuous(breaks = seq(2000, 2025, 5)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(title = "Annual articles by translational depth", x = "Publication year", y = "Number of articles", color = "Translational depth") +
  theme_q1 +
  theme(panel.grid.major.y = element_line(color = "gray88", linewidth = 0.35))

# Combine Panels
figure_2 <- (panel_a | panel_b) / (panel_c | panel_d) +
  plot_layout(guides = "collect") +
  plot_annotation(
    title = "Outcome levels and translational depth in anatomy education research",
    subtitle = "Exploratory Scopus-based snapshot of the refined anatomy education subcorpus. Temporal analyses were restricted to 2000–2025.",
    tag_levels = "A",
    theme = theme(
      plot.title = element_text(face = "bold", size = 23, hjust = 0, color = "gray10"),
      plot.subtitle = element_text(size = 16, color = "gray30", hjust = 0),
      plot.tag = element_text(face = "bold", size = 19, color = "gray10"),
      legend.position = "bottom"
    )
  ) & theme(legend.position = "bottom")

# Save Figure
ggsave(
  filename = file.path(output_dir, "Figure_2_Translational_Depth.png"),
  plot = figure_2,
  width = 16,
  height = 12,
  dpi = 300
)

############################
# 10. Console Output Summary
############################

cat("\n==============================\n")
cat("FINAL ANALYSIS SUMMARY\n")
cat("==============================\n\n")

cat("Total refined corpus:", nrow(df_final), "\n")
cat("Years:", min(df_final$year, na.rm = TRUE), "-", max(df_final$year, na.rm = TRUE), "\n\n")

cat("Outcome distribution:\n")
print(outcome_table_final)

cat("\nTranslational depth:\n")
print(depth_table_final)

cat("\nConservative logistic model: high-translational outcome ~ year_decade\n")
print(model_high_conservative_results)

cat("\nSensitivity logistic model among classified records only:\n")
print(model_high_classified_results)

cat("\n==============================\n")
cat("Analysis complete. Figure 2 saved to:", file.path(output_dir, "Figure_2_Translational_Depth.png"), "\n")
