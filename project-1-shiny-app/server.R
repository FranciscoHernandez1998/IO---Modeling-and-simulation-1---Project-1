source('code.R')
library(shiny)

shinyServer(function(input, output) {
    output$averages_ex1 <- renderTable({
        get_week_average_queues(days_to_get = req(input$days_to_get_ex1),num_of_servers = input$num_of_servers_ex1)
    })
    output$arrival_time_probabilities_ex1 <- renderImage({
     list(src = 'arrival-time-probabilities.JPG', width = 600)
    }, deleteFile=FALSE)
    output$averages_ex2 <- renderTable({
      get_week_average_queue_waiting_time(days_to_get = req(input$days_to_get_ex2), 
                                            num_of_servers = input$num_of_servers_ex2, 
                                            max_queue_size = req(input$queue_max_size_ex2))
    })
    output$averages_ex3 <- renderTable({
      get_week_average_unattended_customers(days_to_get = req(input$days_to_get_ex3), 
                                            num_of_servers = input$num_of_servers_ex3, 
                                            max_queue_size = req(input$queue_max_size_ex3))
    })
})
