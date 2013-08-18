SELECT mb06 AS meshblockID, sum(ST_Area(geom)) / 1000000 AS area
FROM meshblocks
GROUP BY mb06
ORDER BY mb06;