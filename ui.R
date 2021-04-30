source("app.R")
library(shiny)
library(timevis)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Adiciona o titulo que constará em cada gráfico
    HTML('<h2 style="text-align: center;"><strong>Processos executados no Data Warehouse da Funcesp</strong></h2>'),
    
    # Adiciona as abas
    navbarPage("Gráficos", 
               
               tabPanel("Gráfico por processo",  

                        # Comentário sobre o gráfico
                        HTML('<p style="text-align: left;">&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;Processos executados dentro de um periodo de tempo, com suas respectivas quantidade de processos e o tempo que levou para completar.<br/><br/></p>'),
                                                
                        sidebarLayout(
                            sidebarPanel(
                                dateInput("date1", "Escolha uma data:", format = "dd/mm/yyyy", language = "pt-BR", width = "150px"),
                                selectInput("select1", "Escolha um processo:", dfLog3$NM_ENVIRONMENT, selected = NULL,  width = "150px"),
                                actionButton(inputId = "go2", label = "Atualizar", icon("refresh"), width = "150px", height = "200"),
                                div(style="display: inline-block;vertical-align:top; width: 200px;",HTML("<br>")),
                                dateRangeInput("daterange1", "Escolha um período:", start = Sys.Date()-1, end = Sys.Date(), format = "dd/mm/yy", separator = " - ", width = "170px", language = "pt-BR"),
                                width = 2),
                            mainPanel(timevisOutput("app1"), width = 10)
                        )),
                        
                        # Adiciona o menu com opções e as opções (inputs) para o usuário alterar de acordo com a necessidade
                        # wellPanel(
                        #  div(style="display: inline-block;vertical-align:top; width: 200px;", dateInput("date1", "Escolha uma data:", format = "dd/mm/yyyy", language = "pt-BR", width = "150px")),
                        #  #div(style="display: inline-block;vertical-align:top; width: 100px;",HTML("<br>")),
                        #  div(style="display: inline-block;vertical-align:top; width: 200px;", selectInput("select1", "Escolha um processo:", dfLog3$NM_ENVIRONMENT, selected = NULL,  width = "150px")),
                        #  #div(style="display: inline-block;vertical-align:top; width: 100px;",HTML("<br>")),
                        #  div(style="display: inline-block;vertical-align:top; width: 200px;", dateRangeInput("daterange1", "Escolha um período:", start = Sys.Date()-1, end = Sys.Date(), format = "dd/mm/yy", separator = " - ", width = "170px", language = "pt-BR")),
                        #  #div(style="display: inline-block;vertical-align:top; width: 100px;",HTML("<br>")),
                        #  div(style="display: inline-block;vertical-align:top; width: 200px;", dateInput("date2", "Vá para a data de hoje:", format = "dd/mm/yyyy", language = "pt-BR", width = "170px"))),
                        #  #div(style="display: inline-block;vertical-align:top; width: 100px;",HTML("<br>")),
                        #  #div(style="display: inline-block;vertical-align:top; width: 100px;",actionButton(inputId = "go", label = "Atualizar", icon("refresh"), width = "100px", height = "200"))),
               
                        #timevisOutput("app1")),
                        
               tabPanel("Gráfico por sistema",
                        
                        sidebarLayout(
                            sidebarPanel(
                                dateInput("date1", "Escolha uma data:", format = "dd/mm/yyyy", language = "pt-BR", width = "150px"),
                                selectInput("select1", "Escolha um sistema/área:", dfLog4$NM_SYSTEM, selected = NULL,  width = "150px"),
                                actionButton(inputId = "go2", label = "Atualizar", icon("refresh"), width = "150px", height = "200"),
                                div(style="display: inline-block;vertical-align:top; width: 200px;",HTML("<br>")),
                                dateRangeInput("daterange1", "Escolha um período:", start = Sys.Date()-1, end = Sys.Date(), format = "dd/mm/yy", separator = " - ", width = "170px", language = "pt-BR"),
                                width = 2),
                            mainPanel(timevisOutput("app2"), width = 10)
                        )),
                        
                        #timevisOutput("app2")),
               
               tabPanel("Gráfico por data",
                        
                        sidebarLayout(
                            sidebarPanel(
                                dateInput("date1", "Escolha uma data:", format = "dd/mm/yyyy", language = "pt-BR", width = "150px"),
                                dateRangeInput("daterange1", "Escolha um período:", start = Sys.Date()-1, end = Sys.Date(), format = "dd/mm/yy", separator = " - ", width = "170px", language = "pt-BR"),
                                width = 2),
                            mainPanel(timevisOutput("app4"), width = 10)
                        )),
               
                        #timevisOutput("app4")),
               
               tabPanel("Gráfico por eventos individuais",
                        
                        timevisOutput("app3"))
    )
))
