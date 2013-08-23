DROP TABLE IF EXISTS meshblockAreaTemp;

CREATE TABLE meshblockAreaTemp AS 
SELECT meshblocks.mb06
  , areas.area_name
  , COUNT(areas.area_name) OVER (PARTITION BY mb06) as count
FROM meshblocks
  , areas
WHERE ST_Intersects(meshblocks.geom, areas.geom) 
GROUP BY meshblocks.mb06
  , areas.area_name;


DROP TABLE IF EXISTS meshblockAreaDuplicates;

CREATE TABLE meshblockAreaDuplicates AS
SELECT meshblockAreaTemp.mb06
  , meshblockAreaTemp.area_name
  , RANK() OVER (PARTITION BY meshblockAreaTemp.mb06 ORDER BY ST_Area(ST_Intersection(ST_Buffer(meshblocks.geom, 0), ST_Buffer(areas.geom, 0))) DESC) AS rank
FROM meshblockAreaTemp
  INNER JOIN meshblocks ON meshblocks.mb06=meshblockAreaTemp.mb06
  INNER JOIN areas ON areas.area_name=meshblockAreaTemp.area_name
WHERE meshblockAreaTemp.count > 1
;


DROP TABLE IF EXISTS meshblockArea;

CREATE TABLE meshblockArea AS
SELECT meshblockAreaTemp.mb06
  , meshblockAreaTemp.area_name
FROM meshblockAreaTemp
LEFT JOIN meshblockAreaDuplicates ON meshblockAreaDuplicates.mb06=meshblockAreaTemp.mb06
  AND meshblockAreaDuplicates.area_name=meshblockAreaTemp.area_name
WHERE meshblockAreaDuplicates.rank IS NULL OR meshblockAreaDuplicates.rank=1;


DROP TABLE IF EXISTS meshblockAreaTemp;
DROP TABLE IF EXISTS meshblockAreaDuplicates;


SELECT count(mb06) FROM meshblockArea;
SELECT * FROM meshblockArea LIMIT 10;