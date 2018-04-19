library(shiny)
library(rhandsontable)
library(magrittr)

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
    if(!is.null(DF))
      rhandsontable(DF, stretchH = "allf", rowHeaders = NULL, height = 303) %>% 
      hot_col(c("Description", "Cost", "Total"), readOnly = TRUE) %>%
      hot_col(c("Cost","Total"), format = "$ 0.00", language = "en-ZA") %>%
      hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE) %>%
      hot_validate_numeric("Qty", min = 0, max = 1000)
  })
  
  output$hot_cost <- renderRHandsontable({
    mini_DF = values[["mini_DF"]]
    rhandsontable(mini_DF, stretchH = "all", width = 120,
                  rowHeaders = NULL, readOnly = TRUE) %>%
    hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE) %>%
    hot_col("Total Cost", format = "$ 0.00", language = "en-ZA")
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
      save_data(form_data(), input$storage)
      shinyjs::reset("form")
      updateTabsetPanel(session, "mainTabs", "viewTab")
    },
    error = function(err) {
      shinyjs::html("errorMsg", err$message)
      shinyjs::show(id = "error", anim = TRUE, animType = "fade")      
      shinyjs::logjs(err)
    })
  })

  # Update the responses whenever a new submission is made or the
  # storage type is changed
  responses_data <- reactive({
    input$submit
    load_data(input$storage)
  })
})
