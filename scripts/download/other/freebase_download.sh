URL=http://download.freebaseapps.com

mkdir -p freebase
cd freebase

# set the default graph
echo "http://freebase.com" >  ./global.graph

# just download
# wget $URL

#download, split gzip
wget -q -O - $URL | zcat | split -d --line-bytes 500M -a 4 --filter='gzip > $FILE.nt.gz' - "freebase-"

