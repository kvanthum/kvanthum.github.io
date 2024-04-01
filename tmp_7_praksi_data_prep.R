# üllatusküs andmestik https://osf.io/knygh/
# Asu, Eva Liina, Heete Sahkai & Pärtel Lippus. 2024. The prosody of surprise questions in Estonian. Journal of Linguistics 60(1). 7–27. https://doi.org/10.1017/S0022226723000014.



ls(
    
)
summary(dat)

library(tidyverse)

dat %>% 
    group_by(jrk, tyyp1, kysisona,  id_sona) %>% 
    summarise(kestus = mean(phr_dur), f0_kesk = mean(phr_f0_mean), f0_alg = mean(phr_f0_start, na.rm=T), f0_lopp = mean(phr_f0_stop, na.rm=T)) -> tmp
tmp


dat %>% 
    group_by(sp, tyyp1, kysisona) %>% 
    summarise(kestus = mean(phr_dur), f0_kesk = mean(phr_f0_mean), f0_alg = mean(phr_f0_start, na.rm=T), f0_lopp = mean(phr_f0_stop, na.rm=T)) -> tmp

levels(tmp$tyyp1)

boxplot(kestus ~ tyyp1, data = tmp)
boxplot(f0_kesk ~ tyyp1, data = tmp)
boxplot(f0_alg ~ tyyp1, data = tmp)
boxplot(f0_lopp ~ tyyp1, data = tmp)

hist((tmp$kestus))
qqnorm(tmp$kestus)
qqline(tmp$kestus)
shapiro.test(tmp$kestus)
shapiro.test(log(tmp$kestus))
ad.test(tmp$kestus)


var.test(tmp$kestus~tmp$tyyp1)
t.test(tmp$kestus~tmp$tyyp1, var.equal = T)


hist(log(tmp$f0_kesk))
shapiro.test(log(tmp$f0_kesk))
ad.test(log(tmp$f0_kesk))

t.test(f0_kesk ~ tyyp1, data = tmp)

plot(f0_kesk~kestus, data=tmp)
abline(lm(f0_kesk~kestus, data=tmp))
summary(lm(f0_kesk~kestus, data=tmp))
          
plot(f0_alg~f0_lopp, data=tmp)
abline(lm(f0_alg~f0_lopp, data=tmp))
summary(lm(f0_alg~f0_lopp, data=tmp))
      

install.packages('nortest')
library(nortest)

?ad.test()

summary(lm(f0_lopp~ f0_alg + kysisona, data=tmp))
