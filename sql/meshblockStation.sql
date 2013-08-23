DROP TABLE IF EXISTS meshblockStationTemp;

CREATE TABLE meshblockStationTemp AS 
SELECT meshblocks.mb06
  , stations.station_na
  , COUNT(stations.station_na) OVER (PARTITION BY mb06) as count
FROM meshblocks
  , stations
WHERE ST_Intersects(meshblocks.geom, stations.geom) 
GROUP BY meshblocks.mb06
  , stations.station_na;


DROP TABLE IF EXISTS meshblockStationDuplicates;

CREATE TABLE meshblockStationDuplicates AS
SELECT meshblockStationTemp.mb06
  , meshblockStationTemp.station_na
  , RANK() OVER (PARTITION BY meshblockStationTemp.mb06 ORDER BY ST_Area(ST_Intersection(ST_Buffer(meshblocks.geom, 0), ST_Buffer(stations.geom, 0))) DESC) AS rank
FROM meshblockStationTemp
  INNER JOIN meshblocks ON meshblocks.mb06=meshblockStationTemp.mb06
  INNER JOIN stations ON stations.station_na=meshblockStationTemp.station_na
WHERE meshblockStationTemp.count > 1
;


DROP TABLE IF EXISTS meshblockStation;

CREATE TABLE meshblockStation AS
SELECT meshblockStationTemp.mb06
  , meshblockStationTemp.station_na
FROM meshblockStationTemp
LEFT JOIN meshblockStationDuplicates ON meshblockStationDuplicates.mb06=meshblockStationTemp.mb06
  AND meshblockStationDuplicates.station_na=meshblockStationTemp.station_na
WHERE meshblockStationDuplicates.rank IS NULL OR meshblockStationDuplicates.rank=1;


DROP TABLE IF EXISTS meshblockStationTemp;
DROP TABLE IF EXISTS meshblockStationDuplicates;


SELECT count(mb06) FROM meshblockStation;
SELECT * FROM meshblockStation LIMIT 10;