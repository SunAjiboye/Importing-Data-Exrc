library(shiny)
library(rio)
library(shinyFeedback)
library(DT)

# Load dataset
data <- rio::import("mtcars.csv")
summary(mtcars)

ui <- fluidPage(
  useShinyFeedback(),
  titlePanel("File Upload with Error Handling"),
  sidebarLayout(
    sidebarPanel(
      fileInput(
        inputId = "fileUpload",
        label = "Upload a File",
        multiple = FALSE,
        accept = c(".csv", ".xlsx", ".txt", ".json")
      )
    ),
    mainPanel(
      DTOutput("fileTable")
    )
  )
)

server <- function(input, output) {
  fileData <- reactive({
    req(input$fileUpload)
    message("Attempting to load: ", input$fileUpload$datapath)  # Debug
    tryCatch({
      data <- rio::import(input$fileUpload$datapath)
      showFeedbackSuccess("fileUpload", "File loaded successfully!")
      message("Data loaded: ", nrow(data), " rows")  # Debug
      return(data)
    }, error = function(e) {
      showFeedbackDanger("fileUpload", paste("Error:", e$message))
      message("Error: ", e$message)  # Debug
      return(NULL)
    })
  })
  
  output$fileTable <- renderDT({
    req(fileData())
    datatable(fileData(), options = list(pageLength = 10, scrollX = TRUE))
  })
}

shinyApp(ui = ui, server = server)
