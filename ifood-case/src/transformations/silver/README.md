### Silver Layer

Responsável por preparar os dados da camada Bronze para consumo analítico, aplicando padronizações, ajustes de schema e conversões de tipos de dados.

| Origem (Bronze) | Destino (Silver) |
|---|---|
| `ifood.bronze.raw_yellow_taxi_tripdata` | `ifood.silver.mv_yellow_taxi_tripdata` |
| `ifood.bronze.raw_green_taxi_tripdata` | `ifood.silver.mv_green_taxi_tripdata` |

### Campos Adicionados

| Campo | Descrição |
|---|---|
| `type_id` | Identifica o tipo de táxi: `1` para Yellow Taxi, `2` para Green Taxi |
| `processed_at` | Timestamp da última atualização da Materialized View |

Todos os campos não necessários para responder às perguntas do case foram removidos.

### Campos Transformados

Devido às diferenças de schema presentes nos arquivos de janeiro de 2023, alguns campos receberam tratamento específico — o valor é obtido da coluna original e, quando ausente, recuperado a partir de `_rescued_data`.

| Campo | Lógica de recuperação |
|---|---|
| `vendor_id` | Lê `VendorID`; se ausente, busca em `_rescued_data` |
| `passenger_count` | Lê `passenger_count`; se ausente, busca em `_rescued_data` |

### Decisões Técnicas

A camada foi implementada com Materialized Views, uma vez que seus dados são totalmente derivados da Bronze.

### Problemas Encontrados

Durante a exploração dos dados na camada Bronze, foram identificados registros com valores inconsistentes em `total_amount` e na duração das corridas. Para definir os limites de filtragem, foi realizada uma análise de percentis e, com base nos resultados, foram definidos os seguintes filtros para remoção de registros inválidos:

- O limite de `total_amount` entre `1` e `180` cobrindo o p99.9 de ambas as frotas com margem adequada, descartando valores nulos, negativos ou anômalos.
- A duração entre `1` e `90` minutos elimina corridas instantâneas ou excessivamente longas, cobrindo o p99.9 de ambas as frotas com margem adequada.
- Registros com `passenger_count` igual a `0`, `null` ou acima da capacidade do veículo foram **mantidos**, pois, conforme a [documentação oficial](https://www.nyc.gov/assets/tlc/downloads/pdf/trip_record_user_guide.pdf), esse campo é *driver-reported* e suscetível a erro humano.
