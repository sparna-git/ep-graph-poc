java -Xms2000M -Xmx4000M -jar shacl-play-app-0.4-onejar.jar validate \
	-s 01-Dataset1_CV/04-SHACL/Dataset1_CV-Shapes.ttl \
	-i 01-Dataset1_CV/05-RDF/civility.ttl \
  -i 01-Dataset1_CV/05-RDF/country.ttl \
  -i 01-Dataset1_CV/05-RDF/gender.ttl \
  -i 01-Dataset1_CV/05-RDF/reds_Concept_Status.ttl \
	-o 01-Dataset1_CV/07-SHACL-Report/report.html \
	-o 1-Dataset1_CV/07-SHACL-Report/report.ttl

java -Xms2000M -Xmx4000M -jar shacl-play-app-0.4-onejar.jar validate \
  -s 02-Dataset2_MEP/04-SHACL/Dataset2_MEP-Shapes.ttl \
  -i 02-Dataset2_MEP/05-RDF/Assistants_with_MEP.ttl \
  -i 02-Dataset2_MEP/05-RDF/MEP-Body_10-11-2020.ttl \
  -i 02-Dataset2_MEP/05-RDF/PoliticalGroup.ttl \
  -o 02-Dataset2_MEP/07-SHACL-Report/report.html \
  -o 02-Dataset2_MEP/07-SHACL-Report/report.ttl

java -Xms2000M -Xmx4000M -jar shacl-play-app-0.4-onejar.jar validate \
  -s 03-Dataset3_Sessions/04-SHACL/Dataset3_Sessions-Shapes.ttl \
  -i 03-Dataset3_Sessions/05-RDF/Plenary_Setting_Date_MEP.ttl \
  -i 03-Dataset3_Sessions/05-RDF/Plenary_Setting_Session.ttl \
  -o 03-Dataset3_Sessions/07-SHACL-Report/report.html \
  -o 03-Dataset3_Sessions/07-SHACL-Report/report.ttl

java -Xms2000M -Xmx4000M -jar shacl-play-app-0.4-onejar.jar validate \
  -s 04-Dataset4_Votes/04-SHACL/Dataset4_SHACL-Shapes.ttl \
  -i 04-Dataset4_Votes/03-XSLT/output/Q3 \
  -o 04-Dataset4_Votes/07-SHACL-Report/report.html \
  -o 04-Dataset4_Votes/07-SHACL-Report/report.ttl