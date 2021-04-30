<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:ep-aut="http://data.europarl.europa.eu/authority/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl"
	xmlns:org="http://www.w3.org/ns/org#"
	xmlns:dct="http://purl.org/dc/terms/">

	<!-- Import URI stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/uris.xsl" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/builtins.xsl" />
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
		<!-- look for the bodyCode on the first label because some bodyCode are missing -->
		<xsl:variable name="theBodyCode" select="descriptions/item[1]/bodyCode" />
		<org-ep:Organization rdf:about="{org-ep:URI-Organization($theBodyCode, encode-for-uri(normalize-space(bodyId)))}">
			
			<!-- Generate skos notations -->
			<skos:notation rdf:datatype="http://data.europarl.europa.eu/authority/notation-type/codict/bodycode"><xsl:value-of select="normalize-space($theBodyCode)" /></skos:notation>
			<!-- also look for mnemoCode here -->
			<skos:notation rdf:datatype="http://data.europarl.europa.eu/authority/notation-type/codict/mnemocode"><xsl:value-of select="normalize-space(descriptions/item[1]/mnemoCode)" /></skos:notation>
			<!--  Open Data code -->
			<skos:notation rdf:datatype="http://data.europarl.europa.eu/authority/notation-type/od"><xsl:value-of select="normalize-space($theBodyCode)" /></skos:notation>	
			
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
							select="org-ep:URI-COMMITTEEBODY(encode-for-uri(normalize-space(../descriptions/item[1]/bodyCode)))" />
					</xsl:when>
					<!-- DelegationBody -->
					<xsl:when
						test="index-of(('AP','DA','DE','DH','DM'),$bodyTypeOrg)">	
						<xsl:value-of
							select="org-ep:URI-DELEGATIONBODY(encode-for-uri(normalize-space(../descriptions/item[1]/bodyCode)))" />
					</xsl:when>
					<!-- InstitutionBody -->
					<xsl:when test="$bodyTypeOrg='PE'">
						<xsl:value-of
							select="org-ep:URI-INSTITUTIONBODY(encode-for-uri(normalize-space(../descriptions/item[1]/bodyCode)))" />
					</xsl:when>
					<!-- PoliticalGroupBody -->
					<xsl:when test="$bodyTypeOrg='GP'">
						<xsl:value-of
							select="org-ep:URI-POLITICALGROUPBODY(encode-for-uri(normalize-space(../descriptions/item[1]/bodyCode)))" />
					</xsl:when>
					<!-- GovernanceBody -->
					<xsl:when test="index-of(('BU','OD'),$bodyTypeOrg)">
						<xsl:value-of
							select="org-ep:URI-GOVERNANCEBODY(encode-for-uri(normalize-space(../descriptions/item[1]/bodyCode)))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>Warning: bodyType "<xsl:value-of select="$bodyTypeOrg"/>" is unknown to generate hasCorporateBody.</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>			
		</xsl:variable>
		
		<xsl:if test="$var_corporateBody != ''">
			<org-ep:hasCorporateBody rdf:resource="{$var_corporateBody}"/>
		</xsl:if>
		
		<!-- always generate organization type -->
		<org-ep:hasOrganizationType rdf:resource="{org-ep:URI-OrganizationType(encode-for-uri(normalize-space(.)))}"/> 
	</xsl:template>

	<xsl:template match="bodyId">
		<xsl:variable name="idbodyId" select="normalize-space(.)"/>
		<dc:identifier><xsl:value-of select="$idbodyId" /></dc:identifier>
		
		<!-- This build the org:subOrganizationOf -->
		<xsl:for-each select="/all/item[parentBodyId = $idbodyId]">
			<xsl:variable name="bodyParentId" select="bodyId"/>
			<xsl:variable name="idCodeParent" select="/all/item[bodyId=$bodyParentId]/bodyCode"/>
			<xsl:if test="$idCodeParent!=''">
				<org:subOrganizationof rdf:resource="{org-ep:URI-subOrganization(encode-for-uri($idCodeParent),normalize-space($idbodyId))}"/>
			</xsl:if>			
		</xsl:for-each>
		
		
		<!-- This build the dct:hasPart -->
		<xsl:for-each select="/all/item[parentBodyId=$idbodyId]">			
			<xsl:if test="string-length(normalize-space(bodyCode)) &gt; 0">
				<dct:hasPart rdf:resource="{org-ep:URI-subOrganization(encode-for-uri(bodyCode),$idbodyId)}"/>
			</xsl:if>
		</xsl:for-each>		
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