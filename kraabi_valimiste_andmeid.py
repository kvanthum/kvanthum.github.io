import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
import time
import re


driver = webdriver.Chrome(ChromeDriverManager().install())
url = "https://rk2023.valimised.ee/et/candidates"
driver.get(url)
time.sleep(10)
content = driver.find_element(By.CLASS_NAME, "listing")
ringkonnad = content.find_elements(By.TAG_NAME, "a")
ringkonna_lingid = [ring.get_attribute("href") for ring in ringkonnad][1:]

df = pd.DataFrame(columns = ['ringkond', 'nimekiri', 'nimi', 'sünniaeg', 'erakond', 'kontakt', 'haridus', 'amet'])

for link in ringkonna_lingid[0:len(ringkonna_lingid)-1]:
    #link = ringkonna_lingid[0]
    driver.get(link)
    time.sleep(3)
    nimekirjad = driver.find_elements(By.CLASS_NAME, "party-members")
    members = [part.find_elements(By.TAG_NAME, "a") for part in nimekirjad] # list of lists
    memberlinks = sum([[member.get_attribute("href") for member in membergroup] for membergroup in members], [])
    
    for memberlink in memberlinks:
        #memberlink = memberlinks[0]
        driver.get(memberlink)
        time.sleep(3)
        valimisringkond = driver.find_element(By.CLASS_NAME, "p-0").text
        kandiinfo = driver.find_element(By.CLASS_NAME, "box.party-name.mb-3")
        kandinimi = kandiinfo.find_elements(By.TAG_NAME, "span")[2].text
        kanditabel = kandiinfo.find_elements(By.TAG_NAME, "tr")
        nimekiri = kanditabel[0].find_element(By.CLASS_NAME, "second").text
        synniaeg = kanditabel[1].find_element(By.CLASS_NAME, "second").text
        erakond = kanditabel[2].find_element(By.CLASS_NAME, "second").text
        kontakt = kanditabel[3].find_element(By.CLASS_NAME, "second").text
        haridus = kanditabel[4].find_element(By.CLASS_NAME, "second").text
        amet = kanditabel[5].find_element(By.CLASS_NAME, "second").text
        
        df = df.append({"ringkond" : valimisringkond, "nimekiri" : nimekiri, "nimi" : kandinimi, "sünniaeg" : synniaeg, "erakond" : erakond, "kontakt" : kontakt, "haridus" : haridus, "amet" : amet}, ignore_index = True)
        
        
df2 = df.head(968)
df2["kontakt"] = df["kontakt"].str.replace("\n", "; ")


df2.to_csv("C:/Users/a71385/Desktop/kvanthum.github.io/data/kandidaadid_2023_raw.csv", sep = "\t", index = False, encoding = "utf-8", )


# Kraabi tulemused
driver_tulemused = webdriver.Chrome(ChromeDriverManager().install())
url_tulemused = "https://rk2023.valimised.ee/et/detailed-voting-result/index.html"
driver_tulemused.get(url_tulemused)
time.sleep(10)
content_tulemused = driver_tulemused.find_elements(By.CLASS_NAME, "district-link")
ringkonnad_tulemused = [r.find_element(By.TAG_NAME, "a").get_attribute("href") for r in content_tulemused]

df_tulemused = pd.DataFrame(columns = ["nimi", "hääli_kokku", "e-hääli", "hääli_välisriigist", "hääli_väljaspool_ringkonda"])

for t in ringkonnad_tulemused:
    #t = ringkonnad_tulemused[0]
    driver_tulemused.get(t)
    time.sleep(3)
    tabelid = driver_tulemused.find_elements(By.CLASS_NAME, "table")[2:]
    nimekirjatabelid = sum([tbl.find_element(By.TAG_NAME, "tbody").find_elements(By.TAG_NAME, "tr") for tbl in tabelid], [])
    for n in nimekirjatabelid:
        #n = nimekirjatabelid[0]
        if n.get_attribute("class") == "":
            n1 = n.find_elements(By.TAG_NAME, "td")
            kandinimi_tulemus = n1[1].text
            kandi_haali_kokku = n1[2].text
            kandi_e_haali = n1[len(n1)-1].text
            kandi_valisriigist = n1[len(n1)-3].text
            kandi_valjaspool = n1[len(n1)-2].text
            df_tulemused = df_tulemused.append({"nimi" : kandinimi_tulemus, "hääli_kokku" : kandi_haali_kokku, "e-hääli" : kandi_e_haali, "hääli_välisriigist" : kandi_valisriigist, "hääli_väljaspool_ringkonda" : kandi_valjaspool}, ignore_index = True)

df_tulemused.to_csv("C:/Users/a71385/Desktop/kvanthum.github.io/data/kandidaadid_2023_raw_votes.csv", sep = "\t", index = False, encoding = "UTF-8")
