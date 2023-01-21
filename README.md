# Intentona Bolsonarista - 08 de Janeiro

- Lista com presos por dia ([rds](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_atos_golpistas.rds) e [csv](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_atos_golpistas.csv)) extraídos do site da seape.df. Versão [google drive](https://docs.google.com/spreadsheets/d/1f95WGIPm_qnQr1bNNV7KL8rUdCZaM6HRT1zJvLD3PsM/edit#gid=1557228783).
- [arquivos pdf](https://github.com/SoaresAlisson/intentona-08Jan/tree/main/arquivos) com os presos. O padrão do nome é: mês numérico, dia e nome do arquivo no site
- [script em R](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_ato_terrorista.R) de extração dos dados no site da seape-df e de manipulação dos dados
- [financiadores](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/arquivos/financiadores.txt) (txt com fonte dos dados)


## Sobre os scripts

"baixar_pdfs.R": 
consulta a página de presos na seape-df e retorna e baixa o pdf com a lista de presos. Ao início do nome do pdf é acrescido o mês/dia. ATUALIZAÇÂO: O script funcionava coletando o pdf disponível na página, mas dias como 20/01 constam com mais de um pdf. A parte de download será reavaliada.

# presos_ato_terrorista.R
Processa e junta as tabelas que foram baixadas
- Há busca por nome.


## Pendências

Como a tabela é estruturada a partir de pdf não estruturado, é comum acontecer falhas que precisam ser corrigidas:

- Há pessoas cujo nome possui mais de uma grafia e isto ainda não foi resolvido
- Há nomes duplicados por a pessoa constar de mais de uma data de nascimento
- Talvez faltem dados de alguns dias (mas nem todos os dias foram publicadas relatórios)
- ~~Substituir os "NA" por "não"~~
- ~~Não há especificação entre local da prisão (Papuda ou Colmeia) ainda~~