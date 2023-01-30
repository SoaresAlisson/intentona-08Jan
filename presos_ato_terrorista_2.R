library(dplyr)
library(stringr)

# script Para arquivos de data após 20/01/2022

conserta_nomes <- function(input){ # função para retirar acentos dos nomes, e colocá-los como título, preservando "do", "da", etc. em minúsculo
  str_to_title(input, locale="pt") |> 
    str_replace_all(c(" E " = " e ", " Da " = " da ", " De " = " de ", 
                      " Do " = " do ", " Das " = " das ", " Dos " = " dos ")) |>
    iconv(to = "ASCII//TRANSLIT") |>
    str_remove_all("^[ ]+|[ ]+$")
}

regex_data <- "\\d{1,2}.\\d{1,2}.\\d{2,4}"

# função que estrutura o PDF 
parser2_tabela <- function(arqPDF){
  pdftools::pdf_text(str_glue("arquivos/{arqPDF}")) |>
    unlist() |> 
    strsplit("\n") |> unlist() |> 
    str_remove_all("^\\s+") |> str_remove_all("\\s+$") |> 
    as.data.frame() |> rename(id0 =1) |>
    tidyr::extract(id0, regex = str_glue("(.*) ({regex_data}) +(.*)"), into = c("nome", "nascimento", "UF" )) |> 
    mutate(nascimento = str_extract(nascimento, regex_data) |> 
           as.Date(format = "%d.%m.%Y"),
           nome = str_remove(nome, regex_data) |> conserta_nomes(),
           #ano = lubridate::year(nascimento)
           ) |>
    filter(nome != "") 
}

parser3 <- function(Busca, Prisao, PDFsAtual){
  # Busca: termo que filtra o arquivo: "cdp", "pfdf" ou "cime". busca fuzzy
  # Prisao: termo correspondente a ser acrescido na coluna
    parser2_tabela(
          agrep(Busca, 
                gsub("(.*)(pdf$)", "\\1", PDFsAtual), 
                max.distance =1, value = TRUE, ignore.case = TRUE) %>% 
            gsub("(.*)", "\\1pdf", .)) |>
    mutate(prisao = Prisao)
}

parser4 <-function(MesDia){
    PDFsAtual <- grep(str_glue("{MesDia}"), arqPDFseape(), value = T)
    
    CDPII <- parser3("cdp", "M", PDFsAtual)
    PFDF <- parser3("pfdf", "F", PDFsAtual)
    CIME <- parser3("cime", "T.E.", PDFsAtual)
    
    nomeCol <- str_extract(MesDia, "^\\d{4}") |> str_replace("^(\\d{2})(\\d{2})", "\\2.\\1") 
    union(CDPII, PFDF) |> union(CIME) |> 
      mutate({{nomeCol}} := prisao) |> select(-prisao)
}

# testando a função acima
parser4("0130") |> str()

# Junta tabela antiga com a do dia especificado no argumento dataMesDia 2) complementa nascimento onde havia NAs
parser5 <- function(tabela_antiga, dataMesDia){
  novaTabela <- parser4(dataMesDia)
  full_join( tabela_antiga, # tabela criada no script presos_ato-terrorista.R
    select(novaTabela, -nascimento, -UF), 
    by="nome") |>
    # atualiza na tabela somente onde há NAs no nascimento
  rows_patch(novaTabela, by="nome") |> 
  mutate(idade = 
           lubridate::year(lubridate::as.period(lubridate::interval(start = nascimento, end = Sys.Date()))), 
         .after = nascimento) |>  
    relocate(UF, .after = nome) 
}

# append das novos dias
Tabela <- mutate(tabela, UF = as.character(NA))
Tabela <- parser5(Tabela, "0120") 
Tabela <- parser5(Tabela, "0122") 
Tabela <- parser5(Tabela, "0123")
Tabela <- parser5(Tabela, "0125") 
Tabela <- parser5(Tabela, "0130")

View(Tabela)
str(Tabela)

# Pós processamento

## retirando linhas duplicadas
## todo: retirar dupĺicados ao montar a primeira lista de nomes
Tabela <- arrange(Tabela, nome) |>
  mutate(repetido = (nome == lag(nome) & is.na(nascimento))) |>
  filter(repetido != T) |>
  mutate(repetido = (nome == lead(nome) & (lubridate::year(nascimento) == 1900) )) |> filter(repetido != T) |>
  select(-repetido) |> 
  unique() # retirando linhas duplicadas

nrow(Tabela) == nrow(unique(Tabela)) # checando se há linhas duplicadas

 

# salva arquivos csv e rds
saveRDS(Tabela, "presos_atos_golpistas.rds")
write.csv(Tabela, "presos_atos_golpistas.csv")