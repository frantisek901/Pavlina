#### Skript na naètení dat z NodeGame

## Encoding: windows-1250
## Vytvoøil: 2021-04-21 FrK
## Upravil: 2021-04-22 FrK

## Aktuální data jsou ke stažení na této adrese:
## http://207.154.245.100/pgg/monitor/data/*
## POZOR! Nutná je ta hvìzdièka na konci! 
## Ale s pøíslušnými packegemi si skript data umí sám stáhnout a pojmenovat tak, aby je pak zpracoval.

## Hlavièka
rm(list = ls())

## Package
library(dplyr)
library(readr)
library(stringr)
library(httr)



# ## Stažení dat: ---------------------------------------------------------

GET('http://207.154.245.100/pgg/monitor/data/*',  ## Adresa naší hry
    write_disk('aktualniData.zip', overwrite = TRUE))

archive = "aktualniData.zip"
files = unzip(archive, list = T) %>% 
  filter(Length > 0) 
files


# ## Naètení dat ze *.zip archivu: ----------------------------------------

## TO DO: Až bude her víc, tak bude potøeba 

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



