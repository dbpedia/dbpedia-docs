URL=http://downloads.linkedgeodata.org/releases/2013-08-14/

mkdir -p linkedgeodata
cd linkedgeodata

# set the default graph
echo "http://linkedgeodata.org" >  ./global.graph

#download all ttl files from URL
wget -q -O - $URL | sed 's/"/\n/g' | grep "nt.bz2$" | sed "s|^|$URL|g" | xargs wget

# virtuoso does not handle bz2 compressions
bunzip2 *.bz2
# recompress to save space, gz is fine for loading
gzip *.ttl

