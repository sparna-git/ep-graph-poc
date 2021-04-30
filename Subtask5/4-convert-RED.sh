# Converts the RED-model-full by using an extraction query
# By iterating on a map that declares the correspondance between
# RED root and new controlled list code

declare -A mapping
mapping[Status]=legislative-process-status
mapping[DirContProc]=legislative-process-type
mapping[DirContProcNat]=legislative-process-nature
mapping[Phase]=activity-stage
mapping[LegislativeActType]=legislative-act-type
mapping[hasEventType]=activity-type

for i in "${!mapping[@]}"
do
  echo "processing mapping : $i / ${mapping[$i]}"
  # copy template file
  cp 01-cv/03-SPARQL/RED2SKOS.rq 01-cv/03-SPARQL/RED2SKOS-$i.rq
  # replace values
  sed -i "s/RED_VALUE/$i/g" 01-cv/03-SPARQL/RED2SKOS-$i.rq
  sed -i "s/AUTHORITY_VALUE/${mapping[$i]}/g" 01-cv/03-SPARQL/RED2SKOS-$i.rq
  # execute query with bound variables
  java -jar rdf-toolkit-0.6.1-onejar.jar construct \
  	-i 01-cv/01-Data/RED-model-full.ttl \
  	-q 01-cv/03-SPARQL/RED2SKOS-$i.rq \
  	-o 01-cv/05-RDF/${mapping[$i]}_$i.ttl
  # delete temp file
  rm -rf 01-cv/03-SPARQL/RED2SKOS-$i.rq
done
