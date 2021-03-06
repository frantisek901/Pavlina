#### Skript na na�ten� dat z NodeGame

## Encoding: windows-1250
## Vytvo�il: 2021-04-21 FrK
## Upravil: 2021-04-22 FrK

## Aktu�ln� data jsou ke sta�en� na t�to adrese:
## http://207.154.245.100/pgg/monitor/data/*
## POZOR! Nutn� je ta hv�zdi�ka na konci! 
## Ale s p��slu�n�mi packegemi si skript data um� s�m st�hnout a pojmenovat tak, aby je pak zpracoval.

## Hlavi�ka
rm(list = ls())

## Package
library(dplyr)
library(readr)
library(stringr)
library(httr)
library(ggplot2)
library(forcats)
library(lubridate)



# ## Sta�en� dat: ---------------------------------------------------------

## St�hneme data ze server�
GET('http://207.154.245.100/pgg/monitor/data/*',  ## Adresa na�� hry
    write_disk('aktualniData.zip', overwrite = TRUE))
GET('http://134.122.66.93/pgg/monitor/data/*',  ## Adresa na�� hry
    write_disk('aktualniData2.zip', overwrite = TRUE))


## Z�sk�me seznam soubor� ve sta�en�ch datech
archive = "aktualniData.zip"
files = unzip(archive, list = T) %>% 
  filter(Length > 0) %>% filter(str_detect(Name, ".csv") )%>% 
  filter(!(str_detect(Name, "000015")|  # P��prava na dal�� problematick� m�stnosti, ano t�eba 000018...
           str_detect(Name, "000018")))  # V m�stnosti 15 je jen jeden soubor -- vstupn� dotazn�k, jinak nic, jde tedy o nedohranou hru
files


## Na p�ips�n� �asu, kdy hra prob�hla si vytvo��me zvl�tn� soubor
datumy = files[seq(5, nrow(files),5),] %>% 
  mutate(Name = substr(Name, 6, 15)) %>% select(-Length) %>% 
  rename(session = Name, date = Date)
datumy

# ## Na�ten� dat ze *.zip archivu: ----------------------------------------

## �e�en�: 
# Zat�m jsem to vy�e�il tak, �e jsem vymazal na serveru Room000005 s t�m jedin�m souborem,
# te� m� .zip jasnou strukturu: co m�stnost, to 6 sobor�, jen 5 na��t�m.
# Proto jsem ud�lal cyklus, kter� ty �estice zpracuje, nejd��v to prob�hne na prvn� �estici,
# pak nasko�� cyklus, kter� 2. a� posledn� na�te.

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



# ## Spojen� dat ----------------------------------------------------------

## Tohle jsou asi data, se kter�mi budete pracovat nejv�c --
# charakteristiky respondent� a jak ovliv�uj� celkov� v�sledek
vysledek = left_join(bonus, emaily) %>% left_join(Q1) %>% left_join(Q2, by = c("player", "session")) %>% 
  left_join(datumy, by = c("session")) %>% 
  group_by(session) %>% mutate(soucetSkupiny = sum(celkem))  %>% 
  select(names(.)[1:3], soucetSkupiny, names(.)[4],date, names(.)[5:16], -starts_with("time"), -type) %>% ungroup() %>% 
  mutate(across(.cols = znajiSe:kooperujeCiz, 
                .fns = ~(recode(., `7-velmi dob�e` = "7", `7-velmi bl�zk�` = "7", 
                                  `7-velmi spolupracuji` ="7", `1-v�bec nespolupracuji` = "1",
                                  `1-v�bec` = "1") %>% as.integer())),  # `star� hodnota` = "nov� hodnota"
         across(.cols = communication:strategy,
                .fns = as_factor)) %>% 
  rename(realHrac = real1, realSkup = real2) # `nov� n�zev` = `star� n�zev`
glimpse(vysledek)

## A takto si m��eme rovnou nechat vyjet po�ad� hr���!
vyhodnoceni = vysledek %>% ungroup() %>% arrange(., desc(soucetSkupiny), desc(celkem)) %>% 
  select(email, soucetSkupiny, celkem) #%>% filter(!str_detect(email, "fake@"))
vyhodnoceni

## Na p�ehled v�voje hry asi bude sta�it PGG, ale kdyby to bylo pot�eba spojit s kontextov�mi dat,
# tak tady je to v�echno spojen�
celkova = left_join(PGG, vysledek, by = c("player", "session"))
celkova

## Je�t� p�id�me datumy do PGG
PGG = left_join(PGG, datumy)



# ## Ulo�en� dat ----------------------------------------------------------

save(vysledek, PGG, celkova, file = "vsechnaCistaData.RData")



# ## P��prava dat na pou�it� v kurzu KA1 ----------------------------------

# Vytvo�en� dat
KA1_kontext = vysledek %>% select(-email)
KA1_pgg = PGG
KA1_spojeno = left_join(KA1_pgg, (KA1_kontext %>% select(-date)), by = c("player", "session"))

# Ulo�en� dat
save(KA1_kontext, KA1_pgg, KA1_spojeno, file = "KA1_vse.RData")
load(file = "KA1_vse.RData")

# Na�ten� dat z GitHubu
GET("https://github.com/frantisek901/Pavlina/raw/main/KA1_vse.RData", 
    write_disk("KA1_vse.RData", overwrite = T))
load(file = "KA1_vse.RData")

