# Intentona Bolsonarista - 08 de Janeiro


## Arquivos:
- Lista com presos por dia ([rds](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_atos_golpistas.rds) e [csv](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_atos_golpistas.csv)) extraídos do site da seape.df. Versão [google drive](https://docs.google.com/spreadsheets/d/1f95WGIPm_qnQr1bNNV7KL8rUdCZaM6HRT1zJvLD3PsM/edit#gid=1557228783).
- [arquivos pdf](https://github.com/SoaresAlisson/intentona-08Jan/tree/main/arquivos) com os presos. O padrão do nome é: mês numérico, dia e nome do arquivo no site
- script em R de extração dos dados no site da seape-df e de manipulação dos dados (ver abaixo)
- [financiadores](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/arquivos/financiadores.txt) (txt com dados e fonte dos dados referente aos financiadores)

## Sobre os scripts

### script [baixar_pdfs.R](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/baixar_pdfs.R): 
consulta a página de presos na seape-df e retorna e baixa o pdf com a lista de presos. Ao início do nome do pdf é acrescido o mês/dia. ATUALIZAÇÂO: O script funcionava coletando o pdf disponível na página, mas dias como 20/01 constam com mais de um pdf. A parte de download será reavaliada.

### script [presos_ato_terrorista.R](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_ato_terrorista.R)
Processa e junta as tabelas que foram baixadas com a função baixar_pdfs
- Há busca por nome
- Cruza estes nomes dos presos com a lista de financiadores divulgada [aqui](https://g1.globo.com/politica/noticia/2023/01/12/veja-lista-de-pessoas-e-empresas-apontadas-pela-agu-como-financiadoras-dos-atos-golpistas.ghtml), sendo eles no momento:
  - "Michely Paiva Alves", "Patricia dos Santos Alberto Lima", "Jorge Rodrigues Cunha" e "Vanderson Alves Nunes"

## Pendências

Como a tabela é estruturada a partir de pdf não estruturado, é comum acontecer falhas que precisam ser corrigidas:

- Há pessoas cujo nome possui mais de uma grafia e isto ainda não foi resolvido
- Há nomes duplicados por a pessoa constar de mais de uma data de nascimento
- Talvez faltem dados dos primeiros dias (mas nem todos os dias tiveram relatórios publicadas)
- Substituir os "NA" por "não"
- ~~Não há especificação entre local da prisão (Papuda ou Colmeia) ainda~~