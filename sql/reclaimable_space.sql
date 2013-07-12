col alloc_mb format 99,999.99
col used_mb format 99,999.99
col reclaimable_mb format 99,999.99
col pct_wastage format 99.99
SELECT	segment_owner,
	segment_name, 
	segment_type, 
	round(allocated_space/1024/1024,3) alloc_mb,
	round(used_space/1024/1024,3) used_mb,
	round(reclaimable_space/1024/1024,3) reclaimable_mb, 
	round(reclaimable_space/allocated_space*100,3) pct_wastage
FROM 	TABLE(dbms_space.asa_recommendations())
order 	by 6 asc;
