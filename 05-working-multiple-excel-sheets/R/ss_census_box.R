# ss_census_box.R
# Function for reading in state census data from an Excel file, processing it, and aggregating the data by different demographic categories. This function takes the file path as an input, reads the data from multiple sheets, cleans column names and values, filters out unwanted rows, modifies age categories, and finally summarizes the population by former_region, state, gender, and age_category.

# Function to process the state census data
process_ss_census <- function(file_path) {
  # Load necessary libraries
  library(readxl)
  library(dplyr)
  library(tidyr)
  # library(janitor)
  library(purrr)
  
  # Read and process the data
  ss_census <- 
    # Read Excel sheet names
    file_path |> 
    excel_sheets() |> 
    
    # Set sheet names as data frame names
    set_names() |> 
    
    # Read each sheet and combine them into a single data frame
    map_df(read_excel, path = file_path, .id = "state") |> 
    
    # Clean column names
    janitor::clean_names() |> 
    
    # Select columns of interest
    select(
      former_region, 
      state, 
      gender = variable_name, 
      age_category = age_name,
      population = x2008
    ) |> 
    
    # Fill in missing former_region values
    fill(former_region, .direction = "down") |> 
    
    # Clean gender values
    mutate(gender = str_remove_all(gender, "Population, | \\(Number\\)")) |> 
    
    # Remove unwanted rows
    filter(
      gender != "Total",
      age_category != "Total"
    ) |> 
    
    # Modify age categories
    mutate(
      age_category = case_when(
        age_category %in% c("0 to 4", "5 to 9")     ~ "Below 10",
        age_category %in% c("10 to 14", "15 to 19") ~ "10-19", 
        age_category %in% c("20 to 24", "25 to 29") ~ "20-29", 
        age_category %in% c("30 to 34", "35 to 39") ~ "30-39",  
        age_category %in% c("40 to 44", "45 to 49") ~ "40-49", 
        age_category %in% c("50 to 54", "55 to 59") ~ "50-64",
        TRUE ~ "65 and above"
      )
    ) |> 
    
    # Summarize data by former_region, state, gender, and age_category
    summarize(
      population = sum(population), 
      .by = c(former_region, state, gender, age_category)
    )
  
  # Return the processed data
  return(ss_census)
}

# Function to read and select specific columns from an Excel file
read_multiple_excel_sheets <- function(file) {
  
  read_xlsx(file) |> 
    select(
      `Former Region`, 
      `Region Name`, 
      `Variable Name`, 
      `Age Name`, `2008`
    )
}
