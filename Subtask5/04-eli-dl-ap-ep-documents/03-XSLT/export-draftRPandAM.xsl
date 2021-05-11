<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

	<xsl:template match="/all">		
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="/all/item">
	
		<xsl:variable name="documentReference" select="key[@name = 'reds:reference']" />
		<xsl:variable name="documentType" select="substring-after(key[@name = 'reds:type'], 'reds:')" />
		<xsl:variable name="procedure" select="key[@name = 'reds:hasRelations']/item[key[@name = 'reds:hasPredicate'] = 'reds:hasDirContProc']/key[@name = 'reds:hasObject']/key[@name = 'reds:reference']" />
		
		<xsl:message>Document <xsl:value-of select="$documentReference" />, type <xsl:value-of select="$documentType" />, in procedure <xsl:value-of select="$procedure" /></xsl:message>
	
		<eli-dl:LegislativeProcessWork rdf:about="{org-ep:URI-LegislativeProcessWork($procedure, $documentType, $documentReference)}">
			
			 
		</eli-dl:LegislativeProcessWork>
	</xsl:template>	
	
</xsl:stylesheet>