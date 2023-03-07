library(rvest)
library(tidyverse)

# Loe andmed sisse
dat <- read.delim("C:/Users/a71385/Desktop/kvanthum.github.io/data/kandidaadid_2023_raw.csv", encoding = "UTF-8")
head(dat)

# Lisa sugu, vanus ja tähtkuju
lapply(dat$nimi, function(x) strsplit(x, " ") %>% unlist() %>% .[1]) %>% unlist()

# Kraabi Vikipeediast naistenimede loend
naisteurl <- "https://et.wikipedia.org/wiki/Naisenimede_loend"
meesteurl <- "https://et.wikipedia.org/wiki/Mehenimede_loend"

naised <- read_html(naisteurl)
naised %>% 
    html_elements(., ".mw-parser-output") %>%
    html_elements(., "p") %>%
    .[4:length(.)] %>%
    html_elements(., "a") %>%
    html_text() %>%
    tolower() -> naisenimed

mehed <- read_html(meesteurl)
mehed %>%
    html_elements(., ".mw-parser-output") %>%
    html_elements(., "p") %>%
    .[4:length(.)] %>%
    html_elements(., "a") %>%
    html_text() %>%
    tolower() -> mehenimed

# lisame veel mõned puuduvad tavalised mehenimed
mehenimed <- c(mehenimed, "aivar", "raivo", "martti", "marti", "aleksei", "aleksandr", "arne")

# Millised naisenimed on ka mehenimed?
naisenimed[naisenimed %in% mehenimed]

# Kui nimi on ainult naisenimedes JA ei ole mehenimedes
# Kui nimi on ainult mehenimedes JA ei ole naisenimedes
# Kui nime esiosa enne sidekriipsu on ainult naisenimedes JA ei ole mehenimedes
# Kui nime esiosa enne sidekriipsu on ainult mehenimedes JA ei ole naisenimedes
# Kui nime tagumine osa pärast sidekriipsu on ainult naisenimedes JA ei ole mehenimedes
# Kui nime tagumine osa pärast sidekriipsu on ainult mehenimedes JA ei ole naisenimedes

dat %>%
    mutate(eesnimi = tolower(gsub("^([^ ]+?) .*$", "\\1", nimi))) %>%
    mutate(sugu = case_when(eesnimi %in% naisenimed & !eesnimi %in% mehenimed ~ "N",
                            eesnimi %in% mehenimed & !eesnimi %in% naisenimed ~ "M",
                            gsub("^([^-]+?)-.*$", "\\1", eesnimi) %in% naisenimed & !gsub("^([^-]+?)-.*$", "\\1", eesnimi) %in% mehenimed ~ "N",
                            gsub("^([^-]+?)-.*$", "\\1", eesnimi) %in% mehenimed & !gsub("^([^-]+?)-.*$", "\\1", eesnimi) %in% naisenimed ~ "M",
                            gsub("^[^-]+?-(.*)$", "\\1", eesnimi) %in% naisenimed & !gsub("^[^-]+?-(.*)$", "\\1", eesnimi) %in% mehenimed ~ "N",
                            gsub("^[^-]+?-(.*)$", "\\1", eesnimi) %in% mehenimed & !gsub("^[^-]+?-(.*)$", "\\1", eesnimi) %in% naisenimed ~ "M")) %>%
    select(-eesnimi) -> dat2

(dat2 %>%
        filter(is.na(sugu)) %>%
        pull(nimi) -> soota_nimed)

on_mees <- ifelse(c(T, T, T, T, T, F, F, F, T, F, F, T, T, T, F, F, F, F, T, T, T, F, F, F, F, F, T, F, T, T, F, T, T, T, T, T, T, T, F, T, F, F, F, T, F, T, F, F, F, F, F, F, F, T, F, T, T, T, T, T, T, T, F, T, T, T, T, T, F, F, F, T, T, T, T, F, T, F), "M", "N")

data.frame(soota_nimed, on_mees) %>% arrange(on_mees)

dat2[is.na(dat2$sugu),]$sugu <- on_mees

# arvuta vanus
library(lubridate)

dat2 %>%
    mutate(vanus = floor(interval(as.Date(sünniaeg, format = "%d.%m.%Y"), as.Date("05.03.2023", format = "%d.%m.%Y")) / years(1))) -> dat2



# leia tähtkuju
library(DescTools)
dat2 %>%
    mutate(tähtkuju = factor(Zodiac(as.Date(dat2$sünniaeg, format = "%d.%m.%Y")), labels = c("Kaljukits", "Veevalaja", "Kalad", "Jäär", "Sõnn", "Kaksikud", "Vähk", "Lõvi", "Neitsi", "Kaalud", "Skorpion", "Ambur"))) -> dat2


names(dat2)
dat2 %>%
    select(ringkond, nimekiri, nimi, sünniaeg, vanus, sugu, tähtkuju, haridus, erakond, amet, kontakt) -> dat2


tulemused <- read.delim("data/kandidaadid_2023_raw_votes.csv", header = T, sep = "\t", encoding = "UTF-8")
tulemused
# Kas kõik nimed mõlemas tabelis?
dat2$nimi[!dat2$nimi %in% tulemused$nimi]

left_join(dat2, tulemused, by = "nimi")
dat2[520,]
tulemused[tulemused$nimi == "TARMO TAMM",] # e200 - 876
left_join(dat2, tulemused, by = "nimi", multiple = "all") -> valimised_tulemused
valimised_tulemused %>% filter(nimi == "TARMO TAMM")
valimised_tulemused <- valimised_tulemused[!(valimised_tulemused$nimi == "TARMO TAMM" & valimised_tulemused$nimekiri == "Erakond Eesti 200" & valimised_tulemused$hääli_kokku == 1258),]
valimised_tulemused <- valimised_tulemused[!(valimised_tulemused$nimi == "TARMO TAMM" & valimised_tulemused$nimekiri != "Erakond Eesti 200" & valimised_tulemused$hääli_kokku != 1258),]

valimised_tulemused[valimised_tulemused$nimi == "KERT KINGO",]$sugu <- "N"

write.table(valimised_tulemused, "C:/Users/a71385/Desktop/kvanthum.github.io/data/kandidaadid_2023.csv", quote = F, sep = "\t", fileEncoding = "UTF-8", row.names = F)
