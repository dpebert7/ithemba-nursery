# Input stock data
# Ideally this will be from updateable Google Doc
#outdir = getwd()
#outfilename="gradebook1"

google_sheet_titles = gs_ls()$sheet_title

if("ithemba-nursery-inventory-list" %in% google_sheet_titles){
  google_inventory <- gs_title("ithemba-nursery-inventory-list")
  DF = as.data.frame(gs_read(google_inventory))
}else if("nursery_price_list_raw.csv" %in% list.files(outdir)){
  DF = read.csv("nursery_price_list_raw.csv")
  DF$Description = paste(DF$Description, " (", DF$Unit, ")", sep = "")
  DF$Unit = NULL
} else {
  DF <- data.frame(
    Total = rep(0.0,5),
    Qty = integer(5),
    Unit = c("Plug", "Plug", "Plug", "Plug", "Plug"),
    Price = rep(1.5,5),
    Description = c("Beetroot", "Broccoli", "Cabbage", "Carrot", "Cauliflower"))
}

mini_DF <- as.data.frame(0)
colnames(mini_DF) <- c("Total Cost")

# mandatory fields in the form
fields_mandatory <- c(
  "name",
  "email",
  "phone",
  "pickup"
)

# all fields in the form we want to save
fields_all <- c(
  fields_mandatory,
  "preferred_contact",
  "comment",
  "timestamp"
)

# get current Epoch time
get_time_epoch <- function() {
  return(as.integer(Sys.time()))
}

# get a formatted string of the timestamp (exclude colons as they are invalid
# characters in Windows filenames)
get_time_human <- function() {
  format(Sys.time(), "%Y%m%d-%H%M%OS")
}
