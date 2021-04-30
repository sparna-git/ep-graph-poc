<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
>

	<xsl:param name="SHARED_XML_DIR">../01-Data</xsl:param>
	<xsl:param name="CV_XML_DIR">../../01-cv/10-XML</xsl:param>

	<!-- Read source file from CV -->
	<xsl:param name="gender_file"
		select="document(concat($CV_XML_DIR, '/', 'Gender.xml'))/all/item" />
	<xsl:param name="Town"
		select="document(concat($CV_XML_DIR, '/', 'Town.xml'))/all/item" />	
	<xsl:param name="parliamentaryTerm_file"
		select="document(concat($CV_XML_DIR, '/', 'parliamentaryTerm.xml'))/all/item" />	
	
	<!-- Country code mapping does not come from CV, it is an input file -->
	<xsl:param name="country_file"
		select="document(concat($SHARED_XML_DIR, '/','CountryISO.xml'))/root/row" />

	<xsl:function name="org-ep:URI-MEP">
		<xsl:param name="mepId" />
		<xsl:value-of select="org-ep:URI-Person($mepId)" />
	</xsl:function>

	<xsl:function name="org-ep:URI-ASSISTANT">
		<xsl:param name="AssistantId" />
		<xsl:value-of select="org-ep:URI-Person($AssistantId)" />
	</xsl:function>

	<xsl:function name="org-ep:URI-Person">
		<xsl:param name="personId" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/person/', encode-for-uri($personId))" />
	</xsl:function>

	<!-- URI Organisation -->
	<xsl:function name="org-ep:URI-Organization">
		<xsl:param name="organeCode"/>
		<xsl:param name="organeId"/>
		<xsl:value-of select="concat('http://data.europarl.europa.eu/org/', encode-for-uri($organeCode),'-',$organeId)" />
	</xsl:function>

	<!-- URI Person Type -->
	<xsl:function name="org-ep:URI-PersonType">
		<xsl:param name="uriAutority" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/authority/person-type/', $uriAutority)" />
	</xsl:function>

	<!-- parliamentary terms -->
	<xsl:function name="org-ep:URI-PARLIAMENTARY_TERM">
		<xsl:param name="parliamentaryTermId" />
		<xsl:value-of select="concat(org-ep:URI-Authority('parliamentary-term/'), $parliamentaryTermId)"/>
	</xsl:function>

	<!-- MEP  -->

	<!-- URI MEMBERSHIP  -->
	<xsl:function name="org-ep:URI-MEMBERSHIP">
		<xsl:param name="identifier"/>
		<xsl:param name="mandateId"/>
		<xsl:value-of select="concat(org-ep:URI-MEP($identifier),'/membership/',$mandateId)"/>
	</xsl:function>

	<!-- PHOTO -->
	<xsl:function name="org-ep:URI-MEPPHOTO">
		<xsl:param name="identifier"/>
		<xsl:value-of select="concat('www.europarl.europa.eu/mepphoto/',$identifier,'.jpg')"/>
	</xsl:function>

	<!-- Gender-->
	<xsl:function name="org-ep:URI-GENDER">
		<xsl:param name="genderId" />
		<xsl:value-of select="concat(org-ep:URI-Authority('gender/'), $genderId)" />
	</xsl:function>

	<!-- PLACE -->
	<xsl:function name="org-ep:URI-PLACE">
		<xsl:param name="placeId"/>
		<xsl:value-of select="org-ep:URI-Authority(concat('place/', $placeId))"/>
	</xsl:function>

	<!-- URI Place (publication.europa.eu)  -->
	<xsl:function name="org-ep:URI-PublicationsLOCALITY">
		<xsl:param name="uriPublications" />
		<xsl:value-of select="concat('http://publications.europa.eu/resource/authority/place/', $uriPublications)" />
	</xsl:function>

	<!-- Country -->
	<xsl:function name="org-ep:URI-COUNTRY">
		<xsl:param name="countryId" />
		<!--
		<xsl:value-of select="concat(org-ep:URI-Authority('country/'), $countryId)" />
		 -->
		<xsl:value-of select="concat('http://publications.europa.eu/resource/authority/country/', $countryId)" />
	</xsl:function>

	<!-- ADDRESSES  -->

	<!-- ContactPoint electronic  -->
	<xsl:function name="org-ep:URI-ContactPoint-Electronic">
		<xsl:param name="identifier"/>
		<xsl:param name="typeContact"/>
		<xsl:value-of select="concat('http://data.europarl.europa.eu/resource/contact-point/electronic/',$identifier,'/',$typeContact)"/>
	</xsl:function>

	<!-- ContactPoint place  -->
	<xsl:function name="org-ep:URI-ContactPoint-Place">
		<xsl:param name="identifier"/>
		<xsl:param name="office"/>
		<xsl:value-of select="concat('http://data.europarl.europa.eu/resource/contact-point/place/',$identifier,'/',$office)"/>
	</xsl:function>

	<!-- URI SITE  -->
	<xsl:function name="org-ep:URI-PublicationsSITE">
		<xsl:param name="uriPublications" />
		<xsl:value-of select="concat('http://publications.europa.eu/resource/authority/site/', $uriPublications)" />
	</xsl:function>


	<!-- MANDATE  -->
	
	<!-- URI MEMBERSHIP MANDATE -->	
	<xsl:function name="org-ep:URI-MEMBERSHIPMANDATE">
		<xsl:param name="mepId" />
		<xsl:param name="mandateId" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/resource/person/',$mepId,'/membership-mandate/', $mandateId)" />
	</xsl:function>


	<!-- URI CONSTITUENCY  -->
	<xsl:function name="org-ep:URI-CONSTITUENCY">
		<xsl:param name="countryISOcode"/>
		<xsl:param name="mandateId"/>
		<xsl:value-of select="concat(org-ep:URI-Authority('constituency/'),org-ep:Lookup_COUNTRY($countryISOcode),'-',$mandateId)"/>
	</xsl:function>

	<!-- URI Membership TYPE  -->
	<xsl:function name="org-ep:URI-MembershipType">
		<xsl:param name="idMembershipType"/>
		<xsl:value-of select="org-ep:URI-Authority(concat('membership-type/',$idMembershipType))"/>
	</xsl:function>


	<!-- URI Civiliy-->
	<xsl:function name="org-ep:URI-CIVILITY">
		<xsl:param name="cvCivility" />
		<xsl:value-of select="concat(org-ep:URI-Authority('civility/'), encode-for-uri($cvCivility))" />
	</xsl:function>

	<!-- Contact Point Type electronic-->
	<xsl:function name="org-ep:URI-CONTACT_POINT_TYPE_ELECTRONIC">
		<xsl:param name="ctType" />
		<xsl:value-of select="concat(org-ep:URI-Authority('contact-point-type/electronic/'), $ctType)"/>
	</xsl:function>

	<!-- Contact Point Type place -->
	<xsl:function name="org-ep:URI-CONTACT_POINT_TYPE_PLACE">
		<xsl:param name="ctType" />
		<xsl:value-of select="concat(org-ep:URI-Authority('contact-point-type/place/'), $ctType)"/>
	</xsl:function>

	<!-- Function -->
	<xsl:function name="org-ep:URI-FUNCTION">
		<xsl:param name="functionId" />
		<xsl:value-of select="concat(org-ep:URI-Authority('function/'), $functionId)"/>
	</xsl:function>

	<!-- Organization Type -->
	<xsl:function name="org-ep:URI-OrganizationType">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(org-ep:URI-Authority('org-type/'), $inData)"/>
	</xsl:function>

	<!-- Corporate Body -->
	<xsl:function name="org-ep:URI-COMMITTEEBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(org-ep:URI-Authority('committee-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="org-ep:URI-DELEGATIONBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(org-ep:URI-Authority('delegation-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="org-ep:URI-GOVERNANCEBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(org-ep:URI-Authority('governance-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="org-ep:URI-INSTITUTIONBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(org-ep:URI-Authority('institution-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="org-ep:URI-NATIONALPARTYBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(org-ep:URI-Authority('national-party-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="org-ep:URI-POLITICALGROUPBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(org-ep:URI-Authority('political-group-body/'), $inData)"/>
	</xsl:function>
 	
 	
 	<!-- ***** Activities ***** -->
 	
 	<!-- Generates a LegislationActivity URI from procedure reference, e.g. 'COD-2018-0436', + activity ID -->
 	<xsl:function name="org-ep:URI-LegislativeActivity">
		<xsl:param name="reference" />
		<xsl:param name="activityId" />
		<xsl:value-of select="concat(org-ep:URI-LegislativeProcess($reference), '/event/', $activityId)"/>
	</xsl:function> 	
 	
 	<!-- Generates a LegislationProcess URI from reference, e.g. 'COD-2018-0436' -->
 	<xsl:function name="org-ep:URI-LegislativeProcess">
		<xsl:param name="reference" />
		<xsl:variable name="year" select="tokenize($reference,'-')[2]" />
		<xsl:variable name="number" select="tokenize($reference,'-')[3]" />
		<xsl:variable name="type" select="lower-case(tokenize($reference,'-')[1])" />
		<xsl:value-of select="org-ep:URI-LegislativeProcess($year,$number,$type)"/>
	</xsl:function>
 	
 	<!-- Generates a LegislationProcess URI from year, number, type -->
 	<xsl:function name="org-ep:URI-LegislativeProcess">
		<xsl:param name="year" />
		<xsl:param name="number" />
		<xsl:param name="type" />		
		<xsl:value-of select="concat('http://data.europarl.europa.eu/eli/dl/proc/',$year,'/',$number,'/',$type)" />
	</xsl:function>
 	
 	<!-- ***** Primitive methods ***** -->

	<!-- URI VOCABULARY -->
	<xsl:function name="org-ep:URI-ONTOLOGY">
		<xsl:param name="cv" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/ontology/org-ep#',$cv)" />
	</xsl:function>

	<!-- URI AUTHORITY -->
	<xsl:function name="org-ep:URI-Authority">
		<xsl:param name="uriAutority" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/authority/', $uriAutority)" />
	</xsl:function>

	<!-- URI of a Controlled Vocabulary -->
	<xsl:function name="org-ep:URI-CVEPONTO">
		<xsl:param name="cvId" />
		<xsl:value-of select="org-ep:URI-ONTOLOGY($cvId)" />
	</xsl:function>	
	
	<!-- ***** Lookup Methods ***** -->
	
	<!-- fonction -->
	<xsl:function name="org-ep:Lookup_GENDER">
		<xsl:param name="dataInput" />
		<xsl:variable name="gender" select="$gender_file[
			isoCode = $dataInput
		]"/>
		<xsl:choose>
			<xsl:when test="count($gender) = 0">
				<xsl:message>Warning : cannot find gender "<xsl:value-of select="$dataInput" /></xsl:message>
			</xsl:when>
			<xsl:when test="count($gender) > 1">
				<xsl:message>Warning : find <xsl:value-of select="count($gender)" /> genders named "<xsl:value-of select="$dataInput" /> - Taking first one.</xsl:message>
				<xsl:value-of select="$gender[1]/referenceCode" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$gender[1]/referenceCode" />
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:function>

	<xsl:function name="org-ep:Lookup_TOWN">
		<xsl:param name="in_countryId" />
		<xsl:param name="in_countryIsocode" />
		<xsl:param name="in_BirthPlace" />
		<xsl:variable name="towns" select="$Town[
			countryId = $in_countryId
			and 
			countryIsoCode = $in_countryIsocode
			and
			originalName = $in_BirthPlace
		]" />
		<xsl:choose>
			<xsl:when test="count($towns) = 0">
				<xsl:message>Warning : cannot find Town '<xsl:value-of select="$in_BirthPlace" />' in country "<xsl:value-of select="$in_countryId" />" (<xsl:value-of select="$in_countryIsocode" />)</xsl:message>
			</xsl:when>
			<xsl:when test="count($towns) > 1">
				<xsl:message>Warning : find <xsl:value-of select="count($towns)" /> towns named '<xsl:value-of select="$in_BirthPlace" />' in country "<xsl:value-of select="$in_countryId" />" (<xsl:value-of select="$in_countryIsocode" />) - Taking first one.</xsl:message>
				<xsl:value-of select="$towns[1]/townCode" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$towns[1]/townCode" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="org-ep:Lookup_COUNTRY_ID">
		<xsl:param name="in_townId" />
		<xsl:variable name="town_Id" select="$Town[
			identifier = $in_townId]" />
		<xsl:choose>
			<xsl:when test="count($town_Id) = 0">
				<xsl:message>Warning : cannot find Town Id <xsl:value-of select="$in_townId" />"</xsl:message>
			</xsl:when>
			<xsl:when test="count($town_Id) > 1">
				<xsl:message>Warning : find <xsl:value-of select="count($town_Id)" /> towns Id "<xsl:value-of select="$in_townId" />" - Taking first one.</xsl:message>
				<xsl:value-of select="org-ep:Lookup_COUNTRY($town_Id[1]/countryIsoCode)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="org-ep:Lookup_COUNTRY($town_Id[1]/countryIsoCode)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="org-ep:Lookup_COUNTRY">
		<xsl:param name="in_countryIsocode" />
		<xsl:variable name="country" select="$country_file[
			Alpha-2 = $in_countryIsocode
		]"/>
		<xsl:choose>
			<xsl:when test="count($country) = 0">
				<xsl:message>Warning : cannot find country code "<xsl:value-of select="$in_countryIsocode" />"</xsl:message>
			</xsl:when>
			<xsl:when test="count($country) > 1">
				<xsl:message>Warning : find <xsl:value-of select="count($country)" /> countries named "<xsl:value-of select="$in_countryIsocode" />" -Don't know which one to take.</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$country[1]/Alpha-3" />
			</xsl:otherwise>
		</xsl:choose>			
	</xsl:function>


	<!-- Date -->
	<xsl:function name="org-ep:Lookup_PARLIAMENTARY_TERM">
		<xsl:param name="p_StartDate"/>
		<xsl:param name="p_EndDate"/>
		<!-- cf https://stackoverflow.com/questions/28225257/how-to-subtract-1-day-calculate-day-before-in-xslt-2-0 -->
		<xsl:variable name="StartDateParliamentaryTerm" select="$parliamentaryTerm_file/startDate" as="xsd:dateTime+"/>
		<xsl:variable name="minStartDate" select="min($StartDateParliamentaryTerm)" as="xsd:dateTime"/>
		<xsl:variable name="period_ParliamentaryTerm" select="$parliamentaryTerm_file[			
					xsd:dateTime(startDate) &lt;= xsd:dateTime($p_StartDate)			
					and			
					(xsd:dateTime(endDate) + xsd:dayTimeDuration('P3D')) &gt;= xsd:dateTime($p_EndDate)			
		]"/>
		
		<!-- Si on en trouve 2, on refait le test sans les 3 jours de décalage -->
		
		<xsl:choose>
			<xsl:when test="count($period_ParliamentaryTerm) = 0">
				<xsl:message>Warning : cannot find the parliamentary term encompassing "<xsl:value-of select="$p_StartDate" />" and "<xsl:value-of select="$p_EndDate" />" </xsl:message>
				<xsl:if test="format-dateTime($p_StartDate,'[Y0001]') &lt; format-dateTime($minStartDate,'[Y0001]')">
					<xsl:value-of select="0"/>
				</xsl:if>				
			</xsl:when>
			<xsl:when test="count($period_ParliamentaryTerm) > 1">
				<xsl:variable name="period_ParliamentaryTerm_" select="$parliamentaryTerm_file[			
					xsd:dateTime(startDate) &lt;= xsd:dateTime($p_StartDate)			
					and			
					xsd:dateTime(endDate) &gt;= xsd:dateTime($p_EndDate)]"/>				
				<xsl:message>Warning : find <xsl:value-of select="count($period_ParliamentaryTerm)" /> periods "<xsl:value-of select="$p_StartDate" />" and "<xsl:value-of select="$p_EndDate" />"  - Don't know which one to take.</xsl:message>
				<xsl:value-of select="$period_ParliamentaryTerm_[1]/order"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$period_ParliamentaryTerm[1]/order"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>	

</xsl:stylesheet>