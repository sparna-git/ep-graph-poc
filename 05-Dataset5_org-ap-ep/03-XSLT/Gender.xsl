<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:ep-org="http://data.europarl.europa.eu/ontology/ep-org#"
	xmlns:ep-aut="http://data.europarl.europa.eu/authority/"
	xmlns:scheme="http://data.europarl.europa.eu/authority/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl">


	<!-- Import URI stylesheet -->
	<xsl:import href="uris.xsl" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="builtins.xsl" />
	
	<xsl:variable name="SCHEME_URI" select="ep-org:URI-Authority('gender')" />

	<xsl:output indent="yes" method="xml" />

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="all">
		<!-- Output the ConceptScheme in a header -->
		<skos:ConceptScheme rdf:about="{$SCHEME_URI}">
			<skos:prefLabel xml:lang="en">Gender</skos:prefLabel>
		</skos:ConceptScheme>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="all/item">
		<skos:Concept
			rdf:about="{ep-org:URI-GENDER(referenceCode)}">
			<rdf:type rdf:resource="{ep-org:URI-CVEPONTO('Gender')}"/>
			<skos:notation>
				<xsl:value-of select="referenceCode" />
			</skos:notation>
			<ep-org:isoCode
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="isoCode" />
			</ep-org:isoCode>
			<xsl:apply-templates />
			<skos:inScheme rdf:resource="{$SCHEME_URI}"/>				 
		</skos:Concept>
	</xsl:template>

	<xsl:template match="desc">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="item">
			<skos:preflabel xml:lang="{lower-case(langIso)}">
				<xsl:value-of select="fullName"/>
			</skos:preflabel>
	</xsl:template>
</xsl:stylesheet>