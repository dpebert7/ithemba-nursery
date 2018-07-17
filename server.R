library(shiny)
library(rhandsontable)
library(magrittr)
library(mailR)

source("storage.R")
source("helpers.R")

shinyServer(function(input, output, session) {
  
  # Give an initial value to the timestamp field
  updateTextInput(session, "timestamp", value = get_time_epoch())
  
  # Enable the Submit button when all mandatory fields are filled out
  observe({
    fields_filled <-
      fields_mandatory %>%
      sapply(function(x) !is.null(input[[x]]) && input[[x]] != "") %>%
      all
      
    shinyjs::toggleState("submit", fields_filled)
  })
  
  # Gather all the form inputs
  form_data <- reactive({
    sapply(fields_all, function(x) x = input[[x]])
  })
  
  # Hands On Table
  values <- reactiveValues()

  observe({
    if (!is.null(input$hot_stock)) {
      DF = hot_to_r(input$hot_stock)
    } else {
      if (is.null(values[["DF"]]))
        DF <- DF
      else
        DF <- values[["DF"]]
    }
    total_cost = sum(DF$Total, na.rm = TRUE)
    mini_DF <- as.data.frame(total_cost)
    colnames(mini_DF) = "Total Cost"
    values[["DF"]] <- DF
    values[["mini_DF"]] <- mini_DF
  })


  output$hot_stock <- renderRHandsontable({
    DF <- values[["DF"]]
    DF$Total = DF$Qty*DF$Cost
    DF$Total = na_if(DF$Total,0)
    DF$Season = as.character(DF$Season)
    DF$`In Stock` = as.character(DF$`In Stock`)
    if(!is.null(DF))
      rhandsontable(DF, stretchH = "allf", rowHeaders = NULL, height = 603) %>%  
                                                              #Can also try 1303 for height
      hot_col(c("Description", "Cost", "Total", "Season", "In Stock"), readOnly = TRUE) %>%
      hot_col(c("Cost","Total"), format = "$ 0/.00", language = "en-ZA") %>%
      #hot_col("Qty", td.style.background = 'grey') %>% # This isn't working :(
      hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE) %>%
      hot_validate_numeric("Qty", min = 0, max = 1000)
  })
  
  
  output$hot_cost <- renderRHandsontable({
    mini_DF = values[["mini_DF"]]
    rhandsontable(mini_DF, width = 150,
                  rowHeaders = NULL, readOnly = TRUE) %>%
    hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE) %>%
    hot_col("Total Cost", format = "$ 0/.00", language = "en-ZA") %>%
    hot_col("Total Cost", width=120)
  })
  
  # When the Submit button is clicked 
  observeEvent(input$submit, {
    # Update the timestamp field to be the current time
    updateTextInput(session, "timestamp", value = get_time_epoch())
    
    # User-experience stuff
    shinyjs::disable("submit")
    shinyjs::show("submitMsg")
    shinyjs::hide("error")
    on.exit({
      shinyjs::enable("submit")
      shinyjs::hide("submitMsg")
    })
    
    # Save the data (show an error message in case of error)
    tryCatch({
      # Gather necessary data
      form_df = form_data()
      order_df = values[["DF"]]
      order_df = order_df[!is.na(order_df$Total),]
      total_cost_df = values[["mini_DF"]]
      num_worksheets = invoices_doc$n_ws
      invoice_name = paste0(form_df[[1]],"-",num_worksheets)
      customer_info = data.frame(
        c("Invoice Name:", "Name:", "Email:", "Phone:", "Pickup:", "Preferred Contact:", 
          "Comment:", "Timestamp:", "Total Cost"), 
        c(invoice_name, form_df[[1]], form_df[[2]], form_df[[3]], form_df[[4]], form_df[[5]], 
          form_df[[6]], form_df[[7]], as.character(sum(order_df$Total))))
      names(customer_info) = NULL
      
      # save customer info to new line
      customer_info_doc <- customer_info_doc %>% 
        gs_add_row(input = t(form_df))
      
      # Save customer and order info to invoice sheet
      invoices_doc <- invoices_doc %>%
        gs_ws_new(ws_title = invoice_name, row_extent = 50, col_extent = 8) %>%
        gs_edit_cells(ws = invoice_name, input = customer_info)  %>%
        gs_edit_cells(ws = invoice_name, input = order_df, anchor = "R11C1")
      
      # Send Email
      send.mail(from = "ithembagardens@gmail.com",
                to = c("dpebert7@gmail.com", "ithembagardens@gmail.com"),
                subject = "New Order",
                body = paste("New iThemba Gardens order. Invoice:", invoice_name),
                smtp = list(host.name = "smtp.gmail.com", port = 465, 
                            user.name = "ithembagardens", 
                            passwd = "123Password!", ssl = TRUE),
                authenticate = TRUE,
                send = TRUE)
      
      #send.mail(from= "ithembagardens@gmail.com",
      #          to = form_df[[2]],
      #          subject = "Your iThemba Gardens Order",
      #          body = paste("This is the body. More info to come later."),
      #          smtp = list(host.name = "smtp.gmail.com", port = 465, 
      #                      user.name = "ithembagardens", 
      #                      passwd = "123Password!", ssl = TRUE),
      #          authenticate = TRUE,
      #          send = TRUE)
      
      # Reset
      shinyjs::reset("form")
      updateTabsetPanel(session, "mainTabs", "viewTab")
    },
    
    error = function(err) {
      shinyjs::html("errorMsg", err$message)
      shinyjs::show(id = "error", anim = TRUE, animType = "fade")      
      shinyjs::logjs(err)
    })
    
    shinyjs::html("successMsg")
    shinyjs::show(id="success", anim = TRUE, animType = "fade")
  })

  # Update the responses whenever a new submission is made or the
  # storage type is changed
  #responses_data <- reactive({
  #  input$submit
  #  load_data(input$storage)
  #})
})
