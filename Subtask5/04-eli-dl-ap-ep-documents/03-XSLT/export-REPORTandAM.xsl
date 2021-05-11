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
		<!-- Process all normal documents -->
		<xsl:apply-templates />
		<!-- Process all erratum documents -->
		<xsl:apply-templates mode="erratum" />
	</xsl:template>
	
	<xsl:template match="/all/item">
	
		<xsl:variable name="currentDocument" select="." />
		<xsl:variable name="documentReference" select="key[@name = 'reds:reference']" />
		<xsl:variable name="documentType" select="substring-after(key[@name = 'reds:type'], 'reds:')" />
		<xsl:variable name="procedures" select="key[@name = 'reds:hasRelations']/item[key[@name = 'reds:hasPredicate'] = 'reds:hasDirContProc']/key[@name = 'reds:hasObject']/key[@name = 'reds:reference']" />
		
		<!-- A document can belong to multiple procedures, so we iterate on procedures -->
		<!-- Exemple of document belonging to multiple procedures : 
			 Document A-8-2019-0076, type iPlRp, in procedure COD-2018-0330 COD-2018-0330A -->
		<xsl:for-each select="$procedures">
			<xsl:variable name="currentProcedure" select="." />
			<xsl:message>Document <xsl:value-of select="$documentReference" />, type <xsl:value-of select="$documentType" />, for procedure <xsl:value-of select="$currentProcedure" /></xsl:message>
	
			<elidl-ep:ReportOnAmendmentsToDraftLegislationWork rdf:about="{org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference)}">
				
				<!-- Select all languages of non-erratum documents -->
				<xsl:for-each select="distinct-values($currentDocument/key[@name = 'reds:hasMedias']/item[
					not(key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR'])		
				]/key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasCode'])">
					
					<xsl:variable name="currentLanguage" select="." />
					<eli:is_realized_by>
						<eli:Expression rdf:about="{concat(org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference), '/', $currentLanguage)}">
							
							<!-- Then iterate on each non-erratum format -->
							<xsl:for-each select="$currentDocument/key[@name = 'reds:hasMedias']/item[ 
								key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasCode'] = $currentLanguage
								and
								not(key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR'])
							]">
								<xsl:variable name="currentFormat" select="key[@name = 'reds:hasFormat']" />
								<eli:is_embodied_by>
									<eli:Manifestation rdf:about="{concat(
										org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
										'/',
										$currentLanguage,
										'/',
										org-ep:manifestationUriComponent($currentFormat)
									)}">
									</eli:Manifestation>
								</eli:is_embodied_by>
							</xsl:for-each>
						</eli:Expression>
					</eli:is_realized_by>	
				</xsl:for-each>					 
			</elidl-ep:ReportOnAmendmentsToDraftLegislationWork>		
		
		</xsl:for-each>
		
		

	</xsl:template>	

	<!-- Exemple de document avec des erratums : 2434199 / A-8-2019-0002, dans la langue anglaise -->
	<!-- http://data.europarl.europa.eu/resource/eli/dl/proc/2018/0114/cod/doc/iPlRp/A-8-2019-0002/en -->	
	<xsl:template match="/all/item[
		key[@name = 'reds:hasMedias']/item/key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasProperties']/item[
			key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR'
		]
	]" mode="erratum">

		<xsl:variable name="currentDocument" select="." />
		<xsl:variable name="documentReference" select="key[@name = 'reds:reference']" />
		<xsl:variable name="documentType" select="substring-after(key[@name = 'reds:type'], 'reds:')" />
		<xsl:variable name="procedures" select="key[@name = 'reds:hasRelations']/item[key[@name = 'reds:hasPredicate'] = 'reds:hasDirContProc']/key[@name = 'reds:hasObject']/key[@name = 'reds:reference']" />

		<xsl:for-each select="$procedures">
			<xsl:variable name="currentProcedure" select="." />
			<xsl:message>Document Erratum <xsl:value-of select="$documentReference" />, type <xsl:value-of select="$documentType" />, for procedure <xsl:value-of select="$currentProcedure" /></xsl:message>
		
			<xsl:variable name="erratum_numbers" select="distinct-values(
				$currentDocument/key[@name = 'reds:hasMedias']/item/key[@name = 'reds:hasLanguages']/item[
					key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR']
				]/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:mediaCategoryItem']/key[@name = 'reds:hasValue']			
			)" />
			
			<xsl:for-each select="$erratum_numbers">
				<xsl:variable name="currentErratumNumber" select="." />
				<xsl:message>  Erratum number <xsl:value-of select="$currentErratumNumber" /></xsl:message>
		
				<elidl-ep:ReportOnAmendmentsToDraftLegislationWork rdf:about="{concat(
					org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
					'/erratum_',
					$currentErratumNumber
				)}">	
				
					<!-- Select all languages of erratum documents -->
					<xsl:for-each select="distinct-values($currentDocument/key[@name = 'reds:hasMedias']/item/key[@name = 'reds:hasLanguages']/item[
						key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR']	
					]/key[@name = 'reds:hasCode'])">
						
						<xsl:variable name="currentLanguage" select="." />
						<xsl:message>  Language <xsl:value-of select="$currentLanguage" /></xsl:message>
						<eli:is_realized_by>
							<eli:Expression rdf:about="{concat(
								org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference), 
								'/erratum_',
								$currentErratumNumber,
								'/', 
								$currentLanguage
							)}">
							
								<!-- Then iterate on each erratum format -->
								<xsl:for-each select="$currentDocument/key[@name = 'reds:hasMedias']/item[ 
									key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasCode'] = $currentLanguage
									and
									key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR']
								]">
								
									<xsl:variable name="currentFormat" select="key[@name = 'reds:hasFormat']" />
									<xsl:message>  Format <xsl:value-of select="$currentFormat" /></xsl:message>
									<eli:is_embodied_by>
										<eli:Manifestation rdf:about="{concat(
											org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
											'/erratum_',
											$currentErratumNumber,
											'/',
											$currentLanguage,
											'/',
											org-ep:manifestationUriComponent($currentFormat)
										)}">
										</eli:Manifestation>
									</eli:is_embodied_by>
								
								</xsl:for-each>
								
							</eli:Expression>
						</eli:is_realized_by>
						
						
					</xsl:for-each>
				
				</elidl-ep:ReportOnAmendmentsToDraftLegislationWork>	
			</xsl:for-each>
			
		</xsl:for-each>
		
		

		
	</xsl:template>
	
</xsl:stylesheet>