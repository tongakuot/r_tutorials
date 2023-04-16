# OUR FUNCTION FOR CLEANING AND TRANSFORMING SOUTH SUDAN 2008 CENSUS DATA

box::use(
  dplyr[filter, select, mutate, summarize, case_when],
  purrr[map_df],
  readxl[read_excel, read_xlsx],
  janitor[clean_names],
  stringr[str_detect, str_remove_all],
  tidyr[fill]
)

#'@export
#'
tweak_census <- function(path, 
                         condition, 
                         pattern, 
                         group_var, 
                         ...) {
  # box::use(
  #   dplyr[filter, select, mutate, summarize, case_when],
  #   purrr[map_df],
  #   readxl[read_excel, read_xlsx],
  #   janitor[clean_names],
  #   stringr[str_detect, str_remove_all],
  #   tidyr[fill]
  # )
  
  census <- path |>
    
    # map_df(read_xlsx)
    # map_df(file_path, ~read_excel(.x))
    map_df(\(x) read_xlsx(x)) |> 
    
    # Select columns of interest
    clean_names() |> 
    select(...) |>
    
    fill(
      former_region, .direction = "down"
    ) |> 
    
    # Transform column values
    mutate(
      gender = str_remove_all(gender, {{ pattern }})
    ) |> 
    
    # Remove unwanted rows
    filter({{ condition }}) |> 
    
    mutate(
      age_category = case_when(
        str_detect(age_category, "0 to 4|5 to 9|10 to 14") ~ "0-14",
        str_detect(age_category, "15 to 19|20 to 24|25 to 29") ~ "15-29",
        str_detect(age_category, "30 to 34|35 to 39|40 to 44|45 to 49") ~ "30-49",
        str_detect(age_category, "50 to 54|55 to 59|60 to 64") ~ "50-64",
        TRUE ~ "65+"
      )
    ) |> 
    
    # Grouping and summarization
    summarize(
      total = sum(population),
      .by = {{ group_var }}
    )
}

#' @export
calc_state_totals <- function(data, group_var) {
  
  # box::use(dplyr[summarize])
  
  state <- data |> 
    
    summarize(
      total = sum(total),
      .by = {{ group_var }}
    )
}