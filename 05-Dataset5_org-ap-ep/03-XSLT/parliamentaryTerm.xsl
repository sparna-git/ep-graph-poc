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
			rdf:about="{ep-org:URI-CVPARLIAMENTARY(identifier)}">
			<rdf:type rdf:resource="{ep-org:URI-CVEPONTO('parliamentary-term')}" />
			
			
			<rdfs:label>
				<xsl:value-of select="fullName"/>
			</rdfs:label>
			
			<ep-org:isoLanguage
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="langIso" />
			</ep-org:isoLanguage>
			
			<ep-org:Period>
				<xsl:value-of select="periodType"/>
			</ep-org:Period>
			
			<ep-org:dateEnd
				rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
				<xsl:value-of select="endDate" />
			</ep-org:dateEnd>
			<ep-org:dateStart
				rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
				<xsl:value-of select="startDate" />
			</ep-org:dateStart>
			
			<skos:inScheme
				rdf:resource="{ep-org:URI-Autority('parliamentary-term')}" />

		</skos:Concept>
	</xsl:template>

</xsl:stylesheet>