library(dplyr)
library(stringr)

# função que deixa nomes sem acento, e só primeira letra da palavra maiúscula
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
  tabTemp <- pdftools::pdf_text(str_glue("arquivos/{arqPDF}")) |>
    unlist() |> 
    strsplit("\n") |> unlist() |> 
    str_remove_all("^\\s+") |> str_remove_all("\\s+$") |> 
    str_subset("\\d|Feminina") |>
    as.data.frame() |> rename(id0 =1) 
  
  
  tabTemp2 <- tabTemp |>
    tidyr::extract(id0, regex = "(^\\d+) (.*)|.*Feminina.*", into = c("id", "nome0" ), remove = FALSE) |> 
    mutate(nascimento = str_extract(nome0, regex_data) |> as.Date(format = "%d.%m.%Y"),
         nome2 = str_remove(nome0, regex_data) |> # str_remove(nome0, "[\\d\\.]+") |> 
                    str_remove("^ +") |> str_remove(" +$"),
         ano = lubridate::year(nascimento)) |>
    rename(nome = nome2) |> 
    select(nome, nascimento, ano, id0) |> 
    mutate(nome = conserta_nomes(nome))
  
  linha <- mutate(tabTemp2, linha = 1:nrow(tabTemp2)) |>
    filter(grepl("Feminina", id0, ignore.case = T))
  Linha <- linha$linha
    
  tabTemp2 |> mutate(linha = 1:nrow(tabTemp2),
         prisao = ifelse(
                 linha <= Linha, 
                 "M", "F")) |> #select(nome, nascimento, ano, prisao) #|>  arrange(prisao, nome)
          filter(nome != "") |>
    select(-id0, -linha)
  
}

# exemplo de tabela
parser_tabela(arqsPDF[4]) |> str()

# --- Juntando tabelas de todos os dias -------
## criando um dataframe inicial com todos os nomes - nascimento e prisão
nomeNascimento <- parser_tabela(arqsPDF[1]) |> select(nome, nascimento, prisao)

for (i in 2:length(arqsPDF)){
  nomeNascimento2 <- parser_tabela(arqsPDF[i]) |> select(nome,nascimento, prisao)
  nomeNascimento <- union(nomeNascimento, nomeNascimento2)
}
nomeNascimento <- arrange(nomeNascimento, nome)

parser_tabela(arqsPDF[3]) |> filter(nome == nomesDuplicados[1])
View(parser_tabela(arqsPDF[3]))
arqPDF=arqsPDF[4]


tabela <- nomeNascimento
for (i in 1:length(arqsPDF)){
  nomeCol <- str_extract(arqsPDF[i], "^\\d{4}") |> str_replace("^(\\d{2})(\\d{2})", "\\2.\\1") 
  tabela2 <- parser_tabela(arqsPDF[i]) |> mutate({{nomeCol}} := "sim") |> select(nome, {nomeCol})
  tabela <- left_join(tabela, tabela2, by="nome")
  tabela <- mutate(tabela, {{nomeCol}} := tidyr::replace_na("não"))
}
tabela <- arrange(tabela, prisao, nome) 
# ----
str(tabela)

# salva arquivos csv e rds
saveRDS(tabela, "presos_atos_golpistas.rds")
write.csv(tabela, "presos_atos_golpistas.csv")

#--  busca por nome
termo = "zambiasi" # nomea ser buscado
# tabela$nome[grepl(termo, tabela$nome, ignore.case = T)]
filter(tabela, grepl(termo, nome,ignore.case = T))
# ----

# cruzar dados de presos com os financiadores
financiadores <- readLines('arquivos/financiadores.txt')  |> strsplit("\\n") |> unlist() |>
  str_remove("^ +") |> str_remove("^#.*") |> str_remove(",.*")

tabela$nome[tabela$nome %in% financiadores]
# ----