#### Skript na na�ten� dat ve form�tu *.json

## Encoding: windows-1250
## Vytvo�il: 2021-04-21 FrK
## Upravil: 2021-04-22 FrK


## Hlavi�ka
rm(list = ls())
library(rjson)
library(rlist)
library(dplyr)
library(readr)
library(stringr)

## Prvn� pokus:
raw = fromJSON(file = 'm87.json')

str(raw, max.level = 3)

list.select(raw, time, session) %>%  # Vyt�hne z RAW p��slu�n� prom�nn�
  list.stack()  # Ud�l� dataframe

raw[[57]] %>% bind_rows()



## Druh� pokus -- p�ech�z�me na *.csv:
read.csv('q1.csv', encoding = "UTF-8")



## T�et� pokus -- na��st data ze *.zip archivu:
archive = "pgg-data_2021-04-22T04_56_33.753Z.zip"
files = unzip(archive, list = T) %>% 
  filter(Length > 0) 

bonus = unz(archive, files$Name[2]) %>% read_csv()
bonus

emaily = unz(archive, files$Name[3]) %>% read_csv()
emaily

dfPGG = unz(archive, files$Name[5]) %>% read_csv()
dfPGG

dfQ1 = unz(archive, files$Name[6]) %>% read_csv()
dfQ1

dfQ2 = unz(archive, files$Name[7]) %>% read_csv()
dfQ2



