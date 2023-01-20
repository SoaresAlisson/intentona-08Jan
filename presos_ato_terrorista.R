library(dplyr)
library(stringr)
library(rvest)

url = "https://seape.df.gov.br/prisoes-dos-atentados-bsb/"

pagina <- rvest::read_html(url) 

#ultimaAtualizacao <- pagina |> rvest::html_element("em") |> rvest::html_text() # ultima atualizacao
#ultimaAtualizacao
#mesDia <- str_extract(ultimaAtualizacao, "[\\d\\/]+") |> str_replace("(.*)/(.*)", "\\2\\1")

ultimaAtualizacao <- pagina |> rvest::html_element(".margin-top-60") |> rvest::html_text() |> str_remove(".*Atualizado") |>  str_extract("\\d{2}/\\d{2}/\\d+")# ultima atualizacao
mesDia <- ultimaAtualizacao |> str_replace("(.*)/(.*)/(.*)", "\\2\\1")
urlPDF <- pagina |> rvest::html_element("#conteudo a") |> rvest::html_attr("href")
arqsPDF <- list.files("arquivos", pattern = "^\\d{4}_.*pdf$")

# salvar novo pdf
nomeNovoArquivoPDF <- paste0(mesDia, "_",
                             str_replace(urlPDF, ".*/(.*pdf)", "\\1"))
# arquivo já existe? se não, baixe
ifelse((nomeNovoArquivoPDF %in% arqsPDF), 
       str_glue('Arquivo "{nomeNovoArquivoPDF}" já existente!'),
       download.file(urlPDF, str_glue("arquivos/{nomeNovoArquivoPDF}"))
)

parser_tabela <- function(arqPDF){
  pdftools::pdf_text(str_glue("arquivos/{arqPDF}")) |>
  unlist() |> 
  strsplit("\n") |> unlist() |> 
  str_remove_all("^ +") |> str_remove_all(" +$") |> 
  str_subset("\\d") |>
  as.data.frame() |> rename(id =1) |>
  tidyr::extract(id, regex = "(^\\d+) (.*)", into = c("id", "nome0" )) |> 
  mutate(nascimento = str_extract(nome0, "[\\d\\.]+") |> as.Date(format = "%d.%m.%Y"),
         nome2 = str_remove(nome0, "[\\d\\.]+") |> str_remove("^ +") |> str_remove(" +$"),
         ano = lubridate::year(nascimento)
         ) |>
  filter(nome2 != "") |>
  select(nome2, nascimento, ano) |> rename(nome = nome2) 
}

# exemplo de tabela
parser_tabela(arqsPDF[3]) |> str()
parser_tabela(arqsPDF[1]) 

# ------
pdf = arqsPDF[1] # temporario
nomeCol <- str_extract(pdf, "^\\d{4}") |> str_replace("^(\\d{2})(\\d{2})", "\\2.\\1") 
tabela <- parser_tabela(pdf) |> mutate({{nomeCol}} := "sim") 

for (i in 2:length(arqsPDF)){
  pdf = arqsPDF[i] # temporario
  nomeCol <- str_extract(pdf, "^\\d{4}") |> str_replace("^(\\d{2})(\\d{2})", "\\2.\\1") 
  tabela2 <- parser_tabela(pdf) |>mutate({{nomeCol}} := "sim") |> select(nome,nascimento, {nomeCol})
  tabela <- full_join(tabela, tabela2, by="nome")
}
tabela <- arrange(tabela, nome)
#----


# ---
nomeNascimento <- parser_tabela(arqsPDF[1]) |> select(nome,nascimento)
for (i in 2:length(arqsPDF)){
  nomeNascimento2 <- parser_tabela(arqsPDF[i]) |> select(nome,nascimento)
  nomeNascimento <- union(nomeNascimento, nomeNascimento2)
}
nomeNascimento <- arrange(nomeNascimento, nome)

tabela <- nomeNascimento
for (i in 1:length(arqsPDF)){
  nomeCol <- str_extract(arqsPDF[i], "^\\d{4}") |> str_replace("^(\\d{2})(\\d{2})", "\\2.\\1") 
  tabela2 <- parser_tabela(arqsPDF[i]) |> mutate({{nomeCol}} := "sim") |> select(nome, {nomeCol})
  tabela <- left_join(tabela, tabela2, by="nome")
}
str(tabela)
# ----

saveRDS(tabela, "presos_atos_golpistas.rds")
write.csv(tabela, "presos_atos_golpistas.csv")


#--  busca por nome
termo = "Trevisani" # nomea ser buscado
# tabela$nome[grepl(termo, tabela$nome, ignore.case = T)]
filter(tabela, grepl(termo, nome,ignore.case = T))
# ----


# cruzar dados d presos com os financiadores
financiadores <- readLines('arquivos/financiadores.txt')  |> strsplit("\\n") |> unlist() |>
  str_remove("^ +") |> str_remove("^#.*") |> str_remove(",.*")

nomesTabela[nomesTabela %in% financiadores]
# ----