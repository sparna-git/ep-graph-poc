# recreate inferences
for f in $(find 06-inferences/01-SPARQL -name '*.rq');
do
   : 
   	 FILENAME=$(basename $f .rq)
   	 echo "Inference $f ..."
   	 java -jar rdf-toolkit-0.6.1-onejar.jar construct \
		-i 03-eli-dl-ap-ep-activities/05-RDF/ \
		-i 04-eli-dl-ap-ep-documents/05-RDF/ \
		-i 05-translations/05-RDF/ \
		-q 06-inferences/01-SPARQL/$FILENAME.rq \
		-o 06-inferences/05-RDF/$FILENAME.ttl
done

