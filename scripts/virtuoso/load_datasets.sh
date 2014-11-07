#! /bin/bash
set -o nounset

find_script_dir () {
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    echo "$( cd -P "$( dirname "$SOURCE" )" && pwd )"
}

SCRIPT_DIR=`find_script_dir`

NO_ARGS=0 
E_OPTERROR=85
DEFAULT_PW='dba'

exit_with_usage_help() {
  cat <<EOF 
Usage: `basename $0` [options]"
mandatory options:
-d [dataset directory]
-p [input file pattern]
-g [target graph name (URL)]

other options:
-n - no re-activation of online FT indexing and no FT index incr. update
-f - skip filling the geo-index
-a - specify non-default password for 'dba' user (default value: 'dba')
EOF
  exit $E_OPTERROR 
}


if [ $# -eq "$NO_ARGS" ]; then
  exit_with_usage_help
fi  

REINDEX=1
GEO_FILL=1
DBA_PW="$DEFAULT_PW"
while getopts "d:p:g:a:nf" Option
do
  [[ -z $Option ]] && exit_with_usage_help
  case $Option in
    d) LOAD_DIR="$OPTARG";;
    p) FILE_PATTERN="$OPTARG";;
    g) TARGET_GRAPH="$OPTARG";;
    n) REINDEX=0;;
    f) GEO_FILL=0;;
    a) DBA_PW="$OPTARG";;
  esac
done

check_visql_cmd () {
  if ! which visql > /dev/null; then
    cat <<EOF  
[ERROR] program 'visql' cannot be found. Please set PATH or symlinks in a manner that
 that the command visql points to the virtuoso isql executable.
 (Be aware that the 'isql' command points to a generic ODBC sql client in most default
  sytem configurations)  
EOF
  exit 2  
  fi  
}


run_virtuoso_cmd () {
  VIRT_OUTPUT=`echo "$1" | visql -H localhost -S 1111 -U dba -P "$DBA_PW" 2>&1`
  VIRT_RETCODE=$?
  #echo "$VIRT_OUTPUT"
  echo "$VIRT_OUTPUT" | tail -n+5 | perl -pe 's|^SQL> ||g'
  if [[ $VIRT_RETCODE -ne 0 ]]; then
    echo -e "[ERROR] running the these commands in virtuoso:\n$1"
    exit 3
  fi
}

check_visql_cmd  

echo "[INFO] load dir: $LOAD_DIR"
echo "[INFO] file pattern: $FILE_PATTERN"
echo "[INFO] target graph: $TARGET_GRAPH"

echo "[INFO] deactivating auto-indexing"
run_virtuoso_cmd "DB.DBA.VT_BATCH_UPDATE ('DB.DBA.RDF_OBJ', 'ON', NULL);"

echo "[INFO] performing bulk load of files in of data in '$LOAD_DIR'"

echo "[INFO] clearing load list"
run_virtuoso_cmd 'delete from DB.DBA.load_list;'

echo "[INFO] registring files to load"
#      <folder with data>  <pattern>    <default graph if no graph file specified>
run_virtuoso_cmd "ld_dir ('${LOAD_DIR}', '${FILE_PATTERN}', '${TARGET_GRAPH}');"

echo '[INFO] Will load the following files (to the corresponding graph):';
run_virtuoso_cmd 'select ll_file, ll_graph from  DB.DBA.load_list;'

echo '[INFO] Starting load process...';
run_virtuoso_cmd 'rdf_loader_run();'
echo '[INFO] Load process completed.';

ERRONEOUS_INPUTS=`run_virtuoso_cmd 'select ll_file, ll_state, ll_error from DB.DBA.load_list where ll_state <> 2 OR ll_error IS NOT NULL;'`
ERR_LINES=`echo "$ERRONEOUS_INPUTS" | wc -l`


if (( $ERR_LINES > 6 )); then
  echo '[WARN] some input files could not be loaded successfully:'
  echo "$ERRONEOUS_INPUTS"
  echo '[WARN] script finished with unsuccessful imports'
  exit 1
fi

if (( $REINDEX > 0 )); then
  echo "[INFO] re-activating auto-indexing"
  run_virtuoso_cmd "DB.DBA.RDF_OBJ_FT_RULE_ADD (null, null, 'All');"
  run_virtuoso_cmd 'DB.DBA.VT_INC_INDEX_DB_DBA_RDF_OBJ ();'
fi

if (( $GEO_FILL > 0 )); then
  echo "[INFO] update/filling of geo index"
  run_virtuoso_cmd 'rdf_geo_fill();'
fi

echo '[INFO] script finished successfully'
