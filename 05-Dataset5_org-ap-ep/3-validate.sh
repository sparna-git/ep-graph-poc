export SHACL_DIR=04-SHACL
export SHACL_TTL_DIR=20-SHACL_TTL
export RDF_DIR=05-RDF
export DOCUMENTATION_DIR=21-DOCUMENTATION
export REPORT_DIR=20-REPORT

mkdir $REPORT_DIR
mkdir $SHACL_TTL_DIR
mkdir $DOCUMENTATION_DIR

# convert everything in SHACL dir
#
for f in $(find $SHACL_DIR -name '*.xlsx'); do
	SHACL_TTL=$SHACL_TTL_DIR/$(basename "$f" | cut -d. -f1).ttl
	echo "Converting $f to $SHACL_TTL"
	java -jar xls2rdf-app-2.1.3-onejar.jar convert -i $f -o $SHACL_TTL -l en
	# Generate doc
	SHACL_HTML_DOC=$DOCUMENTATION_DIR/$(basename "$f" | cut -d. -f1).html
	java -jar shacl-play-app-0.4-onejar.jar doc -i $SHACL_TTL -o $SHACL_HTML_DOC -l en
done

# now validate MEPs
java -Xmx2048M -jar shacl-play-app-0.4-onejar.jar validate \
-i $RDF_DIR \
-s $SHACL_TTL_DIR/Dataset5_MEP-Shapes.ttl \
-o $REPORT_DIR/kmscodictfeedMEPs.html
