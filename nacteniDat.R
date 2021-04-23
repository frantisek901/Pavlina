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
library(ggplot2)


# ## Stažení dat: ---------------------------------------------------------

GET('http://207.154.245.100/pgg/monitor/data/*',  ## Adresa naší hry
    write_disk('aktualniData.zip', overwrite = TRUE))

archive = "aktualniData.zip"
files = unzip(archive, list = T) %>% 
  filter(Length > 0) 
files


# ## Naètení dat ze *.zip archivu: ----------------------------------------

## Øešení: 
# Zatím jsem to vyøešil tak, že jsem vymazal na serveru Room000005 s tím jediným souborem,
# teï má .zip jasnou strukturu: co místnost, to 6 soborù, jen 5 naèítám.
# Proto jsem udìlal cyklus, který ty šestice zpracuje, nejdøív to probìhne na první šestici,
# pak naskoèí cyklus, který 2. až poslední naète.

bonus = unz(archive, files$Name[1]) %>% read_csv() %>% rename(player = id, celkem = bonus) 
emaily = unz(archive, files$Name[2]) %>% read_csv() %>% rename(email = value)
PGG = unz(archive, files$Name[4]) %>% read_csv()
Q1 = unz(archive, files$Name[5]) %>% read_csv()
Q2 = unz(archive, files$Name[6]) %>% read_csv()

for (f in 1:(nrow(files)/6 - 1)) {
  bonus = unz(archive, files$Name[f*6 + 1]) %>% read_csv() %>% 
    rename(player = id, celkem = bonus) %>% rbind(bonus, .) 

  emaily = unz(archive, files$Name[f*6 + 2]) %>% read_csv() %>% 
    rename(email = value) %>% rbind(emaily, .)

  PGG = unz(archive, files$Name[f*6 + 4]) %>% read_csv() %>% rbind(PGG, .)

  Q1 = unz(archive, files$Name[f*6 + 5]) %>% read_csv() %>% rbind(Q1, .)

  Q2 = unz(archive, files$Name[f*6 + 6]) %>% read_csv() %>% rbind(Q2, .)
}  


# ## Spojení dat ----------------------------------------------------------

## Tohle jsou asi data, se kterými budete pracovat nejvíc --
# charakteristiky respondentù a jak ovlivòují celkový výsledek
vysledek = left_join(bonus, emaily) %>% left_join(Q1) %>% left_join(Q2, by = c("player", "session")) %>% 
  group_by(session) %>% mutate(soucetSkupiny = sum(celkem)) %>% 
  select(names(vysledek)[1:4], soucetSkupiny, names(vysledek)[5:16])

## A takto si mùžeme rovnou nechat vyjet poøadí hráèù!
vyhodnoceni = vysledek %>% ungroup() %>% arrange(., desc(soucetSkupiny), desc(celkem)) %>% 
  select(email, soucetSkupiny, celkem)
vyhodnoceni

## Na pøehled vývoje hry asi bude staèit dfPGG, ale kdyby to bylo potøeba spojit s kontextovými dat,
# tak tady je to všechno spojené
celkova = left_join(PGG, vysledek, by = c("player", "session"))
celkova




# ## Vývojový graf --------------------------------------------------------
library(ggplot2)
ggplot(PGG, aes(x = stage.round, y = contribution, col = as.factor(player))) +
  geom_line()

PGG %>% group_by(stage.round, session) %>% summarise(contribution = mean(contribution)) %>% 
  ggplot(aes(x = stage.round, y = contribution, col = session)) +
  geom_line()

