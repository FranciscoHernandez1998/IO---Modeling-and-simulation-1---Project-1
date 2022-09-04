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
                         'num_of_servers_ex1', 'Select a number of servers', num_of_servers_options, selected = 7
                     )
                 ),
                 fluidRow(
                   numericInput(
                     'days_to_get_ex1', 
                     'Enter how many days of the week to display: ',
                     value = 7,
                     min = 1,
                     max = 7,
                     step = 1
                   )
                 ),
                 fluidRow(
                     withSpinner(tableOutput('averages_ex1'))
                 ),
                 fluidRow(
                   helpText('Simulations were made considering that it takes an average time of 8 minutes for an agent to serve a customer and it has a standard deviation of 5 minutes'),
                   helpText('The time between arrivals by day is given by the next table: ')
                 ),
                 fluidRow(
                   withSpinner(imageOutput("arrival_time_probabilities_ex1"))
                 )
        ),
        tabPanel('Ex. 3 - Unattended Customers Average',
                 fluidRow(
                   helpText('The next table displays the average amount of unattended customers
                            due to a maximum size of the waiting queue at the bank')
                 ),
                 fluidRow(
                   selectInput(
                     'num_of_servers_ex3', 'Select a number of servers', num_of_servers_options, selected = 7
                   )
                 ),
                 fluidRow(
                   numericInput(
                     'days_to_get_ex3', 
                     'Enter how many days of the week to display: ',
                     value = 7,
                     min = 1,
                     max = 7,
                     step = 1
                   )
                 ),
                 fluidRow(
                   numericInput(
                     'queue_max_size_ex3', 
                     'Enter a maximum number for the queue of the bank: ',
                     value = 10,
                     min = 1,
                     step = 1
                   )
                 ),
                 fluidRow(
                   withSpinner(tableOutput('averages_ex3'))
                 )
        )
    )
))
