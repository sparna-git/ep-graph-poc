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
			rdf:about="{ep-org:URI-CVCONTACTPOINTTYPE(normalize-space(addtCode))}">
			<rdf:type rdf:resource="{ep-org:URI-CVEPONTO('contact-point-type')}" />
			
			<rdfs:label>
				<xsl:value-of select='shortName'/>
			</rdfs:label>
			
			<skos:notation>
				<xsl:value-of select="mepCode" />
			</skos:notation>
			
			
			<ep-org:euContactType
				rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
				<xsl:value-of select="lower-case(mepFlag)"/>
			</ep-org:euContactType>
			
			<ep-org:CodeGroup>
				<xsl:value-of select="groupCode"/>
			</ep-org:CodeGroup>
			
			<skos:inScheme
				rdf:resource="{ep-org:URI-Autority('contact-point-type')}" />
			<xsl:apply-templates />
			
			<xsl:apply-templates/>
		</skos:Concept>
	</xsl:template>

	<xsl:template match="desc">
		<xsl:for-each select="item">
			<skos:prefLabel xml:lang="{lower-case(langIso)}">
				<xsl:value-of select="fullName" />
			</skos:prefLabel>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>