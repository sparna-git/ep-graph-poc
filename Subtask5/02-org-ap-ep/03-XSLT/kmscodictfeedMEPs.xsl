<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:org="http://www.w3.org/ns/org#"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">

	<!-- Import URI stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/uris.xsl" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="../../00-shared/03-XSLT/builtins.xsl" />

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

		<org-ep:MEP rdf:about="{org-ep:URI-MEP(identifier)}">
			<xsl:variable name="lastdateMandate" select="mandates[1]/item/endDateTime" as="xs:dateTime+"/>
			<xsl:variable name="lastyear" select="max($lastdateMandate)" as="xs:dateTime"/>
			
			<!-- Generate dateEndActivity by finding the last endDate of the past mandates -->
			<!-- Only if mandate is not ongoing -->
			<xsl:if test="format-dateTime($lastyear,'[Y0001]') &lt; format-date(current-date(),'[Y0001]')">
				<org-ep:dateEndActivity
					rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
					<xsl:value-of select="$lastyear"/>
				</org-ep:dateEndActivity>
			</xsl:if>
			
			<org-ep:personId
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="identifier" />
			</org-ep:personId>
			
			<!-- First names -->
			<foaf:firstName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="firstName" />
			</foaf:firstName>
			<org-ep:upperFirstName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="upperFirstName" />
			</org-ep:upperFirstName>
			<xsl:if test="nonLatinFirstName != ''">
				<org-ep:officialFirstName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="nonLatinFirstName" />
				</org-ep:officialFirstName>
			</xsl:if>
			<xsl:if test="upperNonLatinFirstName != ''">
				<org-ep:officialUpperFirstName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="upperNonLatinFirstName" />
				</org-ep:officialUpperFirstName>
			</xsl:if>
			
			<!-- Family names -->
			<foaf:familyName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="familyName" />
			</foaf:familyName>	
			<org-ep:upperFamilyName
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="upperFamilyName" />
			</org-ep:upperFamilyName>
			<xsl:if test="nonLatinFamilyName != ''">
				<org-ep:officialFamilyName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="nonLatinFamilyName" />
				</org-ep:officialFamilyName>
			</xsl:if>
			<xsl:if test="upperNonLatinFamilyName != ''">
				<org-ep:officialUpperFamilyName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="upperNonLatinFamilyName" />
				</org-ep:officialUpperFamilyName>
			</xsl:if>		


			<xsl:if test="birthDate != ''">
				<schema:birthDate
					rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
					<xsl:value-of select="birthDate" />
				</schema:birthDate>
				<!-- Conserver le libelle en input   -->
				<xsl:if test="string-length(normalize-space(birthPlace)) &gt; 0">
					<org-ep:birthPlaceLabel>
						<xsl:value-of select="birthPlace"/>
					</org-ep:birthPlaceLabel>
				</xsl:if>
			</xsl:if>
					
			
			
			<foaf:img
				rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
				<xsl:value-of select="org-ep:URI-MEPPHOTO(identifier)" />
			</foaf:img>

			<xsl:variable name="genderId" select="org-ep:Lookup_GENDER(genderIsoCode)" />
			<xsl:if test="$genderId != ''">
				<schema:gender
					rdf:resource="{org-ep:URI-GENDER($genderId)}" />
			</xsl:if>
			
			<schema:honorificPrefix
				rdf:resource="{org-ep:URI-CIVILITY(titleCode)}" />

			<!--
			<xsl:variable name="townCode" select="org-ep:Lookup_TOWN(countryId,countryIsoCode,birthPlace)" />
			<xsl:if test="$townCode != ''">
				<schema:birthPlace rdf:resource="{org-ep:URI-PLACE($townCode)}" />
			</xsl:if>
			-->

			<xsl:variable name="countryId" select="org-ep:Lookup_COUNTRY(countryIsoCode)" />
			<xsl:if test="$countryId != ''">
				<schema:nationality rdf:resource="{org-ep:URI-COUNTRY($countryId)}" />
			</xsl:if>

			<!-- Process all children except assistants -->
			<xsl:apply-templates select="* except assistants" />
		</org-ep:MEP>

		<!-- After MEP, generate the Assistant membership -->
		<xsl:apply-templates select="assistants/item" mode="membership" />
	</xsl:template>

	<!-- Assistants references through memberships -->
	<xsl:template match="all/item/assistants/item"
		mode="membership">
		<org-ep:Person
			rdf:about="{org-ep:URI-ASSISTANT(identifier)}">
			<org:hasMembership>
				<org-ep:Membership
					rdf:about="{org-ep:URI-MEMBERSHIP(identifier,ancestor::item/identifier)}">
					<org-ep:hasMembershipType
						rdf:resource="{org-ep:URI-MembershipType('PERSON')}" />
					<org-ep:hasOrganization
						rdf:resource="{org-ep:URI-Person(ancestor::item/identifier)}" />
					<org:role
						rdf:resource="{org-ep:URI-FUNCTION('ASSISTANT')}" />
				</org-ep:Membership>
			</org:hasMembership>
		</org-ep:Person>
	</xsl:template>

	<!-- Assistants entities -->
	<xsl:template match="all/item/assistants/item"
		mode="person">

		<xsl:variable name="thisIdentifier" select="identifier" />

		<!-- process only if it is the first occurrence of this assistant in the 
			file -->
		<xsl:if
			test="count(../../preceding-sibling::item[assistants/item/identifier = $thisIdentifier]) = 0">

			<org-ep:Person
				rdf:about="{org-ep:URI-ASSISTANT(identifier)}">
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
				<org-ep:hasPersonType
					rdf:resource="{org-ep:URI-PersonType($haspersonType)}" />
				<org-ep:personId
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="identifier" />
				</org-ep:personId>
				<org-ep:upperFamilyName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="upperFamilyName" />
				</org-ep:upperFamilyName>
				<org-ep:upperFirstName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="upperFirstName" />
				</org-ep:upperFirstName>
				<foaf:familyName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="richFamilyName" />
				</foaf:familyName>
				<foaf:firstName
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
					<xsl:value-of select="richFirstName" />
				</foaf:firstName>
			</org-ep:Person>
		</xsl:if>
	</xsl:template>

	<!-- CV -->
	<xsl:template match="cv">
		<xsl:for-each
			select="item[langIsoCode = 'EN' or langIsoCode = 'FR']">
			<org-ep:curriculumVitae
				xml:lang="{lower-case(langIsoCode)}">
				<xsl:value-of select="decription" />
			</org-ep:curriculumVitae>
		</xsl:for-each>
	</xsl:template>

	<!-- ContactPoint electronic -->
	<xsl:template match="eaddresses">
		<xsl:for-each
			select="item[normalize-space(address) != '']">
			<schema:contactPoint>
				<schema:ContactPoint
					rdf:about="{org-ep:URI-ContactPoint-Electronic(ancestor::item/identifier,concat(addressCodeType,generate-id(.)))}">
					<schema:contactType
						rdf:resource="{org-ep:URI-CONTACT_POINT_TYPE_ELECTRONIC(addressCodeType)}" />
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
					rdf:about="{org-ep:URI-ContactPoint-Place(identifier,officeNum)}">

					<org-ep:hasSite
						rdf:resource="{org-ep:URI-SITE(buildingCode)}" />
					<org-ep:officeId
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="officeNum" />
					</org-ep:officeId>
					
					<!-- Setup addressCountry and addressLocality depending on town code : STR or BRU -->
					<xsl:choose>
						<xsl:when test="townCode = 'BRU'">
							<schema:addressCountry rdf:resource="{org-ep:URI-COUNTRY('BEL')}" />
							<schema:addressLocality rdf:resource="{org-ep:URI-LOCALITY('BEL_BRU')}" />
						</xsl:when>
						<xsl:when test="townCode = 'STR'">
							<schema:addressCountry rdf:resource="{org-ep:URI-COUNTRY('FRA')}" />
							<schema:addressLocality rdf:resource="{org-ep:URI-LOCALITY('FRA_SXB')}" />	
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>Unexpected townCode in addresses : <xsl:value-of select="townCode" /></xsl:message>
						</xsl:otherwise>
					</xsl:choose>		
					
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
				<org-ep:MembershipMandate rdf:about="{org-ep:URI-MEMBERSHIPMANDATE(personId,mandateId)}">
					
					<org-ep:hasMembershipType
							rdf:resource="{org-ep:URI-MembershipType('MANDATE')}" />
					
					<!--  
					<org-ep:constituency
						rdf:resource="{org-ep:URI-CONSTITUENCY(countryIsoCode,mandateId)}" />	
					-->		
					<xsl:if test="circons != ''">				
						<org-ep:constituencyLabel><xsl:value-of select="circons"/></org-ep:constituencyLabel>
					</xsl:if>

					<xsl:variable name="countryId" select="org-ep:Lookup_COUNTRY(countryIsoCode)" />
					<xsl:if test="$countryId != ''">
						<org-ep:hasOrganization rdf:resource="{org-ep:URI-COUNTRY($countryId)}" />
					</xsl:if>

					<xsl:variable name="ptId" select="org-ep:Lookup_PARLIAMENTARY_TERM(startDateTime,endDateTime,personId,mandateId)" />
					<xsl:if
						test="$ptId != ''">
						<org-ep:hasParliamentaryTerm
							rdf:resource="{org-ep:URI-PARLIAMENTARY_TERM($ptId)}" />
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
					
					
					<xsl:variable name="in_seatBru" select="normalize-space(../../seatBru)"/>
					<xsl:variable name="in_seatStr" select="normalize-space(../../seatStr)"/>
					<xsl:choose>
						<xsl:when test="number($in_seatBru) = 0 and number($in_seatStr) = 0">
							<xsl:message>Warning!! The values of seatBru and seaStr is 0.</xsl:message>
						</xsl:when>
						<xsl:when test="number($in_seatBru) = 0">
							<xsl:message>Warning!! The value of seatBru is 0</xsl:message>
						</xsl:when>
						<xsl:when test="number($in_seatStr) = 0">
							<xsl:message>Warning!! The value of seatStr is 0</xsl:message>
						</xsl:when>
					</xsl:choose>
					
					<!-- if the mandat is the current  -->
					<xsl:if test="endDateTime &gt; current-dateTime()">
						<xsl:if test="string-length($in_seatBru) &gt; 0">
							<org-ep:memberSeatBru rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="$in_seatBru"/></org-ep:memberSeatBru> 
						</xsl:if>
						<xsl:if test="string-length($in_seatStr) &gt; 0">
							<org-ep:memberSeatStr rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="$in_seatStr"/></org-ep:memberSeatStr>					
						</xsl:if>				
					</xsl:if>
				</org-ep:MembershipMandate>	
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
				
				<!-- Variable org-ep:hasMembershipType -->
				<xsl:variable name="var_hasMembershipType">
					<xsl:choose>
						<!-- COMMITTEE -->
						<xsl:when
							test="index-of(('CO', 'CI', 'SC', 'CE', 'CT', 'CJ', 'CM'), typeOrganeCode) > 0">
							<xsl:value-of select="'COMMITTEE'" />
						</xsl:when>
						<!-- DELEGATION -->
						<xsl:when
							test="index-of(('AP', 'DA', 'DC', 'DE', 'DH', 'DM'), typeOrganeCode) > 0">
							<xsl:value-of select="'DELEGATION'" />
						</xsl:when>
						<!-- MANDATE -->
						<xsl:when test="typeOrganeCode='PE'">
							<xsl:value-of select="'MANDATE'" />
						</xsl:when>
						<!-- POLITICAL-GROUP -->
						<xsl:when test="typeOrganeCode='GP'">
							<xsl:value-of select="'POLITICAL-GROUP'" />
						</xsl:when>
						<!-- NATIONAL-PARTY -->
						<xsl:when test="typeOrganeCode='PN'">
							<xsl:value-of select="'NATIONAL-PARTY'" />							
						</xsl:when>
						<!-- GOVERNANCE BODY -->
						<xsl:when test="typeOrganeCode='BU' or typeOrganeCode='OD'">
							<xsl:value-of select="GOVERNANCE-BODY"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>Cannot determine membership type from typeOrganeCode '<xsl:value-of select="typeOrganeCode" />' </xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>


				<org-ep:Membership
					rdf:about="{org-ep:URI-MEMBERSHIP(memberIdentifier,identifier)}">

					<xsl:if test="$var_hasMembershipType != ''">
						<org-ep:hasMembershipType
									rdf:resource="{org-ep:URI-MembershipType($var_hasMembershipType)}" />												
					</xsl:if>

					<org-ep:hasOrganization
						rdf:resource="{org-ep:URI-Organization(organeCode,organeId)}" />

					<xsl:variable name="ptId" select="org-ep:Lookup_PARLIAMENTARY_TERM(startDateTime,endDateTime,memberIdentifier,identifier)" />
					<xsl:if
						test="$ptId != ''">
						<org-ep:hasParliamentaryTerm
							rdf:resource="{org-ep:URI-PARLIAMENTARY_TERM($ptId)}" />
					</xsl:if>

					<schema:endDate
						rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
						<xsl:value-of select="endDateTime" />
					</schema:endDate>
					<schema:startDate
						rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
						<xsl:value-of select="startDateTime" />
					</schema:startDate>							
					
					<org:role
						rdf:resource="{org-ep:URI-FUNCTION(functionCode)}" />
				</org-ep:Membership>
			</org:hasMembership>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet> 