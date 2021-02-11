java -Xms2000M -Xmx4000M -jar shacl-play-app-0.4-onejar.jar doc \
	-i 01-Dataset1_CV/04-SHACL/Dataset1_CV-Shapes.ttl \
  -w /home/thomas/sparna/00-Clients/EP/21-Ontology/onto-ep\ 7/onto-ep/ep.ttl \
	-o Dataset1_CV-Shapes.html \
  -l en

java -Xms2000M -Xmx4000M -jar shacl-play-app-0.4-onejar.jar doc \
  -i 02-Dataset2_MEP/04-SHACL/Dataset2_MEP-Shapes.ttl \
  -w /home/thomas/sparna/00-Clients/EP/21-Ontology/onto-ep\ 7/onto-ep/ep.ttl \
  -o Dataset2_MEP-Shapes.html \
  -l en

java -Xms2000M -Xmx4000M -jar shacl-play-app-0.4-onejar.jar doc \
  -i 03-Dataset3_Sessions/04-SHACL/Dataset3_Sessions-Shapes.ttl \
  -w /home/thomas/sparna/00-Clients/EP/21-Ontology/onto-ep\ 7/onto-ep/ep.ttl \
  -o Dataset3_Sessions-Shapes.html \
  -l en

java -Xms2000M -Xmx4000M -jar shacl-play-app-0.4-onejar.jar doc \
  -i 04-Dataset4_Votes/04-SHACL/Dataset4_SHACL-Shapes.ttl \
  -w /home/thomas/sparna/00-Clients/EP/21-Ontology/onto-ep\ 7/onto-ep/ep.ttl \
  -o Dataset4_SHACL-Shapes.html \
  -l en