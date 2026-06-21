CREATE OR REFRESH MATERIALIZED VIEW gold.mv_taxi_tripdata (
    type_id COMMENT "Identificador do tipo de táxi. Valores possíveis: 1 = Yellow Taxi e 2 = Green Taxi.",
    type_name COMMENT "Nome do tipo de táxi: Yellow ou Green.",
    vendor_id COMMENT "Identificador da empresa fornecedora do serviço de táxi.",
    vendor_name COMMENT "Nome da empresa fornecedora do serviço de táxi.",
    passenger_count COMMENT "Quantidade de passageiros informada na corrida.",
    total_amount COMMENT "Valor total pago pelo passageiro.",
    pickup_datetime COMMENT "Data e hora de embarque do passageiro.",
    dropoff_datetime COMMENT "Data e hora de desembarque do passageiro.",
    trip_year COMMENT "Ano da data de embarque da corrida.",
    trip_month COMMENT "Mês da data de embarque da corrida.",
    trip_day COMMENT "Dia do mês da data de embarque da corrida.",
    trip_hour COMMENT "Hora da data de embarque da corrida.",
    ingestion_at COMMENT "Data e hora em que o registro foi ingerido na camada bronze.",
    processed_at COMMENT "Data e hora de processamento do registro na camada silver.",
    updated_at COMMENT "Data e hora da última atualização do registro na camada gold."
)
COMMENT "Camada gold com registros unificados de corridas de táxi amarelo e verde de Nova York (NYC Taxi Trip Data)."
AS
WITH transformed AS (
    SELECT * FROM silver.mv_yellow_taxi_tripdata
    UNION ALL
    SELECT * FROM silver.mv_green_taxi_tripdata
)
SELECT
    type_id,
    CASE type_id
        WHEN 1 THEN 'Yellow'
        WHEN 2 THEN 'Green'
    END AS type_name,
    vendor_id,
    CASE vendor_id
        WHEN 1 THEN 'Creative Mobile Technologies LLC'
        WHEN 2 THEN 'Curb Mobility LLC'
        WHEN 6 THEN 'Myle Technologies Inc'
        WHEN 7 THEN 'Helix'
    END AS vendor_name,
    passenger_count,
    total_amount,
    pickup_datetime,
    dropoff_datetime,
    YEAR(pickup_datetime)   AS trip_year,
    MONTH(pickup_datetime)  AS trip_month,
    DAY(pickup_datetime)    AS trip_day,
    HOUR(pickup_datetime)   AS trip_hour,
    ingestion_at,
    processed_at,
    current_timestamp() AS updated_at
FROM transformed