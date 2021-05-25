
# convert all
./4-convert-RED.sh
./2-convert.sh 02-org-ap-ep
./2-convert.sh 03-eli-dl-ap-ep-activities
./2-convert.sh 04-eli-dl-ap-ep-documents
./2-convert.sh 05-translations

# split translation activities in document dataset
java -jar saxon-he-10.1.jar \
	-s:04-eli-dl-ap-ep-documents/05-RDF/export-REPORTandAM.rdf \
	-xsl:04-eli-dl-ap-ep-documents/03-XSLT/split-translations.xsl \
	-o:04-eli-dl-ap-ep-documents/05-RDF/dummy.xml

# validate all
# ./3-validate.sh 01-cv
# ./3-validate.sh 02-org-ap-ep
# ./3-validate.sh 03-eli-dl-ap-ep-activities
# ./3-validate.sh 04-eli-dl-ap-ep-documents
# ./3-validate.sh 05-translations

# recreate inferences