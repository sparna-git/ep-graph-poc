# Converts the RED-model-full by using an extraction query
# By iterating on a map that declares the correspondance between
# RED root and new controlled list code


# extract document types
java -jar rdf-toolkit-0.6.1-onejar.jar construct \
      -i 01-cv/01-Data/RED-model-full.ttl \
      -q 01-cv/03-SPARQL/RED2SKOS-legislative-process-work-type.rq \
      -o 01-cv/05-RDF/legislative-process-work-type.rdf


declare -A mapping
# warning, this one is mapped on 2 output
mapping[Status]=legislative-process-status,legislative-process-work-status
mapping[DirContProc]=legislative-process-type
mapping[DirContProcNat]=legislative-process-nature
mapping[Phase]=activity-stage
mapping[LegislativeActType]=legal-resource-type
mapping[hasEventType]=activity-type
mapping[EventSubTypeS20]=activity-context-precision
mapping[DirContDossNat]=activity-nature
mapping[CodeVote]=vote-result
mapping[voteMode]=vote-mode
mapping[hasDocumentUse]=involved-work-role
mapping[DirContDocFam]=legislative-process-work-type-family
mapping[Role]=activity-membership-role
mapping[InfTypIter]=activity-context
mapping[DirContDocUse]=involved-work-role


for i in "${!mapping[@]}"
do
  # split value on commas for special case where 1 input goes to multiple outputs
  for output in $(echo ${mapping[$i]} | tr "," "\n")
  do
    echo "processing mapping : $i / $output"
    # copy template file
    cp 01-cv/03-SPARQL/RED2SKOS.rq 01-cv/03-SPARQL/RED2SKOS-$output.rq
    # replace values
    sed -i "s/RED_VALUE/$i/g" 01-cv/03-SPARQL/RED2SKOS-$output.rq
    sed -i "s/AUTHORITY_VALUE/$output/g" 01-cv/03-SPARQL/RED2SKOS-$output.rq
    # execute query with bound variables
    java -jar rdf-toolkit-0.6.1-onejar.jar construct \
      -i 01-cv/01-Data/RED-model-full.ttl \
      -q 01-cv/03-SPARQL/RED2SKOS-$output.rq \
      -o 01-cv/05-RDF/$output.rdf
    # delete temp file
    rm -rf 01-cv/03-SPARQL/RED2SKOS-$output.rq
  done
done
