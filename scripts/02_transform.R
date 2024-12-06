# Load the required packages
library(readr)   # for read_csv, write_csv
library(dplyr)   # for data manipulation functions
library(stringr) # for string manipulation
library(purrr)   # for functional programming functions

# Helper function to process muscle data
process_muscle_data <- function(data, data_type, type) {
  muscle_config <- list(
    back_biceps = list(
      cols = c("Lat", "Mid_Trap", "Lower_Trap"),
      names = c(
        "Lat" = "Latissimus Dorsi",
        "Mid_Trap" = "Middle Trapezius",
        "Lower_Trap" = "Lower Trapezius"
      )
    ),
    shoulder = list(
      cols = c("Upper_Trap", "Anterior_Delt", "Lateral_Delt", "Posterior_Delt"),
      names = c(
        "Upper_Trap" = "Upper Trapezius",
        "Anterior_Delt" = "Anterior Deltoid",
        "Lateral_Delt" = "Lateral Deltoid",
        "Posterior_Delt" = "Posterior Deltoid"
      )
    ),
    chest_triceps = list(
      cols = c("Upper_Pec", "Mid_Pec", "Lower_Pec", "Tri_Long_Head"),
      names = c(
        "Upper_Pec" = "Upper Pectoralis",
        "Mid_Pec" = "Middle Pectoralis",
        "Lower_Pec" = "Lower Pectoralis",
        "Tri_Long_Head" = "Triceps Long Head"
      )
    ),
    legs = list(
      cols = c("Glute_Max", "Vastus_Lateralis", "Adductor_Longis", "Biceps_Femoris"),
      names = c(
        "Glute_Max" = "Gluteus Maximus",
        "Vastus_Lateralis" = "Vastus Lateralis",
        "Adductor_Longis" = "Adductor Longus",
        "Biceps_Femoris" = "Biceps Femoris"
      )
    ),
    core = list(
      cols = c("Lower_Rectus_Abdominis", "Internal_Oblique", "External_Oblique", "Lumbar_Erector"),
      names = c(
        "Lower_Rectus_Abdominis" = "Lower Rectus Abdominis",
        "Internal_Oblique" = "Internal Oblique",
        "External_Oblique" = "External Oblique",
        "Lumbar_Erector" = "Lumbar Erector"
      )
    )
  )
  
  config <- muscle_config[[data_type]]
  col_names <- paste0(config$cols, "_", type)
  
  data %>%
    select(Exercise, all_of(col_names)) %>%
    pivot_longer(
      cols = contains(type),
      names_to = "Muscle",
      values_to = "Activation"
    ) %>%
    mutate(
      Muscle = str_replace_all(
        str_remove(Muscle, paste0("_", type)),
        config$names
      )
    )
}

# Process each dataset
datasets <- c("back_biceps", "shoulder", "chest_triceps", "legs", "core")

for(dataset in datasets) {
  # Read cleaned data
  cleaned_data <- read_csv(sprintf("data/processed/cleaned_%s.csv", dataset), show_col_types = FALSE)
  
  # Get mean columns for this dataset
  mean_cols <- names(cleaned_data)[grep("Mean$", names(cleaned_data))]
  peak_cols <- names(cleaned_data)[grep("Peak$", names(cleaned_data))]
  
  # Transform and save main data
  cleaned_data %>%
    mutate(
      !!paste0(tools::toTitleCase(dataset), "_Mean") := reduce(select(., mean_cols), `+`) / length(mean_cols),
      !!paste0(tools::toTitleCase(dataset), "_Peak") := reduce(select(., peak_cols), `+`) / length(peak_cols)
    ) %>%
    write_csv(sprintf("data/processed/transformed_%s.csv", dataset))
  
  # Process and save individual muscle data
  muscles_mean <- process_muscle_data(cleaned_data, dataset, "Mean")
  muscles_peak <- process_muscle_data(cleaned_data, dataset, "Peak")
  
  write_csv(muscles_mean, sprintf("data/processed/muscles_%s_mean.csv", dataset))
  write_csv(muscles_peak, sprintf("data/processed/muscles_%s_peak.csv", dataset))
}