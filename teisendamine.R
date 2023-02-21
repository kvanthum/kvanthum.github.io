eelmine <- read.delim("data/kysimustik_2022_vastused.csv")
str(kysimustik)
str(eelmine)

levels(kysimustik$oppekava)
eelmine$oppekava <- factor(eelmine$oppekava)
levels(eelmine$oppekava)

levels(kysimustik$kogemused_kvant)
eelmine$kogemused_kvant <- factor(eelmine$kogemused_kvant)
levels(eelmine$kogemused_kvant)

levels(kysimustik$programmeerimisoskus)
class(kysimustik$programmeerimisoskus)
eelmine$programmeerimisoskus <- factor(eelmine$programmeerimisoskus)
levels(eelmine$programmeerimisoskus)

levels(kysimustik$kursuse_labimine)
class(kysimustik$kursuse_labimine)
eelmine$kursuse_labimine <- factor(eelmine$kursuse_labimine, ordered = T, levels = c("1", "2", "3", "4", "5"))
levels(eelmine$kursuse_labimine)
class(eelmine$kursuse_labimine)

levels(kysimustik$lemmikjook)
eelmine$lemmikjook <- factor(eelmine$lemmikjook)
levels(eelmine$lemmikjook)

levels(kysimustik$soogitegemisoskus)
class(kysimustik$soogitegemisoskus)
eelmine$soogitegemisoskus <- factor(eelmine$soogitegemisoskus, ordered = T, levels = c("1", "2", "3", "4", "5"))
levels(eelmine$soogitegemisoskus)

levels(kysimustik$lemmikloom)
eelmine$lemmikloom <- factor(eelmine$lemmikloom)
levels(eelmine$lemmikloom)

levels(kysimustik$aasta)
eelmine$aasta <- factor(eelmine$aasta)
levels(eelmine$aasta)

str(eelmine)

kysimustik <- eelmine
save(kysimustik, file = "data/kysimustik_2023.RData")

teema <- theme(axis.text = element_text(size = 12),
               title = element_text(size = 14),
               panel.background = element_blank(),
               axis.line.x = element_line(color = "grey80"),
               axis.ticks.y = element_blank(),
               axis.ticks.x = element_line(color = "grey70"))


kategs <- function(tunnus, pealkiri, aspekt, loomad, ord, caption = ""){
    if(ord){
        kysimustik %>%
            group_by(.data[[tunnus]], .drop = FALSE) %>%
            tally() %>%
            ggplot(aes(x = .data[[tunnus]], y = n)) + labs(caption = caption) -> p
    }else{
        kysimustik %>%
            group_by(.data[[tunnus]], .drop = FALSE) %>%
            tally() %>%
            ggplot(aes(x = reorder(.data[[tunnus]], n), y = n)) -> p
    }
    p +
        geom_col(aes(fill = n), width = 0.95, show.legend = F) +
        geom_text(aes(label = n), hjust = 1.2, color = "white") +
        coord_flip() +
        scale_fill_gradient(low = "#68948D", high = "#D2B278") +
        scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 30, whitespace_only = F)) +
        labs(x = "", y = "", title = pealkiri) +
        teema +
        theme(aspect.ratio = 1/aspekt) -> p1
    if(loomad){
        p1 +
            annotation_custom(rasterGrob(koer), xmin = 3.5, xmax = 4.5, ymin = 0.5, ymax = 3.5) +
            annotation_custom(rasterGrob(kaelkirjak), xmin = 2.5, xmax = 3.5, ymin = 0.5, ymax = 3.5) +
            annotation_custom(rasterGrob(glaucus), xmin = 1.5, xmax = 2.5, ymin = 0.5, ymax = 3.5)
    }else{
        p1
    }
}

kategs("oppekava", "Millisel õppekaval õpid?", 1, F, F)
kategs("kogemused_kvant", "Kas sul on varasemaid kogemusi kvantitatiivsete meetoditega?", 5, F, F)
kategs("lemmikjook", "Kohv või tee?", 4, F, F)
kategs("lemmikloom", "Vali loom", 4, T, F)
kategs("programmeerimisoskus", "Kirjelda oma programmeerimisoskusi", 2, F, F)
kategs("kursuse_labimine", "Kui tõenäoline on, et läbid selle kursuse?", 3, F, T, "Skaala: 1 (kindlasti kukun läbi) - 5 (kindlasti saan läbi)")
kategs("soogitegemisoskus", "Hinda oma söögitegemisoskusi", 3, F, T, "Skaala: 1 (tellin toitu koju) - 5 (meisterkokk)")


nums <- function(tunnus, tyyp, pealkiri){
    ggplot(data = kysimustik, aes(x = .data[[tunnus]])) +
        teema -> p
    if(tyyp == "tulp"){
        p +
            geom_bar(aes(fill = after_stat(count)), show.legend = F) +
            coord_flip() +
            scale_fill_gradient(low = "#68948D", high = "#D2B278") +
            theme(axis.text.y = element_text(size = 10)) +
            labs(x = "", y = "", title = pealkiri)
    }else if(tyyp == "hist"){
        p +
            geom_histogram(aes(fill = after_stat(count)), show.legend = F, binwidth = 5) +
            scale_fill_gradient(low = "#68948D", high = "#D2B278") +
            theme(axis.line = element_line(color = "grey80")) +
            labs(x = pealkiri, y = "", subtitle = "Histogramm")
    }else if(tyyp == "tihedus"){
        p +
            geom_density(fill = "#68948D", color = "#D2B278") +
            theme(axis.line = element_line(color = "grey80")) +
            labs(x = pealkiri, y = "Tõenäosustihedus", subtitle = "Tihedusgraafik")
    }else{
        p +
            geom_boxplot(fill = "#68948D", color = "#D2B278") +
            theme(axis.text.y = element_blank()) +
            labs(x = pealkiri, y = "", subtitle = "Karpdiagramm")
    }
}


nums("synniaasta", "tulp", "Mis on sinu sünniaasta?")
nums("synniaasta", "hist", "Sünniaasta")
nums("synniaasta", "tihedus", "Sünniaasta")
nums("synniaasta", "karp", "Sünniaasta")
nums("kaua_opid", "hist", "Õpitud aastaid")
nums("kaua_opid", "tihedus", "Õpitud aastaid")
nums("kaua_opid", "karp", "Õpitud aastaid")
