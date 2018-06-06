# Writing customer data to file for invoice
# First attempt: write.csv.
# This FAILS for the shiny server!!

DF <- data.frame(
  Total = rep(0.0,5),
  Qty = integer(5),
  Unit = c("Plug", "Plug", "Plug", "Plug", "Plug"),
  Price = rep(1.5,5),
  Description = c("Beetroot", "Broccoli", "Cabbage", "Carrot", "Cauliflower"))

cost = 10
name = "David"

out_file <- file("test_output.csv", open="w")  #creates a file in append mode
write.csv(data.frame("cost" = cost), file = out_file, row.names = FALSE)
write.csv(data.frame(), file = out_file, row.names = FALSE)
write.csv(list("name" = name), file = out_file, row.names = FALSE)
write.csv(data.frame(), file = out_file, row.names = FALSE)
write.table(DF, file=out_file, sep=",", dec=".", quote=FALSE, row.names=FALSE, append = TRUE)  #writes the data.frames
close(out_file)  #close connection to file.csv



# Second attempt: Use googlesheets
# Many of the functions for writing to file are pickier
# However, gs_edit_cells works OK
# In practice we'll use a new sheet for each invoice from the google sheet called "Invoices"

library(googlesheets)
library(magrittr)
invoices = gs_new("invoices")
gs_ws_new(invoices, ws_title = "test", row_extent = 100, col_extent = 8)
gs_add_row(invoices, ws = "test", input = c("Cost" = cost))


customer_info = data.frame(c("Name:", "Cost:"), c(name, cost))
names(customer_info) = NULL

foo <- gs_new("invoices2") %>% 
  gs_ws_rename(from = "Sheet1", to = "test")
  # In the future we'll create a new sheet by invoice number
  # BETTER: copy a template with iThemba Gardens info to new sheet 
  #          and fill in info accordingly!

foo <- foo %>%
  gs_edit_cells(ws = "test", input = customer_info)  %>%
  gs_edit_cells(ws = "test", input = DF, anchor = "R4C1")


gs_delete(foo)


################################
### TEST mailR FUNCTIONALITY ###
################################

library(mailR)
send.mail(from = "ithembagardens@gmail.com",
          to = c("dpebert7@gmail.com", "ithembagardens@gmail.com"),
          subject = "Test",
          body = "Test!",
          smtp = list(host.name = "smtp.gmail.com", port = 465, 
                      user.name = "ithembagardens", 
                      passwd = "123Password!", ssl = TRUE),
          authenticate = TRUE,
          send = TRUE)

