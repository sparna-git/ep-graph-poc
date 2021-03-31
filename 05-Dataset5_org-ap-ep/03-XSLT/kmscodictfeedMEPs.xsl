<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:ep="http://data.europarl.europa.eu/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl"
	xmlns:ep-org="http://data.europarl.europa.eu/ontology/ep-org#"
	xmlns:org="http://www.w3.org/ns/org#">

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

		<!-- Variables -->
		<xsl:variable name="IdMEP" select="identifier" />

		<ep:MEP rdf:about="{ep:URI-MEP(identifier)}">
			<!-- CV -->
			<xsl:for-each select="cv/item">
				<xsl:choose>
					<xsl:when test="langIsoCode='EN'">
						<ep-org:curriculumVitae xml:lang="en">
							<xsl:value-of select="decription" />
						</ep-org:curriculumVitae>
					</xsl:when>
					<xsl:when test="langIsoCode='FR'">
						<ep-org:curriculumVitae xml:lang="fr">
							<xsl:value-of select="decription" />
						</ep-org:curriculumVitae>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>

			<ep-org:dateEndActivity
				rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
			</ep-org:dateEndActivity>
			<ep-org:personId
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="identifier" />
			</ep-org:personId>
			<ep-org:upperFamilyName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="upperFamilyName" />
			</ep-org:upperFamilyName>
			<ep-org:upperFirstName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="upperFirstName" />
			</ep-org:upperFirstName>
			<schema:birthDate
				rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
				<xsl:value-of select="birthDate" />
			</schema:birthDate>
			<foaf:familyName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="familyName" />
			</foaf:familyName>
			<foaf:firstName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="firstName" />
			</foaf:firstName>
			<foaf:img
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of
					select="ep:URI-MEPPHOTO(identifier)" />
			</foaf:img>

			<schema:gender
				rdf:resource="{ep:URI-MEPGENDER(genderIsoCode)}" />
			<schema:honorificPrefix
				rdf:resource="{ep:URI-MEPCIVILITY(titleCode)}" />
			<schema:birthPlace
				rdf:resource="{ep:URI-MEPBIRTHPLACE(countryIsoCode,birthPlace)}" />
			<schema:nationality
				rdf:resource="{ep:URI-MEPNATIONALITY(countryIsoCode)}" />
			<xsl:apply-templates />
		</ep:MEP>
		<!-- Assistant -->
		<xsl:for-each select="assistants/item">
			<ep-org:Person
				rdf:about="{ep:URI-ASSISTANT(identifier)}">
				<ep-org:hasPersonType
					rdf:resource="{ep:URI-AutorityPERSON('AST-APA')}" />
				<ep-org:personId
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">identifier</ep-org:personId>
				<ep-org:upperFamilyName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="upperFamilyName" />
				</ep-org:upperFamilyName>
				<ep-org:upperFirstName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="upperFirstName" />
				</ep-org:upperFirstName>
				<foaf:familyName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="richFamilyName" />
				</foaf:familyName>
				<foaf:firstName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="richFirstName" />
				</foaf:firstName>

				<org:hasMembership>
					<ep-org:Membership
						rdf:about="{ep:URI-MEMBERSHIP(identifier,identifier)}">
						<ep-org:hasMembershipType
							rdf:resource="{ep:URI-MembershipType('PERSON')}" />
						<ep-org:hasOrganization
							rdf:resource="{ep:URI-Person(ancestor::identifier)}" />
						<org:role
							rdf:resource="{ep:URI-AutorityFUNCTION('ASSISTANT')}" />
					</ep-org:Membership>
				</org:hasMembership>

			</ep-org:Person>
		</xsl:for-each>
	</xsl:template>

	<!-- ContactPoint electronic -->
	<xsl:template match="eaddresses">
		<schema:contactPoint>
			<xsl:for-each select="item/addressCodeType">
				<schema:ContactPoint
					rdf:about="{ep:eaddresses(ancestor::item/identifier,concat(../addressCodeType,../order))}">
					<schema:contactType
						rdf:resource="{ep:eaddressesContactType(.)}">
						<schema:url
							rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
							<xsl:value-of select="../address" />
						</schema:url>
					</schema:contactType>
				</schema:ContactPoint>
			</xsl:for-each>
		</schema:contactPoint>
	</xsl:template>

	<!-- ContactPoint PostalAdress -->
	<xsl:template match="addresses">
		<schema:contactPoint>
			<xsl:for-each select="item">
				<schema:PostalAddress
					rdf:about="{ep:addresses(identifier,officeNum)}">
					<ep-org:hasSite
						rdf:resource="{ep:URI-PublicationsSITE(buildingCode)}" />
					<ep-org:officeId
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="officeNum" />
					</ep-org:officeId>
					<schema:addressCountry
						rdf:resource="{ep:URI-PublicationsCOUNTRY(townCode)}" />
					<schema:addressLocality
						rdf:resource="{ep:URI-PublicationsLOCALITY(townName)}" />
					<schema:faxNumber
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="faxNum" />
					</schema:faxNumber>
					<schema:telephone
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="phoneNum" />
					</schema:telephone>
				</schema:PostalAddress>
			</xsl:for-each>
		</schema:contactPoint>

	</xsl:template>

	<!-- Mandat -->
	<xsl:template match="mandates">
		<org:hasMembership>
			<xsl:for-each select="item">
				<ep-org:Membership
					rdf:about="{ep:URI-MEMBERSHIP(personId,mandateId)}">
					<ep-org:constituency
						rdf:resource="{ep:URI-MandatCONSTITUENCY(countryIsoCode,mandateId)}" />
					<ep-org:hasMembershipType
						rdf:resource="{ep:URI-MandatTYPE('MANDATE')}" />
					<ep-org:hasOrganization
						rdf:resource="{ep:URI-MandatORGANIZATION(countryIsoCode)}" />
					<xsl:variable name="startDate" select="translate(startDateTime,'-','')"/>	
					<xsl:variable name="endDate" select="translate(endDateTime,'-','')"/>
					<ep-org:hasParliamentaryTerm
						rdf:resource="{ep:URI-ParliamentaryTerm($startDate,$endDate)}" />
					<dc:identifier
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="mandateId" />
					</dc:identifier>
					<schema:endDate
						rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
						<xsl:value-of select="endDateTime" />
					</schema:endDate>
					<schema:startDate
						rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
						<xsl:value-of select="startDateTime" />
					</schema:startDate>
				</ep-org:Membership>
			</xsl:for-each>
		</org:hasMembership>
	</xsl:template>

	<xsl:template match="functions">
		<xsl:for-each select="item">
			<xsl:choose>
				<!-- Groupe Politique -->
				<xsl:when test="typeOrganeCode='GP'">
					<xsl:if
						test="ancestor::item/gpId=organeId and ancestor::item/gpCode =organeCode">
						<org:hasMembership>
							<ep-org:Membership
								rdf:about="{ep:URI-MEMBERSHIP(memberIdentifier,identifier)}">
								<ep-org:hasMembershipType
									rdf:resource="ep:URI-MembershipType('POLITICAL-GROUP')" />
								<ep-org:hasOrganization
									rdf:resource="{ep:URI-TYPEOrganization(typeOrganeCode,organeCode,organeId)}" />
								
								<xsl:variable name="startDate" select="translate(startDateTime,'-','')"/>	
								<xsl:variable name="endDate" select="translate(endDateTime,'-','')"/>	
								<ep-org:hasParliamentaryTerm
									rdf:resource="{ep:URI-ParliamentaryTerm($startDate,$endDate)}" />
								
								<schema:endDate
									rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
									<xsl:value-of select="endDateTime" />
								</schema:endDate>
								<schema:startDate
									rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
									<xsl:value-of select="startDateTime" />
								</schema:startDate>
								<org:hasMembershipBasedOn
									rdf:resource="{ep:URI-MEMBERSHIP(memberIdentifier,organeId)}" />
								<org:role
									rdf:resource="{ep:URI-AutorityFUNCTION(functionCode)}" />
							</ep-org:Membership>
						</org:hasMembership>
					</xsl:if>
				</xsl:when>
				<!-- Comité -->
				<xsl:when test="typeOrganeCode='CO'">
					<xsl:if
						test="ancestor::item/epFunctionCode=functionCode and ancestor::item/epFunctionOrder = functionOrder">
						<org:hasMembership>
							<ep-org:Membership
								rdf:about="{ep:URI-MEMBERSHIP(memberIdentifier,identifier)}">
								<ep-org:hasMembershipType
									rdf:resource="{ep:URI-MembershipType('COMMITTEE')}" />
								<ep-org:hasOrganization
									rdf:resource="{ep:URI-TYPEOrganization(typeOrganeCode,organeCode,organeId)}" />
									
								<xsl:variable name="startDate" select="translate(startDateTime,'-','')"/>	
								<xsl:variable name="endDate" select="translate(endDateTime,'-','')"/>	
								<ep-org:hasparliamentaryterm
									rdf:resource="{ep:URI-ParliamentaryTerm($startDate,$endDate)}" />
								<schema:endDate
									rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
									<xsl:value-of select="endDateTime" />
								</schema:endDate>
								<schema:startDate
									rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
									<xsl:value-of select="startDateTime" />
								</schema:startDate>
								<org:hasMembershipBasedOn
									rdf:resource="{ep:URI-MEMBERSHIP(memberIdentifier,organeId)}" />
								<org:role
									rdf:resource="{ep:URI-AutorityFUNCTION(functionCode)}" />
							</ep-org:Membership>
						</org:hasMembership>
					</xsl:if>
				</xsl:when>
				<!-- Parti national -->
				<xsl:when test="typeOrganeCode='PN'">
					<xsl:if
						test="ancestor::item/epFunctionCode=functionCode and ancestor::item/epFunctionOrder = functionOrder">
						<org:hasMembership>
							<ep-org:Membership
								rdf:about="{ep:URI-MEMBERSHIP(memberIdentifier,identifier)}">
								<ep-org:hasMembershipType
									rdf:resource="{ep:URI-MembershipType('NATIONAL-PARTY')}" />
								<ep-org:hasOrganization
									rdf:resource="{ep:URI-TYPEOrganization(typeOrganeCode,organeCode,organeId)}" />
								
								<xsl:variable name="startDate" select="translate(startDateTime,'-','')"/>	
								<xsl:variable name="endDate" select="translate(endDateTime,'-','')"/>	
								<ep-org:hasParliamentaryTerm
									rdf:resource="{ep:URI-ParliamentaryTerm($startDate,$endDate)}" />
							
								
								<schema:endDate
									rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
									<xsl:value-of select="endDateTime" />
								</schema:endDate>
								<schema:startDate
									rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
									<xsl:value-of select="startDateTime" />
								</schema:startDate>
								<org:hasMembershipBasedOn
									rdf:resource="{ep:URI-MEMBERSHIP(memberIdentifier,organeId)}" />
								<org:role
									rdf:resource="{ep:URI-AutorityFUNCTION(functionCode)}" />
							</ep-org:Membership>
						</org:hasMembership>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	
</xsl:stylesheet> 