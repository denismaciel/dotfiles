#! /usr/local/bin/Rscript

# Takes an URL as argument and returns the content of h1
library(magrittr)
args <- commandArgs(trailingOnly = TRUE)

if (is.null(args)) stop("You must pass an URL")

URL <- args[[1]]

# stopifnot(!is.null(args), message = "You must pass an URL")

if (!stringr::str_detect(URL, "http")) {
    URL <- paste0("http://", URL)
}

message(paste("Connecting to ", URL))

html <- xml2::read_html(URL)

html %>% 
    rvest::html_nodes('h1') %>% 
    .[[1]] %>%
    rvest::html_text() %>%
    stringr::str_squish() %>%
    write(file = stdout())
