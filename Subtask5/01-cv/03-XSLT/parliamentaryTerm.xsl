<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:ep-aut="http://data.europarl.europa.eu/authority/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl"
	xmlns:dct="http://purl.org/dc/terms/">

	<!-- Import URI stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/uris.xsl" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/builtins.xsl" />
	<xsl:output indent="yes" method="xml" />
	
	<xsl:variable name="SCHEME_URI" select="org-ep:URI-Authority('parliamentary-term')" />

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="all">
		<!-- Output the ConceptScheme in a header -->
		<skos:ConceptScheme rdf:about="{$SCHEME_URI}">
			<skos:prefLabel xml:lang="en">parliamentary-term</skos:prefLabel>
		</skos:ConceptScheme>	
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="all/item">
		<skos:Concept
			rdf:about="{org-ep:URI-PARLIAMENTARY_TERM(order)}">
			<rdf:type rdf:resource="{org-ep:URI-CVEPONTO('parliamentary-term')}" />			
			
			<skos:notation><xsl:value-of select="order"/></skos:notation>
			
			<skos:prefLabel xml:lang="en">
				<xsl:value-of select="fullName"/>
			</skos:prefLabel>
			
			<dct:temporal>
				<xsl:value-of select="concat(startDate,'/',endDate)"/>
			</dct:temporal>
						
			<skos:inScheme
				rdf:resource="{$SCHEME_URI}" />

		</skos:Concept>
	</xsl:template>

</xsl:stylesheet>