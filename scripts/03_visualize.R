# Load the required packages.
library(readr)   # for read_csv, write_csv
library(dplyr)   # for data manipulation functions
library(stringr) # for string manipulation 
library(purrr)   # for functional programming functions
library(scales)  # change the data scales if needed. It also pulls ggplot2.

# Constants
PLOT_PARAMS <- list(
  n_exercises = 20,
  width = 12,
  height = 12,
  dpi = 300
)

# Plot theme
plot_theme <- theme_minimal() +
  theme(
    plot.background = element_rect(fill = "gray95"),
    panel.background = element_rect(fill = "gray95"),
    panel.grid.major = element_line(color = "white"),
    panel.grid.minor = element_line(color = "white")
  )

# Colors for all muscle groups
COLORS <- list(
  # Back/Biceps colors
  back_mean = "steelblue",
  back_peak = "darkred",
  biceps = "#ff7f0e",
  lat = "#1f77b4",
  mid_trap = "#2ca02c",
  lower_trap = "#ff7f0e",
  
  # Shoulder colors
  shoulder_mean = "steelblue",
  shoulder_peak = "darkred",
  upper_trap = "#1f77b4",
  anterior_delt = "#2ca02c",
  lateral_delt = "#ff7f0e",
  posterior_delt = "#d62728",
  
  # Chest/Triceps colors
  chest_mean = "steelblue",
  chest_peak = "darkred",
  upper_pec = "#1f77b4",
  mid_pec = "#2ca02c",
  lower_pec = "#ff7f0e",
  tri_long = "#d62728",
  
  # Legs colors
  legs_mean = "steelblue",
  legs_peak = "darkred",
  glute = "#1f77b4",
  vastus = "#2ca02c",
  adductor = "#ff7f0e",
  hamstring = "#d62728",
  
  # Core colors
  core_mean = "steelblue",
  core_peak = "darkred",
  lower_abs = "#1f77b4",
  internal_oblique = "#2ca02c",
  external_oblique = "#ff7f0e",
  lumbar = "#d62728"
)

# Plot creation function. Helps as an abstraction to remove repetitiveness.
create_plot <- function(data, x_var, y_var, fill_color, title, y_label) {
  max_val <- max(data %>% pull({{y_var}}), na.rm = TRUE)
  break_seq <- seq(0, ceiling(max_val/25)*25, by = 25)
  
  data %>%
    arrange(desc({{y_var}})) %>%
    slice_head(n = PLOT_PARAMS$n_exercises) %>%
    ggplot(aes(x = reorder({{x_var}}, {{y_var}}), y = {{y_var}})) +
    geom_col(fill = fill_color) +
    geom_text(aes(label = round({{y_var}}, 1)), hjust = -0.2, size = 3) +
    scale_y_continuous(breaks = break_seq) +
    coord_flip() +
    plot_theme +
    labs(title = title, x = "Exercise", y = y_label)
}

create_stacked_plot <- function(data, title, activation_type) {
  data %>%
    group_by(Exercise) %>%
    summarise(Total_Activation = sum(Activation), .groups = "drop") %>%
    arrange(desc(Total_Activation)) %>%
    slice_head(n = 20) %>%
    left_join(data, by = "Exercise") %>%
    ggplot(aes(x = reorder(Exercise, Total_Activation), y = Activation, fill = Muscle)) +
    geom_bar(stat = "identity", position = "stack") +
    geom_text(position = position_stack(vjust = 0.5),
              aes(label = round(Activation, 1)),
              size = 3) +
    scale_fill_brewer(palette = "Set2") +
    coord_flip() +
    plot_theme +
    theme(
      legend.position = "bottom",
      legend.title = element_blank()
    ) +
    labs(
      title = title,
      x = "Exercise",
      y = sprintf("%s Activation (%%)", activation_type)
    )
}

# Read all datasets
datasets <- list(
  back = list(
    transformed = read_csv("data/processed/transformed_back_biceps.csv", show_col_types = FALSE),
    muscles_mean = read_csv("data/processed/muscles_back_biceps_mean.csv", show_col_types = FALSE),
    muscles_peak = read_csv("data/processed/muscles_back_biceps_peak.csv", show_col_types = FALSE),
    biceps = read_csv("data/processed/biceps_data.csv", show_col_types = FALSE)
  ),
  shoulder = list(
    transformed = read_csv("data/processed/transformed_shoulder.csv", show_col_types = FALSE),
    muscles_mean = read_csv("data/processed/muscles_shoulder_mean.csv", show_col_types = FALSE),
    muscles_peak = read_csv("data/processed/muscles_shoulder_peak.csv", show_col_types = FALSE)
  ),
  chest = list(
    transformed = read_csv("data/processed/transformed_chest_triceps.csv", show_col_types = FALSE),
    muscles_mean = read_csv("data/processed/muscles_chest_triceps_mean.csv", show_col_types = FALSE),
    muscles_peak = read_csv("data/processed/muscles_chest_triceps_peak.csv", show_col_types = FALSE)
  ),
  legs = list(
    transformed = read_csv("data/processed/transformed_legs.csv", show_col_types = FALSE),
    muscles_mean = read_csv("data/processed/muscles_legs_mean.csv", show_col_types = FALSE),
    muscles_peak = read_csv("data/processed/muscles_legs_peak.csv", show_col_types = FALSE)
  ),
  core = list(
    transformed = read_csv("data/processed/transformed_core.csv", show_col_types = FALSE),
    muscles_mean = read_csv("data/processed/muscles_core_mean.csv", show_col_types = FALSE),
    muscles_peak = read_csv("data/processed/muscles_core_peak.csv", show_col_types = FALSE)
  )
)

# Create back-biceps combined data
back_biceps_mean <- bind_rows(
  datasets$back$muscles_mean,
  mutate(datasets$back$biceps, 
         Muscle = "Biceps",
         Activation = Biceps_Mean,
         Exercise = Exercise) %>%
    select(Exercise, Muscle, Activation)
)

back_biceps_peak <- bind_rows(
  datasets$back$muscles_peak,
  mutate(datasets$back$biceps, 
         Muscle = "Biceps",
         Activation = Biceps_Peak,
         Exercise = Exercise) %>%
    select(Exercise, Muscle, Activation)
)

# Create chest-triceps combined data
chest_triceps_mean <- datasets$chest$muscles_mean
chest_triceps_peak <- datasets$chest$muscles_peak

# Initialize plots list
plots <- list()

# Back/Biceps plots (stacked versions for mean and peak)
plots[["back_mean"]] <- create_stacked_plot(
  datasets$back$muscles_mean,
  "Top 20 Exercises by Total Back Mean Activation",
  "Mean"
)

plots[["back_peak"]] <- create_stacked_plot(
  datasets$back$muscles_peak,
  "Top 20 Exercises by Total Back Peak Activation",
  "Peak"
)

plots[["biceps_mean"]] <- create_plot(
  datasets$back$biceps, Exercise, Biceps_Mean, COLORS$biceps,
  "Top 20 Exercises by Biceps Activation (Mean)", "Mean Activation (%)"
)

plots[["biceps_peak"]] <- create_plot(
  datasets$back$biceps, Exercise, Biceps_Peak, COLORS$biceps,
  "Top 20 Exercises by Biceps Activation (Peak)", "Peak Activation (%)"
)

# Shoulder plots (only stacked versions)
plots[["shoulder_stack_mean"]] <- create_stacked_plot(
  datasets$shoulder$muscles_mean,
  "Top 20 Exercises by Total Shoulder Mean Activation",
  "Mean"
)

plots[["shoulder_stack_peak"]] <- create_stacked_plot(
  datasets$shoulder$muscles_peak,
  "Top 20 Exercises by Total Shoulder Peak Activation",
  "Peak"
)

# Chest/Triceps plots
plots[["chest_mean"]] <- create_stacked_plot(
  datasets$chest$muscles_mean,
  "Top 20 Exercises by Total Chest Mean Activation",
  "Mean"
)

plots[["chest_peak"]] <- create_stacked_plot(
  datasets$chest$muscles_peak,
  "Top 20 Exercises by Total Chest Peak Activation",
  "Peak"
)

plots[["back_biceps_combined_mean"]] <- create_stacked_plot(
  back_biceps_mean,
  "Top 20 Exercises by Total Back-Biceps Mean Activation",
  "Mean"
)

plots[["back_biceps_combined_peak"]] <- create_stacked_plot(
  back_biceps_peak,
  "Top 20 Exercises by Total Back-Biceps Peak Activation",
  "Peak"
)

plots[["chest_triceps_combined_mean"]] <- create_stacked_plot(
  chest_triceps_mean,
  "Top 20 Exercises by Total Chest-Triceps Mean Activation",
  "Mean"
)

plots[["chest_triceps_combined_peak"]] <- create_stacked_plot(
  chest_triceps_peak,
  "Top 20 Exercises by Total Chest-Triceps Peak Activation",
  "Peak"
)

# Legs plots
plots[["legs_mean"]] <- create_stacked_plot(
  datasets$legs$muscles_mean,
  "Top 20 Exercises by Total Legs Mean Activation",
  "Mean"
)

plots[["legs_peak"]] <- create_stacked_plot(
  datasets$legs$muscles_peak,
  "Top 20 Exercises by Total Legs Peak Activation",
  "Peak"
)

# Core plots
plots[["core_mean"]] <- create_stacked_plot(
  datasets$core$muscles_mean,
  "Top 20 Exercises by Total Core Mean Activation",
  "Mean"
)

plots[["core_peak"]] <- create_stacked_plot(
  datasets$core$muscles_peak,
  "Top 20 Exercises by Total Core Peak Activation",
  "Peak"
)

# Create individual muscle plots for all muscle groups
muscle_configs <- list(
  back = list(
    muscles = c("Latissimus Dorsi", "Middle Trapezius", "Lower Trapezius"),
    colors = c(COLORS$lat, COLORS$mid_trap, COLORS$lower_trap)
  ),
  shoulder = list(
    muscles = c("Upper Trapezius", "Anterior Deltoid", "Lateral Deltoid", "Posterior Deltoid"),
    colors = c(COLORS$upper_trap, COLORS$anterior_delt, COLORS$lateral_delt, COLORS$posterior_delt)
  ),
  chest = list(
    muscles = c("Upper Pectoralis", "Middle Pectoralis", "Lower Pectoralis", "Triceps Long Head"),
    colors = c(COLORS$upper_pec, COLORS$mid_pec, COLORS$lower_pec, COLORS$tri_long)
  ),
  legs = list(
    muscles = c("Gluteus Maximus", "Vastus Lateralis", "Adductor Longus", "Biceps Femoris"),
    colors = c(COLORS$glute, COLORS$vastus, COLORS$adductor, COLORS$hamstring)
  ),
  core = list(
    muscles = c("Lower Rectus Abdominis", "Internal Oblique", "External Oblique", "Lumbar Erector"),
    colors = c(COLORS$lower_abs, COLORS$internal_oblique, COLORS$external_oblique, COLORS$lumbar)
  )
)

# Create individual muscle plots
for (group_name in names(muscle_configs)) {
  config <- muscle_configs[[group_name]]
  
  for (i in seq_along(config$muscles)) {
    muscle_name <- config$muscles[i]
    color <- config$colors[i]
    muscle_key <- tolower(gsub(" ", "_", muscle_name))
    
    plots[[paste0(muscle_key, "_mean")]] <- create_plot(
      datasets[[group_name]]$muscles_mean %>% filter(Muscle == muscle_name),
      Exercise, Activation, color,
      sprintf("Top 20 Exercises by %s Mean Activation", muscle_name),
      "Mean Activation (%)"
    )
    
    plots[[paste0(muscle_key, "_peak")]] <- create_plot(
      datasets[[group_name]]$muscles_peak %>% filter(Muscle == muscle_name),
      Exercise, Activation, color,
      sprintf("Top 20 Exercises by %s Peak Activation", muscle_name),
      "Peak Activation (%)"
    )
  }
}

# Create individual chest muscle plots
for (muscle in c("Upper Pectoralis", "Middle Pectoralis", "Lower Pectoralis")) {
  muscle_key <- tolower(gsub(" ", "_", muscle))
  color <- case_when(
    muscle == "Upper Pectoralis" ~ COLORS$upper_pec,
    muscle == "Middle Pectoralis" ~ COLORS$mid_pec,
    muscle == "Lower Pectoralis" ~ COLORS$lower_pec
  )
  
  # Mean activation plot
  plots[[paste0(muscle_key, "_mean")]] <- create_plot(
    datasets$chest$muscles_mean %>% filter(Muscle == muscle),
    Exercise, Activation, color,
    sprintf("Top 20 Exercises by %s Mean Activation", muscle),
    "Mean Activation (%)"
  )
  
  # Peak activation plot
  plots[[paste0(muscle_key, "_peak")]] <- create_plot(
    datasets$chest$muscles_peak %>% filter(Muscle == muscle),
    Exercise, Activation, color,
    sprintf("Top 20 Exercises by %s Peak Activation", muscle),
    "Peak Activation (%)"
  )
}

# Save plots to appropriate directories
walk2(
  names(plots),
  plots,
  ~{
    dir_name <- case_when(
      str_detect(.x, "^(back|biceps(?!_femoris)|latissimus|middle_trap|lower_trap|back_biceps)") ~ "back_biceps",  # Changed biceps$ to just biceps
      str_detect(.x, "^(shoulder|upper_trap|anterior|lateral|posterior)") ~ "shoulders",
      str_detect(.x, "^(chest|upper_pectoralis|middle_pectoralis|lower_pectoralis|triceps|chest_triceps)") ~ "chest_triceps",
      str_detect(.x, "^(legs|glute|vastus|adductor|biceps_femoris)") ~ "legs",
      str_detect(.x, "^(core|lower_rectus|internal|external|lumbar)") ~ "core",
      TRUE ~ "other"
    )
    
    if(dir_name != "other") {
      ggsave(
        paste0("output/figures/", dir_name, "/", .x, ".png"),
        .y,
        width = PLOT_PARAMS$width,
        height = PLOT_PARAMS$height,
        dpi = PLOT_PARAMS$dpi
      )
    }
  }
)