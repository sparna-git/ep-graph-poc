<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
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

	<xsl:variable name="SCHEME_URI" select="org-ep:URI-Authority('organization')" />

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
		<org-ep:Organization rdf:about="{org-ep:URI-Organization(bodyCode, encode-for-uri(normalize-space(bodyId)))}">		
			<skos:inScheme rdf:resource="{$SCHEME_URI}" />
			<xsl:apply-templates/>
		</org-ep:Organization>
	</xsl:template>

	<xsl:template match="bodyType">
		<xsl:variable name="bodyTypeOrg" select="."/>
		
		<xsl:variable name="var_corporateBody">
			<xsl:if test="string-length(normalize-space($bodyTypeOrg)) &gt; 0">
				<xsl:choose>
					<!-- CommitteeBody -->
					<xsl:when
						test="index-of(('CO','CI','SC','CE','CT','CJ','CM'),$bodyTypeOrg)">
						<xsl:value-of
							select="org-ep:URI-COMMITTEEBODY(encode-for-uri(normalize-space($bodyTypeOrg)))" />
					</xsl:when>
					<!-- DelegationBody -->
					<xsl:when
						test="index-of(('AP','DA','DE','DH','DM'),$bodyTypeOrg)">	
						<xsl:value-of
							select="org-ep:URI-DELEGATIONBODY(encode-for-uri(normalize-space($bodyTypeOrg)))" />
					</xsl:when>
					<!-- InstitutionBody -->
					<xsl:when test="$bodyTypeOrg='PE'">
						<xsl:value-of
							select="org-ep:URI-INSTITUTIONBODY(encode-for-uri(normalize-space($bodyTypeOrg)))" />
					</xsl:when>
					<!-- PoliticalGroupBody -->
					<xsl:when test="$bodyTypeOrg='GP'">
						<xsl:value-of
							select="org-ep:URI-POLITICALGROUPBODY(encode-for-uri(normalize-space($bodyTypeOrg)))" />
					</xsl:when>
					<!-- GovernanceBody -->
					<xsl:when test="index-of(('BU','OD'),$bodyTypeOrg)">
						<xsl:value-of
							select="org-ep:URI-GOVERNANCEBODY(encode-for-uri(normalize-space($bodyTypeOrg)))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>Warning: bodyType "<xsl:value-of select="$bodyTypeOrg"/>" is unknown to generate hasCorporateBody.</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>			
		</xsl:variable>
		
		<!-- always generate organization type -->
		<org-ep:hasOrganizationType rdf:resource="{org-ep:URI-OrganizationType(.)}"/>
		
		<xsl:if test="$var_corporateBody != ''">
			<org-ep:hasCorporateBody rdf:resource="{$var_corporateBody}"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="bodyId">
		<dc:identifier><xsl:value-of select="normalize-space(.)" /></dc:identifier>
	</xsl:template>
	
	<xsl:template match="bodyCode">
		<skos:notation rdf:datatype="http://data.europarl.europa.eu/authority/notation-type/codict/bodycode"><xsl:value-of select="normalize-space(.)" /></skos:notation>
		<!-- also look for mnemoCode here -->
		<skos:notation rdf:datatype="http://data.europarl.europa.eu/authority/notation-type/codict/mnemocode"><xsl:value-of select="normalize-space(../descriptions/item[1]/mnemoCode)" /></skos:notation>
		<!--  OD code ? -->
	</xsl:template>

	<xsl:template match="endDateTime">
		<schema:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
		 	<xsl:value-of select="."/>
		 </schema:endDate>
	</xsl:template>

	<xsl:template match="startDateTime">
		<schema:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
		 	<xsl:value-of select="."/>
		 </schema:endDate>
	</xsl:template>

	
	<xsl:template match="descriptions">
		<xsl:for-each select="item">
			<skos:preflabel xml:lang="{lower-case(langIsoCode)}">
				<xsl:value-of select="shortName"/>
			</skos:preflabel>
		</xsl:for-each>
		<xsl:for-each select="item">
			<skos:altLabel xml:lang="{lower-case(langIsoCode)}">
				<xsl:value-of select="fullName"/>
			</skos:altLabel>
		</xsl:for-each>
	</xsl:template>	 	
</xsl:stylesheet>