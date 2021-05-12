## Skript na tvorbu grafù z turnaje PGG

## Encoding: windows-1250
## Vytvoøil: 2021-04-21 FrK
## Upravil: 2021-05-12 FrK




# ## Hlavièka a naètení dat -----------------------------------------------

## Smazání pamìti
rm(list = ls())


## Package
library(ggplot2)
library(dplyr)


# ## Vývojový graf --------------------------------------------------------

PGG %>% group_by(stage.round, session) %>% summarise(contribution = mean(contribution)) %>% 
  ggplot(aes(x = stage.round, y = contribution, col = session)) +
  geom_line()

PGG %>% group_by(stage.round) %>% summarise(contribution = mean(contribution)) %>% 
  ggplot(aes(x = stage.round, y = contribution)) +
  geom_line()

ggplot(KA1_pgg, aes(x = stage.round, y = contribution, group = session)) +
  geom_jitter(col = "blue", alpha = 0.2, size = 2, width = 0, height = 0.3) +  # Individuální pozorování
  stat_summary(fun = mean,   # Prùmìr skupiny za kolo
               fun.args = list(mult = 1), 
               geom = "line", 
               size = 1.5, 
               color = "#808080") +
  geom_line(data = (KA1_pgg %>% group_by(stage.round) %>% mutate(contribution = mean(contribution, na.rm = T))),
            aes(x = stage.round, y = contribution),
            color = "steelblue",
            size = 0.5) +  # Prùmìr za celý turnaj
  facet_wrap(vars(date %>% as.character()), nrow = 4) +  # Rozdìlení do panelù podle skupin
  guides(color = F) +
  labs(caption = "Vysvìtlivky:
  Tenká modrá èára ukazuje prùmìrnou investici do spoleèného úètu za kolo za celý turnaj.
  Tlustá šedá èára ukazuje prùmìrnou investici za kolo v pøíslušné skupinì.
  Modré body ukazují investice jednotlivých hráèù, které byly celé èíslo v intervalu 0--20. 
  K investicím hráèù je pøièten drobný šum (+/- 0.3), aby byl zøetelnìjší pøekryv hodnot.
  Graf je rozdìlený do panelù podle èasu, kdy skupina dohrála.",
       x = "Kolo", y = "Pøíspìvek", 
       title = "Pøíspìvky jednotlivých hráèù, prùmìry skupin a prùmìr celého turnaje podle kola a skupiny (N = 68).") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(0, 10, 2)) +
  scale_y_continuous(breaks = seq(0, 20, 2)) 
ggsave("kompletniPrehled.png", units = "cm", width = 20, height = 24)



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


vysledek %>% mutate(date = as.Date(date)) %>%  group_by(date) %>% summarise(soucetSkupiny = mean(soucetSkupiny)/4) %>%  
  ggplot(aes(x=date, y=soucetSkupiny)) +
  geom_line() +
  geom_jitter(data = vysledek %>% mutate(date = as.Date(date)), aes(x=date, y=celkem),
              size = 5, alpha = 0.1, width = 0.2)

vysledek %>% group_by(session, soucetSkupiny) %>% 
  mutate(znajiSe = mean(znajiSe, na.rm = T), blizkost = mean(blizkost, na.rm = T)) %>%  
  ggplot(aes(x=blizkost, y=soucetSkupiny)) +
  facet_wrap(~communication) +
  geom_jitter(size = 5, alpha = 0.3) +
  geom_smooth(method = "lm")


vysledek %>% group_by(session, soucetSkupiny) %>% 
  mutate(znajiSe = mean(znajiSe, na.rm = T), 
         blizkost = mean(blizkost, na.rm = T), 
         kooperujeKam = mean(kooperujeKam, na.rm = T), 
         kooperujeCiz = mean(kooperujeCiz, na.rm = T)) %>%  
  ggplot(aes(x=znajiSe, y=soucetSkupiny)) +
  facet_wrap(~communication) +
  geom_jitter(size = 5, alpha = 0.3) +
  geom_smooth(method = "lm")



vysledek %>% group_by(session, soucetSkupiny) %>% 
  mutate(znajiSe = mean(znajiSe, na.rm = T), 
         blizkost = mean(blizkost, na.rm = T), 
         kooperujeKam = mean(kooperujeKam, na.rm = T), 
         kooperujeCiz = mean(kooperujeCiz, na.rm = T)) %>%  
  ggplot(aes(x=kooperujeKam, y=soucetSkupiny)) +
  facet_wrap(~communication) +
  geom_jitter(size = 5, alpha = 0.3) +
  geom_smooth(method = "lm")



vysledek %>% group_by(session, soucetSkupiny) %>% 
  mutate(znajiSe = mean(znajiSe, na.rm = T), 
         blizkost = mean(blizkost, na.rm = T), 
         kooperujeKam = mean(kooperujeKam, na.rm = T), 
         kooperujeCiz = mean(kooperujeCiz, na.rm = T)) %>%  
  ggplot(aes(x=kooperujeCiz, y=soucetSkupiny)) +
  facet_wrap(~communication) +
  geom_jitter(size = 5, alpha = 0.3) +
  geom_smooth(method = "lm")



celkova %>% group_by(player) %>% 
  mutate(contribution = mean(contribution)) %>% filter(stage.round == 1) %>% 
  ggplot(aes(x=znajiSe, y=contribution)) +
  geom_jitter(width = 0.25) 



celkova %>% group_by(player) %>% 
  mutate(contribution = mean(contribution)) %>% filter(stage.round == 1) %>% 
  ggplot(aes(x=blizkost, y=contribution)) +
  geom_jitter(width = 0.25) 



celkova %>% group_by(player) %>% 
  mutate(contribution = mean(contribution)) %>% filter(stage.round == 1) %>% 
  ggplot(aes(x=kooperujeKam, y=contribution)) +
  geom_jitter(width = 0.25) 



celkova %>% group_by(player) %>% 
  mutate(contribution = mean(contribution)) %>% filter(stage.round == 1) %>% 
  ggplot(aes(x=kooperujeCiz, y=contribution)) +
  geom_jitter(width = 0.25) 

