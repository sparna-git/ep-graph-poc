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

	<xsl:template match="all">
		<xsl:apply-templates />

		<!-- Generate all assistants at the end of the file -->
		<xsl:apply-templates select="item/assistants/item"
			mode="person" />

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

			<xsl:if
				test="ep-org:Lookup_COUNTRYBIRTHPLACE(countryId,countryIsoCode,birthPlace) != ''">
				<schema:birthPlace
					rdf:resource="{ep-org:URI-MEPBIRTHPLACE(countryId,countryIsoCode,birthPlace)}" />
			</xsl:if>

			<schema:nationality
				rdf:resource="{ep-org:URI-MEPNATIONALITY(countryIsoCode)}" />

			<!-- Process all children except assistants -->
			<xsl:apply-templates select="* except assistants" />
		</ep-org:MEP>

		<!-- After MEP, generate the Assistant membership -->
		<xsl:apply-templates select="assistants/item"
			mode="membership" />
	</xsl:template>

	<!-- Assistants references through memberships -->
	<xsl:template match="all/item/assistants/item"
		mode="membership">
		<ep-org:Person
			rdf:about="{ep-org:URI-ASSISTANT(identifier)}">
			<org:hasMembership>
				<ep-org:Membership
					rdf:about="{ep-org:URI-MEMBERSHIP(ancestor::item/identifier,identifier)}">
					<ep-org:hasMembershipType
						rdf:resource="{ep-org:URI-MembershipType('PERSON')}" />
					<ep-org:hasOrganization
						rdf:resource="{ep-org:URI-ResourcePerson(ancestor::item/identifier)}" />
					<org:role
						rdf:resource="{ep-org:URI-AutorityFUNCTION('ASSISTANT')}" />
				</ep-org:Membership>
			</org:hasMembership>
		</ep-org:Person>
	</xsl:template>

	<!-- Assistants entities -->
	<xsl:template match="all/item/assistants/item"
		mode="person">

		<xsl:variable name="thisIdentifier" select="identifier" />

		<!-- process only if it is the first occurrence of this assistant in the 
			file -->
		<xsl:if
			test="count(../../preceding-sibling::item[assistants/item/identifier = $thisIdentifier]) = 0">

			<ep-org:Person
				rdf:about="{ep-org:URI-ASSISTANT(identifier)}">
				<xsl:variable name="haspersonType">
					<xsl:choose>
						<xsl:when
							test="count(/all/item[assistants/item/identifier = $thisIdentifier]) > 1">AST-APA-GRP</xsl:when>
						<xsl:when test="accreditations/item[assistantType = 'A']">AST-APA</xsl:when>
						<xsl:when test="accreditations/item[assistantType = 'L']">AST-LOC</xsl:when>
						<xsl:otherwise>
							<xsl:message>
								Cannot determine person-type for assistant
								<xsl:value-of select="$thisIdentifier" />
							</xsl:message>
						</xsl:otherwise>
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
		</xsl:if>
	</xsl:template>

	<!-- CV -->
	<xsl:template match="cv">
		<xsl:for-each
			select="item[langIsoCode = 'EN' or langIsoCode = 'FR']">
			<ep-org:curriculumVitae
				xml:lang="{lower-case(langIsoCode)}">
				<xsl:value-of select="decription" />
			</ep-org:curriculumVitae>
		</xsl:for-each>
	</xsl:template>

	<!-- ContactPoint electronic -->
	<xsl:template match="eaddresses">
		<xsl:for-each
			select="item[normalize-space(address) != '']">
			<schema:contactPoint>
				<schema:ContactPoint
					rdf:about="{ep-org:eaddresses(ancestor::item/identifier,concat(addressCodeType,order))}">
					<schema:contactType
						rdf:resource="{ep-org:eaddressesContactType(addressCodeType)}" />
					<schema:url
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="normalize-space(address)" />
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
					<schema:addressLocality>
						<xsl:value-of select="townName" />
					</schema:addressLocality>
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

					<xsl:if
						test="ep-org:OrderparliamentaryTerm(startDateTime,endDateTime) != ''">
						<ep-org:hasParliamentaryTerm
							rdf:resource="{ep-org:URI-ParliamentaryTerm(startDateTime,endDateTime)}" />
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
							test="index-of(('CO', 'CI', 'SC', 'CE', 'CT', 'CJ', 'CM'), typeOrganeCode) > 0">
							<xsl:value-of select="'committee-body'" />
						</xsl:when>
						<!-- DelegationBody -->
						<xsl:when
							test="index-of(('AP', 'DA', 'DE', 'DH', 'DM'), typeOrganeCode) > 0">
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
						rdf:resource="{ep-org:URI-Organization(typeOrganeCode,organeCode,organeId)}" />

					<!-- <ep-org:hasParliamentaryTerm rdf:resource="{ep-org:URI-ParliamentaryTerm($startDate,$endDate)}" 
						/> -->


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