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

	<!--  We have dossier that are amendment dossier. So we need to process only dossier that are main dossier of some procedure -->
	<xsl:template match="/all/item[
		key[@name = 'reds:hasObjectRelations']
		/item[
			key[@name = 'reds:hasPredicate'] = 'reds:hasDirContDossier'
			and
			key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MAIN'
		]
	]">		
	
		<xsl:message><xsl:value-of select="key[@name = 'dc:identifier']" /></xsl:message>
		
		<!-- Find procedure reference : reds:hasPredicate = reds:hasDirContDossier with
		 property reds:hasRoleDossier is red:ComRole_MAIN.
		-->
		<!--  Possibly multiple procedure references -->
		<xsl:variable name="procedureObjectReference" select="
			key[@name = 'reds:hasObjectRelations']
			/item[
				key[@name = 'reds:hasPredicate'] = 'reds:hasDirContDossier'
				and
				key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MAIN'
			]
			" 
		/>
	
		<xsl:for-each select="$procedureObjectReference">

			<xsl:variable name="currentReference" select="." />
			
			<!-- Read reference string -->
			<xsl:variable name="procedureReference" select="
				$currentReference
				/key[@name = 'reds:hasSubject']
				/key[@name = 'reds:reference']
				" 
			/>			
			
			<xsl:message><xsl:value-of select="concat(' ', $procedureReference)" /></xsl:message>
			
			<!-- Find the reading for this reference -->
			<xsl:variable name="reading" select="
				$currentReference
				/key[
					@name = 'reds:hasProperties'
				]
				/item[key[@name = 'reds:hasName'] = 'reds:hasReading']
				/key[@name = 'reds:hasValue']
				" 
			/>

			<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity(
				$procedureReference, 
				concat(
					org-ep:readingReference($reading),
					'/',
					'main-dossier_1'
				)
			)}">	
				<xsl:apply-templates />
			</eli-dl:LegislativeActivity>	
		</xsl:for-each>

			
	</xsl:template>
</xsl:stylesheet>