suured <- function(){
    sisend <- readline(prompt = "Sisesta sõnad: ")
    sonad <- unlist(strsplit(sisend, split = " "))
    paste(toupper(substring(sonad, 1, 1)),
          tolower(substring(sonad, 2)), 
          sep = "", collapse = " ")
}