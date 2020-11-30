rm -rf output
mkdir output
java -jar saxon-he-10.1.jar -s:../01-Data/PV-2019-RCV -o:output -xsl:votes.xsl