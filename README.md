# Gantt chart using the Timevis package in R for monitoring processes

A document repository can also be found in my profile article at [Medium](https://guimatheus92.medium.com/gantt-chart-using-the-timevis-package-in-r-for-monitoring-processes-ca7f4b350e0b "Medium").

------------

Using the packages below, I made a query in the database (Oracle) using the function “channel” and I obtained the data from a log table created by us, I transformed the data in R and used Timevis to visualize the data of an easier way.

**Packages:**
- library(shiny)
- library(timevis)
- library(RODBC)
- library(DBI)
- library(dplyr)
- library(lubridate)
- library(reshape2)

I believe that it is not worth me to show the query I made at the db, because it was something specific and created by us, but I will show the final result to show how we managed to find the right solution.

I also used the function "navbarPage" to visualize the graphics created in different tabs and make it more organized.

