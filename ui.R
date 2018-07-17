library(shiny)
library(rhandsontable)

# To run:
# shiny::runApp('~/Desktop/Link to GitRepos/ithemba-nursery')
# To run template:
# shiny::runApp('~/Desktop/shiny-server')

#storage_types <- c("Google Sheets (remote)" = "gsheets")
shinyUI(fluidPage(
  shinyjs::useShinyjs(),
  tags$head(includeCSS(file.path("www", "app.css"))),

  div(id = "header",
      h1(img(src='ithemba-nursery-logo.jpg', width='90%')),
  div(id = "title",
    "Order Request"
    )
  ),

# TABS

  fluidRow(
    column(12, wellPanel(
      tabsetPanel(
        id = "mainTabs", type = "tabs",
        
# FIRST TAB HERE: ABOUT

        tabPanel(
          title = "About", id ="aboutTab", value = "aboutTab",
          includeMarkdown(file.path("text", "about.md"))
          ),    

        

# SECOND TAB: PICKUP

        tabPanel(
          title = "Collection Points", id ="collectionTab", value = "collectionTab",
          includeMarkdown(file.path("text", "collection.md"))
        ),

# THIRD TAB: FORM

        # Build the form
        # tabPanel(
        #   title = "Form", id = "formTab", value = "formTab",
        #   h2("This is some form stuff")
        # )   
        tabPanel(
          title = "Order Form", id = "orderTab", value = "orderTab",

          br(),
          div(id = "form",
            textInput("name", "Name*", ""),
            textInput("email", "Email*", ""),
            textInput("phone", "Phone*", ""),
            selectInput("preferred_contact", "Preferred Contact Method",
                        c("","Email", "Phone"), selected = "Email"),
            selectInput("pickup", "Pickup Location*",
                        c("",
                          "Christ Church Hilton Forest Run (2nd Saturday of each month)",
                          "Hilton Produce Exchange (3rd Saturday of each month)",
                          "La Popote Restaurant (Every Friday)"),
                        width = "100%"),
          
          # RHOT for stock and order
          rHandsontableOutput("hot_stock"),
          br(),
          
          # Simple RHOT showing Total Cost
          rHandsontableOutput("hot_cost"),
          #h2("Total Cost:"),
          #print(total_cost),
          br(),
          br(),
          
          # Comment
          textAreaInput(inputId = "comment", label = "Comments:", width ="150%", 
                        placeholder = "Comments, questions, suggestions"),
          br(),
          
          # Submit Button
          actionButton("submit", "Submit", class = "btn-primary"),
          shinyjs::hidden(
            span(id = "submitMsg", "Submitting Order...", style = "margin-left: 15px;")
            )
          ),
          
          # Print Error messages
          shinyjs::hidden(
            div(id = "error",
                div(br(), tags$b("Error: "), span(id = "errorMsg")),
                style = "color: red;",
                "Please try again"
            )
          ),
          
          # Show Success message
          shinyjs::hidden(
            div(id = "success",
                div(br(), span(id = "successMsg")),
                "Thanks for your order! We'll email your invoice shortly."
            )
          ),

          # hidden input field tracking the timestamp of the submission
          shinyjs::hidden(textInput("timestamp", ""))#,
          
          #div(br()),
          
          # Include markdown showing banking details
          #includeMarkdown(file.path("text", "banking.md"))
        )
      )
    ))
  )
))
