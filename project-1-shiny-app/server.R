source('first-exercise.R')
library(shiny)

shinyServer(function(input, output) {
    output$averages <- renderTable({
        get_week_days_average_queues(num_of_servers = input$num_of_servers)
    })
})
