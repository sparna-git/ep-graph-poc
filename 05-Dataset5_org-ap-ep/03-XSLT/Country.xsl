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
			rdf:about="{ep-org:URI-CVCOUNTRY(normalize-space(isoCode))}">
			<rdf:type rdf:resource="{ep-org:URI-CVEPONTO('Country')}" />

			<xsl:variable name="isoCountryName">
				<xsl:value-of
					select="ep-org:Lookup_COUNTRYNAME(isoCode)" />
			</xsl:variable>

			<xsl:if test="$isoCountryName != ''">
				<rdfs:label>
					<xsl:value-of select="$isoCountryName" />
				</rdfs:label>
			</xsl:if>


			<ep-org:euCandidate
				rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
				<xsl:value-of select="candidateFlag" />
			</ep-org:euCandidate>

			<ep-org:euCountry
				rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
				<xsl:value-of select="candidateFlag" />
			</ep-org:euCountry>

			<ep-org:isoCode
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="isoCode" />
			</ep-org:isoCode>

			<ep-org:isoNumber
				rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">
				<xsl:value-of select="isoNum" />
			</ep-org:isoNumber>

			<skos:inScheme
				rdf:resource="{ep-org:URI-Autority('country')}" />
			<xsl:apply-templates />
		</skos:Concept>
	</xsl:template>

	<xsl:template match="desc">
		<xsl:for-each select="item">
			<skos:prefLabel xml:lang="{lower-case(langIsoCode)}">
				<xsl:value-of select="shortName"/>
			</skos:prefLabel>
		</xsl:for-each>

		<xsl:for-each select="item">
			<skos:altLabel xml:lang="{lower-case(langIsoCode)}">
				<xsl:value-of select="fullName"
					disable-output-escaping="yes" />
			</skos:altLabel>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>