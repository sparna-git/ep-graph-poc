<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:ep-org="http://data.europarl.europa.eu/ontology/ep-org#"
>

	<xsl:param name="XML_DIR">../10-XML</xsl:param>

	<!-- Read source file -->
	<xsl:param name="gender_file"
		select="document(concat($XML_DIR, '/', 'Gender.xml'))/all/item" />
	<xsl:param name="Town"
		select="document(concat($XML_DIR, '/', 'Town.xml'))/all/item" />	
	<xsl:param name="parliamentaryTerm_file"
		select="document(concat($XML_DIR, '/', 'parliamentaryTerm.xml'))/all/item" />	
	<xsl:param name="country_file"
		select="document('CountryISO.xml')/root/row" />


	<xsl:function name="ep-org:URI-MEP">
		<xsl:param name="mepId" />
		<xsl:value-of select="ep-org:URI-Person($mepId)" />
	</xsl:function>

	<xsl:function name="ep-org:URI-ASSISTANT">
		<xsl:param name="AssistantId" />
		<xsl:value-of select="ep-org:URI-Person($AssistantId)" />
	</xsl:function>

	<xsl:function name="ep-org:URI-Person">
		<xsl:param name="personId" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/person/', encode-for-uri($personId))" />
	</xsl:function>

	<!-- URI AUTORITY -->
	<xsl:function name="ep-org:URI-Autority">
		<xsl:param name="uriAutority" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/authority/', $uriAutority)" />
	</xsl:function>

	<!-- URI AUTORITY PERSON-->
	<xsl:function name="ep-org:URI-AutorityPERSON">
		<xsl:param name="uriAutority" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/authority/person-type/', $uriAutority)" />
	</xsl:function>

	<!-- URI AUTORITY FUNCTION -->
	<xsl:function name="ep-org:URI-AutorityFUNCTION">
		<xsl:param name="uriFUNCTION" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/authority/function/', $uriFUNCTION)" />
	</xsl:function>

	<!-- URI Organisation (org:Organization) -->
	<xsl:function name="ep-org:URI-Organization">
		<xsl:param name="uriOrganitasation" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/org/', $uriOrganitasation)" />
	</xsl:function>

	<!-- hasOrganization -->
	<xsl:function name="ep-org:URI-Organization">
		<xsl:param name="typeOrganeCode"/>
		<xsl:param name="organeCode"/>
		<xsl:param name="organeId"/>
		<xsl:value-of select="ep-org:URI-Organization(concat($typeOrganeCode,'/',encode-for-uri($organeCode),'-',$organeId))"/>
	</xsl:function>

	<!-- URI PARLAIMENTARY TERM  -->
	<xsl:function name="ep-org:URI-ParliamentaryTerm">
		<xsl:param name="starDate"/>
		<xsl:param name="endDate"/>
		<xsl:value-of select="ep-org:URI-Autority(concat('parliamentary-term/',ep-org:OrderparliamentaryTerm($starDate,$endDate)))"/>
	</xsl:function>

	<!-- MEP  -->

	<!-- URI MEMBERSHIP  -->
	<xsl:function name="ep-org:URI-MEMBERSHIP">
		<xsl:param name="identifier"/>
		<xsl:param name="mandateId"/>
		<xsl:value-of select="concat(ep-org:URI-MEP($identifier),'/membership/',$mandateId)"/>
	</xsl:function>

	<xsl:function name="ep-org:URI-MembershipType">
		<xsl:param name="idMembershipType"/>
		<xsl:value-of select="ep-org:URI-Autority(concat('membership-type/',$idMembershipType))"/>
	</xsl:function>

	<!-- PHOTO -->
	<xsl:function name="ep-org:URI-MEPPHOTO">
		<xsl:param name="identifier"/>
		<xsl:value-of select="concat('www.europarl.europa.eu/mepphoto/',$identifier,'.jpg')"/>
	</xsl:function>

	<!-- GENDER -->
	<xsl:function name="ep-org:URI-MEPGENDER">
		<xsl:param name="IdGender"/>
		<xsl:value-of select="ep-org:URI-Autority(concat('gender/',ep-org:Lookup_GENDER($IdGender)))"/>
	</xsl:function>

	

	<!-- BIRTHPLACE -->
	<xsl:function name="ep-org:URI-MEPBIRTHPLACE">
		<xsl:param name="countryId"/>
		<xsl:param name="countryISOcode"/>
		<xsl:param name="BirthPlace"/>
		<xsl:value-of select="ep-org:URI-Autority(concat(
			'place/',ep-org:Lookup_COUNTRYBIRTHPLACE($countryId,$countryISOcode,$BirthPlace)))"/>
	</xsl:function>

	<!-- NATIONALITY -->
	<xsl:function name="ep-org:URI-MEPNATIONALITY">
		<xsl:param name="countryISOcode"/>
		<xsl:value-of select="ep-org:URI-Autority(concat('country/',ep-org:Lookup_COUNTRY($countryISOcode)))"/>
	</xsl:function>


	<!-- ADDRESSES  -->

	<!-- URI eaddresses  -->
	<xsl:function name="ep-org:eaddresses">
		<xsl:param name="identifier"/>
		<xsl:param name="typeContact"/>
		<xsl:value-of select="concat('http://data.europarl.europa.eu/resource/contact-point/electronic/',$identifier,'/',$typeContact)"/>
	</xsl:function>


	<!-- URI eaddresses ContactType  -->
	<xsl:function name="ep-org:eaddressesContactType">
		<xsl:param name="typeContact"/>
		<xsl:value-of select="concat(ep-org:URI-Autority('contact-point-type/'),$typeContact)"/>
	</xsl:function>	

	<!-- URI addresses  -->
	<xsl:function name="ep-org:addresses">
		<xsl:param name="identifier"/>
		<xsl:param name="office"/>
		<xsl:value-of select="concat('http://data.europarl.europa.eu/resource/contact-point/place/',$identifier,'/',$office)"/>
	</xsl:function>

	<!-- URI PUBLICATION SITE  -->
	<xsl:function name="ep-org:URI-PublicationsSITE">
		<xsl:param name="uriPublications" />
		<xsl:value-of select="concat('http://publications.europa.eu/resource/authority/site/', $uriPublications)" />
	</xsl:function>

	<!-- URI PUBLICATION COUNTRY  -->
	<xsl:function name="ep-org:URI-PublicationsCOUNTRY">
		<xsl:param name="uriPublications" />
		<xsl:value-of select="concat('http://publications.europa.eu/resource/authority/country/', $uriPublications)" />
	</xsl:function>

	<!-- URI PUBLICATION LOCALITY  -->
	<xsl:function name="ep-org:URI-PublicationsLOCALITY">
		<xsl:param name="uriPublications" />
		<xsl:value-of select="concat('http://publications.europa.eu/resource/authority/place/', $uriPublications)" />
	</xsl:function>


	<!-- MANDAT  -->

	<!-- URI CONSTITUENCY  -->
	<xsl:function name="ep-org:URI-MandatCONSTITUENCY">
		<xsl:param name="countryISOcode"/>
		<xsl:param name="mandateId"/>
		<xsl:value-of select="concat(ep-org:URI-Autority('constituency/'),ep-org:Lookup_COUNTRY($countryISOcode),'-',$mandateId)"/>
	</xsl:function>

	<!-- URI TYPE  -->
	<xsl:function name="ep-org:URI-MandatTYPE">
		<xsl:param name="mandateId"/>
		<xsl:value-of select="concat(ep-org:URI-Autority('membership-type/'),$mandateId)"/>
	</xsl:function>

	<!-- URI ORGANIZATION  -->
	<xsl:function name="ep-org:URI-MandatORGANIZATION">
		<xsl:param name="countryISOcode"/>
		<xsl:value-of select="ep-org:URI-Autority(concat('country/',ep-org:Lookup_COUNTRY($countryISOcode)))"/>
	</xsl:function>


	<!-- URI VOCABULARY -->
	<xsl:function name="ep-org:URI-ONTOLOGY">
		<xsl:param name="cv" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/ontology/ep-org#',$cv)" />
	</xsl:function>

	<!-- CV Gender-->
	<xsl:function name="ep-org:URI-CVGENDER">
		<xsl:param name="cvGender" />
		<xsl:value-of select="concat(ep-org:URI-Autority('gender/'), $cvGender)" />
	</xsl:function>

	<!-- CV Civiliy-->
	<xsl:function name="ep-org:URI-CIVILITY">
		<xsl:param name="cvCivility" />
		<xsl:value-of select="concat(ep-org:URI-Autority('civility/'), encode-for-uri($cvCivility))" />
	</xsl:function>


	<!-- URI EPONTO -->
	<xsl:function name="ep-org:URI-CVEPONTO">
		<xsl:param name="cvEPONTOGender" />
		<xsl:value-of select="ep-org:URI-ONTOLOGY($cvEPONTOGender)" />
	</xsl:function>

	<!-- CV Country -->
	<xsl:function name="ep-org:URI-CVCOUNTRY">
		<xsl:param name="cvCountry" />
		<xsl:value-of select="concat(ep-org:URI-Autority('country/'), $cvCountry)" />
	</xsl:function>

	<!-- Contact Point Type electronic-->
	<xsl:function name="ep-org:URI-CVCONT_POINT_T_ELECTRONIC">
		<xsl:param name="cvCTP" />
		<xsl:value-of select="concat(ep-org:URI-Autority('contact-point-type/electronic/'), $cvCTP)"/>
	</xsl:function>

	<!-- Contact Point Type place -->
	<xsl:function name="ep-org:URI-CVCONT_POINT_T_PLACE">
		<xsl:param name="cvCTP" />
		<xsl:value-of select="concat(ep-org:URI-Autority('contact-point-type/place/'), $cvCTP)"/>
	</xsl:function>

	<!-- Contact Point -->
	<xsl:function name="ep-org:URI-ONTO_CONTACTPOINT_T">
		<xsl:param name="cvCTP" />
		<xsl:value-of select="concat(ep-org:URI-ONTOLOGY('contact-point-type/'), $cvCTP)"/>
	</xsl:function>


	<!-- function ou Role -->
	<xsl:function name="ep-org:URI-CVROLE">
		<xsl:param name="cvCTP" />
		<xsl:value-of select="concat(ep-org:URI-Autority('role/'), $cvCTP)"/>
	</xsl:function>

	<!-- Place -->
	<xsl:function name="ep-org:URI-CVPLACE">
		<xsl:param name="cvCTP" />
		<xsl:value-of select="concat(ep-org:URI-Autority('place/'), $cvCTP)"/>
	</xsl:function>

	
	<!-- parliamentary terms -->
	<xsl:function name="ep-org:URI-CVPARLIAMENTARY">
		<xsl:param name="cvCV" />
		<xsl:value-of select="concat(ep-org:URI-Autority('parliamentary-term/'), $cvCV)"/>
	</xsl:function>

	<!-- Organization Type -->
	<xsl:function name="ep-org:URI-CVORGTYPE">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(ep-org:URI-Autority('org-type/'), $inData)"/>
	</xsl:function>

	<!-- Corporate Body -->
	<xsl:function name="ep-org:URI-COMMITTEEBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(ep-org:URI-Autority('committee-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="ep-org:URI-DELEGATIONBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(ep-org:URI-Autority('delegation-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="ep-org:URI-GOVERNANCEBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(ep-org:URI-Autority('governance-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="ep-org:URI-INSTITUTIONBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(ep-org:URI-Autority('institution-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="ep-org:URI-NATIONALPARTYBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(ep-org:URI-Autority('national-party-body/'), $inData)"/>
	</xsl:function>

	<xsl:function name="ep-org:URI-POLITICALGROUPBODY">
		<xsl:param name="inData" />
		<xsl:value-of select="concat(ep-org:URI-Autority('political-group-body/'), $inData)"/>
	</xsl:function>

	
	<!-- fonction -->
	<xsl:function name="ep-org:Lookup_GENDER">
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

	<xsl:function name="ep-org:Lookup_COUNTRYBIRTHPLACE">
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
				<xsl:message>Warning : cannot find town "<xsl:value-of select="$in_BirthPlace" />"" in country <xsl:value-of select="$in_countryId" /> (<xsl:value-of select="$in_countryIsocode" />)</xsl:message>
			</xsl:when>
			<xsl:when test="count($towns) > 1">
				<xsl:message>Warning : find <xsl:value-of select="count($towns)" /> towns named "<xsl:value-of select="$in_BirthPlace" />" in country <xsl:value-of select="$in_countryId" /> (<xsl:value-of select="$in_countryIsocode" />) - Taking first one.</xsl:message>
				<xsl:value-of select="$towns[1]/townCode" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$towns[1]/townCode" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="ep-org:Lookup_COUNTRY">
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
	<xsl:function name="ep-org:OrderparliamentaryTerm">
		<xsl:param name="p_StartDate"/>
		<xsl:param name="p_EndDate"/>
		<!-- TODO : comparer la p_EndDate avec la endDate + 3 jours -->
		<!-- Utiliser <xsl:value-of select="$vToday + xsd:dayTimeDuration('P3D')"/> -->
		<!-- cf https://stackoverflow.com/questions/28225257/how-to-subtract-1-day-calculate-day-before-in-xslt-2-0 -->
		<xsl:variable name="period_ParliamentaryTerm" select="$parliamentaryTerm_file[
			translate(startDate,'-','') &lt;= $p_StartDate
			and
			translate(endDate,'-','') &gt;= $p_EndDate
		]"/>
		<xsl:choose>
			<xsl:when test="count($period_ParliamentaryTerm) = 0">
				<xsl:message>Warning : cannot find the parliamentary term encompassing "<xsl:value-of select="$p_StartDate" />" and <xsl:value-of select="$p_EndDate" /> </xsl:message>
			</xsl:when>
			<xsl:when test="count($period_ParliamentaryTerm) > 1">
				<xsl:message>Warning : find <xsl:value-of select="count($period_ParliamentaryTerm)" /> periods "<xsl:value-of select="$p_StartDate" />" and "<xsl:value-of select="$p_EndDate" />"  - Don't know which one to take.</xsl:message>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$period_ParliamentaryTerm[1]/order"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>	

</xsl:stylesheet>