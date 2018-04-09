library(shiny)
library(rhandsontable)


# To run:
# shiny::runApp('~/Desktop/Link to GitRepos/ithemba-garden')

storage_types <- c("Google Sheets (remote)" = "gsheets")


shinyUI(fluidPage(
  title = "iThemba Gardens",
  shinyjs::useShinyjs(),
  tags$head(includeCSS(file.path("www", "app.css"))),
  div(id = "header",
      div(id = "title", "iThemba Gardens")
  ),
  
  fluidRow(
    column(8, wellPanel(
      tabsetPanel(
        id = "mainTabs", type = "tabs",
        
# FIRST TAB HERE: ABOUT

        tabPanel(
          title = "About", id ="aboutTab", value = "aboutTab",
          h2("This is some about stuff")
        ),    
        

# SECOND TAB: PICKUP

        tabPanel(
          title = "Pickup", id = "pickupTab", value = "pickupTab",
          h2("This is some pickup stuff")
          ),        


# THIRD TAB: FORM

        # Build the form
        # tabPanel(
        #   title = "Form", id = "formTab", value = "formTab",
        #   h2("This is some form stuff")
        # )   
        tabPanel(
          title = "Order Form", id = "submitTab", value = "submitTab",

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
          textInput("comment", "Comments or Suggestions", width = "100%", 
                    placeholder = "Comments, questions, suggestions"),
          
          # RHOT
          rHandsontableOutput("hot"),
          br(),
          
          actionButton("submit", "Submit", class = "btn-primary"),
          shinyjs::hidden(
            span(id = "submitMsg", "Submitting...", style = "margin-left: 15px;")
            )
          ),
          shinyjs::hidden(
            div(id = "error",
                div(br(), tags$b("Error: "), span(id = "errorMsg")),
                style = "color: red;"
            )
          ),

          # hidden input field tracking the timestamp of the submission
          shinyjs::hidden(textInput("timestamp", ""))
        )
      )
    ))
  )
))
