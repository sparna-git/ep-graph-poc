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
	<!-- Document -->
	<xsl:param name="gender_file"
		select="document('Gender.xml')/all/item" />
	<xsl:param name="country_file"
		select="document('countryISO_.xml')/root/row" />
	<!-- fonction -->
	<xsl:function name="ep:Lookup">
		<xsl:param name="dataInput" />
		<xsl:param name="Document" />
		<xsl:param name="KeyDocto" />
		<xsl:choose>
			<xsl:when test="$dataInput = 'Gender'">
				<xsl:for-each select="$Document">
					<xsl:choose>
						<xsl:when test="isoCode = $KeyDocto">
							<xsl:value-of select="referenceCode" />
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$dataInput = 'Countries'">
				<xsl:for-each select="$Document">
					<xsl:choose>
						<xsl:when test="Alpha-2 = $KeyDocto">
							<xsl:value-of select="Alpha-3" />
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>



	</xsl:function>

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
					select="concat('www.europarl.europa.eu/mepphoto/',identifier,'.jpg')" />
			</foaf:img>

			<schema:gender
				rdf:resource="{concat('http://data.europarl.europa.eu/authority/gender/',ep:Lookup('Gender',$gender_file,genderIsoCode))}" />
			<schema:honorificPrefix
				rdf:resource="{concat('http://data.europarl.europa.eu/authority/civility/',titleCode)}" />
			<schema:birthPlace
				rdf:resource="{concat('http://publications.europa.eu/resource/authority/place/',ep:Lookup('Countries',$country_file,countryIsoCode),'_',birthPlace)}" />
			<schema:nationality
				rdf:resource="{concat('http://publications.europa.eu/resource/authority/country/',ep:Lookup('Countries',$country_file,countryIsoCode))}" />
			<xsl:apply-templates />
		</ep:MEP>
	</xsl:template>

	<!-- ContactPoint electronic -->
	<xsl:template match="eaddresses">
		<schema:contactPoint>
			<xsl:for-each select="item/addressCodeType">
				<schema:ContactPoint
					rdf:about="{concat('http://data.europarl.europa.eu/resource/contact-point/electronic/',ancestor::item/identifier,'/',../addressType)}">
					<schema:contactType
						rdf:resource="{concat('http://data.europarl.europa.eu/authority/contact-point-type-type/',.)}">
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
					rdf:about="{concat('http://data.europarl.europa.eu/resource/contact-point/place/',identifier,'/',officeNum)}">
					<ep-org:hasSite
						rdf:resource="{concat('http://publications.europa.eu/resource/authority/site/',buildingCode)}" />
					<ep-org:officeId
						rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
						<xsl:value-of select="officeNum" />
					</ep-org:officeId>
					<schema:addressCountry
						rdf:resource="{concat('http://publications.europa.eu/resource/authority/country/',townCode)}" />
					<schema:addressLocality
						rdf:resource="{concat('http://publications.europa.eu/resource/authority/place/',townName)}" />
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
					rdf:about="{concat('http://data.europarl.europa.eu/resource/person/',personId,'/membership/',mandateId)}">
					<ep-org:constituency
						rdf:resource="{concat('http://data.europarl.europa.eu/authority/constituency/',countryIsoCode,'-',mandateId)}" />
					<ep-org:hasMembershipType
						rdf:resource="http://data.europarl.europa.eu/authority/membership-type/MANDATE" />
					<ep-org:hasOrganization
						rdf:resource="{concat('http://publications.europa.eu/resource/authority/country/',ep:Lookup('Countries',$country_file,countryIsoCode))}" />
					<ep-org:hasParliamentaryTerm
						rdf:resource="{concat('http://data.europarl.europa.eu/authority/parliamentary-term/',countryId)}" />
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

	<!-- Groupe Politique -->
	<xsl:template match="functions">
		<xsl:for-each select="item">
			<xsl:message><xsl:value-of select="child::gpId"/></xsl:message>
			<xsl:if test="ancestor::gpId = organeId">
				<org:hasMembership>
					<ep-org:Membership
						rdf:about="{concat('http://data.europarl.europa.eu/resource/person/',memberIdentifier,'/membership/',identifier)}">
						<ep-org:hasMembershipType
							rdf:resource="http://data.europarl.europa.eu/authority/membership-type/POLITICAL-GROUP" />
						<ep-org:hasOrganization
							rdf:resource="{concat('http://data.europarl.europa.eu/resource/org/',organeCode)}" />
						<ep-org:hasParliamentaryTerm
							rdf:resource="{concat('http://data.europarl.europa.eu/authority/parliamentary-term/',organeId)}" />
						<schema:endDate
							rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="endDateTime"/></schema:endDate>
						<schema:startDate
							rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="startDateTime"/></schema:startDate>
						<org:hasMembershipBasedOn
							rdf:resource="concat('http://data.europarl.europa.eu/resource/person/',memberIdentifier,'/membership/',identifier)" />
						<org:role
							rdf:resource="{concat('http://data.europarl.europa.eu/authority/function/',functionCode)}" />
					</ep-org:Membership>
				</org:hasMembership>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Comité <xsl:template match=""> </xsl:template> 

	 Parti national 
	<xsl:template match="">
		<org:hasMembership>
			<ep-org:Membership
				rdf:about="http://data.europarl.europa.eu/resource/person/124936/membership/888800004">
				<ep-org:hasMembershipType
					rdf:resource="http://data.europarl.europa.eu/authority/membership-type/NATIONAL-PARTY" />
				<ep-org:hasOrganization
					rdf:resource="http://data.europarl.europa.eu/resource/org/MR-111" />
				<ep-org:hasParliamentaryTerm
					rdf:resource="http://data.europarl.europa.eu/authority/parliamentary-term/8" />
				<schema:endDate
					rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">2019-07-01T00:00:00</schema:endDate>
				<schema:startDate
					rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">2014-07-01T00:00:00</schema:startDate>
				<org:hasMembershipBasedOn
					rdf:resource="http://data.europarl.europa.eu/resource/person/124936/membership/11111118" />
				<org:role
					rdf:resource="http://data.europarl.europa.eu/authority/function/MEF" />
			</ep-org:Membership>
		</org:hasMembership>
	</xsl:template>

	 Un assistant et le lien vers le député 
	<xsl:template match="assistants">
		<xsl:for-each select="item">
			<ep-org:Person
				rdf:about="{concat('http://data.europarl.europa.eu/resource/person/',identifier)}">
				<ep-org:hasPersonType
					rdf:resource="{concat('http://data.europarl.europa.eu/authority/person-type/','AST-APA')}" />
				<ep-org:personId
					rdf:datatype="http://www.w3.org/2001/XMLSchema#string">311270</ep-org:personId>
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

				<xsl:for-each select="accreditations/item">
					<org:hasMembership>
						<ep-org:Membership
							rdf:about="{concat('http://data.europarl.europa.eu/resource/person/',assistantId,'/membership/',identifier)}">
							<ep-org:hasMembershipType
								rdf:resource="http://data.europarl.europa.eu/authority/membership-type/PERSON" />
							<ep-org:hasOrganization
								rdf:resource="{concat('http://data.europarl.europa.eu/resource/person/',accrResponsibleId)}" />
							<org:role
								rdf:resource="http://data.europarl.europa.eu/authority/function/ASSISTANT" />
						</ep-org:Membership>
					</org:hasMembership>
				</xsl:for-each>

			</ep-org:Person>
		</xsl:for-each>
	</xsl:template>-->


</xsl:stylesheet>