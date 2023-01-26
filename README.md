# Intentona Bolsonarista - 08 de Janeiro


## Arquivos:
- Lista com presos por dia ([rds](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_atos_golpistas.rds) e [csv](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_atos_golpistas.csv)) extraídos do site da seape.df:
  - No dia 20/01, a SEAPE mudou o modo de divulgação dos dados em PDF, incluindo a partir de então tabela com pessoas liberadas mediante monitoração por tornozeleira eletrônica. Tal mudança se reflete na coluna deste dia, que adotamos notação diferente:
    - ao invés de `NA` para não, e `sim` para a presença da pessoa, como nos dias anteriores:
    - A partir do dia 20/01, `F` indica presídio feminino (Penitenciária Feminina do Distrito Federal), `M` indica os homens no Centro de Detenção Provisória II e `T.E.` indica "tornozeleira eletrônica", isto é, o monitoramento eletrônico.
<!-- Versão [google drive](https://docs.google.com/spreadsheets/d/1f95WGIPm_qnQr1bNNV7KL8rUdCZaM6HRT1zJvLD3PsM/edit#gid=1557228783). -->
- [arquivos pdf](https://github.com/SoaresAlisson/intentona-08Jan/tree/main/arquivos) com os presos. O padrão do nome é: mês numérico, dia e nome do arquivo no site
- script em R de extração dos dados no site da seape-df e de manipulação dos dados (ver abaixo)
- Lista dos [financiadores](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/arquivos/financiadores.txt) (txt com dados e fonte dos dados referente aos financiadores)

## Sobre os scripts

### script [baixar_pdfs.R](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/baixar_pdfs.R): 
consulta a página de presos na seape-df e retorna e baixa o pdf com a lista de presos. Ao início do nome do pdf é acrescido o mês/dia. ATUALIZAÇÂO: O script funcionava coletando o pdf disponível na página, mas dias como 20/01 constam com mais de um pdf. A parte de download foi atualizada.

### script [presos_ato_terrorista.R](https://github.com/SoaresAlisson/intentona-08Jan/blob/main/presos_ato_terrorista.R)
Processa e junta as tabelas que foram baixadas com a função baixar_pdfs
- Há busca por nome
- Cruza estes nomes dos presos com a lista de financiadores divulgada [aqui](https://g1.globo.com/politica/noticia/2023/01/12/veja-lista-de-pessoas-e-empresas-apontadas-pela-agu-como-financiadoras-dos-atos-golpistas.ghtml), sendo eles no momento:
  - Jorge Rodrigues Cunha", "Michely Paiva Alves", "Patricia dos Santos Alberto Lima" "Sheila Mantovanni", "Vanderson Alves Nunes"."  
  
A versão 2 do script lida com arquivos a partir do dia 20/01.

Esta versão retira duplicados com base nos seguintes critérios:
- Ordenando os nomes em ordem alfabética, se o nome atual e o nome anterior são iguais E a data de nascimento da linha atual é um valor faltante (_missing_, isto é, um `NA`), a linha atual é excluída.
- Ordenando os nomes em ordem alfabética, se o nome atual e o próximo nome são iguais, E se a data de nascimento é o ano 1990 (foram várias ocorrências com a data de 01.01.1990), esta linha é excluída.

Com estas medidas os duplicados caíram de 27 para 16. Estes nomes que permanecem duplicados o são por possuírem mais de uma data de nascimento. Para ver quais são eles, rode o seguinte comando:

```
Tabela <- readRDS("presos_atos_golpistas.rds")
nomesDuplicados <- Tabela$nome[duplicated(Tabela$nome)] # nomes duplicadas
nomesDuplicados 
for(i in nomesDuplicados){print(filter(tabelaNova2, nome == i))}
```

## Pendências

Como a tabela é estruturada a partir de pdf não estruturado, é comum acontecer falhas que ainda precisam ser corrigidas:

- ~~Há 27 nomes duplicados por a pessoa ter mais de uma data de nascimento~~ 
- Há pessoas cujo nome possui mais de uma grafia: pretende-se indicar nomes parecidos em nova coluna
- Talvez faltem dados dos primeiros dias (mas nem todos os dias tiveram relatórios publicadas)
- Substituir os "NA" por "não"
- ~~Não há especificação entre local da prisão (Papuda ou Colmeia) ainda~~