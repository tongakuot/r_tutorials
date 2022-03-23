tweak_ss_census_data <- function(data, 
                                 filter_var,
                                 group_var, 
                                 pop_var, ...) {
  
  ss_census_tbl <- data %>% 
    
    # Select Columns of Interest
    select(...) %>% 
    
    # Rename the Columns
    set_names(
      "former region", "state", 
      "pop. category", "age category", 
      "population"
    ) %>% 
    
    # Fill in Blank Cells or NAS
    fill(`former region`,
         .direction = "down") %>% 
    
    # Modify the Pop Category
    separate(
      `pop. category`, 
      into = c("pop", "gender", "other"),
      sep = " "
    ) %>% 
    
    # Remove the Extra Columns
    select(-c(pop,other)) %>% 
    
    # Modify age category column
    mutate(
      `age category` = case_when(
        `age category` %in% c("0 to 4",  "5 to 9", "10 to 14")   ~ "0-14",
        `age category` %in% c("15 to 19", "20 to 24")            ~ "15-24",
        `age category` %in% c("25 to 29", "30 to 34")            ~ "25-34", 
        `age category` %in% c("35 to 39", "40 to 44")            ~ "35-44",
        `age category` %in% c("45 to 49", "50 to 54")            ~ "45-54",
        `age category` %in% c("55 to 59", "60 to 64")            ~ "55-64",
        `age category` %in% c("65+")                             ~ "65+",
        TRUE ~ `age category`)
    ) %>% 
    
    # Remove Unwanted Rows
    filter(
      gender != {{ filter_var }},
      `age category` != {{ filter_var }}
    ) %>% 
    
    # Summarization and Group
    group_by(across({{ group_var }})) %>% 
    summarize(
      total      = {{ pop_var }},
      .groups    = "drop"
    )
    
}
