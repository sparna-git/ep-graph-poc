# Specifications


Préfixe ep = http://data.europarl.europa.eu/ pour les propriétés et les classes (entêtes de colonnes)
Préfixe ep = ???? pour les instances (cellules du tableau)  


Fichier MEP :

  -	ep:MEP.ep:uri = URI de la personne
  - ep:MEP.ep:uri rdf:type ep:MEP
  - ep:MEP.ep:familyName = foaf:familyName
  - ep:MEP.ep:firstName = foaf:firstName
  - ep:MEP.ep:persId = skos:notation
  -	ep:Civility.ep:uri = ep:Civility
  - ep:Gender.ep:uri = ep:Gender
  -	ep:Status.ep:uri = ep:Status
  -	ep:hasBirthCountry.ep:uri = ep:hasBirthCountry
  -	ep:hasPoliticalGroup.ep:uri =
  		- org:hasMembership vers une URI qu'il faut générer : URI de la personne + "/membership"
  		- URI "/membership" org:organization vers l'URI du parti politique
  		- URI "/membership" rdf:type org:Membership


Fichier PoliticalGroup :

  - ep:uri = URI du groupe
  - ep:uri rdf:type org:Organization
  - ep:activatedDate = ep:activatedDate
  - ep:startDate = ep:startDate
  - ep:endDate = ep:endDate
  - ep:orderNumber = ep:orderNumber
  - skos:notation = skos:notation
  - ep:label = rdfs:label
  - skos:prefLabel.hu = skos:prefLabel avec la langue "hu"
  - idem pour les autres skos:prefLabel


Fichier Assistants :

  - ep:Assistant.ep:uri = URI de l'assistant
  - ep:Assistant.ep:uri rdf:type ep:Assistant
  - ep:Assistant.ep:firstName = foaf:firstName
  - ep:Assistant.ep:lastName = foaf:familyName
  - ep:Assistant.ep:assistantType = ep:assistantType
  - ep:MEP.ep:familyName = ne pas mapper
  - ep:MEP.ep:firstName = ne pas mapper
  - ep:MEP.ep:uri =
      - org:hasMembership vers une URI qu'il faut générer : URI de l'assistant + "/membership"
      - URI "/membership" org:organization vers l'URI du MEP
      - URI "/membership" rdf:type org:Membership
      - ==> même structure que le lien entre un MEP et le parti politique