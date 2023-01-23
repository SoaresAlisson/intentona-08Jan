library(stringr)
library(rvest)
# library(dplyr)

# script que verifica se há atualização na página do Seape-df e faz o download dos arquivos, caso estes não existam ainda na pasta "arquivos"

url = "https://seape.df.gov.br/prisoes-dos-atentados-bsb/"

pagina <- rvest::read_html(url) 

# opção 1: pegar o texto "ultima atualização" . Funcionava anteriormente
#ultimaAtualizacao <- pagina |> rvest::html_element("em") |> rvest::html_text() # ultima atualizacao
#ultimaAtualizacao
#mesDia <- str_extract(ultimaAtualizacao, "[\\d\\/]+") |> str_replace("(.*)/(.*)", "\\2\\1")

# opção 2: pegar o texto "ultima atualização" do topo do texto.
pagina |> rvest::html_element(".margin-top-60") |> rvest::html_text() |> str_replace(".*(Atualizado.*)", "\\1") |> str_remove_all("\\n")
ultimaAtualizacao <- pagina |> rvest::html_element(".margin-top-60") |> rvest::html_text() |> str_remove(".*Atualizado") |>  str_extract("\\d{2}/\\d{2}/\\d+")# ultima atualizacao
mesDia <- ultimaAtualizacao |> str_replace("(.*)/(.*)/(.*)", "\\2\\1")

# A  partir do dia 20/01, começaram a ser disponibilizados 3 pdfs
urlsPDFs <- pagina |> rvest::html_elements("a") |> rvest::html_attr("href") |> str_subset("uploads/2023.*pdf$") # todos os links de pdfs da página


# checa se o arquivo já foi baixado
arqsPDF <- list.files("arquivos", pattern = "^\\d{4}_.*pdf$") # somente um pdf

checarArquivo <- function(arquivo){
  nomeNovoArquivoPDF <- paste0(mesDia, "_",
                               str_replace(arquivo, ".*/(.*pdf)", "\\1"))
  ifelse((nomeNovoArquivoPDF %in% arqsPDF), 
         str_glue('Arquivo "{nomeNovoArquivoPDF}" já existente!'),
         #print(nomeNovoArquivoPDF))
         download.file(arquivo, str_glue("arquivos/{nomeNovoArquivoPDF}")))
}

sapply(urlsPDFs, checarArquivo)



# #################### 
# Antes do dia 20/01 havia apenas 1 pdf na página da seape. Usava-se este código:
# urlPDF <- pagina |> rvest::html_element("#conteudo a") |> rvest::html_attr("href")
# 
# # salvar novo pdf
# nomeNovoArquivoPDF <- paste0(mesDia, "_",
#                              str_replace(urlPDF, ".*/(.*pdf)", "\\1"))
# # arquivo já existe? se não, baixe
# ifelse((nomeNovoArquivoPDF %in% arqsPDF), 
#        str_glue('Arquivo "{nomeNovoArquivoPDF}" já existente!'),
#        download.file(urlPDF, str_glue("arquivos/{nomeNovoArquivoPDF}"))
# )
