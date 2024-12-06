# Introduction
- The project creates visualizations for one of the most popular and comprehensive EMG (Electromyography) studies to assess the muscular stimulations during different resistance training exercises mainly used in powerlifting, bodybuilding, and fitness; as well as a lot of different sports for supplementary training.
- This can be particularly useful for strength & training coaches, scientists and athletes. Though a caution needs to be taken because hypertrophy for example can not be explained only by muscle stimulation. Other factors such as stretching during exercises, time under tension, muscle damage, metabolic stress, and mechanical tension can also play a significant role but this data still shows a substantial amount of information as to which exercises can be superior for different purposes. If other factors are not completely ignored; the data can be extremely useful to select more efficient exercises.
- Information regarding muscle stimulation is also useful due to the presence of many surprising findings.

# Data
- The data had been shared by [Dr. Bret Contreras](https://bretcontreras.com/about-me/) on the popular bodybuilding forum [T-Nation](https://t-nation.com/) and it is used as a reputable source by many institutes such as the ISSA (International Sports Sciences Association) even though it has a lot of limitations because there is a lack of relevant data in the field. He named the series as: "Inside the Muscle".
- He performed the exercises in a 5 rep max condition, and collected the data by using electrical nodes on his body.
- The data has "mean" and "peak" activation numbers for different exercises in a table format. It is not ordered in any way in its original form.
- Mean activation is the mean value during the whole repetition phase while peak activation is the maximum contraction in any point of a single repetition of an exercise.
- In this project, I removed the weights used in the exercise names, and removed the duplicates (50kg bench press and 75kg bench press can be an example) by selecting the best activity among the same exercises but with different weights used. So, these charts only have unique exercises without weights used. Additionally, several different orders and averages are used to find potentially surprising results. 
- The data consists of several csv files for different muscle groups and is copied from tables directly and turned to csv format manually.

# Organization
- EMG Analysis is a concise but expressive name for the project since EMG only means Electromyography and it is only used to assess muscular response.
- The project consists of 4 R scripts inside the `scripts` folder, and 1 `raw_data` folder inside the `data` folder, containing raw data for each muscle group. Then the script creates the `processed` folder inside the `data` folder but that directory and its contents are removed at the end because they are not necessary as an output but only used as intermediate files.
- The user should only run the `00_main.R` script. The subsequent scripts are run automatically. The `01_clean.R` is to clean and the `02_transform.R` is to transform and the `03_visualize.R` is to visualize the data respectively. The naming is quite expressive and intuitive. On the other hand, neither for the folder names, nor for the file names; nothing but lowercased English alphanumeric characters and underscores are used to decrease the possibility of a filesystem problem and to increase compatibility.

# Data Cleaning
The main cleaning steps included:
- Removed weight specifications ("30 lb") from exercise names using regex.
- Trimmed any extra whitespace from exercise names. This standardization was crucial to ensure consistent exercise naming across the dataset.
- Some exercises appeared multiple times in the raw data (from different sessions with different weights). For each exercise, I kept only the record with the highest total muscle activation. This was calculated by summing the mean EMG values for all relevant muscles or group of muscles in each group.
- Since biceps measurements were included in the back/biceps dataset, I extracted these into a separate file. This allowed for independent analysis of biceps activation patterns. It also helps analyzing all back muscles together separately from the biceps muscles.
- Implemented `clean_data()` to ensure consistent processing across all datasets. The function calculates total mean activation for each muscle group. Applies the standardization rules. Removes duplicates based on highest total activation.

# Data Transformation
I performed several key transformations on the cleaned data to prepare it for analysis. The transformations were systematically applied across all muscle group datasets (back/biceps, shoulder, chest/triceps, legs, and core) using consistent methodology.

For each muscle group, I calculated:
- Mean activation: Average of all individual muscle means in the group.
- Peak activation: Average of all individual muscle peaks in the group.
- Mean and peak activation for individual muscles.
- Transformed the wide-format data into long format using `pivot_longer()`. This made the data more suitable for comparative analysis across muscles.
- Separated mean and peak activation data into distinct datasets.

Implemented a naming convention for muscles:
- Back/Biceps: Latissimus Dorsi, Middle Trapezius, Lower Trapezius.
- Shoulders: Upper Trapezius, Anterior/Lateral/Posterior Deltoid.
- Chest/Triceps: Upper/Middle/Lower Pectoralis, Triceps Long Head.
- Legs: Gluteus Maximus, Vastus Lateralis, Adductor Longus, Biceps Femoris.
- Core: Lower Rectus Abdominis, Internal/External Oblique, Lumbar Erector.

Created separate files for different analysis levels:
- transformed_[muscle_group].csv: Contains overall muscle group metrics.
- muscles_[muscle_group]_mean.csv: Individual muscle mean activations.
- muscles_[muscle_group]_peak.csv: Individual muscle peak activations.

The transformation process used a modular approach with two main functions:
- A helper function (`process_muscle_data`) to handle consistent processing across datasets.
- A main processing loop that applied transformations systematically.

# Visualization
The visualizations were designed to address the project's main objective: Identifying the most effective exercises for targeting specific muscles and muscle groups.

Implemented a consistent visual theme using `theme_minimal()` with:
- Light gray background for better readability. Some people use dark mode ans
- d with the default mode in R, the image viewer can have problems regarding contrast as the background becomes black.
- White grid lines for subtle reference points.
- Fixed dimensions (12x12 inches) and resolution (300 DPI).
- Consistent color scheme for each muscle group using a predefined color palette.

Two Main Plot Types:
**a)** Individual Muscle Plots:
- Bar charts showing top 20 exercises by activation level.
- Numerical values displayed on bars for precise reference.
- Y-axis scaled in 25% increments for easy comparison.
- Exercises ordered by activation level.
      
**b)** Stacked Bar Plots:
- Shows contribution of each muscle to total activation.
- Allows visualization of both overall effectiveness and muscle balance.
- Color-coded by muscle with a legend.
- Individual values displayed within segments.

Created plots for:
- Overall muscle group activation (mean and peak).
- Individual muscle activation (mean and peak).
- Combined muscle group analysis (such as back-biceps combined, only back muscles without biceps, latissimus dorsi).

Rationale for Visualization Choices:
Chose horizontal bar charts for:
- Easy reading of exercise names.
- Clear comparison of activation levels.
- Space efficiency with long exercise names.

Stack bars selected for muscle group analysis because they:
- Show total activation and individual muscle contributions.
- Enable quick identification of balanced exercises.
- Facilitate comparison of relative muscle involvement.

The data is limited to top 20 exercises to:
- Focus on most effective exercises.
- Maintain readability.
- Prevent information overload.

Added numerical values to:
- Provide precise measurements.
- Enable exact comparisons.
- Support detailed analysis.

The visualizations help answer the project's objectives by:
- Clearly identifying most effective exercises for each muscle or muscle group.
- Showing relative effectiveness of exercises.
- Revealing muscle activation patterns.
- Enabling comparison between mean and peak activation.
- Highlighting exercises that provide balanced muscle activation.
- Facilitating evidence based exercise selection.
