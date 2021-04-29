<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:org-ep="http://data.europarl.europa.eu/ontology/org-ep#"
	xmlns:eli-dl="http://data.europa.eu/eli/eli-draft-legislation-ontology#"
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
		<eli-dl:LegislativeProcess rdf:about="{org-ep:URI-LegislativeProcess(key[@name = 'reds:reference'])}">
			<!-- always create the activity of procedure-creation -->
			<eli-dl:consists_of>
				<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity(key[@name = 'reds:reference'], 'procedure-creation_1')}">

				</eli-dl:LegislativeActivity>
			</eli-dl:consists_of>
			<xsl:apply-templates />
		</eli-dl:LegislativeProcess>
	</xsl:template>
</xsl:stylesheet>