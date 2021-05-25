<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:eli-dl="http://data.europa.eu/eli/eli-draft-legislation-ontology#"
	xmlns:elidl-ep="http://data.europarl.europa.eu/ontology/elidl-ep#"
	xmlns:ep-aut="http://data.europarl.europa.eu/authority/"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl">
	
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
	
	<xsl:template match="/document">
			<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="/document/record">
		<xsl:variable name="fdrId" select="FDR_Number"/>
		<xsl:variable name="targetLanguage" select="lower-case(normalize-space(Target_Language))"/>		
		<xsl:variable name="Language3Lettre" select="org-ep:Lookup_Language_3LettersCode($targetLanguage)"/>
		<elidl-ep:ForeseenActivity rdf:about="{org-ep:URI-ForeseenTranslationActivity_FromFDR($fdrId,$Language3Lettre)}">
			<elidl-ep:activityId><xsl:value-of select="concat($fdrId,'_',$Language3Lettre)"/></elidl-ep:activityId>
			<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('TRANSLATION')}"/>
			<xsl:apply-templates/>
		</elidl-ep:ForeseenActivity>
	</xsl:template>
	
	
	<!-- Start Date (Entry_Date) -->
	<xsl:template match="Entry_Date">
		<xsl:variable name="Entrydate" select="."/>
		
		<xsl:variable name="day" select="substring($Entrydate,1,2)"/>
		<xsl:variable name="month" select="substring($Entrydate,4,2)"/>
		<xsl:variable name="year" select="substring($Entrydate,7,4)"/>
		<xsl:variable name="heur" select="substring($Entrydate,12,2)"/>
		<xsl:variable name="minut" select="substring($Entrydate,15,2)"/>
		<xsl:variable name="formatDateTime">
			<xsl:value-of select="concat($year,'-',$month,'-',$day,'T',$heur,':',$minut,':','00')"/>
		</xsl:variable>
		
		<eli-dl:activity_start_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
			<xsl:value-of select="$formatDateTime"/>
		</eli-dl:activity_start_date>
		
	</xsl:template>
	
	<!-- Activity Due Date (Due_out_date_TargetLg) -->
	<xsl:template match="Due_out_date_TargetLg">
		<xsl:variable name="Due_date" select="."/>
		
		<xsl:variable name="day" select="substring($Due_date,1,2)"/>
		<xsl:variable name="month" select="substring($Due_date,4,2)"/>
		<xsl:variable name="year" select="substring($Due_date,7,4)"/>
		<xsl:variable name="heur" select="substring($Due_date,12,2)"/>
		<xsl:variable name="minut" select="substring($Due_date,15,2)"/>
		<xsl:variable name="formatDateTime">
			<xsl:value-of select="concat($year,'-',$month,'-',$day,'T',$heur,':',$minut,':','00')"/>
		</xsl:variable>
		
		<elidl-ep:activityDueDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
			<xsl:value-of select="$formatDateTime"/>
		</elidl-ep:activityDueDate>
	</xsl:template>
	
	<!-- Target Language -->
	<xsl:template match="Target_Language">
		<xsl:variable name="currentTargetLanguage" select="lower-case(normalize-space(.))"/>
		<xsl:for-each select="$currentTargetLanguage">
			<xsl:variable name="currentTargetLang" select="."/>
			<xsl:variable name="Language3Lettre" select="org-ep:Lookup_Language_3LettersCode($currentTargetLanguage)"/>
			<elidl-ep:translationRequestedFor rdf:resource="{org-ep:URI-Language($Language3Lettre)}"/>		
		</xsl:for-each>		
	</xsl:template>
	
	 <!-- Language Source List -->
	<xsl:template match="Lang_Source_List">
		<xsl:variable name="currentSourceList" select="tokenize(normalize-space(.),'\s')"/>
		<xsl:for-each select="$currentSourceList">
			<xsl:variable name="currentSource" select="lower-case(.)"/>
			<xsl:variable name="Language3Lettre" select="org-ep:Lookup_Language_3LettersCode($currentSource)"/>
			<elidl-ep:translationRequestedFrom rdf:resource="{org-ep:URI-Language($Language3Lettre)}"/>			
		</xsl:for-each>		
	</xsl:template>
	
</xsl:stylesheet>