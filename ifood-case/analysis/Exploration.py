# Databricks notebook source
# MAGIC %md
# MAGIC Schema:

# COMMAND ----------

spark.read.parquet(
    "/Volumes/ifood/nyc/yellow_tripdata/"
).printSchema()

# COMMAND ----------

# MAGIC %md
# MAGIC Perfil dos dados núméricos que serão utilizandos nas análises:

# COMMAND ----------

display(
    spark.read
         .parquet("/Volumes/ifood/nyc/yellow_tripdata/")
         .select(
             "passenger_count",
             "total_amount"
         )
         .describe()
)


# COMMAND ----------

display(
    spark.read
         .parquet("/Volumes/ifood/nyc/green_tripdata/")
         .select(
             "passenger_count",
             "total_amount"
         )
         .describe()
)

# COMMAND ----------

# DBTITLE 0,Cell 1
display(
    spark.read
         .parquet("/Volumes/ifood/nyc/yellow_tripdata/yellow_tripdata_2023-01.parquet")
         .select(
             "passenger_count",
             "total_amount"
         )
         .describe()
)

# COMMAND ----------

display(
    spark.read
         .parquet("/Volumes/ifood/nyc/green_tripdata/green_tripdata_2023-01.parquet")
         .select(
             "passenger_count",
             "total_amount"
         )
         .describe()
)

# COMMAND ----------

# MAGIC %md
# MAGIC Perfil dos campos timestamp:

# COMMAND ----------

from pyspark.sql.functions import min, max, count, when, col

display(
    spark.read
        .parquet("/Volumes/ifood/nyc/yellow_tripdata/yellow_tripdata_2023-01.parquet")
        .agg(
            min("tpep_pickup_datetime").alias("min_pickup"),
            max("tpep_pickup_datetime").alias("max_pickup"),
            min("tpep_pickup_datetime").alias("min_dropoff"),
            max("tpep_pickup_datetime").alias("max_dropoff"),
            count(when(col("tpep_pickup_datetime").isNull(), 1)).alias("pickup_nuls"),
            count(when(col("tpep_dropoff_datetime").isNull(), 1)).alias("dropoff_nulls")
        )
)

# COMMAND ----------

from pyspark.sql.functions import min, max, count, when, col

display(
    spark.read
        .parquet("/Volumes/ifood/nyc/green_tripdata/green_tripdata_2023-01.parquet")
        .agg(
            min("lpep_pickup_datetime").alias("min_pickup"),
            max("lpep_pickup_datetime").alias("max_pickup"),
            min("lpep_dropoff_datetime").alias("min_dropoff"),
            max("lpep_dropoff_datetime").alias("max_dropoff"),
            count(when(col("lpep_pickup_datetime").isNull(), 1)).alias("pickup_nuls"),
            count(when(col("lpep_dropoff_datetime").isNull(), 1)).alias("dropoff_nulls")
        )
)

# COMMAND ----------

# MAGIC %md
# MAGIC Anomalias

# COMMAND ----------

# MAGIC %sql
# MAGIC WITH raw AS (
# MAGIC     SELECT 'Yellow' type, date_diff(minute, tpep_pickup_datetime,  tpep_dropoff_datetime) AS trip_minutes, total_amount FROM ifood.bronze.raw_yellow_taxi_tripdata 
# MAGIC     union all 
# MAGIC     SELECT 'Green' type, date_diff(minute,  lpep_pickup_datetime, lpep_dropoff_datetime) as trip_minutes, total_amount FROM ifood.bronze.raw_green_taxi_tripdata
# MAGIC )
# MAGIC select 
# MAGIC     type,
# MAGIC     percentile_approx(total_amount, 0.50) AS total_amount_p50,
# MAGIC      percentile_approx(total_amount, 0.99) AS total_amount_p99,
# MAGIC     percentile_approx(total_amount, 0.999) AS total_amount_p999,
# MAGIC     percentile_approx(trip_minutes, 0.50) AS duration_p50,
# MAGIC     percentile_approx(trip_minutes, 0.99) AS duration_p99,
# MAGIC     percentile_approx(trip_minutes, 0.999) AS duration_p999
# MAGIC from raw where total_amount > 0 and trip_minutes > 0
# MAGIC group by type
# MAGIC