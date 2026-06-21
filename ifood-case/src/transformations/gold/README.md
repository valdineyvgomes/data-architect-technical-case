%md
### Gold Layer

Responsável pela unificação e enriquecimento dos dados das duas frotas de táxi, consolidando os registros de Yellow e Green Taxi em uma única tabela analítica.

| Origem (Silver) | Destino (Gold) |
|---|---|
| `ifood.silver.mv_yellow_taxi_tripdata` | `ifood.gold.mv_taxi_tripdata` |
| `ifood.silver.mv_green_taxi_tripdata` | `ifood.gold.mv_taxi_tripdata` |

#### Campos adicionados

Extraídos de `pickup_datetime` para facilitar análises temporais:

| Campo | Descrição |
|---|---|
| `trip_year` | Ano da corrida |
| `trip_month` | Mês da corrida |
| `trip_day` | Dia da corrida |
| `trip_hour` | Hora da corrida |

Os seguintes campos técnicos foram adicionados na tabela final. 

| Campo | Descrição |
|---|---|
| `updated_at` | Timestamp da última atualização da Materialized View |

#### Decisões Técnicas

A camada foi implementada com Materialized Views, seguindo o mesmo padrão da Silver. A unificação dos dados é feita via `UNION ALL` das duas views da camada anterior, garantindo que todos os registros de ambas as frotas sejam consolidados sem deduplicação.

Os campos `type_name` e `vendor_name` são derivados diretamente via `CASE` na própria view, evitando a necessidade de tabelas auxiliares de lookup.
