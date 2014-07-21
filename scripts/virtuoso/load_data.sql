
-- Disable auto indexing before doing bulk insertions / deletions

-- Deleting previous entries of loader script
delete from DB.DBA.load_list;

-- see http://www.openlinksw.com/dataspace/dav/wiki/Main/VirtBulkRDFLoader
select 'Loading data...';
--      <folder with data>  <pattern>    <default graph if no graph file specified>
ld_dir ('/opt/static/data/live', '*.gz', 'http://live.nl.dbpedia.org');

rdf_loader_run();

-- See if we have any errors
select * from DB.DBA.load_list where ll_state <> 2;


-- renable auto-indexing once finished with bulk operations
