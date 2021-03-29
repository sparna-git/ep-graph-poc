export SHACL_DIR=04-SHACL
export RDF_DIR=05-RDF
export REPORT_DIR=20-REPORT

# convert everything in SHACL dir
for f in $(find $SHACL_DIR -name '*.xlsx'); do
	SHACL_TTL=$SHACL_DIR/$(basename "$f" | cut -d. -f1).ttl
	echo "Converting $f to $SHACL_TTL"
	java -jar xls2rdf-app-2.1.3-onejar.jar convert -i $f -o $SHACL_TTL -l en
done

# now validate
mkdir $REPORT_DIR
java -Xmx2048M -jar shacl-play-app-0.4-onejar.jar -i $RDF_DIR/kmscodictfeedMEPs.rdf -s $SHACL_DIR/Dataset5_MEP-Shapes.ttl -o $REPORT_DIR/kmscodictfeedMEPs.html
