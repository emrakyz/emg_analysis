# Load the required packages
library(readr)   # for read_csv, write_csv
library(dplyr)   # for data manipulation functions
library(stringr) # for string replacement

# Clean data function
clean_data <- function(data, data_type) {
  total_col <- case_when(
    data_type == "back_biceps" ~ "Total_Back_Mean",
    data_type == "shoulder" ~ "Total_Shoulder_Mean",
    data_type == "chest_triceps" ~ "Total_Chest_Mean",
    data_type == "legs" ~ "Total_Legs_Mean",
    data_type == "core" ~ "Total_Core_Mean"
  )
  
  mean_cols <- names(data)[grep("Mean$", names(data))]
  
  data %>%
    mutate(
      !!total_col := reduce(select(., mean_cols), `+`),
      Exercise = str_replace_all(Exercise, "\\d+\\s*lb\\s+", "") %>% str_trim()
    ) %>%
    group_by(Exercise) %>%
    slice_max(order_by = !!sym(total_col), n = 1) %>%
    ungroup() %>%
    select(-!!sym(total_col))
}

# Read and clean each dataset
raw_back <- read_csv("data/raw/raw_back_biceps.csv", show_col_types = FALSE)
raw_shoulder <- read_csv("data/raw/raw_shoulder.csv", show_col_types = FALSE)
raw_chest <- read_csv("data/raw/raw_chest_triceps.csv", show_col_types = FALSE)
raw_legs <- read_csv("data/raw/raw_legs.csv", show_col_types = FALSE)
raw_core <- read_csv("data/raw/raw_core.csv", show_col_types = FALSE)

# Extract and save biceps data
biceps_data <- raw_back %>%
  select(Exercise, contains("Biceps")) %>%
  # Clean exercise names like other data
  mutate(
    Exercise = str_replace_all(Exercise, "\\d+\\s*lb\\s+", "") %>% str_trim()
  ) %>%
  # Keep only highest activation for duplicates
  group_by(Exercise) %>%
  slice_max(order_by = Biceps_Mean, n = 1) %>%
  ungroup()

write_csv(biceps_data, "data/processed/biceps_data.csv")

# Clean and save each dataset
cleaned_back <- clean_data(raw_back, "back_biceps")
cleaned_shoulder <- clean_data(raw_shoulder, "shoulder")
cleaned_chest <- clean_data(raw_chest, "chest_triceps")
cleaned_legs <- clean_data(raw_legs, "legs")
cleaned_core <- clean_data(raw_core, "core")

write_csv(cleaned_back, "data/processed/cleaned_back_biceps.csv")
write_csv(cleaned_shoulder, "data/processed/cleaned_shoulder.csv")
write_csv(cleaned_chest, "data/processed/cleaned_chest_triceps.csv")
write_csv(cleaned_legs, "data/processed/cleaned_legs.csv")
write_csv(cleaned_core, "data/processed/cleaned_core.csv")

# Print summary for each dataset
datasets <- list(
  back_biceps = list(raw = raw_back, cleaned = cleaned_back),
  shoulder = list(raw = raw_shoulder, cleaned = cleaned_shoulder),
  chest_triceps = list(raw = raw_chest, cleaned = cleaned_chest),
  legs = list(raw = raw_legs, cleaned = cleaned_legs),
  core = list(raw = raw_core, cleaned = cleaned_core)
)

walk(names(datasets), ~{
  cat(sprintf("\n%s dataset:\n", .x))
  cat(sprintf("Original exercises: %d\nCleaned exercises: %d\nDuplicates removed: %d\n",
              nrow(datasets[[.x]]$raw), 
              nrow(datasets[[.x]]$cleaned),
              nrow(datasets[[.x]]$raw) - nrow(datasets[[.x]]$cleaned)))
})