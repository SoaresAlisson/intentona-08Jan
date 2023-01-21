library(dplyr)
library(stringr)

# Para arquivos de data após 20/01/2022



conserta_nomes <- function(input){
  str_to_title(input, locale="pt") |> 
    str_replace_all(c(" E " = " e ", " Da " = " da ", " De " = " de ", 
                      " Do " = " do ", " Das " = " das ", " Dos " = " dos ")) |>
    iconv(to = "ASCII//TRANSLIT") |>
    str_remove_all("^[ ]+|[ ]+$")
}

regex_data <- "\\d{1,2}.\\d{1,2}.\\d{2,4}"
# função que estrutura o PDF 
parser_tabela <- function(arqPDF){
  pdftools::pdf_text(str_glue("arquivos/{arqPDF}")) |>
    unlist() |> 
    strsplit("\n") |> unlist() |> 
    str_remove_all("^\\s+") |> str_remove_all("\\s+$") |> 
    as.data.frame() |> rename(id0 =1) |>
    tidyr::extract(id0, regex = str_glue("(.*) ({regex_data}) +(.*)"), into = c("nome", "nascimento", "UF" )) |> 
    mutate(nascimento = str_extract(nascimento, regex_data) |> as.Date(format = "%d.%m.%Y"),
            nome = str_remove(nome, regex_data) |> conserta_nomes(),
            ano = lubridate::year(nascimento)) |>
    # # rename(nome = nome2) |> 
    # select(nome, nascimento, ano, id0) |> 
    # mutate(nome = conserta_nomes(nome)) |>
    filter(nome != "") #|>     select(-id0, -linha)
}

PDFsHoje <- grep(str_glue("{mesDia}"), arqsPDF, value = T)

CDPII <- parser_tabela(
            grep("cdp2", PDFsHoje, value = T)) |> 
          mutate(prisao="M")

PFDF <- parser_tabela(
  grep("pfdf", PDFsHoje, value = T)) |> 
  mutate(prisao="F")

CIME <- parser_tabela(
  grep("cime", PDFsHoje, value = T)) |> 
  mutate(prisao="M.E.")

nomeCol <- str_extract(mesDia, "^\\d{4}") |> str_replace("^(\\d{2})(\\d{2})", "\\2.\\1") 
novaTabela <- union(CDPII, PFDF) |> union(CIME) |> mutate({{nomeCol}} := prisao) 
str(novaTabela)

tabelaNova <- left_join(tabela, 
                        select(novaTabela, -nascimento, -prisao, -ano), 
                        by="nome") |>
  relocate(UF, .after = nascimento) #|> head(15)

View(tabelaNova)

# salva arquivos csv e rds
saveRDS(tabelaNova, "presos_atos_golpistas.rds")
write.csv(tabelaNova, "presos_atos_golpistas.csv")