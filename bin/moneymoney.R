library(magrittr)
suppressMessages(library(dplyr))

df <- read.table(pipe("pbpaste"), sep = "\t", stringsAsFactors = FALSE)

df <- tibble::as_tibble(df)

df <- df %>% 
    transmute(Date = as.Date(V1, "%d.%m.%Y"),
             Sender = V2,
             Reason = V3,
             IBAN = V4,
             Value = readr::parse_double(df$V6, locale = readr::locale(decimal_mark = ",")))
df %>%
    write.table(pipe("pbcopy"), sep = "\t", row.names = FALSE)
