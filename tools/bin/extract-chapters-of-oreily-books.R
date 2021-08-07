library(pdftools)
library(tidyverse)

book <- pdftools::pdf_text("~/Dropbox/Books/2020/data-science/Aurélien Géron - Hands-on machine learning with Scikit-Learn, Keras and Tensorflow.pdf")

book <- tibble(pages = book)


book %>% 
    mutate(str_split())


chapter_lines <- function(page) {
    lines <- str_split(page, "\n")[[1]] %>% str_squish() 
    boo <- str_detect(lines, "\\d{1,2}\\.")
    return(lines[boo])
}

chapter_lines(book$pages[5])

book %>% 
    mutate(chapters = map(pages, chapter_lines)) %>% 
    unnest(chapters) %>% 
    mutate(chp_number = str_extract(chapters, "^\\d+\\."),
           start_page = str_extract(chapters, "\\d+$"),
           end_page = as.numeric(lead(start_page)) - 1) %>%
    select(-pages) %>% 
    mutate(chapters = str_remove(chapters, "(\\. ){2,}\\d+")) %>% 
    .[2:20, ] %>% 
    write_csv("~/Desktop/machine-learning-chapters.csv")

