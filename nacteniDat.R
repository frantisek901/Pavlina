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

## Stáhneme data ze serverù
GET('http://207.154.245.100/pgg/monitor/data/*',  ## Adresa naší hry
    write_disk('aktualniData.zip', overwrite = TRUE))
GET('http://134.122.66.93/pgg/monitor/data/*',  ## Adresa naší hry
    write_disk('aktualniData2.zip', overwrite = TRUE))


## Získáme seznam souborù ve stažených datech
archive = "aktualniData.zip"
files = unzip(archive, list = T) %>% 
  filter(Length > 0) %>% filter(str_detect(Name, ".csv") )%>% 
  filter(!(str_detect(Name, "000015")|  # Pøíprava na další problematické místnosti, ano tøeba 000018...
           str_detect(Name, "000018")))  # V místnosti 15 je jen jeden soubor -- vstupní dotazník, jinak nic, jde tedy o nedohranou hru
files


## Na pøipsání èasu, kdy hra probìhla si vytvoøíme zvláštní soubor
datumy = files[seq(5, nrow(files),5),] %>% 
  mutate(Name = substr(Name, 6, 15)) %>% select(-Length) %>% 
  rename(session = Name, date = Date)
datumy

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
  left_join(datumy, by = c("session")) %>% 
  group_by(session) %>% mutate(soucetSkupiny = sum(celkem))  %>% 
  select(names(.)[1:3], soucetSkupiny, names(.)[4],date, names(.)[5:16], -starts_with("time"), -type) %>% ungroup() %>% 
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

PGG %>% group_by(stage.round, session) %>% summarise(contribution = mean(contribution)) %>% 
  ggplot(aes(x = stage.round, y = contribution, col = session)) +
  geom_line()

PGG %>% group_by(stage.round) %>% summarise(contribution = mean(contribution)) %>% 
  ggplot(aes(x = stage.round, y = contribution)) +
  geom_line()

ggplot(PGG, aes(x = stage.round, y = contribution, group = session)) +
  geom_jitter(col = "blue", alpha = 0.2, size = 2, width = 0, height = 0.3) +  # Individuální pozorování
  stat_summary(fun = mean,   # Prùmìr skupiny za kolo
               fun.args = list(mult = 1), 
               geom = "line", 
               size = 1.5, 
               color = "#808080") +
  geom_line(data = (PGG %>% group_by(stage.round) %>% mutate(contribution = mean(contribution, na.rm = T))),
             aes(x = stage.round, y = contribution),
             color = "steelblue",
             size = 0.5) +  # Prùmìr za celý turnaj
  facet_wrap(vars(session), nrow = 3) +  # Rozdìlení do panelù podle skupin
  guides(color = F) +
  labs(caption = "Vysvìtlivky:
  Tenká modrá èára ukazuje prùmìrnou investici do spoleèného úètu za kolo za celý turnaj.
  Tlustá šedá èára ukazuje prùmìrnou investici za kolo v pøíslušné skupinì.
  Modré body ukazují investice jednotlivých hráèù, které byly celé èíslo v intervalu 0--20. 
  K investicím hráèù je pøièten drobný šum (+/- 0.3), aby byl zøetelnìjší pøekryv hodnot.
  Graf je rozdìlený do panelù podle skupin.") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(0, 10, 2)) +
  scale_y_continuous(breaks = seq(0, 20, 2))



ggplot(PGG, aes(x = stage.round, y = contribution, group = stage.round)) +
  geom_jitter(col = "blue", alpha = 0.2, size = 2, width = 0.15, height = 0.35) +  # Individuální pozorování
  geom_line(data = (PGG %>% group_by(stage.round) %>% mutate(contribution = mean(contribution, na.rm = T))),
            aes(x = stage.round, y = contribution, group = player),
            color = "steelblue",
            size = 1.5) +  # Prùmìr za celý turnaj
  geom_boxplot(alpha = 0.1, fill = "steelblue", col = "steelblue") +
  guides(color = F) +
  labs(caption = "Vysvìtlivky:
  Tlustá modrá èára ukazuje prùmìrnou investici do spoleèného úètu za kolo za celý turnaj.
  Modré box-ploty ukazují celkovou distribuci investic v jednotlivých kolech.
  Modré body ukazují investice jednotlivých hráèù, které byly celé èíslo v intervalu 0--20. 
  K investicím hráèù je pøièten drobný šum (+/- 0.3), aby byl zøetelnìjší pøekryv hodnot.
  Graf je rozdìlený do panelù podle skupin.") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(0, 10, 2)) +
  scale_y_continuous(breaks = seq(0, 20, 2))



# ## Odmìny ---------------------------------------------------------------

## Nejdøív je potøeba ynovu vygenerovat vyhodnoceni:
dfv = vysledek %>% ungroup() %>% arrange(., desc(soucetSkupiny), desc(celkem)) %>% 
  select(email, session, soucetSkupiny, celkem) #%>% 
  # group_by(email) %>% mutate(x = 1) %>% mutate(x = sum(x)) %>%   # Kontrola, jestli tam není nìjaký email dvakrát.
  # arrange(., desc(x), email)  # OK, dopadlo to dobøe, každý mail tu jejen jednou!
# vyhodnoceni

 
## Teï je potøeba vùbec nadefinovat vektor s odmìnami a doplnit 0 na délku `vyhodnoceni`:
odmeny = c(seq(1000, 500, -100), 450, 400, 400, 350, rep(300,3), 250, rep(200, 5), 150,
           150, rep(100, 6), rep(50, 16), 25, 25, rep(0, nrow(vyhodnoceni) - 45))
# length((odmeny))
# sum(odmeny)
# SUPER! Sedí to!


## Tak... Teï pøipojím `odmeny` jako další promìnnou do `vyhodnoceni` a 
# rovnou každému vypoètu jeho odmìnu:
# 1) seskupím je podle `soucetSkupiny` a podle `celkem`, tím mi pøirozenì vzniknou skupinky, 
#    které si budou dìlit odmìny prùmìrem (pøi rovnosti bodù skupiny vytváøí `super-skupiny` 
#    a uvnitø nich si dìlí odmìnu rovným dílem hráèi se stejným poètem bodù)
# 2) uvnitø skupin daných rovnými body (jak skupin tak hráèù) spoèítám prùmìrné odmìny
# 3) když budou body unikátní, zkrátka se replikuje hodnota, když ne, rozdìlí se
# 4) využívám toho, že žebøíèek hráèù a jejich výsledkù už je seøazený sestupnì, od nejlepší skupiny 
#    po nejhorší, a totéž s hráèi, když k tomu pak pøidám sestupnì seøazené odmìny, snadno to spoètu
vyhodnoceni = cbind(dfv, 'odmena' = odmeny) %>% group_by(soucetSkupiny, celkem) %>% 
  mutate(odmena = mean(odmena))
vyhodnoceni
