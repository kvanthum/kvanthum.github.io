import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
import time

# initsialiseeri draiver, mis avaks Chrome'i akna
driver = webdriver.Chrome(ChromeDriverManager().install())
url = "https://rk2023.valimised.ee/et/candidates" # veebilehe aadress
driver.get(url) # liigu Chrome'i aknas veebilehele

# leia ringkondade lingid
content = driver.find_element(By.CLASS_NAME, "listing") # leia elemendid, mille class'i väärtus on "listing"
ringkonnad = content.find_elements(By.TAG_NAME, "a") # sellest omakorda kõik lingid
ringkonna_lingid = [ring.get_attribute("href") for ring in ringkonnad][1:] # ja pane linkide aadressid listi

# tee tühi andmetabel, kuhu kandidaatide infot koguda
df = pd.DataFrame(columns = ['ringkond', 'nimekiri', 'nimi', 'sünniaeg', 'erakond', 'kontakt', 'haridus', 'amet'])

# iga ringkonna lingi puhul
for link in ringkonna_lingid[0:len(ringkonna_lingid)-1]:
    driver.get(link) # liigu Chrome'i aknas sellele lingile
    time.sleep(3) # oota 3 sekundit, et leht laeks
    nimekirjad = driver.find_elements(By.CLASS_NAME, "party-members") # leia ringkonna nimekirjad
    members = [part.find_elements(By.TAG_NAME, "a") for part in nimekirjad] # leia nimekirjade lingid
    memberlinks = sum([[member.get_attribute("href") for member in membergroup] for membergroup in members], []) # pane linkide aadressid listi
    
    # iga kandidaadi lingi puhul
    for memberlink in memberlinks:
        driver.get(memberlink) # liigu Chrome'i aknas sellele lingile
        time.sleep(3) # oota 3 sekundit, et leht laeks
        valimisringkond = driver.find_element(By.CLASS_NAME, "p-0").text # ringkonna nimi
        kandiinfo = driver.find_element(By.CLASS_NAME, "box.party-name.mb-3") # kandidaadi info
        kandinimi = kandiinfo.find_elements(By.TAG_NAME, "span")[2].text # kandidaadi nimi
        kanditabel = kandiinfo.find_elements(By.TAG_NAME, "tr") # kandidaadi infotabeli read
        nimekiri = kanditabel[0].find_element(By.CLASS_NAME, "second").text # kandidaadi valimisnimekiri
        synniaeg = kanditabel[1].find_element(By.CLASS_NAME, "second").text # kandidaadi sünniaeg
        erakond = kanditabel[2].find_element(By.CLASS_NAME, "second").text # kandidaadi erakondlik kuuluvus
        kontakt = kanditabel[3].find_element(By.CLASS_NAME, "second").text # kandidaadi kontaktandmed
        haridus = kanditabel[4].find_element(By.CLASS_NAME, "second").text # kandidaadi haridus
        amet = kanditabel[5].find_element(By.CLASS_NAME, "second").text # kandidaadi amet
        
        # lisa kandidaadi infoga rida andmetabelisse
        df = df.append({"ringkond" : valimisringkond, "nimekiri" : nimekiri, "nimi" : kandinimi, "sünniaeg" : synniaeg, "erakond" : erakond, "kontakt" : kontakt, "haridus" : haridus, "amet" : amet}, ignore_index = True)
        
        
df["kontakt"] = df["kontakt"].str.replace("\n", "; ") # asenda kontaktandmetes reavahetused semikooloniga

# kirjuta kandidaatide andmed faili
df.to_csv("C:/Users/a71385/Desktop/kvanthum.github.io/data/kandidaadid_2023_raw.csv", sep = "\t", index = False, encoding = "utf-8", )


# Kraabi tulemused
# initsialiseeri draiver, mis avaks Chrome'i akna
driver_tulemused = webdriver.Chrome(ChromeDriverManager().install())
url_tulemused = "https://rk2023.valimised.ee/et/detailed-voting-result/index.html" # tulemuste veebilehe aadress
driver_tulemused.get(url_tulemused) # liigu Chrome'i aknas veebilehele

# leia ringkondade tulemuste lingid
content_tulemused = driver_tulemused.find_elements(By.CLASS_NAME, "district-link") # leia elemendid, mille class'i väärtus on "district-link"
ringkonnad_tulemused = [r.find_element(By.TAG_NAME, "a").get_attribute("href") for r in content_tulemused] # sellest omakorda pane listi kõik lingid

# tee tühi andmetabel, kuhu kandidaatide tulemusi koguda
df_tulemused = pd.DataFrame(columns = ["nimi", "hääli_kokku", "e-hääli", "hääli_välisriigist", "hääli_väljaspool_ringkonda"])

# iga ringkonna lingi puhul
for t in ringkonnad_tulemused:
    driver_tulemused.get(t) # liigu Chrome'i aknas sellele lingile
    time.sleep(3) # oota 3 sekundit, et leht laeks
    tabelid = driver_tulemused.find_elements(By.CLASS_NAME, "table")[2:] # leia lehelt kõik tabelid (peale esimese kahe)
    nimekirjatabelid = sum([tbl.find_element(By.TAG_NAME, "tbody").find_elements(By.TAG_NAME, "tr") for tbl in tabelid], []) # pane kõikide tabelite read (= kandidaatide info) listi
    
    # iga kandidaadi puhul
    for n in nimekirjatabelid:
        if n.get_attribute("class") == "": # kui tegemist ei ole kokkuvõttereaga
            n1 = n.find_elements(By.TAG_NAME, "td") # leia kandidaadi rea lahtrid
            kandinimi_tulemus = n1[1].text # kandidaadi nimi
            kandi_haali_kokku = n1[2].text # kandidaadi hääli kokku
            kandi_e_haali = n1[len(n1)-1].text # kandidaadi e-hääli
            kandi_valisriigist = n1[len(n1)-3].text # kandidaadi välisriigist saadud hääled
            kandi_valjaspool = n1[len(n1)-2].text # kandidaadi väljaspool Eestit saadud hääled
            
            # lisa kandidaadi infoga rida andmetabelisse
            df_tulemused = df_tulemused.append({"nimi" : kandinimi_tulemus, "hääli_kokku" : kandi_haali_kokku, "e-hääli" : kandi_e_haali, "hääli_välisriigist" : kandi_valisriigist, "hääli_väljaspool_ringkonda" : kandi_valjaspool}, ignore_index = True)

# kirjuta kandidaatide andmed faili
df_tulemused.to_csv("C:/Users/a71385/Desktop/kvanthum.github.io/data/kandidaadid_2023_raw_votes.csv", sep = "\t", index = False, encoding = "UTF-8")
