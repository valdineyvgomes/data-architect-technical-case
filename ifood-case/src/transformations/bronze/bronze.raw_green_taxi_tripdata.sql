CREATE OR REFRESH STREAMING TABLE bronze.raw_green_taxi_tripdata
COMMENT "Camada bronze com registros de corridas de táxi verde de Nova York (NYC Green Taxi Trip Data)."
AS
SELECT 
    VendorID,
    lpep_pickup_datetime AS lpep_pickup_datetime,
    lpep_dropoff_datetime AS lpep_dropoff_datetime,
    store_and_fwd_flag,
    RatecodeID,
    PULocationID,
    DOLocationID,
    passenger_count,
    trip_distance,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    ehail_fee,
    improvement_surcharge,
    total_amount,
    payment_type,
    trip_type,
    congestion_surcharge,
    _rescued_data,
    _metadata.file_path AS source_file,
    _metadata.file_modification_time AS source_file_modified_at,
    current_timestamp() AS ingestion_at
FROM STREAM read_files(
    "/Volumes/ifood/nyc/green_tripdata/",
    schemaHints => "VendorID INT, passenger_count LONG, RatecodeID LONG, PULocationID INT, DOLocationID INT, payment_type LONG, trip_type LONG, Airport_fee DOUBLE, lpep_pickup_datetime TIMESTAMP, lpep_dropoff_datetime TIMESTAMP",
    format              => "parquet",
    rescuedDataColumn   => "_rescued_data",                
    schemaEvolutionMode => "rescue"                       
);