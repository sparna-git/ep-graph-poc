<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:eli-dl="http://data.europa.eu/eli/eli-draft-legislation-ontology#"
	xmlns:eli="http://data.europa.eu/eli/ontology#"
	xmlns:elidl-ep="http://data.europarl.europa.eu/ontology/elidl-ep#"
	xmlns:ep-aut="http://data.europarl.europa.eu/authority/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl">
	
	<xsl:output indent="yes" method="xml" />

	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="rdf:RDF">

		<xsl:result-document href="translation-activities.rdf" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:copy-of select="attribute::*"/>
				<xsl:copy-of select="eli-dl:LegislativeActivity" />
			</rdf:RDF>		
		</xsl:result-document>
		
		<xsl:result-document href="export-REPORTandAM-documents.rdf" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:copy-of select="attribute::*"/>
				<xsl:copy-of select="* except eli-dl:LegislativeActivity" />
			</rdf:RDF>		
		</xsl:result-document>
	</xsl:template>	
	
	
</xsl:stylesheet>