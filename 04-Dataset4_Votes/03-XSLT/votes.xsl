<?xml version="1.0" encoding="UTF-8"?>

<!-- Note the version : always work in XSLT 2.0 -->
<!-- Use http://prefix.cc to lookup namespaces -->
<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:eponto="http://data.europarl.europa.eu/ontology/ep#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
>

	<!-- controls output style -->
	<xsl:output method="xml" indent="yes" />
	
	<xsl:variable name="POLITICAL_PARTY_MAPPING_FILE">Mapping-PoliticalgroupId.xml</xsl:variable>
	<xsl:variable name="POLITICAL_PARTY_MAPPING" select="document($POLITICAL_PARTY_MAPPING_FILE)" />
	
	<xsl:variable name="MEP_ID_MAPPING_FILE">mep.xml</xsl:variable>
	<xsl:variable name="MEP_ID_MAPPING" select="document($MEP_ID_MAPPING_FILE)" />


	
	<!-- Matches the XML document -->
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- Matches the root element, create our output root, and recurse on children -->
	<xsl:template match="PV.RollCallVoteResults">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>
	
	<!-- Matches one vote results and generates a corresponding Vote object -->
	<xsl:template match="RollCallVote.Result">
		<eponto:Vote rdf:about="{eponto:URI_Vote(
			translate(/PV.RollCallVoteResults/@Sitting.Date, '-', ''),
			count(preceding-sibling::RollCallVote.Result)+1
		)}">
			
			<skos:prefLabel xml:lang="fr"><xsl:value-of select="RollCallVote.Description.Text" /></skos:prefLabel>
			
			<eponto:voteIdentifier rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="count(preceding-sibling::RollCallVote.Result)+1" /></eponto:voteIdentifier>
			
			<xsl:apply-templates select="
				Result.For/Result.PoliticalGroup.List/PoliticalGroup.Member.Name
				|
				Result.Against/Result.PoliticalGroup.List/PoliticalGroup.Member.Name
				|
				Result.Abstention/Result.PoliticalGroup.List/PoliticalGroup.Member.Name
				|
				Result.For/Result.PoliticalGroup.List/Member.Name
				|
				Result.Against/Result.PoliticalGroup.List/Member.Name
				|
				Result.Abstention/Result.PoliticalGroup.List/Member.Name
			"></xsl:apply-templates>
			
			<eponto:voteFormsPartOfPlenarySitting rdf:resource="{eponto:URI_PlenarySitting(translate(/PV.RollCallVoteResults/@Sitting.Date, '-', ''))}" />
			
		</eponto:Vote>
	</xsl:template>
	
	<xsl:template match="PoliticalGroup.Member.Name | Member.Name">
		<eponto:voteConsistsOfMEPVote>
			
			<xsl:variable name="LOCAL_MEP_ID" select="@MepId" />
			<xsl:variable name="VALID_MEP_ID" select="$MEP_ID_MAPPING/document/record[MEMB_MEP_ID = $LOCAL_MEP_ID]/PERS_ID" />
			
			<eponto:MEPVote rdf:about="{eponto:URI_MEPVote(
				translate(/PV.RollCallVoteResults/@Sitting.Date, '-', ''),
				count(ancestor::RollCallVote.Result/preceding-sibling::RollCallVote.Result)+1,
				concat('MEP_', $VALID_MEP_ID)
			)}">
			
				<!-- Political Group mapping -->
				<xsl:variable name="CURRENT_PG_ID" select="ancestor::Result.PoliticalGroup.List/@Identifier" />
				<xsl:variable 
				name="POLITICAL_GROUP_URI" 
				select="$POLITICAL_PARTY_MAPPING/document/record[Vote_mapping = $CURRENT_PG_ID]/uri" />
			
				<eponto:voteFromPoliticalGroup rdf:resource="{$POLITICAL_GROUP_URI}" />
				
				<!-- MEP mapping -->
				<eponto:voteByMEP rdf:resource="{eponto:URI_MEP($VALID_MEP_ID)}" />
								
				<!-- Vote Position -->
				<xsl:choose>
					<xsl:when test="ancestor::Result.For">
						<eponto:votePosition rdf:resource="http://data.europarl.europa.eu/authority/votePosition/for" />
					</xsl:when>
					<xsl:when test="ancestor::Result.Against">
						<eponto:votePosition rdf:resource="http://data.europarl.europa.eu/authority/votePosition/against" />
					</xsl:when>
					<xsl:when test="ancestor::Result.Abstention">
						<eponto:votePosition rdf:resource="http://data.europarl.europa.eu/authority/votePosition/abstention" />
					</xsl:when>
				</xsl:choose>
				
				<!-- Link back to Vote -->
				<eponto:MEPVoteFormsPartOfVote rdf:resource="{eponto:URI_Vote(
					translate(/PV.RollCallVoteResults/@Sitting.Date, '-', ''),
					count(ancestor::RollCallVote.Result/preceding-sibling::RollCallVote.Result)+1
				)}" />
				
			</eponto:MEPVote>
		</eponto:voteConsistsOfMEPVote>
	</xsl:template>
	
	<!-- Functions to create URIs -->
	
	<xsl:function name="eponto:URI_Vote">
		<xsl:param name="date" />
		<xsl:param name="number" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/eli/dl/iPlMeeting/', $date, '/', $number)" />
	</xsl:function>

	<xsl:function name="eponto:URI_PlenarySitting">
		<xsl:param name="date" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/eli/dl/iPlMeeting/', $date)" />
	</xsl:function>
	
	<xsl:function name="eponto:URI_MEPVote">
		<xsl:param name="date" />
		<xsl:param name="number" />
		<xsl:param name="mep" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/eli/dl/iPlMeeting/', $date, '/', $number, '/', $mep)" />
	</xsl:function>

	<xsl:function name="eponto:URI_PoliticalGroup">
		<xsl:param name="groupId" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/org/group/', encode-for-uri($groupId))" />
	</xsl:function>

	<xsl:function name="eponto:URI_MEP">
		<xsl:param name="MEP_ID" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/person/MEP_', $MEP_ID)" />
	</xsl:function>
	
	<!-- XSLT built-in templates - explicited for clarity -->
	
	<!-- Copies text and attributes -->
	<!--
	<xsl:template match="text() | @*">
		<xsl:value-of select="." />
	</xsl:template>
	 -->
	 <!-- Simply ignore text and comments -->
	<xsl:template match="text() | @*" />
	
	
	<!-- Recurse in all elements, and also from root -->
	<!-- 
	<xsl:template match="*|/">
		<xsl:apply-templates />
	</xsl:template>
	-->
	
	<!-- Ignore comments -->
	<!--
	<xsl:template match="processing-instruction()|comment()" />
	-->
</xsl:stylesheet>