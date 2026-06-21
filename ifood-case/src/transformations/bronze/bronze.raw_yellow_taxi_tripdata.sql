CREATE OR REFRESH STREAMING TABLE bronze.raw_yellow_taxi_tripdata
COMMENT "Camada bronze com registros de corridas de táxi amarelo de Nova York (NYC Yellow Taxi Trip Data)."
AS
SELECT 
    VendorID,
    tpep_pickup_datetime AS tpep_pickup_datetime,
    tpep_dropoff_datetime AS tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID,
    store_and_fwd_flag,
    PULocationID,
    DOLocationID,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    Airport_fee,
    _rescued_data,
    _metadata.file_path              AS source_file,
    _metadata.file_modification_time AS source_file_modified_at,
    current_timestamp()              AS ingestion_at
FROM STREAM read_files(
    "/Volumes/ifood/nyc/yellow_tripdata/",
    schemaHints => "VendorID INT, passenger_count LONG, RatecodeID LONG, PULocationID INT, DOLocationID INT, Airport_fee DOUBLE, tpep_pickup_datetime TIMESTAMP, tpep_dropoff_datetime TIMESTAMP",
    format              => "parquet",
    rescuedDataColumn   => "_rescued_data",                
    schemaEvolutionMode => "rescue"                       
);