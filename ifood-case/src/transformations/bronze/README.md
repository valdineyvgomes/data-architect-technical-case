### Bronze Layer

Responsável pela ingestão dos arquivos Parquet originais do conjunto de dados [NYC Yellow Taxi Trip Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page), preservando os dados o mais próximo possível da fonte. Para simplificar o processo de ingestão, os arquivos de origem foram carregados em um volume interno utilizado como landing zone.

| Dataset | Volume (Landing Zone) | Destino (Bronze) |
|---|---|---|
| `yellow_tripdata` | `/Volumes/ifood/nyc/yellow_tripdata/` | `ifood.bronze.raw_yellow_taxi_tripdata` |
| `green_tripdata` | `/Volumes/ifood/nyc/green_tripdata/` | `ifood.bronze.raw_green_taxi_tripdata` |

#### Campos Técnicos

Durante a leitura dos arquivos, os seguintes campos são adicionados:

| Campo | Descrição |
|---|---|
| `_rescued_data` | Armazena dados que não puderam ser interpretados durante a leitura do arquivo |
| `source_file` | Caminho do arquivo de origem |
| `source_file_modified_at` | Data de última modificação do arquivo de origem |
| `ingestion_at` | Momento em que o registro foi ingerido |

#### Decisões Técnicas

A ingestão desta camada utiliza Streaming Tables, uma vez que os arquivos de origem são imutáveis e novos dados são disponibilizados apenas pela adição de novos arquivos. Esse modelo permite que a pipeline processe incrementalmente apenas os dados ainda não ingeridos.

Por se tratar de um case técnico, não foi configurada uma política de atualização automática para esta Streaming Table. A atualização dos dados ocorre apenas quando a pipeline é executada manualmente.

Os schemaHints foram configurados para refletir o schema predominante no conjunto de dados. Como o arquivo de janeiro de 2023 era o primeiro a ser processado durante a inferência de schema, sua estrutura acabava sendo utilizada como referência para os demais arquivos, gerando incompatibilidades. Com a definição explícita dos tipos por meio dos schemaHints, foi possível alinhar a leitura ao formato adotado pela maioria dos arquivos e reduzir inconsistências durante a ingestão.

#### Problemas Encontrados

Os arquivos Parquet referentes a 2023-01 apresentam diferenças de schema em relação aos demais meses do conjunto de dados. Para garantir a ingestão sem perda de informação, o campo `_rescued_data` foi habilitado, permitindo capturar dados que não puderam ser mapeados para o schema definido durante a leitura dos arquivos pelo `read_files`. Ex.:

| Arquivo | Campo | Tipo |
|---|---|---|
| `yellow_tripdata_2023-01.parquet` | `passenger_count` | `DOUBLE` |
| `yellow_tripdata_2023-02.parquet` | `passenger_count` | `BIGINT` |