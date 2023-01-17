library(dplyr)
library(stringr)
library(rvest)

url = "https://seape.df.gov.br/prisoes-dos-atentados-bsb/"
pagina <- rvest::read_html(url) 
pagina |> rvest::html_element("em") |> rvest::html_text() # ultima atualizacao
urlPDF <- pagina |> rvest::html_element("#conteudo a") |> rvest::html_attr("href")

tabela0 <- pdftools::pdf_text(urlPDF)

tabela <- tabela0 |> unlist() |> 
  strsplit("\n") |> unlist() |> 
  str_remove_all("^ +| +$") |> 
  str_subset("\\d") |>
  as.data.frame() |> rename(id =1) |>
  tidyr::extract(id, regex = "(^\\d+) (.*)", into = c("id", "nome0" )) |> 
  mutate(data = str_extract(nome0, "[\\d\\.]+"),
         nome2 = str_remove(nome0, "[\\d\\.]+") |> str_remove(" +$"),
         ano = stringr::str_extract(data, "\\d{4}$")) |>
  filter() |>
  filter(nome2 != "") |>
  select(id, nome2, data, ano) |> rename(nome = nome2) 

#--  busca por query
termo = "cesa"
tabela$nome[grepl(termo, tabela$nome, ignore.case = T)]

# Pensionistas
pensionistas <- read.csv("~/Documentos/Programação/data/politica/202001_Pensionistas_DEFESA/202001_Cadastro.csv", 
                         header = T, sep = ";", stringsAsFactors = F, fileEncoding="latin1") %>% as_tibble()

nomesTabela <- stringr::str_to_title(tabela$nome) 
nomesPensio <-  stringr::str_to_title(pensionistas$NOME)

nomesTabela[nomesTabela %in%  nomesPensio]

write.csv(tabela, "presos_atos_golpistas.csv")

financiadores <- readLines('arquivos/financiadores.txt')  |> strsplit("\\n") |> unlist() |>
  str_remove("^ +") |> str_remove("^#.*") |> str_remove(",.*")


nomesTabela[nomesTabela %in% financiadores]
