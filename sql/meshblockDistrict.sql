DROP TABLE IF EXISTS meshblockDistrictTemp;

CREATE TABLE meshblockDistrictTemp AS 
SELECT meshblocks.mb06
  , districts.district_n
  , COUNT(districts.district_n) OVER (PARTITION BY mb06) as count
FROM meshblocks
  , districts
WHERE ST_Intersects(meshblocks.geom, districts.geom) 
GROUP BY meshblocks.mb06
  , districts.district_n;


DROP TABLE IF EXISTS meshblockDistrictDuplicates;

CREATE TABLE meshblockDistrictDuplicates AS
SELECT meshblockDistrictTemp.mb06
  , meshblockDistrictTemp.district_n
  , RANK() OVER (PARTITION BY meshblockDistrictTemp.mb06 ORDER BY ST_Area(ST_Intersection(ST_Buffer(meshblocks.geom, 0), ST_Buffer(districts.geom, 0))) DESC) AS rank
FROM meshblockDistrictTemp
  INNER JOIN meshblocks ON meshblocks.mb06=meshblockDistrictTemp.mb06
  INNER JOIN districts ON districts.district_n=meshblockDistrictTemp.district_n
WHERE meshblockDistrictTemp.count > 1
;


DROP TABLE IF EXISTS meshblockDistrict;

CREATE TABLE meshblockDistrict AS
SELECT meshblockDistrictTemp.mb06
  , meshblockDistrictTemp.district_n
FROM meshblockDistrictTemp
LEFT JOIN meshblockDistrictDuplicates ON meshblockDistrictDuplicates.mb06=meshblockDistrictTemp.mb06
  AND meshblockDistrictDuplicates.district_n=meshblockDistrictTemp.district_n
WHERE meshblockDistrictDuplicates.rank IS NULL OR meshblockDistrictDuplicates.rank=1;


DROP TABLE IF EXISTS meshblockDistrictTemp;
DROP TABLE IF EXISTS meshblockDistrictDuplicates;


SELECT count(mb06) FROM meshblockDistrict;
SELECT * FROM meshblockDistrict LIMIT 10;