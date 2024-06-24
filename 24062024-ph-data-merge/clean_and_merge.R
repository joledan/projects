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
library(lubridate)
library(janitor)

#### define paths ####
user <- Sys.getenv("USERNAME")
# specify project folder
main <- paste0("C:/Users/", user, "/Documents/Github/projects/24062024-ph-data-merge")
dataraw <- paste(main, "dataraw", sep = "/")
dataout <- paste(main, "dataout", sep = "/")


# read uwazi df - "main data set"
# make unique id for each row for matching
df1 <- paste(dataraw,
             "Uwazi-2024-02-12T12 03 44.csv",
             sep = "/") %>%
  read_delim() %>%
  mutate(id = row_number())

# read data to merge
# extract date from "Date(s)" variable
  # clean date string in several steps
  # use Name of Defender/Group/Description of Defenders and date to match
  # with original data set
df2 <- paste(dataraw,
              "Criminalization data Anna.xlsx",
             sep = "/") %>%
  read_excel(sheet = "Phillipines") %>%
  mutate(d1 = as.numeric(str_extract(`Date(s)`, "\\d+")),
         d2 = case_when(d1 > 40000 ~ as.Date(d1, origin = "1899-12-30"),
                     T ~ NA),
         d3 = format(d2, "%B %d, %Y"),
         d4 = str_extract(`Date(s)`, 
                          pattern='\\w+\\s\\d+(st)?(nd)?(rd)?(th)?,\\s+\\d+'),
         d5 = case_when(
           is.na(d4) ~ d3,
           T ~ d4) %>%
           str_to_sentence(.),
         d6 = case_when(
           `Date(s)` == "Arrested Aug. 30, 2022" ~ "August 20, 2022",
           `Date(s)` == "Arrested Feb. 5, 2021" ~ "February 5, 2021",
           T ~ d5),
         date_cleaned = str_replace(d6, "Jan ", "January ")
         ) %>%
  select(`Name of Defender/Group/Description of Defenders`,
         `Description of events`,
         `date_cleaned`) %>%
  clean_names() %>%
  mutate(name_title = str_squish(name_of_defender_group_description_of_defenders) %>%
           str_to_title(),
         text = paste0("date_cleaned == \"", date_cleaned, "\" & name_title == \"", name_title, "\" ~ "))

df3 <- df1 %>%
  select(`Initial Date`,
         `Summary for Publications`,
         id) 

df4 <- df2 %>%
  mutate(id = case_when(
    date_cleaned == "June 11, 2022" & name_title == "Daisy Macapanpan" ~ 73,
    date_cleaned == "September 15, 2023" & name_title == "Bea Lopez" ~ 13,
    date_cleaned == "August 24, 2023" & name_title == "Ernesto Baez Jr." ~ 16,
    date_cleaned == "July 12, 2023" & name_title == "Miguela Peniero And Youth Volunteer Rowena Dasig" ~ 22,
    date_cleaned == "July 10, 2023" & name_title == "Four Igorot Activists In The Cordillera" ~ 23,
    date_cleaned == "January 30, 2023" & name_title == "Jennifer Awingan And Other Cpa Workers" ~ 23,
    #date_cleaned == "NA" & name_title == "NA" ~                                                                
    #date_cleaned == "NA" & name_title == "Gloria Campos Tumalon" ~                                             
    is.na(date_cleaned) & name_title == "Jhed Tamano Jonila Castro" ~ 8,                                        
    date_cleaned == "December 1, 2022" & name_title == "Sarah Dekdeken" ~ 49,                                 
    date_cleaned == "July 17, 2022" & name_title == "Gary S. Campos" ~ 68,
    date_cleaned == "June 9, 2022" & name_title == "93 Collective Farmers" ~ 74,                             
    date_cleaned == "July 16, 2021" & name_title == "Julieta Gomez And Niezel Velasco" ~ 104,                    
    date_cleaned == "June 25, 2021" & name_title == "Dana Marie Marcellana And Christian Relao" ~ 106,              
    date_cleaned == "June 25, 2021" & name_title == "Bohol Carmilo Tabada, Pastor Nathaniel Vallente" ~ 107,      
    date_cleaned == "June 03, 2021" & name_title == "Amihan National Federation Of Peasant Women" ~ 108,           
    date_cleaned == "May 14, 2021" & name_title == "Marcela “Silay” Diaz, 59, Virgilio “Yoyong” Lincuna, 70" ~ 110,
    date_cleaned == "May 05, 2021" & is.na(name_title) ~ 111,                                                      
    date_cleaned == "February 7, 2020" & name_title == "Marielle “Maye” Domequil" ~ 190,                           
    date_cleaned == "February 7, 2020" & name_title == "Frenchie Mae Cumpio" ~ 190,                                 
    date_cleaned == "February 7, 2020" & name_title == "Marissa Cabaljao" ~ 190,                                   
    date_cleaned == "February 7, 2020" & name_title == "Mira Legion" ~ 190,                                    
    date_cleaned == "February 7, 2020" & name_title == "Alexander Philip Dizon Abinguna" ~ 190,                 
    date_cleaned == "March 16, 2023" & name_title == "Angeline Magdua" ~ 35,                                      
    date_cleaned == "June 25, 2023" & name_title == "Susan Medes" ~ 24,                                            
    date_cleaned == "June 19, 2023" & name_title == "Artemio Sanchez" ~ 26,                                      
    date_cleaned == "June 19, 2023" & name_title == "Jose Retubio" ~ 26,                                          
    date_cleaned == "June 19, 2023" & name_title == "Nenita Petallo" ~ 26,                                        
    date_cleaned == "June 19, 2023" & name_title == "William Petallo" ~ 26,                                     
    date_cleaned == "May 25, 2023" & name_title == "Adolfo “Tatay Opong” Salas Sr." ~ 30,                         
    date_cleaned == "August 20, 2022" & name_title == "Atheliana “Atel” Hijos" ~ 62,                              
    date_cleaned == "March 18, 2022" & name_title == "Caarlo Reduta" ~ 84,                                         
    date_cleaned == "October 6, 2021" & name_title == "Erlindo “Lino” Baez" ~ 97,                                 
    date_cleaned == "October 6, 2021" & name_title == "Willy Capareño" ~ 97,                                
    date_cleaned == "May 6, 2021" & name_title == "Gary Doroteo" ~ 111,                                            
    date_cleaned == "May 6, 2021" & name_title == "Benito Lucio" ~ 111,                                        
    date_cleaned == "May 6, 2021" & name_title == "Loreto Balino" ~ 111,                                        
    date_cleaned == "May 2, 2021" & name_title == "Dan Balucio" ~ 112,                                            
    date_cleaned == "May 2, 2021" & name_title == "Maria Jesusa “Sasah” Sta. Rosa" ~ 112,                          
    date_cleaned == "April 5, 2021" & name_title == "Genelyn Dichoso" ~ 117,                                       
    date_cleaned == "April 5, 2021" & name_title == "Genelyn Dichoso's Daughter" ~ 117,                         
    date_cleaned == "March 21, 2021" & name_title == "Renalyn Tejero" ~ 120,                                        
    date_cleaned == "February 5, 2021" & name_title == "Greco Regala" ~ 130,                                       
    date_cleaned == "January 18, 2021" & name_title == "Salvacion Abonilla" ~ 132,                                  
    date_cleaned == "January 18, 2021" & name_title == "John Jason Abonilla" ~ 132,                           
    date_cleaned == "January 18, 2021" & name_title == "Jenny Capa" ~ 132,                                          
    date_cleaned == "January 18, 2021" & name_title == "Catherine Magdato" ~ 132,                                    
    date_cleaned == "January 18, 2021" & name_title == "Eden Gualberto" ~ 132,                                       
    date_cleaned == "December 2, 2020" & name_title == "Amanda Echanis" ~ 137,                                     
    date_cleaned == "December 2, 2020" & name_title == "Randall Emmanuel" ~ 137,                                   
    date_cleaned == "October 25, 2020" & name_title == "Beatrice Belen" ~ 142,                                      
    date_cleaned == "April 11, 2020" & name_title == "Proceso Torralba" ~ 178,                                     
    date_cleaned == "March 19, 2020" & name_title == "Gloria Tomalon" ~ 186,                                        
    date_cleaned == "October 31, 2019" & name_title == "John Milton Luzande" ~ 202,                               
    date_cleaned == "October 31, 2019" & name_title == "Danny Tabura" ~ 202,                                       
    date_cleaned == "October 31, 2019" & name_title == "Albert Dela Cerna" ~ 202,                                  
    #date_cleaned == "November 1, 2019" & name_title == "Imelda Sultan" ~                                       
    #date_cleaned == "November 1, 2019" & name_title == "Lindy Perocho" ~                                       
    date_cleaned == "October 31, 2019" & name_title == "Karina Dela Cerna." ~ 202,                                 
    date_cleaned == "October 10, 2019" & name_title == "Virgilio “Ka Yoyong” Lincuna" ~ 204,                       
    date_cleaned == "January 28, 2019" & name_title == "Datu Jomorito Goaynon" ~ 236,                              
    date_cleaned == "January 28, 2019" & name_title == "Ireneo Udarbe" ~ 236,                          
    date_cleaned == "October 13, 2018" & name_title == "Rachel Galario" ~ 244,                                     
    date_cleaned == "October 13, 2018" & name_title == "Eulalia Ladesma" ~ 244,                                     
    date_cleaned == "October 13, 2018" & name_title == "Yolanda Diamsay Ortiz" ~ 244,                               
    date_cleaned == "October 13, 2018" & name_title == "Edzel Emocling" ~ 244,                                       
    date_cleaned == "July 4, 2018" & name_title == "Vennel Chenfoo" ~ 251,                                         
    date_cleaned == "July 4, 2018" & name_title == "Datu Jomorito Guaynon" ~ 251,                                   
    date_cleaned == "July 4, 2018" & name_title == "Ireneo Udarbe" ~ 251,                                          
    date_cleaned == "July 4, 2018" & name_title == "Kristine Cabardo" ~ 251,                                        
    date_cleaned == "July 4, 2018" & name_title == "Teresita Naul" ~ 251,                                          
    date_cleaned == "July 4, 2018" & name_title == "Aldeem Yanez" ~ 251,                                           
    date_cleaned == "July 4, 2018" & name_title == "Roger Plana" ~ 251,                                           
    date_cleaned == "April 16, 2018" & name_title == "Sister Fox" ~ 260,                                           
    date_cleaned == "February 23, 2018" & name_title == "Roger Gonzales" ~ 267
  ))


# testing change

date_cleaned == "NA" & name_title == "NA" ~                                                                
date_cleaned == "NA" & name_title == "Gloria Campos Tumalon" ~                                             
date_cleaned == "NA" & name_title == "Jhed Tamano Jonila Castro" ~ 8,                                        
date_cleaned == "December 1, 2022" & name_title == "Sarah Dekdeken" ~ 49,                                 
date_cleaned == "July 17, 2022" & name_title == "Gary S. Campos" ~ 68,
date_cleaned == "June 9, 2022" & name_title == "93 Collective Farmers" ~ 74,                             
date_cleaned == "July 16, 2021" & name_title == "Julieta Gomez And Niezel Velasco" ~ 104,                    
date_cleaned == "June 25, 2021" & name_title == "Dana Marie Marcellana And Christian Relao" ~ 106,              
date_cleaned == "June 25, 2021" & name_title == "Bohol Carmilo Tabada, Pastor Nathaniel Vallente" ~ 107,      
date_cleaned == "June 03, 2021" & name_title == "Amihan National Federation Of Peasant Women" ~ 108,           
date_cleaned == "May 14, 2021" & name_title == "Marcela “Silay” Diaz, 59, Virgilio “Yoyong” Lincuna, 70" ~ 110,
date_cleaned == "May 05, 2021" & name_title == "NA" ~                                                      
date_cleaned == "February 7, 2020" & name_title == "Marielle “Maye” Domequil" ~ 190,                           
date_cleaned == "February 7, 2020" & name_title == "Frenchie Mae Cumpio" ~ 190,                                 
date_cleaned == "February 7, 2020" & name_title == "Marissa Cabaljao" ~ 190,                                   
date_cleaned == "February 7, 2020" & name_title == "Mira Legion" ~ 190,                                    
date_cleaned == "February 7, 2020" & name_title == "Alexander Philip Dizon Abinguna" ~ 190,                 
date_cleaned == "March 16, 2023" & name_title == "Angeline Magdua" ~ 35,                                      
date_cleaned == "June 25, 2023" & name_title == "Susan Medes" ~ 24,                                            
date_cleaned == "June 19, 2023" & name_title == "Artemio Sanchez" ~ 26,                                      
date_cleaned == "June 19, 2023" & name_title == "Jose Retubio" ~ 26,                                          
date_cleaned == "June 19, 2023" & name_title == "Nenita Petallo" ~ 26,                                        
date_cleaned == "June 19, 2023" & name_title == "William Petallo" ~ 26,                                     
date_cleaned == "May 25, 2023" & name_title == "Adolfo “Tatay Opong” Salas Sr." ~ 30,                         
date_cleaned == "August 20, 2022" & name_title == "Atheliana “Atel” Hijos" ~ 62,                              
date_cleaned == "March 18, 2022" & name_title == "Caarlo Reduta" ~ 84,                                         
date_cleaned == "October 6, 2021" & name_title == "Erlindo “Lino” Baez" ~ 97,                                 
date_cleaned == "October 6, 2021" & name_title == "Willy Capareño" ~ 97,                                
date_cleaned == "May 6, 2021" & name_title == "Gary Doroteo" ~ 111,                                            
date_cleaned == "May 6, 2021" & name_title == "Benito Lucio" ~ 111,                                        
date_cleaned == "May 6, 2021" & name_title == "Loreto Balino" ~ 111,                                        
date_cleaned == "May 2, 2021" & name_title == "Dan Balucio" ~ 112,                                            
date_cleaned == "May 2, 2021" & name_title == "Maria Jesusa “Sasah” Sta. Rosa" ~ 112,                          
date_cleaned == "April 5, 2021" & name_title == "Genelyn Dichoso" ~ 117,                                       
date_cleaned == "April 5, 2021" & name_title == "Genelyn Dichoso's Daughter" ~ 117,                         
date_cleaned == "March 21, 2021" & name_title == "Renalyn Tejero" ~ 120,                                        
date_cleaned == "February 5, 2021" & name_title == "Greco Regala" ~ 130,                                       
date_cleaned == "January 18, 2021" & name_title == "Salvacion Abonilla" ~ 132,                                  
date_cleaned == "January 18, 2021" & name_title == "John Jason Abonilla" ~ 132,                           
date_cleaned == "January 18, 2021" & name_title == "Jenny Capa" ~ 132,                                          
date_cleaned == "January 18, 2021" & name_title == "Catherine Magdato" ~ 132,                                    
date_cleaned == "January 18, 2021" & name_title == "Eden Gualberto" ~ 132,                                       
date_cleaned == "December 2, 2020" & name_title == "Amanda Echanis" ~ 137,                                     
date_cleaned == "December 2, 2020" & name_title == "Randall Emmanuel" ~ 137,                                   
date_cleaned == "October 25, 2020" & name_title == "Beatrice Belen" ~ 142,                                      
date_cleaned == "April 11, 2020" & name_title == "Proceso Torralba" ~ 178,                                     
date_cleaned == "March 19, 2020" & name_title == "Gloria Tomalon" ~ 186,                                        
date_cleaned == "October 31, 2019" & name_title == "John Milton Luzande" ~ 202,                               
date_cleaned == "October 31, 2019" & name_title == "Danny Tabura" ~ 202,                                       
date_cleaned == "October 31, 2019" & name_title == "Albert Dela Cerna" ~ 202,                                  
date_cleaned == "November 1, 2019" & name_title == "Imelda Sultan" ~                                       
date_cleaned == "November 1, 2019" & name_title == "Lindy Perocho" ~                                       
date_cleaned == "October 31, 2019" & name_title == "Karina Dela Cerna." ~ 202,                                 
date_cleaned == "October 10, 2019" & name_title == "Virgilio “Ka Yoyong” Lincuna" ~ 204,                       
date_cleaned == "January 28, 2019" & name_title == "Datu Jomorito Goaynon" ~ 236,                              
date_cleaned == "January 28, 2019" & name_title == "Ireneo Udarbe" ~ 236,                          
date_cleaned == "October 13, 2018" & name_title == "Rachel Galario" ~ 244,                                     
date_cleaned == "October 13, 2018" & name_title == "Eulalia Ladesma" ~ 244,                                     
date_cleaned == "October 13, 2018" & name_title == "Yolanda Diamsay Ortiz" ~ 244,                               
date_cleaned == "October 13, 2018" & name_title == "Edzel Emocling" ~ 244,                                       
date_cleaned == "July 4, 2018" & name_title == "Vennel Chenfoo" ~ 251,                                         
date_cleaned == "July 4, 2018" & name_title == "Datu Jomorito Guaynon" ~ 251,                                   
date_cleaned == "July 4, 2018" & name_title == "Ireneo Udarbe" ~ 251,                                          
date_cleaned == "July 4, 2018" & name_title == "Kristine Cabardo" ~ 251,                                        
date_cleaned == "July 4, 2018" & name_title == "Teresita Naul" ~ 251,                                          
date_cleaned == "July 4, 2018" & name_title == "Aldeem Yanez" ~ 251,                                           
date_cleaned == "July 4, 2018" & name_title == "Roger Plana" ~ 251,                                           
date_cleaned == "April 16, 2018" & name_title == "Sister Fox" ~ 260,                                           
date_cleaned == "February 23, 2018" & name_title == "Roger Gonzales" ~ 267   


