<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
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


	<!-- Assistants -->
	<xsl:template match="all/item/assistants">
		<ep-org:Person
			rdf:about="{ep-org:URI-ASSISTANT(identifier)}">
			<xsl:variable name="haspersonType">
				<xsl:choose>
					<xsl:when test="accreditations/item/assistantType = 'A'">
						<xsl:value-of select="AST-APA" />
					</xsl:when>
					<xsl:when test="accreditations/item/assistantType = 'L'">
						<xsl:value-of select="AST-LOC" />
					</xsl:when>
					<xsl:when
						test="child::identifier != accreditations/item/accrResponsibleId">
						<xsl:value-of select="AST-APA-GRP" />
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<ep-org:hasPersonType
				rdf:resource="{ep-org:URI-AutorityPERSON($haspersonType)}" />
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
			<foaf:familyName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="richFamilyName" />
			</foaf:familyName>
			<foaf:firstName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="richFirstName" />
			</foaf:firstName>
		</ep-org:Person>
	</xsl:template>


	<xsl:template match="all">
		<xsl:apply-templates />
	</xsl:template>


	<xsl:template match="all/item">

		<!-- Variables -->
		<xsl:variable name="IdMEP" select="identifier" />

		<ep-org:MEP rdf:about="{ep-org:URI-MEP(identifier)}">
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
				<xsl:value-of select="ep-org:URI-MEPPHOTO(identifier)" />
			</foaf:img>

			<schema:gender
				rdf:resource="{ep-org:URI-MEPGENDER(genderIsoCode)}" />
			<schema:honorificPrefix
				rdf:resource="{ep-org:URI-CIVILITY(titleCode)}" />

			<!--
			<schema:birthPlace
				rdf:resource="{ep-org:URI-MEPBIRTHPLACE(countryId,countryIsoCode,birthPlace)}" />
			-->

			<schema:nationality
				rdf:resource="{ep-org:URI-MEPNATIONALITY(countryIsoCode)}" />

			<xsl:apply-templates />
		</ep-org:MEP>
	</xsl:template>


	<!-- CV -->
	<xsl:template match="cv">
		<xsl:for-each select="item">
			<xsl:if test="langIsoCode='EN'">
				<ep-org:curriculumVitae xml:lang="">
					<xsl:value-of select="decription" />
				</ep-org:curriculumVitae>
			</xsl:if>
			<xsl:if test="langIsoCode='FR'">
				<ep-org:curriculumVitae
					xml:lang="{lower-case(langIsoCode)}">
					<xsl:value-of select="decription" />
				</ep-org:curriculumVitae>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- ContactPoint electronic -->
	<xsl:template match="eaddresses">
		<xsl:for-each select="item">
			<schema:contactPoint>
				<schema:ContactPoint
					rdf:about="{ep-org:eaddresses(ancestor::item/identifier,concat(addressCodeType,order))}">
					<schema:contactType
						rdf:resource="{ep-org:eaddressesContactType(addressCodeType)}" />
					<schema:url
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="address" />
					</schema:url>
				</schema:ContactPoint>
			</schema:contactPoint>
		</xsl:for-each>
	</xsl:template>

	<!-- ContactPoint PostalAdress -->
	<xsl:template match="addresses">
		<xsl:for-each select="item">
			<schema:contactPoint>
				<schema:PostalAddress
					rdf:about="{ep-org:addresses(identifier,officeNum)}">

					<ep-org:hasSite
						rdf:resource="{ep-org:URI-PublicationsSITE(buildingCode)}" />
					<ep-org:officeId
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="officeNum" />
					</ep-org:officeId>
					<schema:addressCountry
						rdf:resource="{ep-org:URI-PublicationsCOUNTRY(townCode)}" />
					<schema:addressLocality
						rdf:resource="{ep-org:URI-PublicationsLOCALITY(townName)}" />
					<schema:faxNumber
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="faxNum" />
					</schema:faxNumber>
					<schema:telephone
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="phoneNum" />
					</schema:telephone>
				</schema:PostalAddress>
			</schema:contactPoint>
		</xsl:for-each>
	</xsl:template>

	<!-- Mandat -->
	<xsl:template match="mandates">
		<xsl:for-each select="item">
			<org:hasMembership>
				<ep-org:Membership
					rdf:about="{ep-org:URI-MEMBERSHIP(personId,mandateId)}">
					<ep-org:constituency
						rdf:resource="{ep-org:URI-MandatCONSTITUENCY(countryIsoCode,mandateId)}" />

					<ep-org:hasOrganization
						rdf:resource="{ep-org:URI-MandatORGANIZATION(countryIsoCode)}" />
					<xsl:variable name="startDate"
						select="translate(startDateTime,'-','')" />
					<xsl:variable name="endDate"
						select="translate(endDateTime,'-','')" />

					<xsl:if
						test="string-length(normalize-space(ep-org:OrderparliamentaryTerm($startDate,$endDate))) &gt; 0">
						<ep-org:hasParliamentaryTerm
							rdf:resource="{ep-org:URI-ParliamentaryTerm($startDate,$endDate)}" />
					</xsl:if>
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

					<ep-org:hasMembershipBasedOn
						rdf:resource="{ep-org:URI-MEMBERSHIP(personId,mandateId)}" />

				</ep-org:Membership>
			</org:hasMembership>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="functions">
		<xsl:for-each select="item">
			<org:hasMembership>
				<xsl:variable name="startDate"
					select="translate(startDateTime,'-','')" />
				<xsl:variable name="endDate"
					select="translate(endDateTime,'-','')" />
				<!-- Variable ep-org:hasMembershipType -->
				<xsl:variable name="var_hasMembershipType">
					<xsl:choose>
						<!-- CommitteeBody -->
						<xsl:when
							test="typeOrganeCode='CO' or typeOrganeCode='CI' or typeOrganeCode='SC' or typeOrganeCode='CE' or typeOrganeCode='CT' or typeOrganeCode='CJ' or typeOrganeCode='CM' ">
							<xsl:value-of select="'committee-body'" />
						</xsl:when>
						<!-- DelegationBody -->
						<xsl:when
							test="typeOrganeCode='AP' or typeOrganeCode='DA' or typeOrganeCode='DE' or typeOrganeCode='DH' or typeOrganeCode='DM'">
							<xsl:value-of select="'delegation-body'" />
						</xsl:when>
						<!-- InstitutionBody -->
						<xsl:when test="typeOrganeCode='PE'">
							<xsl:value-of select="'institution-body'" />
						</xsl:when>
						<!-- PoliticalGroupBody -->
						<xsl:when test="bodyType='GP'">
							<xsl:value-of select="'political-group-body'" />
						</xsl:when>
						<!-- GovernanceBody -->
						<xsl:when test="bodyType='BU' or bodyType='OD'">
							<xsl:value-of select="governance-body" />
						</xsl:when>
						<!-- Parti national -->
						<xsl:when test="bodyType='PN'">
							<xsl:value-of select="'national-party-body'" />
						</xsl:when>
					</xsl:choose>
				</xsl:variable>


				<ep-org:Membership
					rdf:about="{ep-org:URI-MEMBERSHIP(memberIdentifier,identifier)}">

					<xsl:if test="$var_hasMembershipType != ''">
						<ep-org:hasMembershipType
							rdf:resource="{ep-org:URI-MembershipType($var_hasMembershipType)}" />
					</xsl:if>


					<ep-org:hasOrganization
						rdf:resource="{ep-org:URI-TYPEOrganization(typeOrganeCode,organeCode,organeId)}" />



					<ep-org:hasParliamentaryTerm
						rdf:resource="{ep-org:URI-ParliamentaryTerm($startDate,$endDate)}" />


					<schema:endDate
						rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
						<xsl:value-of select="endDateTime" />
					</schema:endDate>
					<schema:startDate
						rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
						<xsl:value-of select="startDateTime" />
					</schema:startDate>



					<org:role
						rdf:resource="{ep-org:URI-AutorityFUNCTION(functionCode)}" />
				</ep-org:Membership>
			</org:hasMembership>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet> 