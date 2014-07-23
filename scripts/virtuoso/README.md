## List of Virtuoso scripts for loading / maintenance


* `auto_indexing_disable.sql` disables auto indexing of VIrtuoso to make loading faster
* `auto_indexing_enable.sql` enables auto indexing of VIrtuoso. This is used for functions like `bif:contains`
* `clear_graph.sql` clears the contents of a graph (need to set the graph)
* `create_graph_groups.sql` Creates a virtual graph as a view of multiple graphs
* `fct_plugin_reindex.sql` indexes the database to make the FCT plugin work better
* `init_dbpedia_vad_plugin.sql` Used to setup the basic configuration for the dbpedia_vad plugin
* `load_data.sql` loads the contents of a folder to the db
* `load_manually_rdf_file.sql` inserts a single RDF/XML file to the db
* `virtuoso-run-isql.sh` Open an ISQL interface (need to adapt username, password isql port)
* `virtuoso-run-script.sh` (need to adapt username, password isql port)
