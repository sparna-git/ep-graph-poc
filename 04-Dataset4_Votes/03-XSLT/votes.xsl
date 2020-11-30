<?xml version="1.0" encoding="UTF-8"?>

<!-- Note the version : always work in XSLT 2.0 -->
<!-- Use http://prefix.cc to lookup namespaces -->
<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:eponto="http://data.europarl.europa.eu/ontology/ep#"
>

	<!-- controls output style -->
	<xsl:output method="xml" indent="yes" />
	
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
			
			<xsl:apply-templates select="
				Result.For/Result.PoliticalGroup.List/PoliticalGroup.Member.Name
				|
				Result.Against/Result.PoliticalGroup.List/PoliticalGroup.Member.Name
				|
				Result.Abstention/Result.PoliticalGroup.List/PoliticalGroup.Member.Name
			"></xsl:apply-templates>
			
		</eponto:Vote>
	</xsl:template>
	
	<xsl:template match="PoliticalGroup.Member.Name">
		<eponto:voteConsistsOfMEPVote>
			<eponto:MEPVote rdf:about="{eponto:URI_MEPVote(
				translate(/PV.RollCallVoteResults/@Sitting.Date, '-', ''),
				count(ancestor::RollCallVote.Result/preceding-sibling::RollCallVote.Result)+1,
				concat('MEP_', @MepId)
			)}">
			
			</eponto:MEPVote>
		</eponto:voteConsistsOfMEPVote>
	</xsl:template>
	
	<!-- Functions to create URIs -->
	
	<xsl:function name="eponto:URI_Vote">
		<xsl:param name="date" />
		<xsl:param name="number" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/eli/dl/iPlMeeting/', $date, '/', $number)" />
	</xsl:function>
	
	<xsl:function name="eponto:URI_MEPVote">
		<xsl:param name="date" />
		<xsl:param name="number" />
		<xsl:param name="mep" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/eli/dl/iPlMeeting/', $date, '/', $number, '/', $mep)" />
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