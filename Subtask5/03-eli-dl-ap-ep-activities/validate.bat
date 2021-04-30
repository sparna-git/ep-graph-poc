mkdir 20-SHACL_TTL
mkdir 21-DOCUMENTATION
mkdir 20-REPORT
java -jar ..\xls2rdf-app-2.1.3-onejar.jar convert -i 04-SHACL\Activities-Shapes.xlsx -o 20-SHACL_TTL\Activities-Shapes.ttl -l en

java -jar ..\shacl-play-app-0.4-onejar.jar doc -i 20-SHACL_TTL\Activities-Shapes.ttl -o 21-DOCUMENTATION\Activities-Shapes.html -l en

java -Xmx2048M -jar ..\shacl-play-app-0.4-onejar.jar validate --createDetails -i 05-RDF -s 20-SHACL_TTL -o 20-REPORT\report.ttl -o 20-REPORT\report.html