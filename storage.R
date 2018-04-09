#install.packages("markdown")
library(markdown)
library(dplyr)
library(digest)
#library(DBI)
#library(RMySQL)
#library(RSQLite)
#library(mongolite)

library(googlesheets)
#library(aws.s3)
#library(rdrop2)

DB_NAME <- "shinyapps"
TABLE_NAME <- "google_form_mock"


load_data <- function(type) {
  fxn <- get_load_fxn(type)
  data <- do.call(fxn, list())
  
  # Just for a nicer UI, if there is no data, construct an empty
  # dataframe so that the colnames will still be shown
  if (nrow(data) == 0) {
    data <-
      matrix(nrow = 0, ncol = length(fields_all),
             dimnames = list(list(), fields_all)) %>%
      data.frame
  }
  data %>% dplyr::arrange(desc(timestamp))
}

#### Method 5: Google Sheets ####

#gs_auth() #token = "googlesheets_token.rds"

save_data_gsheets <- function(data) {
  #print(TABLE_NAME)
  #print(gs_title)
  #print(data)
  TABLE_NAME %>% gs_title %>% gs_add_row(input = t(data))
}
load_data_gsheets <- function() {
  TABLE_NAME %>% gs_title %>% gs_read_csv
}