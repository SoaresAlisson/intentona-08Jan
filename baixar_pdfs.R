library(stringr)
library(rvest)
# library(dplyr)

url = "https://seape.df.gov.br/prisoes-dos-atentados-bsb/"

pagina <- rvest::read_html(url) 

# opção 1: pegar o texto "ultima atualização" . Funcionava anteriormente
#ultimaAtualizacao <- pagina |> rvest::html_element("em") |> rvest::html_text() # ultima atualizacao
#ultimaAtualizacao
#mesDia <- str_extract(ultimaAtualizacao, "[\\d\\/]+") |> str_replace("(.*)/(.*)", "\\2\\1")

# opção 2: pegar o texto "ultima atualização" do topo do texto.
ultimaAtualizacao <- pagina |> rvest::html_element(".margin-top-60") |> rvest::html_text() |> str_remove(".*Atualizado") |>  str_extract("\\d{2}/\\d{2}/\\d+")# ultima atualizacao
mesDia <- ultimaAtualizacao |> str_replace("(.*)/(.*)/(.*)", "\\2\\1")

# antes do dia 20/01 havia apenas 1 pdf
urlPDF <- pagina |> rvest::html_element("#conteudo a") |> rvest::html_attr("href")
arqsPDF <- list.files("arquivos", pattern = "^\\d{4}_.*pdf$") # somente um pdf

# salvar novo pdf
nomeNovoArquivoPDF <- paste0(mesDia, "_",
                             str_replace(urlPDF, ".*/(.*pdf)", "\\1"))
# arquivo já existe? se não, baixe
ifelse((nomeNovoArquivoPDF %in% arqsPDF), 
       str_glue('Arquivo "{nomeNovoArquivoPDF}" já existente!'),
       download.file(urlPDF, str_glue("arquivos/{nomeNovoArquivoPDF}"))
)



# A  partir do dia 20/01, começaram a ser disponibilizados 3 pdfs
pagina |> rvest::html_elements("a") |> 
  
urlsPDFs <- pagina |> rvest::html_elements("a") |> rvest::html_attr("href") |> str_subset("uploads/2023.*pdf$") # todos os links de pdfs da página


for(i in urlsPDFs){
  nomeNovoArquivoPDF <- paste0(mesDia, "_",
                               str_replace(i, ".*/(.*pdf)", "\\1"))
  print(nomeNovoArquivoPDF)
  download.file(i, str_glue("arquivos/{nomeNovoArquivoPDF}"))
}
