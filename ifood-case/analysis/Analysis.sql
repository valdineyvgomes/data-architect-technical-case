-- Databricks notebook source
-- MAGIC %md
-- MAGIC **Qual a média de valor total (total_amount) recebido em um mês considerando todos os yellow táxis da frota?**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Se o objetivo da pergunta é saber o valor médio de cada corrida em cada mês:

-- COMMAND ----------

SELECT
    trip_year,
    trip_month,
    ROUND(AVG(total_amount), 2) AS avg_amount_per_trip
FROM ifood.gold.mv_taxi_tripdata
WHERE type_id = 1 --Considera somente Yellow Taxi.
  AND trip_year = 2023 --Limita o ano a 2023 pois há datas fora do range dos arquivos originais. 
  AND trip_month BETWEEN 1 AND 5 --Limita os meses para análise. 
GROUP BY ALL
ORDER BY
    trip_year,
    trip_month;


-- COMMAND ----------

-- MAGIC %md
-- MAGIC Agora, se o objetivo é saber o valor médio mensal do faturamento. 

-- COMMAND ----------

WITH total_amount_per_month AS (
  SELECT
      trip_year,
      trip_month,
      ROUND(SUM(total_amount),2) AS total_amount
  FROM ifood.gold.mv_taxi_tripdata
  WHERE type_id = 1
    AND trip_year = 2023 
    AND trip_month BETWEEN 1 AND 5 
  GROUP BY ALL
  ORDER BY
      trip_year,
      trip_month
)
SELECT
    AVG(total_amount) AS avg_amount
FROM total_amount_per_month;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Qual a média de passageiros (passenger_count) por cada hora do dia que pegaram táxi no mês de maio considerando todos os táxis da frota?

-- COMMAND ----------

SELECT
    trip_year,
    trip_month,
    trip_hour,
    ROUND(AVG(passenger_count), 2) AS avg_passenger_per_hour
FROM ifood.gold.mv_taxi_tripdata
WHERE 
    trip_year = 2023 
    AND trip_month = 5 
    AND passenger_count BETWEEN 1 and 5 --Filtra somente viagens com número de passageiro entre 1 e 5. Temos viagens com mais de 5 passageiros e viagens sem passageiros, mas essa informação é fornecida pelo motorista então pode haver esquecimento ou erro na hora de informar o valor. 
GROUP BY ALL
ORDER BY
    trip_year,
    trip_month,
    trip_hour;