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

	<xsl:variable name="SCHEME_URI" select="ep-org:URI-Autority('corporate-body')" />

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="all">
		<!-- Output the ConceptScheme in a header -->
		<skos:ConceptScheme rdf:about="{$SCHEME_URI}">
			<skos:prefLabel xml:lang="en">Organization</skos:prefLabel>
		</skos:ConceptScheme>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="all/item">
		<xsl:variable name="var_corporateBody">
			<xsl:if test="string-length(normalize-space(bodyCode)) &gt; 0">
				<xsl:choose>
					<!-- CommitteeBody -->
					<xsl:when
						test="bodyType='CO' or bodyType='CI' or bodyType='SC' or bodyType='CE' or bodyType='CT' or bodyType='CJ' or bodyType='CM' ">
						<xsl:value-of
							select="ep-org:URI-COMMITTEEBODY(encode-for-uri(normalize-space(bodyCode)))" />
					</xsl:when>
					<!-- DelegationBody -->
					<xsl:when
						test="bodyType='AP' or bodyType='DA' or bodyType='DE' or bodyType='DH' or bodyType='DM'">
						<xsl:value-of
							select="ep-org:URI-DELEGATIONBODY(encode-for-uri(normalize-space(bodyCode)))" />
					</xsl:when>
					<!-- InstitutionBody -->
					<xsl:when test="bodyType='PE'">
						<xsl:value-of
							select="ep-org:URI-INSTITUTIONBODY(encode-for-uri(normalize-space(bodyCode)))" />
					</xsl:when>
					<!-- PoliticalGroupBody -->
					<xsl:when test="bodyType='GP'">
						<xsl:value-of
							select="ep-org:URI-POLITICALGROUPBODY(encode-for-uri(normalize-space(bodyCode)))" />
					</xsl:when>
					<!-- GovernanceBody -->
					<xsl:when test="bodyType='BU' or bodyType='OD'">
						<xsl:value-of
							select="ep-org:URI-GOVERNANCEBODY(encode-for-uri(normalize-space(bodyCode)))" />
					</xsl:when>
				</xsl:choose>
			</xsl:if>			
		</xsl:variable>
		<!-- Type corporate body -->
		<xsl:variable name="var_corporateBodytype">
			<xsl:choose>
				<!-- CommitteeBody -->
				<xsl:when
					test="bodyType='CO' or bodyType='CI' or bodyType='SC' or bodyType='CE' or bodyType='CT' or bodyType='CJ' or bodyType='CM' ">
					<xsl:value-of select="'committee-body'" />
				</xsl:when>
				<!-- DelegationBody -->
				<xsl:when
					test="bodyType='AP' or bodyType='DA' or bodyType='DE' or bodyType='DH' or bodyType='DM'">
					<xsl:value-of select="'delegation-body'" />
				</xsl:when>
				<!-- InstitutionBody -->
				<xsl:when test="bodyType='PE'">
					<xsl:value-of select="'institution-body'" />
				</xsl:when>
				<!-- PoliticalGroupBody -->
				<xsl:when test="bodyType='GP'">
					<xsl:value-of select="'political-group-body'" />
				</xsl:when>
				<!-- GovernanceBody -->
				<xsl:when test="bodyType='BU' or bodyType='OD'">
					<xsl:value-of select="'governance-body'" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$var_corporateBody != ''">
			<skos:Concept rdf:about="{$var_corporateBody}">
				<rdf:type
					rdf:source="{ep-org:URI-CVEPONTO($var_corporateBodytype)}" />
				<ep-org:hasOrganizationType>
					<skos:notation>
						<xsl:value-of
							select="encode-for-uri(normalize-space(bodyCode))" />
					</skos:notation>
				</ep-org:hasOrganizationType>
			</skos:Concept>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>