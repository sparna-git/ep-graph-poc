<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:ep-aut="http://data.europarl.europa.eu/authority/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl">

	<!-- Import URI stylesheet -->
	<xsl:import href="uris.xsl" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="builtins.xsl" />
	<xsl:output indent="yes" method="xml" />

	<xsl:variable name="SCHEME_URI"
		select="org-ep:URI-Authority('place')" />

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="all">
		<!-- Output the ConceptScheme in a header -->
		<skos:ConceptScheme rdf:about="{$SCHEME_URI}">
			<skos:prefLabel xml:lang="en">Place</skos:prefLabel>
		</skos:ConceptScheme>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="all/item">
		<skos:Concept
			rdf:about="{org-ep:URI-PLACE(normalize-space(townCode))}">
			<rdf:type rdf:resource="{org-ep:URI-CVEPONTO('place')}" />

			<rdfs:label>
				<xsl:value-of select="townCode" />
			</rdfs:label>
			
			<xsl:apply-templates/>

			<skos:inScheme rdf:resource="{$SCHEME_URI}" />
		</skos:Concept>
	</xsl:template>

	<xsl:template match="desc">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="item">
		<skos:prefLabel xml:lang="{lower-case(langIso)}">
			<xsl:value-of select="normalize-space(townName)" />
		</skos:prefLabel>
	</xsl:template>

</xsl:stylesheet>