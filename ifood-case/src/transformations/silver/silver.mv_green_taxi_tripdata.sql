CREATE OR REFRESH MATERIALIZED VIEW silver.mv_green_taxi_tripdata (
    type_id COMMENT "Identificador do tipo de táxi. Valor fixo 2 para corridas Green Taxi.",
    vendor_id COMMENT "Identificador da empresa fornecedora do serviço de táxi.",
    passenger_count COMMENT "Quantidade de passageiros informada na corrida.",
    total_amount COMMENT "Valor total pago pelo passageiro.",
    pickup_datetime COMMENT "Data e hora de embarque do passageiro.",
    dropoff_datetime COMMENT "Data e hora de desembarque do passageiro.",
    ingestion_at COMMENT "Data e hora em que o registro foi ingerido na camada bronze.",
    processed_at COMMENT "Data e hora de processamento do registro na camada silver."
)
COMMENT "Camada silver com registros tratados de corridas de táxi verde de Nova York (NYC Green Taxi Trip Data)."
AS
WITH transformed  AS (
SELECT
    2  AS type_id, 
    COALESCE(VendorID, CAST(get_json_object(_rescued_data, '$.VendorID') AS INT)) AS vendor_id,
    COALESCE(passenger_count, CAST(get_json_object(_rescued_data, '$.passenger_count') AS DOUBLE)) AS passenger_count,
    total_amount,
    lpep_pickup_datetime AS pickup_datetime,
    lpep_dropoff_datetime AS dropoff_datetime,
    ingestion_at,
    current_timestamp()  AS processed_at
FROM bronze.raw_green_taxi_tripdata
) SELECT * FROM transformed 
WHERE
    total_amount BETWEEN 1 AND 180
    AND date_diff(MINUTE, pickup_datetime,  dropoff_datetime) BETWEEN 1 and 90;