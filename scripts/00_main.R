# Load the required packages
library(purrr) # for functional programming functions

# Function to check and create directories
create_directories <- function() {
  dirs <- c(
    "data/processed",
    "output/figures/back_biceps",
    "output/figures/shoulders",
    "output/figures/chest_triceps",
    "output/figures/legs",
    "output/figures/core"
  )
  
  walk(dirs, ~dir.create(., recursive = TRUE, showWarnings = FALSE))
}

# Function to run script with error handling
run_script <- function(script_name, step_number) {
  cat(sprintf("\nStep %d: Running %s...\n", step_number, script_name))
  
  tryCatch({
    start_time <- Sys.time()
    source(file.path("scripts", script_name))
    end_time <- Sys.time()
    
    cat(sprintf("✓ Completed successfully in %.2f seconds\n", 
                as.numeric(end_time - start_time, units = "secs")))
    return(TRUE)
    
  }, error = function(e) {
    cat(sprintf("✗ Error in %s:\n%s\n", script_name, e$message))
    return(FALSE)
  })
}

# Main execution function
main <- function() {
  cat("EMG Analysis Pipeline\n")
  cat("=====================\n")
  
  # Ensure working directory is correct
  if (!file.exists("data/raw/raw_back_biceps.csv")) {
    stop("Please ensure you're in the project root directory and data exists")
  }
  
  # Create necessary directories
  create_directories()
  
  # Define scripts to run in order
  scripts <- c(
    "01_clean.R",
    "02_transform.R",
    "03_visualize.R"
  )
  
  # Run each script
  results <- map2(scripts, seq_along(scripts), run_script)
  
  # Remove unnecessary directory
  unlink("data/processed", recursive = TRUE)
  
  # Final summary
  cat("\nPipeline Summary\n")
  cat("================\n")
  
  # Unlist needed to suppress the warning
  if (all(unlist(results))) {
    cat("✓ All steps completed successfully!\n")
    cat("\nOutputs:\n")
    cat("- Cleaned data in data/processed/\n")
    cat("- Transformed data in data/processed has been removed./\n")
    cat("- Plots in output/figures/\n")
  } else {
    cat("✗ Some steps failed. Please check the errors above.\n")
    failed_scripts <- scripts[!unlist(results)]
    cat("Failed scripts:\n")
    walk(failed_scripts, ~cat(sprintf("- %s\n", .)))
  }
}

# Run the pipeline
main()
