<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:ep-aut="http://data.europarl.europa.eu/authority/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl">

	<!-- Import URI stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/uris.xsl" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/builtins.xsl" />
	<xsl:output indent="yes" method="xml" />

	<xsl:variable name="SCHEME_URI"
		select="org-ep:URI-Authority('country')" />

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="all">
		<!-- Output the ConceptScheme in a header -->
		<skos:ConceptScheme rdf:about="{$SCHEME_URI}">
			<skos:prefLabel xml:lang="en">country</skos:prefLabel>
		</skos:ConceptScheme>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="all/item">
		<!-- Do not process items that have been deleted -->
		<xsl:if test="not((xs:dateTime(deletedDate) cast as xs:date) &lt;= current-date())">
			<skos:Concept
				rdf:about="{org-ep:URI-COUNTRY(encode-for-uri(normalize-space(isoCode)))}">
				<rdf:type rdf:resource="{org-ep:URI-CVEPONTO('Country')}" />
	
				<org-ep:euCandidate
					rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
					<xsl:value-of select="lower-case(candidateFlag)" />
				</org-ep:euCandidate>
	
				<org-ep:euCountry
					rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
					<xsl:value-of select="lower-case(euFlag)" />
				</org-ep:euCountry>
	
				<org-ep:isoCode
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="isoCode" />
				</org-ep:isoCode>
	
				<skos:notation>
					<xsl:value-of select="isoCode" />
				</skos:notation>
	
				<org-ep:isoNumber
					rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">
					<xsl:value-of select="isoNum" />
				</org-ep:isoNumber>
	
				<xsl:apply-templates />
	
				<skos:inScheme rdf:resource="{$SCHEME_URI}" />
			</skos:Concept>
		</xsl:if>
	</xsl:template>

	<xsl:template match="desc">
		<xsl:for-each select="item">
			<skos:prefLabel xml:lang="{lower-case(langIsoCode)}">
				<xsl:value-of select="shortName" />
			</skos:prefLabel>
		</xsl:for-each>

		<xsl:for-each select="item">
			<skos:altLabel xml:lang="{lower-case(langIsoCode)}">
				<xsl:value-of select="fullName" />
			</skos:altLabel>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>