library(markdown)
library(dplyr)
library(digest)
library(googlesheets)
library(magrittr)


#######################################
### RETRIEVE INVENTORY FROM STORAGE ###
#######################################


DF = as.data.frame(gs_read(gs_key("1WA_w-SioIsRP2iON4LFGdvxpMx3dYMLoPO9d_kYHpmY")))

###
# Below works if running locally. It is commented out for web app version
###
# google_sheet_titles = gs_ls()$sheet_title
# if("ithemba-nursery-inventory-list" %in% google_sheet_titles){
#   google_inventory <- gs_title("ithemba-nursery-inventory-list")
#   DF = as.data.frame(gs_read(google_inventory))
# }else if("nursery_price_list_raw.csv" %in% list.files(outdir)){
#   DF = read.csv("nursery_price_list_raw.csv")
#   DF$Description = paste(DF$Description, " (", DF$Unit, ")", sep = "")
#   DF$Unit = NULL
# } else {
#   DF <- data.frame(
#     Total = rep(0.0,5),
#     Qty = integer(5),
#     Unit = c("Plug", "Plug", "Plug", "Plug", "Plug"),
#     Price = rep(1.5,5),
#     Description = c("Beetroot", "Broccoli", "Cabbage", "Carrot", "Cauliflower"))
# }

# Cleanup inventory list
DF = DF[!is.na(DF$Cost),]
DF = DF[DF$Cost>=0,]

# Make mini_DF showing total cost
mini_DF <- as.data.frame(0)
colnames(mini_DF) <- c("Total Cost")

#############################
### CUSTOMER INFO STORAGE ###
#############################

# Register sheet created previously in Google Drive
# This sheet must have the correct columns and at least one row of info already supplied

customer_info_doc <- gs_key("1kLgwG-wXpWzyOyPYiqwE2vklV5lWUlZkqE-vbPMVO-M")




#######################
### INVOICE STORAGE ###
#######################

# Run once only in order to get key for invoice sheet
#gs_new("ithemba-gardens-invoices")

# Register sheet
invoices_doc <- gs_key("1nEgjeMrNZYPhfVy27_4v8kEeeIWYTzdCBkdEQoOvPIU")

