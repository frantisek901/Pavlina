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

## TO DO: 
# Až bude her víc, tak bude potøeba upravit kod tak,
# aby vybral všechny relevantní soubory (Q1, Q2, PGG, EMAIL, BONUS) a
# všechny je spojil do jednoho dataframu, 
# resp. možná nechal bokem PGG, ale jinak to spojil.

bonus = unz(archive, files$Name[2]) %>% read_csv() %>% rename(player = id, celkem = bonus)
bonus

emaily = unz(archive, files$Name[3]) %>% read_csv() %>% rename(email = value)
emaily

dfPGG = unz(archive, files$Name[5]) %>% read_csv()
dfPGG

dfQ1 = unz(archive, files$Name[6]) %>% read_csv()
dfQ1

dfQ2 = unz(archive, files$Name[7]) %>% read_csv()
dfQ2


# ## Spojení dat ----------------------------------------------------------

## Tohle jsou asi data, se kterými budete pracovat nejvíc --
# charakteristiky respondentù a jak ovlivòují celkový výsledek
vysledek = left_join(bonus, emaily) %>% left_join(dfQ1) %>% left_join(dfQ2, by = c("player", "session"))
vysledek

## Na pøehled vývoje hry asi bude staèit dfPGG, ale kdyby to bylo potøeba spojit s kontextovými dat,
# tak tady je to všechno spojené
celkova = left_join(dfPGG, vysledek, by = c("player", "session"))
celkova
