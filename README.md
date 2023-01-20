# Intentona Bolsonarista - 08 de Jan

- Lista com presos por dia ([rds](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_atos_golpistas.rds) e [csv](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_atos_golpistas.csv)) extraídos do site da seape.df. Versão [google drive](https://docs.google.com/spreadsheets/d/1f95WGIPm_qnQr1bNNV7KL8rUdCZaM6HRT1zJvLD3PsM/edit#gid=1557228783).
- [arquivos pdf](https://github.com/SoaresAlisson/intentona-08Jan/tree/main/arquivos) com os presos. O padrão do nome é: mês numérico, dia e nome do arquivo no site
- [script em R](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_ato_terrorista.R) de extração dos dados no site da seape-df e de manipulação dos dados
- [financiadores](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/arquivos/financiadores.txt) (txt com fonte dos dados)

Há também busca por nome.

Há ainda algumas pendências:
- como a tabela é estruturada a partir de pdf não estruturado, é comum acontecer falhas que precisam ser corrigidas
- Há pessoas cujo nome possui mais de uma grafia e isto ainda não foi resolvido
- Substituir os NAs por "não"
- faltam dados de alguns dias