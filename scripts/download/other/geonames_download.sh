mkdir -p geonames
cd geonames
# download all data
wget -i ../geonames_urls.txt

# set the default graph
echo "http://geonames.org" >  ./global.graph

unzip all-geonames-rdf.zip

rm geonames.nt
touch geonames.nt

unzip -p all-geonames-rdf.zip | grep -v "^http" | while read p; do
  echo $p | rapper -q -I - - file -i rdfxml | rapper -q -I - - file -i ntriples -o turtle  >> geonames.nt
done

