##### install and load packages #####
rm(list=ls())

# load packages
library(tidyverse)
# extract currencies from string
library(strex)
library(readxl)
library(ggplot2)
library(magrittr)
library(fuzzyjoin)

#### define paths ####
user <- Sys.getenv("USERNAME")
# specify project folder
project <- "bbb-euros"
main <- paste0("C:/Users/", user, "/Documents/Github/projects/", project)
dataraw <- paste(main, "dataraw", sep = "/")
dataout <- paste(main, "dataout", sep = "/")
temp <- paste(main, "temp", sep = "/")

# read data file 
df <- read_excel(path = paste(dataraw, 
                              "euros_stadiums.xlsx",
                              sep = "/"),
                 sheet = "Sheet1")


# count unique stadiums
n_distinct(df$stadium)
