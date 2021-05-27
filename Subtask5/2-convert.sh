export DATASET_FOLDER=$1

export INPUT_DIR=$DATASET_FOLDER/10-XML
export OUTPUT_DIR=$DATASET_FOLDER/05-RDF
export XSLT_DIR=$DATASET_FOLDER/03-XSLT

# remove trailing slash
DATASET_NAME=$(basename $DATASET_FOLDER)
rm -rf convert-$DATASET_NAME.log

# hack for draft reports
cp 04-eli-dl-ap-ep-documents/03-XSLT/export-REPORTandAM.xsl 04-eli-dl-ap-ep-documents/03-XSLT/export-draftRPandAM.xsl

# convert every file in XML folder to RDF folder, using stylesheet with same name
for f in $(find $INPUT_DIR -name '*.xml');
do
   : 
   	 FILENAME=$(basename $f .xml)
   	 echo "Converting $FILENAME.xml ..."
   	 java -Xmx2048M -jar saxon-he-10.1.jar \
		-s:$INPUT_DIR/$FILENAME.xml \
		-o:$OUTPUT_DIR/$FILENAME.rdf \
		-xsl:$XSLT_DIR/$FILENAME.xsl &>> convert-$DATASET_NAME.log
done
