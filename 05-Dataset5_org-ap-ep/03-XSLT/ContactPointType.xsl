<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:ep-org="http://data.europarl.europa.eu/ontology/ep-org#"
	xmlns:scheme="http://data.europarl.europa.eu/authority/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl"
	xmlns:dc="http://purl.org/dc/elements/1.1/">

	<!-- Import URI stylesheet -->
	<xsl:import href="uris.xsl" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="builtins.xsl" />
	<xsl:output indent="yes" method="xml" />

	<xsl:variable name="SCHEME_URI"
		select="ep-org:URI-Autority('contact-point-type')" />

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
		<xsl:variable name="sTypeContactPoint">
			<xsl:choose>
				<xsl:when test="groupCode = 'VIRTUAL'">
					<xsl:value-of
						select="ep-org:URI-CVCONT_POINT_T_ELECTRONIC(encode-for-uri(normalize-space(addtCode)))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="ep-org:URI-CVCONT_POINT_T_PLACE(encode-for-uri(normalize-space(addtCode)))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sContactPoint">
			<xsl:choose>
				<xsl:when test="groupCode = 'VIRTUAL'">
					<xsl:value-of
						select="ep-org:URI-ONTO_CONTACTPOINT_T('electronic')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="ep-org:URI-ONTO_CONTACTPOINT_T('place')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<skos:Concept rdf:about="{$sTypeContactPoint}">
			<rdf:type rdf:resource="{$sContactPoint}" />

			<xsl:choose>
				<xsl:when test="groupCode = 'VIRTUAL'">
					<dc:identifier>
						<xsl:value-of select='tmsCode' />
					</dc:identifier>
				</xsl:when>
				<xsl:otherwise>
					<ep-org:officeId>
						<xsl:value-of select='tmsCode' />
					</ep-org:officeId>
				</xsl:otherwise>
			</xsl:choose>

			<rdfs:label>
				<xsl:value-of select='shortName' />
			</rdfs:label>

			<skos:notation>
				<xsl:value-of select="mepCode" />
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