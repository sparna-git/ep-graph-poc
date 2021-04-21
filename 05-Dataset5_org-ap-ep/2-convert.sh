export INPUT_DIR=10-XML
export OUTPUT_DIR=05-RDF
export XSLT_DIR=03-XSLT



FILES=( 
	"Civility"
	"ContactPointType"
	"Country"
	"Function"
	"Gender"
	"OrganizationType"
	"parliamentaryTerm"
	"Town"
)

for f in "${FILES[@]}"
do
   : 
   	 echo "Converting $f.xml ..."
   	 java -Xmx2048M -jar saxon-he-10.1.jar \
		-s:$INPUT_DIR/$f.xml \
		-o:$OUTPUT_DIR/$f.rdf \
		-xsl:$XSLT_DIR/$f.xsl
done

# convert
echo "Converting kmscodictfeedMEPs.xml ..."
java -Xmx2048M -jar saxon-he-10.1.jar \
	-s:$INPUT_DIR/kmscodictfeedMEPs_19-03-2021_09-45.xml \
	-o:$OUTPUT_DIR/kmscodictfeedMEPs.rdf \
	-xsl:$XSLT_DIR/kmscodictfeedMEPs.xsl
