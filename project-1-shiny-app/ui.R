library(shiny)
library(shinycssloaders)

num_of_servers_options <- seq(from = 1, to = 7, by = 1)

shinyUI(fluidPage(
    navbarPage(title='Project 1',
        tabPanel('Ex. 1 - Customer Queue Average',
                 fluidRow(
                     selectInput(
                         "num_of_servers", "Select a number of servers", num_of_servers_options, selected = 7
                     )
                 ),
                 fluidRow(
                     withSpinner(tableOutput("averages"))
                 )
        )
    )
))
