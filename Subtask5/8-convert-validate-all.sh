
# clean all
rm -rf 01-cv/05-RDF \
	02-org-ap-ep/05-RDF \
	03-eli-dl-ap-ep-activities/05-RDF \
	04-eli-dl-ap-ep-documents/05-RDF \
	05-translations/05-RDF \
	06-inferences/05-RDF

rm -rf 01-cv/20-SHACL_TTL 01-cv/21-DOCUMENTATION 01-cv/20-REPORT \
	02-org-ap-ep/20-SHACL_TTL 02-org-ap-ep/21-DOCUMENTATION 02-org-ap-ep/20-REPORT \
	03-eli-dl-ap-ep-activities/20-SHACL_TTL 03-eli-dl-ap-ep-activities/21-DOCUMENTATION 03-eli-dl-ap-ep-activities/20-REPORT \
	04-eli-dl-ap-ep-documents/20-SHACL_TTL 04-eli-dl-ap-ep-documents/21-DOCUMENTATION 04-eli-dl-ap-ep-documents/20-REPORT \
	05-translations/20-SHACL_TTL 05-translations/21-DOCUMENTATION 05-translations/20-REPORT

# convert all
./2-convert.sh 01-cv
./2-convert.sh 02-org-ap-ep
./2-convert.sh 03-eli-dl-ap-ep-activities
./2-convert.sh 04-eli-dl-ap-ep-documents
./2-convert.sh 05-translations

# validate all
./3-validate.sh 01-cv
./3-validate.sh 02-org-ap-ep
./3-validate.sh 03-eli-dl-ap-ep-activities
./3-validate.sh 04-eli-dl-ap-ep-documents
./3-validate.sh 05-translations

# convert CVs
./4-convert-RED.sh

# recreate inferences
./5-infer.sh

