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
library(forcats)



# ## Stažení dat: ---------------------------------------------------------

GET('http://207.154.245.100/pgg/monitor/data/*',  ## Adresa naší hry
    write_disk('aktualniData.zip', overwrite = TRUE))
GET('http://134.122.66.93/pgg/monitor/data/*',  ## Adresa naší hry
    write_disk('aktualniData2.zip', overwrite = TRUE))

archive = "aktualniData.zip"
files = unzip(archive, list = T) %>% 
  filter(Length > 0) %>% filter(str_detect(Name, ".csv") )%>% 
  filter(!str_detect(Name, "000015"))  # V místnosti 15 je jen jeden soubor -- vstupní dotazník, jinak nic, jde tedy o nedohranou hru
files



# ## Naètení dat ze *.zip archivu: ----------------------------------------

## Øešení: 
# Zatím jsem to vyøešil tak, že jsem vymazal na serveru Room000005 s tím jediným souborem,
# teï má .zip jasnou strukturu: co místnost, to 6 soborù, jen 5 naèítám.
# Proto jsem udìlal cyklus, který ty šestice zpracuje, nejdøív to probìhne na první šestici,
# pak naskoèí cyklus, který 2. až poslední naète.

bonus = unz(archive, files$Name[1]) %>% read_csv() %>% rename(player = id, celkem = bonus) 
emaily = unz(archive, files$Name[2]) %>% read_csv() %>% rename(email = value)
PGG = unz(archive, files$Name[3]) %>% read_csv()
Q1 = unz(archive, files$Name[4]) %>% read_csv()
Q2 = unz(archive, files$Name[5]) %>% read_csv()

for (f in 1:(nrow(files)/5 - 1)) {
  bonus = unz(archive, files$Name[f*5 + 1]) %>% read_csv() %>% 
    rename(player = id, celkem = bonus) %>% rbind(bonus, .) 

  emaily = unz(archive, files$Name[f*5 + 2]) %>% read_csv() %>% 
    rename(email = value) %>% rbind(emaily, .)

  PGG = unz(archive, files$Name[f*5 + 3]) %>% read_csv() %>% rbind(PGG, .)

  Q1 = unz(archive, files$Name[f*5 + 4]) %>% read_csv() %>% rbind(Q1, .)

  Q2 = unz(archive, files$Name[f*5 + 5]) %>% read_csv() %>% rbind(Q2, .)
}  



# ## Spojení dat ----------------------------------------------------------

## Tohle jsou asi data, se kterými budete pracovat nejvíc --
# charakteristiky respondentù a jak ovlivòují celkový výsledek
vysledek = left_join(bonus, emaily) %>% left_join(Q1) %>% left_join(Q2, by = c("player", "session")) %>% 
  group_by(session) %>% mutate(soucetSkupiny = sum(celkem))  %>% 
  select(names(.)[1:3], soucetSkupiny, names(.)[4:16], -starts_with("time"), -type) %>% ungroup() %>% 
  mutate(across(.cols = znajiSe:kooperujeCiz, 
                .fns = ~(recode(., `7-velmi dobøe` = "7", `7-velmi blízký` = "7", 
                                  `7-velmi spolupracuji` ="7", `1-vùbec nespolupracuji` = "1",
                                  `1-vùbec` = "1") %>% as.integer())),  # `stará hodnota` = "nová hodnota"
         across(.cols = communication:strategy,
                .fns = as_factor)) %>% 
  rename(realHrac = real1, realSkup = real2) # `nový název` = `starý název`
glimpse(vysledek)

## A takto si mùžeme rovnou nechat vyjet poøadí hráèù!
vyhodnoceni = vysledek %>% ungroup() %>% arrange(., desc(soucetSkupiny), desc(celkem)) %>% 
  select(email, soucetSkupiny, celkem) #%>% filter(!str_detect(email, "fake@"))
vyhodnoceni

## Na pøehled vývoje hry asi bude staèit PGG, ale kdyby to bylo potøeba spojit s kontextovými dat,
# tak tady je to všechno spojené
celkova = left_join(PGG, vysledek, by = c("player", "session"))
celkova



# ## Pøíprava dat na použití v kurzu KA1 ----------------------------------

# Vytvoøení dat
KA1_kontext = vysledek %>% select(-email)
KA1_pgg = PGG
KA1_spojeno = left_join(KA1_pgg, KA1_kontext, by = c("player", "session"))

# Uložení dat
save(KA1_kontext, KA1_pgg, KA1_spojeno, file = "KA1_vse.RData")
load(file = "KA1_vse.RData")

# Naètení dat z GitHubu
GET("https://github.com/frantisek901/Pavlina/raw/main/KA1_vse.RData", 
    write_disk("KA1_vse.RData", overwrite = T))
load(file = "KA1_vse.RData")



# ## Vývojový graf --------------------------------------------------------
ggplot(PGG, aes(x = stage.round, y = contribution, col = as.factor(player))) +
  geom_line()

PGG %>% group_by(stage.round, session) %>% summarise(contribution = mean(contribution)) %>% 
  ggplot(aes(x = stage.round, y = contribution, col = session)) +
  geom_line()

PGG %>% group_by(stage.round) %>% summarise(contribution = mean(contribution)) %>% 
  ggplot(aes(x = stage.round, y = contribution)) +
  geom_line()
