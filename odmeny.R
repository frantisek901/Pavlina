## Skript na zpracov�n� a odesl�n� e-mailu s ozn�men�m odm�n ��astn�k�m turnaje PGG


## Encoding: windows-1250
## Vytvo�il: 2021-04-21 FrK
##  Upravil: 2021-06-02 FrK


# ## Hlavi�ka a na�ten� dat -----------------------------------------------

## Smaz�n� pam�ti
rm(list = ls())


## Package
library(dplyr)
library(readr)
library(readxl)
library(writexl)

## Na�ten� dat
load("vsechnaCistaData.RData")

# ## Odm�ny ---------------------------------------------------------------

## Nejd��v je pot�eba znovu vygenerovat vyhodnoceni:
dfv = vysledek %>% ungroup() %>% arrange(., desc(soucetSkupiny), desc(celkem)) %>% 
  select(email, session, soucetSkupiny, celkem) #%>% 
# group_by(email) %>% mutate(x = 1) %>% mutate(x = sum(x)) %>%   # Kontrola, jestli tam nen� n�jak� email dvakr�t.
# arrange(., desc(x), email)  # OK, dopadlo to dob�e, ka�d� mail tu je jen jednou!
# vyhodnoceni


## Te� je pot�eba v�bec nadefinovat vektor s odm�nami a doplnit 0 na d�lku `vyhodnoceni`:
odmeny = c(seq(1000, 500, -100), 450, 400, 400, 350, rep(300,3), 250, rep(200, 5), 150,
           150, rep(100, 6), rep(50, 16), 25, 25, rep(0, nrow(dfv) - 45))
# length((odmeny))
# sum(odmeny)
# SUPER! Sed� to!


## Tak... Te� p�ipoj�m `odmeny` jako dal�� prom�nnou do `vyhodnoceni` a 
# rovnou ka�d�mu vypo�tu jeho odm�nu:
# 1) seskup�m je podle `soucetSkupiny` a podle `celkem`, t�m mi p�irozen� vzniknou skupinky, 
#    kter� si budou d�lit odm�ny pr�m�rem (p�i rovnosti bod� skupiny vytv��� `super-skupiny` 
#    a uvnit� nich si d�l� odm�nu rovn�m d�lem hr��i se stejn�m po�tem bod�)
# 2) uvnit� skupin dan�ch rovn�mi body (jak skupin tak hr���) spo��t�m pr�m�rn� odm�ny
# 3) kdy� budou body unik�tn�, zkr�tka se replikuje hodnota, kdy� ne, rozd�l� se
# 4) vyu��v�m toho, �e �eb���ek hr��� a jejich v�sledk� u� je se�azen� sestupn�, od nejlep�� skupiny 
#    po nejhor��, a tot� s hr��i, kdy� k tomu pak p�id�m sestupn� se�azen� odm�ny, snadno to spo�tu
vyhodnoceni = cbind(dfv, 'odmena' = odmeny, misto = 1:nrow(dfv)) %>% group_by(soucetSkupiny, celkem) %>% 
  mutate(odmena = mean(odmena), 
         odmena = if_else(odmena == 368.75, 370, odmena),  # Bude to st�t sice 30 K� nav�c, ale zaokrouhl�me to na cel� desetikoruny nahoru, p�eci nebudu 24 v�t�z�m pos�lat 368.75 K� 24x...
         
         # 5) a rovnou si tu p�iprav�m prom�nn� nutn� pro sestaven� emailu hr���m         
         od = min(misto),
         do = max(misto),
         umisteni = if_else(od == do,
                            paste0("na ", od, ". m�st�"),
                            paste0("na ", od, ". a� ", do, ". m�st�")),
         odmenit= if_else(odmena == 0,
                          ". Toto um�st�n� je, Bohu �el, bez finan�n� odm�ny.", 
                          paste0(", za co� V�m n�le�� odm�na ", odmena, " K�. Po�lete n�m pros�m ��slo ��tu, abychom V�m mohli odm�nu zaslat.")),
         email = if_else(email == "annaraichlova@s", "annaraichlova@seznam.cz", email)
         )
vyhodnoceni


dopisy = vyhodnoceni %>% 
  mutate(
    dopis = 
      paste0("Mil� ��astnice, mil� ��astn�ku turnaje PGG,\n\n\n\n",
             "nejprve V�m je�t� jednou srde�n� d�kujeme za Va�� ��ast v turnaji -- bez V�s by nebylo mo�n� zkoumat ",
             "lidskou kooperaci, kter� byla p�edm�tem na�� studie. ",
             "D�le V�m v e-mailu sd�lujeme V� v�sledek v turnaji a jak� odm�na V�m n�le��. \n\n",
             "Toto je n� druh� pokus V�m poslat v�sledky hromadn�, prvn� se p��li� nevyda�il. ",
             "Pokud jste prvn� e-mail s v�sledky dostali, je tento bep�edm�tn� -- nejsou zde nov� informace, ",
             "jen se je�t� jednou sna��me obeslat ��astn�ky najednou.\n\n",
             "Nyn� k v�sledk�m. Jeliko� va�e skupina z�skala dohromady ", soucetSkupiny, " HK a Vy osobn� ",
             celkem, " HK, jste v celkov�m po�ad� ", umisteni, odmenit, "\n\n",
             "Pro zaj�mavost, maxim�ln�ho mo�n�ho v�sledku 1600 HK za celou skupinu dos�hlo 6 skupin a ",
             "jejich �lenky a �lenov� si tak rovn�m d�lem rozd�lili odm�ny za 1. a� 24. m�sto ",
             "(v�ichni shodn� m�li osobn� v�sledek 400 HK, jinak konec konc� nebylo mo�n� maxima dos�hnout). ",
             "Nejvy��� osobn� v�sledek v cel�m turnaji je 417,5 HK, ale ten znamenal 'jen' 29. m�sto.",
             "\n\n\n\nS �ctou,\nFranti�ek Kalvas a Pavl�na M�chov�")
  ) %>% ungroup %>% select(email, dopis) %>% filter(!is.na(email))
dopisy

poslat = read_csv2("prehled.csv") %>% select(email, dopisDorucen)

dopisy2 = left_join(dopisy, poslat) %>% filter(!dopisDorucen)

# ## Odesl�n� personalizovan�ch v�sledk�: ---------------------------------

library(emayili)
library(dplyr)
library(magrittr)

for (d in 1:nrow(dopisy2)) {
  email <- envelope() %>% 
    from("kalvas@kss.zcu.cz") %>% 
    to(dopisy2$email[d]) %>% 
    subject(qp_encode("Vyhodnocen� turnaje PGG (21.4.2021--2.5.2021): Druh� pokus o hromadn� odesl�n�")) %>% 
    text(qp_encode(dopisy2$dopis[d]))
  
  # print(email, details = T)
  
  smtp <- server(host = "smtp.zcu.cz",
                 port = 465,
                 username = "login",
                 password = "pass")
  
  smtp(email, verbose = TRUE)  
}


## Pro otestov�n� adres je�t� ulo��m adresy do Excelu a tam odtud to ru�n� nakop�ruju do ��dku mailu:
write_xlsx(dopisy2, "kontrolaV02.xlsx")
write_xlsx(vyhodnoceni %>% ungroup() %>% select(email, odmena), "odmeny.xlsx")



# ## Upom�nka o ��slo ��tu: ---------------------------------


## Konstrukce zpr�vy
library(dplyr)
library(readr)
library(readxl)

dopisy4= readxl::read_xlsx("prehled.xlsx") %>% select(email, ucet, castka, kdyPoslano) %>%
# dopisy4 = read_csv2("prehled.csv") %>% select(email, ucet, castka, kdyPoslano) %>% 
  filter(ucet == ".", castka > 0) %>%   
  mutate(dopis = 
           paste0(
             "V�en� ��astnice, v�en� ��astn�ku turnaje PGG, \n\n\n",
             "mezi 21. dubnem a 2. kv�tnem 2021 prob�hl turnaj PGG, co� byla kooperativn� hra ",
             "po��dan� Laborato�� experiment�ln� sociologie Z�U, ",
             "kter� jste se ��astnil/a spolu s dal��mi t�emi p��teli nebo zn�m�mi. ",
             "M�me pro V�s za Va�� ��ast p�ipravenou odm�nu ", castka, 
             " K�, ale st�le neevidujeme ��slo Va�eho ��tu. ",
             "Pokud m�te o odm�nu z�jem, za�lete n�m pros�m na tento e-mail ��slo ��tu.",
             "\n\n\nS �ctou,\nFranti�ek Kalvas")) 


## Samotn� odesl�n�
library(emayili)
library(dplyr)
library(magrittr)

for (d in 1:nrow(dopisy4)) {
  email <- envelope() %>% 
    from("kalvas@kss.zcu.cz") %>% 
    to(dopisy4$email[d]) %>% 
    subject(qp_encode("Turnaj PGG: 2. upom�nka")) %>% 
    text(qp_encode(dopisy4$dopis[d]))
  
  # print(email, details = T)
  
  smtp <- server(host = "smtp.zcu.cz",
                 port = 465,
                 username = "login",
                 password = "pass")
  
  smtp(email, verbose = TRUE)  
}



# ## Informace o odesl�n� pen�z -------------------------------------------

## Konstrukce zpr�vy
library(dplyr)
library(readr)
library(readxl)

dopisy3 = readxl::read_xlsx("prehled.xlsx") %>% select(email, ucet, castka, kdyPoslano) %>%
  # dopisy3 = read_csv2("prehled.csv") %>% select(email, ucet, castka, kdyPoslano) %>% 
  filter(kdyPoslano != "---") %>%   
  mutate(dnes = as.Date(kdyPoslano) == Sys.Date(),
         dopis = 
           paste0(
             "V�en� ��astnice, v�en� ��astn�ku turnaje PGG, \n\n\n",
             "dnes (", kdyPoslano, ") jsem V�m odeslal odm�nu ", castka, " K� na V� ��et ��slo ",
             ucet, ". Je�t� jednou -- a naposled -- V�m d�kuji za ��ast v na�em projektu a snad ",
             "se setk�me v jin�m projektu n�kdy v budoucnu. \n\n\nS �ctou,\nFranti�ek Kalvas")) %>% 
  filter(dnes)


## Samotn� odesl�n�
library(emayili)
library(dplyr)
library(magrittr)

for (d in 1:nrow(dopisy3)) {
  email <- envelope() %>% 
    from("kalvas@kss.zcu.cz") %>% 
    to(dopisy3$email[d]) %>% 
    subject(qp_encode("Pen�ze z turnaje PGG V�m byly dnes odesl�ny")) %>% 
    text(qp_encode(dopisy3$dopis[d]))
  
  # print(email, details = T)
  
  smtp <- server(host = "smtp.zcu.cz",
                 port = 465,
                 username = "login",
                 password = "pass")
  
  smtp(email, verbose = TRUE)  
}



