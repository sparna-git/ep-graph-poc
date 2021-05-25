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
		
		<!-- Fetch the procedure number : in the case of amendment, the procedure needs to be read on the amended text -->
		<xsl:variable name="isAmendmentFor" select="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate'] = 'reds:isAmendmentFor']/key[@name='reds:hasObject']/key[@name='reds:reference']" />			
		<xsl:variable name="procedures" select="
			key[@name = 'reds:hasRelations']/item[key[@name = 'reds:hasPredicate'] = 'reds:hasDirContProc']/key[@name = 'reds:hasObject']/key[@name = 'reds:reference']
			|
			/all/item[key[@name = 'reds:reference'] = $isAmendmentFor]/key[@name = 'reds:hasRelations']/item[key[@name = 'reds:hasPredicate'] = 'reds:hasDirContProc']/key[@name = 'reds:hasObject']/key[@name = 'reds:reference']
		" />
		<xsl:variable name="fdr" select="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:fdr']/key[@name='reds:hasValue']" />
		
		<!-- Keep the first procedure to generate sameAs -->
		<xsl:variable name="firstProcedure">
			<xsl:for-each select="$procedures">
				<xsl:sort select="." />
				<xsl:if test="position() = 1"><xsl:value-of select="." /></xsl:if>
			</xsl:for-each>
		</xsl:variable>
		
		<!-- A document can belong to multiple procedures, so we iterate on procedures -->
		<!-- Exemple of document belonging to multiple procedures : 
			 Document A-8-2019-0076, type iPlRp, in procedure COD-2018-0330 COD-2018-0330A -->
		<xsl:for-each select="$procedures">
			<xsl:sort select="." />
			
			<xsl:variable name="currentProcedure" select="." />
			
			<xsl:choose>
				<xsl:when test="position() = 1">

					<xsl:message>Document <xsl:value-of select="$documentReference" />, type <xsl:value-of select="$documentType" />, for procedure <xsl:value-of select="$currentProcedure" />, fdr <xsl:value-of select="$fdr" /></xsl:message>
					<xsl:comment>Document <xsl:value-of select="$documentReference" />, type <xsl:value-of select="$documentType" />, for procedure <xsl:value-of select="$currentProcedure" />, fdr <xsl:value-of select="$fdr" /></xsl:comment>
			
					<eli-dl:LegislativeProcessWork rdf:about="{org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference)}">
						
						<xsl:apply-templates select="$currentDocument/key"/>
						<xsl:apply-templates select="$currentDocument/key[@name = 'reds:hasProperties']/item"/>
						
						<!-- Work contributions -->
						<xsl:for-each select="$currentDocument/key[@name = 'reds:hasRoles']/item[key[@name = 'reds:hasRolePersonName'] = 'reds:AuthRole_NMCP']">
							<elidl-ep:hasWorkContribution>
								<elidl-ep:WorkContribution rdf:about="{concat(
									org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
									'/work-contribution_',
									position()
								)}">
									<elidl-ep:workContributionHasAgent rdf:resource="{org-ep:URI-Person(key[@name = 'reds:hasPerson']/key[@name = 'reds:hasPersId'])}" />
									<elidl-ep:workContributionRole rdf:resource="http://data.europarl.europa.eu/authority/work-membership-role/rapporteur" />
									<xsl:variable name="inNameOfBody" select="org-ep:URI-Organization-FromMnemoCode(
										key[@name = 'reds:hasBody']/key[@name = 'reds:hasBodyCode'],
										$currentDocument/key[@name = 'reds:dateDeposit']
									)" />
									<xsl:if test="inNameOfBody">
										<elidl-ep:workContributionInNameOf rdf:resource="{$inNameOfBody}" />
									</xsl:if>
								</elidl-ep:WorkContribution>
							</elidl-ep:hasWorkContribution>
						</xsl:for-each>
						
						<!-- Amends links for amendments -->
						<xsl:for-each select="$currentDocument/key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate'] = 'reds:isAmendmentFor']">
							<!-- Note : we suppose the amended document belongs to the same procedure -->
							<elidl-ep:amends rdf:resource="{org-ep:URI-LegislativeProcessWork(
								$currentProcedure,
								substring-after(key[@name='reds:hasObject']/key[@name='reds:type'], 'reds:'),
								key[@name='reds:hasObject']/key[@name='reds:reference']
							)}" />
						</xsl:for-each>
						
						<xsl:apply-templates select="$currentDocument/key[@name = 'reds:hasRoles']/item" />					 
					</eli-dl:LegislativeProcessWork>		


					<!-- Select all languages of non-erratum documents -->
					<xsl:for-each select="distinct-values($currentDocument/key[@name = 'reds:hasMedias']/item[
						not(key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR'])		
					]/key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasCode'])">
						
						<xsl:variable name="currentLanguage" select="." />
						<xsl:variable name="currentLanguage3Letters" select="org-ep:Lookup_Language_3LettersCode($currentLanguage)" />

						<eli:Expression rdf:about="{concat(org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference), '/', $currentLanguage3Letters)}">
							<!-- Link back to work -->
							<eli:realizes rdf:resource="{org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference)}" />
							
							<eli:language rdf:resource="{org-ep:URI-Language($currentLanguage3Letters)}" />
							<!-- Titles (all except UNIFORM-ERR) in proper language -->
							<xsl:apply-templates select="$currentDocument/key[@name = 'reds:hasTitles']/item[
								not(key[@name = 'reds:hasType'] = 'UNIFORM-ERR')
								and
								key[@name = 'reds:hasLanguage'] = $currentLanguage									
							]" />
						</eli:Expression>

						<xsl:if test="$fdr">
							<!-- fetch original language -->
							<xsl:variable name="sourceLang" select="$currentDocument/key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:originalLanguage']/key[@name='reds:hasValue']" />
							
							<!-- create Activity -->
							<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-TranslationActivity_FromDocument($currentProcedure, $documentReference, $currentLanguage3Letters)}">
								<!-- Link activity to target expressions -->
								<eli-dl:created_expression rdf:resource="{concat(org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference), '/', $currentLanguage3Letters)}" />
								<!-- Also link to work -->
								<eli-dl:based_on_a_realization_of rdf:resource="{org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference)}" />
								<!-- Set an Activity type -->
								<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('TRANSLATION')}" />
								<!-- Generate realizesForeseenActivity to the activity description coming from the FDR -->
								<elidl-ep:realizesForeseenActivity rdf:resource="{org-ep:URI-ForeseenTranslationActivity_FromFDR($fdr, $currentLanguage3Letters)}" />
							</eli-dl:LegislativeActivity>
							
						</xsl:if>
						
						<!-- Then iterate on each non-erratum format -->
						<xsl:for-each select="$currentDocument/key[@name = 'reds:hasMedias']/item[ 
							key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasCode'] = $currentLanguage
							and
							not(key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR'])
						]">
							<xsl:variable name="currentFormat" select="key[@name = 'reds:hasFormat']" />
								<eli:Manifestation rdf:about="{concat(
									org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
									'/',
									$currentLanguage3Letters,
									'/',
									org-ep:manifestationUriComponent($currentFormat)
								)}">
									<!-- Link back to Expression -->
									<eli:embodies rdf:resource="{concat(
										org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
										'/',
										$currentLanguage3Letters
									)}" />
									<eli:format rdf:resource="{org-ep:URI-IANA_MediaType($currentFormat)}" />
									<eli:media_type rdf:resource="{org-ep:URI-IANA_MediaType($currentFormat)}" />
									<elidl-ep:manifestationDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="replace(
										key[@name = 'reds:hasLanguages']
										/item[ key[@name = 'reds:hasCode'] = $currentLanguage ]
										/key[@name = 'reds:hasProperties']
										/item[key[@name = 'reds:hasName'] = 'reds:referenceLanguageVersion']
										/key[@name = 'reds:hasValue'],
										' ',
										'T')
									" /></elidl-ep:manifestationDate>
									<eli:is_exemplified_by rdf:resource="{replace(key[@name = 'reds:hasUrl'], '\{LANGUAGE\}',$currentLanguage)}" />
								
								</eli:Manifestation>
						</xsl:for-each><!-- end loop on formats -->
						

					</xsl:for-each><!-- end loop on languages -->
			
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>Document <xsl:value-of select="$documentReference" />, for procedure <xsl:value-of select="$currentProcedure" />, treated as sameAs <xsl:value-of select="$firstProcedure" /></xsl:message>
					<xsl:comment>Document <xsl:value-of select="$documentReference" />, for procedure <xsl:value-of select="$currentProcedure" />, treated as sameAs <xsl:value-of select="$firstProcedure" /></xsl:comment>
					<rdf:Description rdf:about="{org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference)}">
						<owl:sameAs rdf:resource="{org-ep:URI-LegislativeProcessWork($firstProcedure, $documentType, $documentReference)}" />
					</rdf:Description>
				</xsl:otherwise>
			</xsl:choose>
	
		
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
		<xsl:variable name="fdr" select="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:fdr']/key[@name='reds:hasValue']" />

		<!-- Keep the first procedure to generate sameAs -->
		<xsl:variable name="firstProcedure">
			<xsl:for-each select="$procedures">
				<xsl:sort select="." />
				<xsl:if test="position() = 1"><xsl:value-of select="." /></xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:for-each select="$procedures">
			<xsl:sort select="." />
			
			<xsl:variable name="currentProcedure" select="." />
			
			<xsl:variable name="erratum_numbers" select="distinct-values(
				$currentDocument/key[@name = 'reds:hasMedias']/item/key[@name = 'reds:hasLanguages']/item[
					key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR']
				]/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:mediaCategoryItem']/key[@name = 'reds:hasValue']			
			)" />
			
			<xsl:choose>
				<xsl:when test="position() = 1">

					<xsl:message>Document Erratum <xsl:value-of select="$documentReference" />, type <xsl:value-of select="$documentType" />, for procedure <xsl:value-of select="$currentProcedure" /></xsl:message>
					<xsl:comment>Document Erratum <xsl:value-of select="$documentReference" />, type <xsl:value-of select="$documentType" />, for procedure <xsl:value-of select="$currentProcedure" /></xsl:comment>
					
					<xsl:for-each select="$erratum_numbers">
						<xsl:variable name="currentErratumNumber" select="." />
						<xsl:message>  Erratum number <xsl:value-of select="$currentErratumNumber" /></xsl:message>
						<xsl:comment>Erratum number <xsl:value-of select="$currentErratumNumber" /></xsl:comment>
				
						<eli-dl:LegislativeProcessWork rdf:about="{concat(
							org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
							'/erratum_',
							$currentErratumNumber
						)}">	
						
							<xsl:for-each select="$currentDocument/key[@name = 'reds:hasRoles']/item[key[@name = 'reds:hasRolePersonName'] = 'reds:AuthRole_NMCP']">
								<elidl-ep:hasWorkContribution>
									<elidl-ep:WorkContribution rdf:about="{concat(
										org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
										'/erratum_',
										$currentErratumNumber,
										'/work-contribution_',
										position()
									)}">
										<elidl-ep:workContributionHasAgent rdf:resource="{org-ep:URI-Person(key[@name = 'reds:hasPerson']/key[@name = 'reds:hasPersId'])}" />
										<elidl-ep:workContributionRole rdf:resource="http://data.europarl.europa.eu/authority/work-membership-role/rapporteur" />
										<xsl:variable name="inNameOfBody" select="org-ep:URI-Organization-FromMnemoCode(
											key[@name = 'reds:hasBody']/key[@name = 'reds:hasBodyCode'],
											$currentDocument/key[@name = 'reds:dateDeposit']
										)" />
										<xsl:if test="inNameOfBody">
											<elidl-ep:workContributionInNameOf rdf:resource="{$inNameOfBody}" />
										</xsl:if>
									</elidl-ep:WorkContribution>
								</elidl-ep:hasWorkContribution>
							</xsl:for-each>
						
						
							<!-- Generates correction link to the source document -->
							<elidl-ep:workCorrects rdf:resource="{org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference)}" />
						
							<!-- Process all direct attributes, and properties -->
							<xsl:apply-templates select="$currentDocument/key"/>
							<xsl:apply-templates select="$currentDocument/key[@name = 'reds:hasProperties']/item"/>
							<xsl:apply-templates select="$currentDocument/key[@name = 'reds:hasRoles']/item"/>
						
						</eli-dl:LegislativeProcessWork>
						
						
						<!-- Select all languages of erratum documents -->
						<xsl:for-each select="distinct-values($currentDocument/key[@name = 'reds:hasMedias']/item/key[@name = 'reds:hasLanguages']/item[
							key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR']	
						]/key[@name = 'reds:hasCode'])">
						
							<xsl:variable name="currentLanguage" select="." />
								<xsl:variable name="currentLanguage3Letters" select="org-ep:Lookup_Language_3LettersCode($currentLanguage)" />
								<xsl:message>  Language <xsl:value-of select="$currentLanguage" /></xsl:message>
								
								<eli:Expression rdf:about="{concat(
									org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference), 
									'/erratum_',
									$currentErratumNumber,
									'/', 
									$currentLanguage3Letters
								)}">
									<!-- Link back to work -->
									<eli:realizes rdf:resource="{concat(
										org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
										'/erratum_',
										$currentErratumNumber
									)}" />
									
									<eli:language rdf:resource="{org-ep:URI-Language($currentLanguage3Letters)}" />
									<!-- Titles (only UNIFORM-ERR) in proper language -->
									<xsl:apply-templates select="$currentDocument/key[@name = 'reds:hasTitles']/item[
										key[@name = 'reds:hasType'] = 'UNIFORM-ERR'
										and
										key[@name = 'reds:hasLanguage'] = $currentLanguage									
									]" />
									
								</eli:Expression>

								<!-- Then iterate on each erratum format -->
								<xsl:for-each select="$currentDocument/key[@name = 'reds:hasMedias']/item[ 
									key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasCode'] = $currentLanguage
									and
									key[@name = 'reds:hasLanguages']/item/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'red:mediaCategory_ERR']
								]">
								
									<xsl:variable name="currentFormat" select="key[@name = 'reds:hasFormat']" />
									<xsl:message>  Format <xsl:value-of select="$currentFormat" /></xsl:message>
									<eli:Manifestation rdf:about="{concat(
										org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
										'/erratum_',
										$currentErratumNumber,
										'/',
										$currentLanguage3Letters,
										'/',
										org-ep:manifestationUriComponent($currentFormat)
									)}">
										<!-- link back to Expression -->
										<eli:embodies rdf:resource="{concat(
											org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
											'/erratum_',
											$currentErratumNumber,
											'/',
											$currentLanguage3Letters
										)}" />
										<eli:format rdf:resource="{org-ep:URI-IANA_MediaType($currentFormat)}" />
										<eli:media_type rdf:resource="{org-ep:URI-IANA_MediaType($currentFormat)}" />
										<elidl-ep:manifestationDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="replace(
											key[@name = 'reds:hasLanguages']
											/item[ key[@name = 'reds:hasCode'] = $currentLanguage ]
											/key[@name = 'reds:hasProperties']
											/item[key[@name = 'reds:hasName'] = 'reds:referenceLanguageVersion']
											/key[@name = 'reds:hasValue'],
											' ',
											'T')
										" /></elidl-ep:manifestationDate>
										<eli:is_exemplified_by rdf:resource="{replace(key[@name = 'reds:hasUrl'], '\{LANGUAGE\}',$currentLanguage)}" />
									
									</eli:Manifestation>
								
								</xsl:for-each><!-- end loop on formats -->
						
						</xsl:for-each><!-- end loop on languages -->						
							
					</xsl:for-each><!-- end loop on erratum numbers -->
					
				</xsl:when>
				<xsl:otherwise>

					<xsl:message>Document Erratum <xsl:value-of select="$documentReference" />, type <xsl:value-of select="$documentType" />, for procedure <xsl:value-of select="$currentProcedure" />, treated as sameAs <xsl:value-of select="$firstProcedure" /></xsl:message>
					<xsl:comment>Document Erratum <xsl:value-of select="$documentReference" />, type <xsl:value-of select="$documentType" />, for procedure <xsl:value-of select="$currentProcedure" />, treated as sameAs <xsl:value-of select="$firstProcedure" /></xsl:comment>
	
					<xsl:for-each select="$erratum_numbers">
						<xsl:variable name="currentErratumNumber" select="." />
						<xsl:message>  Erratum number <xsl:value-of select="$currentErratumNumber" /></xsl:message>
				
						<rdf:Description rdf:about="{concat(
							org-ep:URI-LegislativeProcessWork($currentProcedure, $documentType, $documentReference),
							'/erratum_',
							$currentErratumNumber
						)}">
							<owl:sameAs rdf:resource="{concat(
								org-ep:URI-LegislativeProcessWork($firstProcedure, $documentType, $documentReference),
								'/erratum_',
								$currentErratumNumber
							)}" />
						</rdf:Description>
					</xsl:for-each>
				
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each>		
	</xsl:template>
	
	<!-- ***** metadata fields ***** -->
	
	<xsl:template match="/all/item/key[@name='dc:identifier']">
		<elidl-ep:legislativeProcessInternId><xsl:value-of select="." /></elidl-ep:legislativeProcessInternId>
	</xsl:template>
	
	<xsl:template match="/all/item/key[@name='reds:reference']">
		<eli-dl:legislative_process_work_id><xsl:value-of select="." /></eli-dl:legislative_process_work_id>
	</xsl:template>
	
	<xsl:template match="/all/item/key[@name='reds:dateDeposit']">
		<eli-dl:legislative_process_work_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="substring(.,1,19)" /></eli-dl:legislative_process_work_date>
	</xsl:template>
	
	<xsl:template match="/all/item/key[@name='reds:type']">
		<eli-dl:legislative_process_work_type rdf:resource="{org-ep:URI-LegislativeProcessWorkType(substring-after(., 'reds:'))}" />
	</xsl:template>
	
	<xsl:template match="/all/item/key[@name='reds:status']">
		<elidl-ep:legislativeProcessWorkStatus rdf:resource="{org-ep:URI-LegislativeProcessWorkStatus(substring-after(., '_'))}" />
	</xsl:template>
	
	<!-- ***** properties ***** -->
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:leg']">
		<elidl-ep:workBelongsToParliamentaryTerm rdf:resource="{org-ep:URI-PARLIAMENTARY_TERM(key[@name='reds:hasValue'])}" />
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:nuPe']">
		<elidl-ep:legislativeProcessWorkIdEp><xsl:value-of select="key[@name='reds:hasValue']" /></elidl-ep:legislativeProcessWorkIdEp>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:nuPeVersion']">
		<elidl-ep:legislativeProcessWorkIdEpVersion><xsl:value-of select="key[@name='reds:hasValue']" /></elidl-ep:legislativeProcessWorkIdEpVersion>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:canonicalReferenceRegister']">
		<elidl-ep:legislativeProcessWorkIdRegister><xsl:value-of select="key[@name='reds:hasValue']" /></elidl-ep:legislativeProcessWorkIdRegister>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:geproType']">
		<elidl-ep:legislativeProcessWorkIdGepro><xsl:value-of select="key[@name='reds:hasValue']" /></elidl-ep:legislativeProcessWorkIdGepro>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:hasIterReference']">
		<elidl-ep:legislativeProcessWorkIdIter><xsl:value-of select="key[@name='reds:hasValue']" /></elidl-ep:legislativeProcessWorkIdIter>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:originalLanguage']">
		<elidl-ep:legislativeProcessWorkOriginalLanguage><xsl:value-of select="key[@name='reds:hasValue']" /></elidl-ep:legislativeProcessWorkOriginalLanguage>
	</xsl:template>
		
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:hasType']">
		<elidl-ep:legislativeProcessWorkTypeDetail><xsl:value-of select="key[@name='reds:hasValue']" /></elidl-ep:legislativeProcessWorkTypeDetail>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:hasFamily']">
		<elidl-ep:legislativeProcessWorkTypeFamily rdf:resource="{org-ep:URI-LegislativeProcessWorkTypeFamily(substring-after(key[@name='reds:hasValue'], '_'))}" />
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:version']">
		<eli-dl:legislative_process_work_version><xsl:value-of select="key[@name='reds:hasValue']" /></eli-dl:legislative_process_work_version>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:itemNumberBegin']">
		<elidl-ep:workItemNumberBegin rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="key[@name='reds:hasValue']" /></elidl-ep:workItemNumberBegin>	
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:itemNumberEnd']">
		<elidl-ep:workItemNumberEnd rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="key[@name='reds:hasValue']" /></elidl-ep:workItemNumberEnd>	
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:hasConcept' and ends-with(key[@name='reds:hasValue'], '^^Eurovoc')]">
		<elidl-ep:legislativeProcessWorkIsAboutEurovoc rdf:resource="{substring-before(key[@name='reds:hasValue'],'^^')}" />	
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:hasConcept' and ends-with(key[@name='reds:hasValue'], '^^SubjectHeading')]">
		<elidl-ep:legislativeProcessWorkIsAboutSubjectHeading rdf:resource="{substring-before(key[@name='reds:hasValue'],'^^')}" />	
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:hasConcept' and ends-with(key[@name='reds:hasValue'], '^^DirectoryCode')]">
		<elidl-ep:legislativeProcessWorkIsAboutDirectoryCode rdf:resource="{substring-before(key[@name='reds:hasValue'],'^^')}" />	
	</xsl:template>
	

	
	<!-- ***** titles ***** -->
	
	<xsl:template match="key[@name='reds:hasTitles']/item[key[@name = 'reds:hasType'] = 'MAIN']">
		<eli:title xml:lang="{key[@name='reds:hasLanguage']}"><xsl:value-of select="key[@name='reds:hasValue']" /></eli:title>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasTitles']/item[key[@name = 'reds:hasType'] = 'SHORT']">
		<eli:title_short xml:lang="{key[@name='reds:hasLanguage']}"><xsl:value-of select="key[@name='reds:hasValue']" /></eli:title_short>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasTitles']/item[key[@name = 'reds:hasType'] = 'UNIFORM']">
		<eli:title_alternative xml:lang="{key[@name='reds:hasLanguage']}"><xsl:value-of select="key[@name='reds:hasValue']" /></eli:title_alternative>
	</xsl:template>
	
	<xsl:template match="key[@name='reds:hasTitles']/item[key[@name = 'reds:hasType'] = 'UNIFORM-ERR']">
		<eli:title xml:lang="{key[@name='reds:hasLanguage']}"><xsl:value-of select="key[@name='reds:hasValue']" /></eli:title>
	</xsl:template>

	
</xsl:stylesheet>