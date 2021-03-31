<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:ep="http://data.europarl.europa.eu/"
>

	<!-- Read source file -->
	<xsl:param name="gender_file"
		select="document('Gender.xml')/all/item" />
	<xsl:param name="country_file"
		select="document('countryISO_.xml')/root/row" />
	<xsl:param name="parliamentaryTerm_file"
		select="document('parliamentaryTerm.xml')/all/item" />	


	<xsl:function name="ep:URI-MEP">
		<xsl:param name="mepId" />
		<xsl:value-of select="ep:URI-Person(concat('mep_', $mepId))" />
	</xsl:function>

	<xsl:function name="ep:URI-ASSISTANT">
		<xsl:param name="AssistantId" />
		<xsl:value-of select="ep:URI-Person(concat('assistant_', $AssistantId))" />
	</xsl:function>

	<xsl:function name="ep:URI-Person">
		<xsl:param name="personId" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/person/', encode-for-uri($personId))" />
	</xsl:function>

	<!-- URI AUTORITY -->
	<xsl:function name="ep:URI-Autority">
		<xsl:param name="uriAutority" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/authority/', $uriAutority)" />
	</xsl:function>

	<!-- URI AUTORITY PERSON-->
	<xsl:function name="ep:URI-AutorityPERSON">
		<xsl:param name="uriAutority" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/authority/person-type/', $uriAutority)" />
	</xsl:function>

	<!-- URI AUTORITY FUNCTION -->
	<xsl:function name="ep:URI-AutorityFUNCTION">
		<xsl:param name="uriFUNCTION" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/authority/function/', $uriFUNCTION)" />
	</xsl:function>

	<!-- URI Organisation (org:Organization) -->
	<xsl:function name="ep:URI-Organization">
		<xsl:param name="uriOrganitasation" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/org/', $uriOrganitasation)" />
	</xsl:function>

	<!-- hasOrganization -->
	<xsl:function name="ep:URI-TYPEOrganization">
		<xsl:param name="typeOrganeCode"/>
		<xsl:param name="organeCode"/>
		<xsl:param name="organeId"/>
		<xsl:value-of select="ep:URI-Organization(concat($typeOrganeCode,'/',$organeCode,'-',$organeId))"/>
	</xsl:function>

	<!-- URI PARLAIMENTARY TERM  -->
	<xsl:function name="ep:URI-ParliamentaryTerm">
		<xsl:param name="starDate"/>
		<xsl:param name="endDate"/>
		<xsl:value-of select="ep:URI-Autority(concat('parliamentary-term/',ep:OrderparliamentaryTerm($starDate,$endDate)))"/>
	</xsl:function>

	<!-- MEP  -->

	<!-- URI MEMBERSHIP  -->
	<xsl:function name="ep:URI-MEMBERSHIP">
		<xsl:param name="identifier"/>
		<xsl:param name="mandateId"/>
		<xsl:value-of select="concat(ep:URI-MEP($identifier),'/membership/',$mandateId)"/>
	</xsl:function>

	<xsl:function name="ep:URI-MembershipType">
		<xsl:param name="idMembershipType"/>
		<xsl:value-of select="ep:URI-Autority(concat('membership-type/',$idMembershipType))"/>
	</xsl:function>

	<!-- PHOTO -->
	<xsl:function name="ep:URI-MEPPHOTO">
		<xsl:param name="identifier"/>
		<xsl:value-of select="concat('www.europarl.europa.eu/mepphoto/',$identifier,'.jpg')"/>
	</xsl:function>

	<!-- GENDER -->
	<xsl:function name="ep:URI-MEPGENDER">
		<xsl:param name="IdGender"/>
		<xsl:value-of select="ep:URI-Autority(concat('gender/',ep:Lookup_GENDER($IdGender)))"/>
	</xsl:function>

	<!-- Civility -->
	<xsl:function name="ep:URI-MEPCIVILITY">
		<xsl:param name="IdCivility"/>
		<xsl:value-of select="ep:URI-Autority(concat('civility/',$IdCivility))"/>
	</xsl:function>

	<!-- BIRTHPLACE -->
	<xsl:function name="ep:URI-MEPBIRTHPLACE">
		<xsl:param name="countryISOcode"/>
		<xsl:param name="BirthPlace"/>
		<xsl:value-of select="ep:URI-Autority(concat('place/', ep:Lookup_COUNTRY($countryISOcode),'_',$BirthPlace))"/>
	</xsl:function>

	<!-- NATIONALITY -->
	<xsl:function name="ep:URI-MEPNATIONALITY">
		<xsl:param name="countryISOcode"/>
		<xsl:value-of select="ep:URI-Autority(concat('country/',ep:Lookup_COUNTRY($countryISOcode)))"/>
	</xsl:function>


	<!-- ADDRESSES  -->

	<!-- URI eaddresses  -->
	<xsl:function name="ep:eaddresses">
		<xsl:param name="identifier"/>
		<xsl:param name="typeContact"/>
		<xsl:value-of select="concat('http://data.europarl.europa.eu/resource/contact-point/electronic/','mep_',$identifier,'/',$typeContact)"/>
	</xsl:function>


	<!-- URI eaddresses ContactType  -->
	<xsl:function name="ep:eaddressesContactType">
		<xsl:param name="typeContact"/>
		<xsl:value-of select="concat(ep:URI-Autority('contact-point-type-type/'),$typeContact)"/>
	</xsl:function>	

	<!-- URI addresses  -->
	<xsl:function name="ep:addresses">
		<xsl:param name="identifier"/>
		<xsl:param name="office"/>
		<xsl:value-of select="concat('http://data.europarl.europa.eu/resource/contact-point/place/','mep_',$identifier,'/',$office)"/>
	</xsl:function>

	<!-- URI PUBLICATION SITE  -->
	<xsl:function name="ep:URI-PublicationsSITE">
		<xsl:param name="uriPublications" />
		<xsl:value-of select="concat('http://publications.europa.eu/resource/authority/site/', $uriPublications)" />
	</xsl:function>

	<!-- URI PUBLICATION COUNTRY  -->
	<xsl:function name="ep:URI-PublicationsCOUNTRY">
		<xsl:param name="uriPublications" />
		<xsl:value-of select="concat('http://publications.europa.eu/resource/authority/country/', $uriPublications)" />
	</xsl:function>

	<!-- URI PUBLICATION LOCALITY  -->
	<xsl:function name="ep:URI-PublicationsLOCALITY">
		<xsl:param name="uriPublications" />
		<xsl:value-of select="concat('http://publications.europa.eu/resource/authority/place/', $uriPublications)" />
	</xsl:function>


	<!-- MANDAT  -->

	<!-- URI CONSTITUENCY  -->
	<xsl:function name="ep:URI-MandatCONSTITUENCY">
		<xsl:param name="countryISOcode"/>
		<xsl:param name="mandateId"/>
		<xsl:value-of select="concat(ep:URI-Autority('constituency/'),ep:Lookup_COUNTRY($countryISOcode),'-',$mandateId)"/>
	</xsl:function>

	<!-- URI TYPE  -->
	<xsl:function name="ep:URI-MandatTYPE">
		<xsl:param name="mandateId"/>
		<xsl:value-of select="concat(ep:URI-Autority('membership-type/'),$mandateId)"/>
	</xsl:function>

	<!-- URI ORGANIZATION  -->
	<xsl:function name="ep:URI-MandatORGANIZATION">
		<xsl:param name="countryISOcode"/>
		<xsl:value-of select="ep:URI-Autority(concat('country/',ep:Lookup_COUNTRY($countryISOcode)))"/>
	</xsl:function>

	


	<!--   -->
	<!-- fonction -->
	<xsl:function name="ep:Lookup_GENDER">
		<xsl:param name="dataInput" />
		<xsl:for-each select="$gender_file">
			<xsl:choose>
				<xsl:when test="isoCode = $dataInput">
					<xsl:value-of select="referenceCode" />
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>		
	</xsl:function>

	<xsl:function name="ep:Lookup_COUNTRY">
		<xsl:param name="dataInput" />
		<xsl:for-each select="$country_file">
			<xsl:choose>
				<xsl:when test="Alpha-2 = $dataInput">
					<xsl:value-of select="Alpha-3" />
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>		
	</xsl:function>

	<xsl:function name="ep:OrderparliamentaryTerm">
		<xsl:param name="p_StartDate"/>
		<xsl:param name="p_EndDate"/>	
		<xsl:for-each select="$parliamentaryTerm_file">
			<xsl:variable name="StartDate" select="translate(startDate,'-','')" />
			<xsl:variable name="EndDate" select="translate(endDate,'-','')" />
			<xsl:if test="$StartDate &lt;= $p_StartDate and $p_EndDate &lt;= $EndDate">
				<xsl:value-of select="order"/>
			</xsl:if>	
		</xsl:for-each>
	</xsl:function>	

</xsl:stylesheet>