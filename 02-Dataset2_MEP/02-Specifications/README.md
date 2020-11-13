# Specifications


Fichier MEP :

  -	ep:MEP.ep:uri = URI de la personne
  - ep:MEP.ep:uri rdf:type foaf:Person
  - ep:MEP.ep:familyName = foaf:lastName
  - ep:MEP.ep:firstName = foaf:firstName
  - ep:MEP.ep:persId = dcterms:identifier
  -	ep:Civility.ep:uri = foaf:title
  - ep:Gender.ep:uri = foaf:gender
  -	ep:Status.ep:uri = ????
  -	ep:hasBirthCountry.ep:uri =
  -	ep:hasPoliticalGroup.ep:uri =
  		- org:hasMembership vers une URI qu'il faut générer : URI de la personne + "/membership"
  		- URI "/membership" org:organization vers l'URI du parti politique
  		- URI "/membership" rdf:type org:Membership


Fichier PoliticalGroup :

  - ep:uri = URI du groupe
  - ep:uri rdf:type org:Organization
  - ep:activatedDate = ????
  - ep:startDate = ????
  - ep:endDate = ???
  - ep:orderNumber = ????
  - skos:notation = skos:notation
  - ep:label = rdfs:label
  - skos:prefLabel.hu = skos:prefLabel avec la langue "hu"
  - idem pour les autres skos:prefLabel

