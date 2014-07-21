URL=http://downloads.dbpedia.org/3.9/en/

mkdir -p dbpedia
cd dbpedia

# set the default graph
echo "http://dbpedia.org" >  ./global.graph

#download all ttl files from URL
wget -q -O - $URL | sed 's/"/\n/g' | grep "ttl.bz2$" | sed "s|^|$URL|g" | xargs wget

# virtuoso does not handle bz2 compressions
bunzip2 *.bz2
# recompress to save space, gz is fine for loading
gzip *.ttl

