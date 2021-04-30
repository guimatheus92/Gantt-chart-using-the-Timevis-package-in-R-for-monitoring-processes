if (interactive()) {

# ------------------------------------------------------------
# Crie uma conexão com o banco de dados chamado "channel"

# ------------------------------------------------------------
# Carrega os pacotes abaixo
library(shiny)
library(timevis)
library(RODBC)
library(DBI)
library(dplyr)
library(lubridate)
library(reshape2)
library(shiny)

# Verifico o diretório que se encontra o R
getwd()

# Ajusto o diretório
setwd("Choose your R folder")

# ------------------------------------------------------------

# Se você estiver usando a autenticação do sistema operacional (o computador já sabe quem você é porque está logado)
# Você pode excluir a parte uid = "USERNAME".

#myConn <-odbcConnect("DWDESENV", uid="SYS_R", pwd=password)

# Pergunta ao usuario qual o "Username" utilizado no banco de dados
username = rstudioapi::showPrompt(title = "Username", message = "Username", default = "")

# Abre a conexão de acordo com o nome do DSN do driver ODBC, nome do usuario e senha
channel <- odbcConnect("YOUR SERVER", uid=username, pwd=rstudioapi::askForPassword("Digite sua senha: "), believeNRows=FALSE)

# Ou poderá digitar a senha manualmente
#channel <- odbcConnect("YOUR SERVER", uid="YOUR USER NAME", pwd="YOUR PASSWORD", believeNRows=FALSE)

# Verifique se a conexão está funcionando (opcional)
#odbcGetInfo(channel)

# Descubra quais tabelas estão disponíveis (opcional)
#Tables <- sqlTables(channel, schema="DW_FUNCESP")

SELECT1 <- (
  "SELECT c.nm_system, b.nm_environment, d.dt_timestart, d.dt_timeend, f.*
FROM DW_FUNCESP.F_BI_LOGS_DETAILS F
LEFT JOIN DW_FUNCESP.D_BI_ENVIRONMENTS b
ON f.id_environment = b.id_environment
LEFT JOIN DW_FUNCESP.D_BI_SYSTEMS c
ON c.id_system = f.id_system
LEFT JOIN DW_FUNCESP.D_BI_LOGS d
ON d.id_log = f.ID_LOG
WHERE 1=1
--AND DT_LOG >= TRUNC(SYSDATE)-1
AND f.ID_PROCEDURE IN (SELECT DISTINCT ID_OBJ_FILHO ID_PROCEDURE
                     FROM DW_FUNCESP.D_BI_DEPENDENCIES DP
                        , DW_FUNCESP.D_BI_SYSTEMS SI
                        , DW_FUNCESP.D_BI_JOBSCHEDULES JB
                        , DW_FUNCESP.D_BI_PACKAGES PK
                        , DW_FUNCESP.D_BI_PROCEDURES PO
                        , DW_FUNCESP.D_BI_OBJECTS OB
                     WHERE 1=1
                      --AND SI.CD_SIGLA = 'SC'     -- SIGLA DO SISTEMA QUE SE QUER ACHAR
                      AND JB.ID_SYSTEM = SI.ID_SYSTEM
                      AND PK.ID_JOBSCHEDULE = JB.ID_JOBSCHEDULE
                      AND OB.CD_OBJECT = 'PACKAGE'  -- PARA FORÇAR O TIPO DO OBJETO PAI NA RELAÇÃO
                      AND DP.ID_TPOBJ_PAI = OB.ID_OBJECT
                      AND DP.ID_OBJ_PAI = PK.ID_PACKAGE -- IDENTIFICA TODOS OS PACOTES
                      AND DP.ID_OBJ_FILHO = PO.ID_PROCEDURE -- E TRAS OS PROCEDIMENTOS EXECUTADOS
                     )"
)

# Caso queira fazer algum select de teste, poderá testar abaixo
#sqlQuery(channel, SELECT1)

# Consulte o banco de dados e coloque os resultados no quadro de dados "dataframe"
dfLog <- sqlQuery(channel, SELECT1)

# Fecha a conexão criada com o banco de dados
close(channel)

# Verifico se é um dataframe
is.data.frame(dfLog)

# Visualizo o dataframe
#dfLog

# Verifico a quantidade de linhas e colunas do dataframe
dim(dfLog)

# Verifico a estrutura do dataframe
str(dfLog)

# Crio um subset do dataset original, para fazer alterações
dfLog2 <- subset(dfLog, select = c("DT_LOG", "DT_TIMESTART", "DT_TIMEEND","ID_ENVIRONMENT","NM_ENVIRONMENT","ID_SYSTEM", "NM_SYSTEM", "QT_TIMESECS","QT_SUCCESS","QT_ERRORS","QT_LOGS"))

# Adiciono uma coluna DT_TIMESTART concatenando duas colunas e transformando em data
#dfLog2 <- cbind(DT_TIMESTART = as.POSIXct(paste(dfLog2$DT_LOG, dfLog2$HR_START), format="%Y-%m-%d %H:%M:%S"), dfLog2)

# Adiciono uma coluna DT_TIMEEND somando com a quantidade de segundos que levou cada processo
#dfLog2 <- cbind(DT_TIMEEND = dfLog2$DT_TIMESTART + seconds(dfLog2$QT_TIMESECS), dfLog2)

# Deleto a coluna que não vamos mais utilizar no dataframe
#dfLog2$HR_START <- NULL

# Crio um novo subset agrupando os dados por ambiente
dfLog3 <- dfLog2 %>%
  group_by(DT_LOG, ID_ENVIRONMENT, NM_ENVIRONMENT) %>%
    summarise(DT_TIMESTART = min(DT_TIMESTART), DT_TIMEEND = max(DT_TIMEEND), QT_TIMESECS = sum(QT_TIMESECS), QT_SUCCESS = sum(QT_SUCCESS), QT_ERRORS = sum(QT_ERRORS), QT_LOGS= sum(QT_LOGS))

# Mantenho apenas a data de ontem
#dfLog3 <- dfLog3 %>% filter(DT_LOG >= (Sys.Date() - 1))

# Crio um novo subset agrupando os dados por ambiente
dfLog4 <- dfLog2 %>%
  group_by(DT_LOG, ID_SYSTEM, NM_SYSTEM) %>%
  summarise(DT_TIMESTART = min(DT_TIMESTART), DT_TIMEEND = max(DT_TIMEEND), QT_TIMESECS = sum(QT_TIMESECS), QT_SUCCESS = sum(QT_SUCCESS), QT_ERRORS = sum(QT_ERRORS), QT_LOGS = sum(QT_LOGS))

# Mantenho apenas a data de ontem
#dfLog4 <- dfLog4 %>% filter(DT_LOG >= (Sys.Date() - 1))

# Crio um novo subset mantenho apenas a data de ontem
dfLog5 <- dfLog2 %>% filter(DT_LOG >= (Sys.Date() - 1))  

# Converte todas as colunas como Factor para Char nos dois dataframe
i <- sapply(dfLog2, is.factor)
dfLog2[i] <- lapply(dfLog2[i], as.character)
i <- sapply(dfLog3, is.factor)
dfLog3[i] <- lapply(dfLog3[i], as.character)
i <- sapply(dfLog4, is.factor)
dfLog4[i] <- lapply(dfLog4[i], as.character)

# Verifico o resumo dos dados abaixo
summary(dfLog3$QT_SUCCESS, dfLog$QT_ERRORS)
summary(dfLog4$QT_SUCCESS, dfLog$QT_ERRORS)

# Crio uma função de template que vai constar no gráfico, utilizando valores qualquer
TemplateProcesso <- function(value1, value2, value3, value4, value5) {
  sprintf(
    '<p>Horario inicio:&nbsp;%s&nbsp;&nbsp;Horario fim:&nbsp;%s<br />Quantidade de processos executados:&nbsp;%s<br />Tempo decorrido:&nbsp;%s&nbsp;&nbsp;Tempo de processamento:&nbsp;%s</p>',
    value1, value2, value3, value4, value5,
    gsub("\\s", "", value1), value1, 
    gsub("\\s", "", value2), value2,
    gsub("\\s", "", value3), value3,
    gsub("\\s", "", value4), value4,
    gsub("\\s", "", value5), value5
  )
}


# ------------------------------------------------------------
# Crio o dataframe que será utilizado no gráfico de Gantt
# Para carregar as datas no gráfico de Gantt do pacote Timevis, é necessario que as datas estejam no formato "YYYY-MM-DD HH:MM:SS"

# ----- Dataframe que será utilizado para visão do log por processo (NM_ENVIRONMENT)

dataLog <- data.frame(
  title = paste("Processo:", c(dfLog3$NM_ENVIRONMENT), sep = " "),
  content = c(TemplateProcesso(strftime(dfLog3$DT_TIMESTART, format="%H:%M:%S"), strftime(dfLog3$DT_TIMEEND, format="%H:%M:%S"), dfLog3$QT_LOGS, seconds_to_period((dfLog3$DT_TIMEEND - dfLog3$DT_TIMESTART)), seconds_to_period(dfLog3$QT_TIMESECS))),
  start = c(dfLog3$DT_TIMESTART),
  end = c(dfLog3$DT_TIMEEND),
  #style = c(TemplateCores(nrow(table(dfLog3$NM_ENVIRONMENT)))),
  group = c(dfLog3$ID_ENVIRONMENT))


dataLogGroups <- data.frame(
  id = c(dfLog3$ID_ENVIRONMENT), 
  content = c(dfLog3$NM_ENVIRONMENT),
  style = "font-weight: bold")

timevis(dataLog,distinct(dataLogGroups),showZoom = TRUE,options = list(orientation = 'top')) %>%
  setWindow(Sys.Date() - 1,Sys.Date() + 1) %>%
  addCustomTime(Sys.Date() - 1, "yesterday")

# ------------------------------------------------------------

# ----- Dataframe que será utilizado para visão do log por sistema (NM_SYSTEM)

dataLog2 <- data.frame(
  title = paste("Processo:", c(dfLog4$NM_SYSTEM), sep = " "),
  content = c(TemplateProcesso(strftime(dfLog4$DT_TIMESTART, format="%H:%M:%S"), strftime(dfLog4$DT_TIMEEND, format="%H:%M:%S"), dfLog4$QT_LOGS, seconds_to_period((dfLog4$DT_TIMEEND - dfLog4$DT_TIMESTART)), seconds_to_period(dfLog4$QT_TIMESECS))),
  start = c(dfLog4$DT_TIMESTART),
  end = c(dfLog4$DT_TIMEEND),
  # style = c("border-color: black; font-size: 15px; Background: #492378; Color: white; font-weight: normal", 
  #           "border-color: black; font-size: 15px; Background: #5E2C99; Color: white; font-weight: normal", 
  #           "border-color: black; font-size: 15px; Background: #7638C2; Color: white; font-weight: normal;", 
  #           "border-color: black; font-size: 15px; Background: #8C43E6; Color: white; font-weight: normal;", 
  #           NA,
  #           "border-color: black; font-size: 15px; Background: #b578ff; Color: white; font-weight: normal;"),
  group = c(dfLog4$ID_SYSTEM))

dataLogGroups2 <- data.frame(
  id = c(dfLog4$ID_SYSTEM), 
  content = c(dfLog4$NM_SYSTEM),
  style = "font-weight: bold")

timevis(dataLog2,distinct(dataLogGroups2),showZoom = TRUE,options = list(orientation = 'top')) %>%
  setWindow(Sys.Date() - 1,Sys.Date() + 1)

# ------------------------------------------------------------

# ----- Dataframe que será utilizado para visão do log por processos iniciados em um determinado horario

dataLog3 <- data.frame(
  #title = paste("Processo:", c(dfLog5$QT_PROCEDURE), sep = " "),
  #content = c(TemplateProcesso(df$Qt_recs, df$Tempo)),
  start = c(dfLog5$DT_TIMESTART))

timevis(dataLog3,showZoom = TRUE,options = list(orientation = 'top')) %>%
  setWindow(Sys.Date() - 1,Sys.Date() + 1)

# ------------------------------------------------------------

# ----- Dataframe que será utilizado para visão do log por data agrupada

dataLog4 <- data.frame(
  #title = paste("Processo:", c(dfLog2$NM_ENVIRONMENT), sep = " "),
  #content = c(TemplateProcesso(df$Qt_recs, df$Tempo)),
  start = c(dfLog5$DT_TIMESTART),
  end = c(dfLog5$DT_TIMEEND))

timevis(dataLog4,showZoom = TRUE,options = list(orientation = 'top')) %>%
  setWindow(Sys.Date() - 1,Sys.Date() + 1)

}
