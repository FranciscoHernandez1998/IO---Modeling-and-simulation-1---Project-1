library(shiny)
library(shinycssloaders)

num_of_servers_options <- seq(from = 1, to = 7, by = 1)

shinyUI(fluidPage(
    navbarPage(title='Project 1',
        tabPanel('Ex. 1 - Customer Queue Average',
                 fluidRow(
                   helpText('The next table displays the average size of the customers queue by day of the week 
                            based on the number of servers available at the bank')
                 ),
                 fluidRow(
                     selectInput(
                         'num_of_servers', 'Select a number of servers', num_of_servers_options, selected = 7
                     )
                 ),
                 fluidRow(
                     withSpinner(tableOutput('averages'))
                 ),
                 fluidRow(
                   helpText('It takes and average time of 8 minutes for an agent to serve a customer and it has a standard deviation of 5 minutes'),
                   helpText('The time between arrivals by day is given by the next table: ')
                 ),
                 fluidRow(
                   withSpinner(imageOutput("arrival_time_probabilities"))
                 )
        )
    )
))
