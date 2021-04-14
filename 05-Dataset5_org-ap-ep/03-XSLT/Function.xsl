<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:ep-org="http://data.europarl.europa.eu/ontology/ep-org#"
	xmlns:scheme="http://data.europarl.europa.eu/authority/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl">

	<!-- Import URI stylesheet -->
	<xsl:import href="uris.xsl" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="builtins.xsl" />
	<xsl:output indent="yes" method="xml" />

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="all">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="all/item">
		<skos:Concept
			rdf:about="{ep-org:URI-CVFUNCTION(referenceCode)}">
			<rdf:type rdf:resource="{ep-org:URI-CVEPONTO('function')}" />

			<rdfs:label>
				<xsl:value-of select="tmsCode" />
			</rdfs:label>
			<rdfs:comment>
				<xsl:value-of select="comment" />
			</rdfs:comment>

			<ep-org:identifier
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="identifier" />
			</ep-org:identifier>
			
			<xsl:apply-templates/>
			
			<skos:inScheme
				rdf:resource="{ep-org:URI-Autority('function')}" />
		</skos:Concept>
	</xsl:template>
	
	<xsl:template match="descriptions">
		<xsl:for-each select="item">
			<skos:prefLabel xml:lang="{lower-case(langIsoCode)}">
					<xsl:value-of select="fullName" />
				</skos:prefLabel>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>