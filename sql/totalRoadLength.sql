SELECT sum(ST_Length(clipped_geom))/1000 as roads_km
FROM (SELECT (ST_Dump(ST_Intersection(ST_Buffer(meshblocks.geom, 0.0), roads.geom))).geom As clipped_geom
FROM meshblocks
  INNER JOIN roads
  ON ST_Intersects(meshblocks.geom, roads.geom))  As clipped
	WHERE ST_Dimension(clipped.clipped_geom) = 1 ;