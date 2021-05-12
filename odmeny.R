## Skript na zpracování a odeslání e-mailu s oznámením odmìn úèastníkùm turnaje PGG


## Encoding: windows-1250
## Vytvoøil: 2021-04-21 FrK
## Upravil: 2021-05-12 FrK


# ## Hlavièka a naètení dat -----------------------------------------------

## Smazání pamìti
rm(list = ls())


## Package
library(dplyr)
library(writexl)

## Naètení dat
load("vsechnaCistaData.RData")

# ## Odmìny ---------------------------------------------------------------

## Nejdøív je potøeba znovu vygenerovat vyhodnoceni:
dfv = vysledek %>% ungroup() %>% arrange(., desc(soucetSkupiny), desc(celkem)) %>% 
  select(email, session, soucetSkupiny, celkem) #%>% 
# group_by(email) %>% mutate(x = 1) %>% mutate(x = sum(x)) %>%   # Kontrola, jestli tam není nìjaký email dvakrát.
# arrange(., desc(x), email)  # OK, dopadlo to dobøe, každý mail tu je jen jednou!
# vyhodnoceni


## Teï je potøeba vùbec nadefinovat vektor s odmìnami a doplnit 0 na délku `vyhodnoceni`:
odmeny = c(seq(1000, 500, -100), 450, 400, 400, 350, rep(300,3), 250, rep(200, 5), 150,
           150, rep(100, 6), rep(50, 16), 25, 25, rep(0, nrow(dfv) - 45))
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
vyhodnoceni = cbind(dfv, 'odmena' = odmeny, misto = 1:nrow(dfv)) %>% group_by(soucetSkupiny, celkem) %>% 
  mutate(odmena = mean(odmena), 
         odmena = if_else(odmena == 368.75, 370, odmena),  # Bude to stát sice 30 Kè navíc, ale zaokrouhlíme to na celé desetikoruny nahoru, pøeci nebudu 24 vítìzùm posílat 368.75 Kè 24x...
         
         # 5) a rovnou si tu pøipravím promìnné nutné pro sestavení emailu hráèùm         
         od = min(misto),
         do = max(misto),
         umisteni = if_else(od == do,
                            paste0("na ", od, ". místì"),
                            paste0("na ", od, ". až ", do, ". místì")),
         odmenit= if_else(odmena == 0,
                          ". Toto umístìní je, Bohu žel, bez finanèní odmìny.", 
                          paste0(", za což Vám náleží odmìna ", odmena, " Kè. Pošlete nám prosím èíslo úètu, abychom Vám mohli odmìnu zaslat.")),
         email = if_else(email == "annaraichlova@s", "annaraichlova@seznam.cz", email)
         )
vyhodnoceni


dopisy = vyhodnoceni %>% 
  mutate(
    dopis = 
      paste0("Milá úèastnice, milý úèastníku turnaje PGG,\n\n\n\n",
             "nejprve Vám ještì jednou srdeènì dìkujeme za Vaší úèast v turnaji -- bez Vás by nebylo možné zkoumat ",
             "lidskou kooperaci, která byla pøedmìtem naší studie. ",
             "Dále Vám v e-mailu sdìlujeme Váš výsledek v turnaji a jaká odmìna Vám náleží. \n\n",
             "Jelikož vaše skupina získala dohromady ", soucetSkupiny, " HK a Vy osobnì ",
             celkem, " HK, jste v celkovém poøadí ", umisteni, odmenit, "\n\n",
             "Pro zajímavost, maximálního možného výsledku 1600 HK za celou skupinu dosáhlo 6 skupin a ",
             "jejich èlenky a èlenové si tak rovným dílem rozdìlili odmìny za 1. až 24. místo ",
             "(všichni shodnì mìli osobní výsledek 400 HK, jinak konec koncù nebylo možné maxima dosáhnout). ",
             "Nejvyšší osobní výsledek v celém turnaji je 417,5 HK, ale ten znamenal 'jen' 29. místo.",
             "\n\n\n\nS úctou,\nFrantišek Kalvas a Pavlína Máchová")
  ) %>% ungroup %>% select(email, dopis) %>% filter(!is.na(email))
dopisy



# ## Odeslání personalizovaných výsledkù: ---------------------------------

library(emayili)
library(dplyr)
library(magrittr)

for (d in 1:nrow(dopisy)) {
  email <- envelope() %>% 
    from("kalvas@kss.zcu.cz") %>% 
    to(dopisy$email[13]) %>% 
    subject(qp_encode("Vyhodnocení turnaje PGG (21.4.2021--2.5.2021)")) %>% 
    text(qp_encode(dopisy$dopis[13]))
  
  # print(email, details = T)
  
  smtp <- server(host = "smtp.zcu.cz",
                 port = 465,
                 username = "user",
                 password = "pass")
  
  smtp(email, verbose = TRUE)  
}


## Pro otestování adres ještì uložím adresy do Excelu a tam odtud to ruènì nakopíruju do øádku mailu:
write_xlsx(dopisy, "kontrola.xlsx")
