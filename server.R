library(timevis)
library(shiny)
source("app.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$app1 <- renderTimevis(timevis(dataLog, 
                                         distinct(dataLogGroups), 
                                         showZoom = TRUE, 
                                         options = list(orientation = 'top', showCurrentTime = TRUE),
                                         height = 700
                                         #addCustomTime(Sys.Date() - 1, "yesterday")
    ) %>% setWindow(Sys.Date() - 1,Sys.Date() + 1))
    
    output$app2 <- renderTimevis(timevis(dataLog2, 
                                         distinct(dataLogGroups2), 
                                         showZoom = TRUE, 
                                         options = list(orientation = 'top', showCurrentTime = TRUE),
                                         height = 700
                                         #addCustomTime(Sys.Date() - 1, "yesterday")
    ) %>% setWindow(Sys.Date() - 1,Sys.Date() + 1))
    
    output$app3 <- renderTimevis(timevis(dataLog3, 
                                         showZoom = TRUE, 
                                         options = list(orientation = 'top', showCurrentTime = TRUE),
                                         height = 700
                                         #addCustomTime(Sys.Date() - 1, "yesterday")
    ) %>% setWindow(Sys.Date() - 1,Sys.Date() + 1))
    
    output$app4 <- renderTimevis(timevis(dataLog4, 
                                         showZoom = TRUE, 
                                         options = list(orientation = 'top', showCurrentTime = TRUE),
                                         height = 700
                                         #addCustomTime(Sys.Date() - 1, "yesterday")
    ) %>% setWindow(Sys.Date() - 1,Sys.Date() + 1))

})
