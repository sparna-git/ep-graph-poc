# Specifications

Toutes les colonnes sont converties avec l'URI indiquée dans l'entête, sauf ep:label qui est mappée vers rdfs:label.


## civility.csv

	- ep:uri = URI
	- ep:uri rdf:type skos:Concept
	- ep:uri skos:inScheme ep_instances:Civility
	- ep:isoLanguage = ep:isoLanguage
	- ep:label = rdfs:label
	- skos:altLabel = skos:altLabel avec le code de langue

## Gender

	- ep:uri = URI
	- ep:uri rdf:type skos:Concept 
	- ep:uri skos:inScheme ep_instances:Gender
 	- ep:label = rdfs:label
   	- ep:isoCode = ep:isoCode
   	- skos:notation = skos:notation

## Country

	- ep:uri = URI
	- ep:uri rdf:type skos:Concept
	- ep:uri skos:inScheme ep_instances:Country
   	- ep:euCandidate = ep:euCandidate 
    - ep:euCountry = ep:euCountry
    - ep:euStartDate = ep:euStartDate
    - ep:formalOder = ep:formalOder
    - ep:isoCode = ep:isoCode
    - ep:isoNumber = ep:isoNumber

## reds Concept_Status.json

	- "thesaurus" : ne pas convertir
	- "uri" = URI
	- "uri" rdf:type skos:Concept
	- "uri" skos:inScheme ep_instances:Concept_Status
	- "types" : ne pas convertir
	- labels/zu/http://www.w3.org/2000/01/rdf-schema#label = rdfs:label sans langue
	- labels/en/http://www.w3.org/2004/02/skos/core#prefLabel = skos:prefLabel avec langue @en
	- labels/fr/http://www.w3.org/2004/02/skos/core#prefLabel = skos:prefLabel avec langue @fr
	
## Status.csv

Ne pas convertir (supprimé)

## reds Concept_Type.json

Ne pas convertir


