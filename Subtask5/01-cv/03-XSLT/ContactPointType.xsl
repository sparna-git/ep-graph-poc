<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:ep-aut="http://data.europarl.europa.eu/authority/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl"
	xmlns:dc="http://purl.org/dc/elements/1.1/">

	<!-- Import URI stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/uris.xsl" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/builtins.xsl" />
	<xsl:output indent="yes" method="xml" />

	<xsl:variable name="SCHEME_URI"
		select="org-ep:URI-Authority('contact-point-type')" />

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="all">
		<!-- Output the ConceptScheme in a header -->
		<skos:ConceptScheme rdf:about="{$SCHEME_URI}">
			<skos:prefLabel xml:lang="en">contactType</skos:prefLabel>
		</skos:ConceptScheme>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="all/item">
	
		<!-- 
		<xsl:variable name="sTypeContactPoint">
			<xsl:choose>
				<xsl:when test="groupCode = 'VIRTUAL'">
					<xsl:value-of
						select="org-ep:URI-CONTACT_POINT_TYPE_ELECTRONIC(encode-for-uri(normalize-space(addtCode)))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="org-ep:URI-CONTACT_POINT_TYPE_PLACE(encode-for-uri(normalize-space(addtCode)))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		 -->

		<skos:Concept rdf:about="{org-ep:URI-CONTACT_POINT_TYPE_ELECTRONIC(encode-for-uri(normalize-space(addtCode)))}">
			<rdf:type rdf:resource="http://data.europarl.europa.eu/ontology/org-ep#ContactPointType" />

			<dc:identifier>
				<xsl:value-of select='addtCode' />
			</dc:identifier>

			<rdfs:label>
				<xsl:value-of select='shortName' />
			</rdfs:label>

			<skos:notation>
				<xsl:value-of select="addtCode" />
			</skos:notation>

			<xsl:apply-templates />

			<skos:inScheme rdf:resource="{$SCHEME_URI}" />
		</skos:Concept>
	</xsl:template>

	<xsl:template match="desc">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="item">
		<skos:prefLabel xml:lang="{lower-case(langIso)}">
			<xsl:value-of select="fullName" />
		</skos:prefLabel>
	</xsl:template>
</xsl:stylesheet>