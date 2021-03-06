<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
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
	
	
	<!-- Load the dossier data -->
	<xsl:param name="EXPORT_DOSSIER_PATH">../10-XML/export-dossier.xml</xsl:param>
	<!-- Load the draftRPandAM data -->
	<xsl:param name="EXPORT_DRAFTRPANDAM_PATH">../10-XML/export-draftRPandAM.xml</xsl:param>
	<!-- Read source file from CV -->
	<xsl:param name="EXPORT_DOSSIER" select="document($EXPORT_DOSSIER_PATH)" />
	<!-- Read source file DRAFTRPANDAM -->
	<xsl:param name="EXPORT_DRAFTRPANDAM" select="document($EXPORT_DRAFTRPANDAM_PATH)" />

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="/all">		
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="/all/item">
	
		<xsl:variable name="currentProcedureItem" select="." />
		<xsl:variable name="procedureReference" select="key[@name = 'reds:reference']" />
		
		<xsl:message>Procedure <xsl:value-of select="$procedureReference" /></xsl:message>
	
		<eli-dl:LegislativeProcess
			rdf:about="{org-ep:URI-LegislativeProcess($procedureReference)}">
			
			<eli-dl:legislative_process_id><xsl:value-of select="key[@name = 'reds:reference']"/></eli-dl:legislative_process_id>
			<elidl-ep:legislativeProcessInternId><xsl:value-of select="key[@name = 'dc:identifier']"/></elidl-ep:legislativeProcessInternId>
			 
			<!-- Process all titles -->
			<xsl:apply-templates select="key[@name='reds:hasTitles']/item" />
			
			
			<!-- Procedure creation -->
			<xsl:apply-templates select="key[@name='reds:hasRelations']/item" mode="ProcedureCreation"/>

			<eli-dl:legislative_process_number>
				<xsl:value-of
					select="tokenize(key[@name = 'reds:reference'],'-')[last()]" />
			</eli-dl:legislative_process_number>
			<elidl-ep:legislativeProcessYear rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
				<xsl:value-of
					select="tokenize(key[@name = 'reds:reference'],'-')[2]" />
			</elidl-ep:legislativeProcessYear>
			
			
			<elidl-ep:creationDate
				rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
				<xsl:value-of select="substring(key[@name ='reds:dateDeposit'],1,23)" />				
			</elidl-ep:creationDate>
			
			<eli-dl:legislative_process_status rdf:resource="{org-ep:URI-Activity_ProcessStatus(substring-after(key[@name = 'reds:status'],'_'))}"/>	
			
			<!-- This section does reds:hasEpRule -->
			<xsl:variable name="legalBasis" select="key[@name = 'reds:hasRelations']/item[
				key[@name = 'reds:hasPredicate'] = 'reds:hasEpRule']/key[@name = 'reds:hasObject']/key[@name = 'reds:reference']"/>
			<xsl:choose>
				<xsl:when test="count($legalBasis) = 1">
					<eli-dl:had_legal_basis rdf:resource="{org-ep:URI-LegislativeProcessLegalBasis($legalBasis)}"/>
				</xsl:when>
				<xsl:when test="count($legalBasis) &gt; 1">
					<xsl:for-each select="$legalBasis">
						<eli-dl:had_legal_basis rdf:resource="{org-ep:URI-LegislativeProcessLegalBasis(.)}"/>
					</xsl:for-each>
				</xsl:when>				
			</xsl:choose>
			
			<xsl:variable name="ActivityParticipationRole" select="key[@name = 'reds:hasRoles']/item[key[@name = 'reds:hasRolePersonName']= 'reds:Role_CMS']"/>
			<xsl:for-each select="$ActivityParticipationRole">
			    <xsl:variable name="currentAPRole" select="."/>
				<xsl:variable name="i" select="position()"/>
				<elidl-ep:hasActivityParticipation>
					<elidl-ep:ActivityParticipation rdf:about="{org-ep:URI-ActivityParticipation($procedureReference,concat('activity-participation_',$i))}">
						<elidl-ep:activityParticipationHasAgent rdf:resource="{org-ep:URI-ActiviteParticipationResource(concat('person/',$currentAPRole/key[@name='reds:hasPerson']/key[@name='reds:hasPersId']))}"/>
						<elidl-ep:activityParticipationRole rdf:resource="{org-ep:URI-ActiviteParticipation(substring-after($currentAPRole/key[@name = 'reds:hasRolePersonName'],'_'))}"/>
					</elidl-ep:ActivityParticipation>
				</elidl-ep:hasActivityParticipation>
			</xsl:for-each>
						 
			<!-- Find all its readings : look for all main dossier or MHE, and read their readings --> 
			<xsl:variable name="readings" select="
			distinct-values(
				key[@name ='reds:hasRelations']
				/item[
						key[@name = 'reds:hasPredicate'] = 'reds:hasDirContDossier'
						and
						(
							key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MAIN'
							or
							key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MHE'
						)
				]
				/key[@name = 'reds:hasProperties']
				/item[key[@name = 'reds:hasName'] = 'reds:hasReading']
				/key[@name = 'reds:hasValue']
			)
			" />
			
			<xsl:for-each select="$readings">
				<xsl:variable name="currentReading" select="." />
				<xsl:message>  Reading <xsl:value-of select="$currentReading" /></xsl:message>
				<!-- This section building Reading -->
				<eli-dl:consists_of>
					<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($procedureReference,org-ep:readingReference($currentReading))}">
						<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType(substring-after($currentReading,':'))}" />
						<elidl-ep:activityId>
							<xsl:value-of select="concat(lower-case(substring-before(substring-after($currentReading,':'),'_')),'_',substring-after($currentReading,'_'))" />
						</elidl-ep:activityId>
						
						<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">						
							<xsl:value-of select="substring($currentProcedureItem/key[@name = 'reds:dateDeposit'],1,23)"/>
						</eli-dl:activity_date>
						
						
						<xsl:variable name="BaseOnRealization" select="$currentProcedureItem/key[@name = 'reds:hasRelations']/item[
							key[@name = 'reds:hasPredicate'] = 'reds:hasBase_BAS_I']"/>
						<xsl:for-each select="$BaseOnRealization">
							<xsl:variable name="i" select="position()"/>
							<xsl:variable name="doctype" select="substring-after(./key[@name = 'reds:hasObject']/key[@name = 'reds:type'],':')"/>
							<xsl:variable name="docId" select="./key[@name = 'reds:hasObject']/key[@name = 'reds:reference']"/>
							<eli-dl:based_on_a_realization_of rdf:resource="{org-ep:URI-LegislativeProcessWork($procedureReference,$doctype,$docId)}"/>
							
							<xsl:variable name="WorkRole" select="$BaseOnRealization/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasDocumentUse']/key[@name = 'reds:hasValue']"/>
								<xsl:for-each select="$WorkRole">
									<elidl-ep:hasBaseBas_I>								
											<xsl:variable name="currentWorkRole" select="."/>
											<elidl-ep:InvolvedWork rdf:about="{concat(org-ep:URI-LegislativeActivity($procedureReference,org-ep:readingReference($currentReading)),'/involved-work_',$i)}">
												<xsl:if test="$WorkRole != ''">
													<elidl-ep:involvedWorkRole rdf:resource="{org-ep:URI-InvolvedWork($currentWorkRole)}"/>
												</xsl:if>
												<elidl-ep:hasWorkInvolved rdf:resource="{org-ep:URI-LegislativeProcessWork($procedureReference,$doctype,$docId)}"/>
											</elidl-ep:InvolvedWork>
									</elidl-ep:hasBaseBas_I>
								</xsl:for-each>
						</xsl:for-each>	
						
						<!-- Now within that reading of that procedure, find all main dossiers, there could be multiple -->						
						<xsl:apply-templates select="$currentProcedureItem
								/key[@name ='reds:hasRelations']
								/item[
									key[@name = 'reds:hasPredicate'] = 'reds:hasDirContDossier'
									and
									(
										key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MAIN'
										or
										key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MHE'
									)
									and
									key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue'] = $currentReading
						]"/>
						
						
						
						<!-- Now within that reading of that procedure, find all plenary dossiers, there could be multiple -->						
						<xsl:variable name="indexPRVPL" select="concat('reds:hasEventType_PRVPL_',substring-after($currentReading,'_'))"/>  
						<xsl:variable name="indexiPlRp" select="concat('reds:hasiPlRp_',substring-after($currentReading,'_'))"/>
						<xsl:variable name="PlenaryData" select="$currentProcedureItem
								/key[@name ='reds:hasRelations']
								/item[
									key[@name = 'reds:hasPredicate'] = $indexPRVPL
									and
									key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue'] = $currentReading									
						]"/>
						
						<xsl:for-each select="$PlenaryData">
							<xsl:variable name="index_plenaryDossier" select="position()"/>
							<xsl:variable name="currentPlenary" select="."/>
							
							<xsl:variable name="currentReference" select="../item[key[@name = 'reds:hasPredicate'] = 'reds:hasDirContDossier'
							and
									(
										key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MAIN'
										or
										key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MHE'
									)	
									and
									key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue'] = $currentReading
							]/key[@name = 'reds:hasObject']
							" />
							
							
							<xsl:variable name="dossierRealizationOf" select="$currentProcedureItem
								/key[@name ='reds:hasRelations']
								/item[
									key[@name = 'reds:hasPredicate'] = $indexiPlRp]/key[@name = 'reds:hasObject']"/>
									
							<!--The plenary dossier -->
							<eli-dl:consists_of>	
								<eli-dl:LegislativeActivity
										rdf:about="{org-ep:URI-LegislativeActivity($procedureReference,concat(org-ep:readingReference($currentReading), '/', 'plenary-dossier_', $index_plenaryDossier))}">						
										
									<!-- Find the document in the dossier export -->
									<xsl:for-each select="$currentReference/key[@name='reds:reference']">
										<xsl:variable name="reference" select="."/>
										<elidl-ep:activityId>
												<xsl:value-of select="$reference"/>
										</elidl-ep:activityId>
									</xsl:for-each>
									
									<!--  
									<xsl:variable name="dateReg" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name = 'reds:hasRelations']/item[
												key[@name = 'reds:hasPredicate'] = 'reds:hasEventType_PRVPL_I'
												and
												key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']
											]"/>
											
											 
									<xsl:variable name="StartDate">
										<xsl:for-each select="$dateReg/key[@name = 'reds:hasDate']">
											<xsl:sort select="number(substring(.,1,4))" data-type="number" order="ascending"/>
											<xsl:sort select="number(substring(.,6,2))" data-type="number" order="ascending"/>
											<xsl:sort select="number(substring(.,9,2))" data-type="number" order="ascending"/>
											<xsl:if test="position() = 1">
												<xsl:value-of select="."/>
											</xsl:if>
										</xsl:for-each>
									</xsl:variable>
									
									<xsl:variable name="LastDate">
										<xsl:for-each select="$dateReg/key[@name = 'reds:hasDate']">
											<xsl:sort select="number(substring(.,1,4))" data-type="number" order="descending"/>
											<xsl:sort select="number(substring(.,6,2))" data-type="number" order="descending"/>
											<xsl:sort select="number(substring(.,9,2))" data-type="number" order="descending"/>
											<xsl:if test="position() = 1">
												<xsl:value-of select="."/>
											</xsl:if>
										</xsl:for-each>
									</xsl:variable>
											  
									<xsl:if test="$StartDate != ''">
										<eli-dl:activity_start_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
											<xsl:value-of select="$StartDate"/>
										</eli-dl:activity_start_date>
									</xsl:if>
									-->	
									
									<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
											<xsl:value-of select="substring($currentPlenary/key[@name='reds:hasDate'],1,23)"/>
									</eli-dl:activity_date>
									
									<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType(substring-after($indexPRVPL,'_'))}"/>	
									
									<xsl:for-each select="$dossierRealizationOf">
										<xsl:variable name="currentDossierRealizationOf" select="."/>
										<xsl:variable name="doctype" select="substring-after(key[@name = 'reds:type'],':')"/>
										<xsl:variable name="docId" select="key[@name = 'reds:reference']"/>								
										<eli-dl:based_on_a_realization_of rdf:resource="{org-ep:URI-LegislativeProcessWork($procedureReference,$doctype,$docId)}"/>
										
									</xsl:for-each>	
								</eli-dl:LegislativeActivity>				
							</eli-dl:consists_of>
						</xsl:for-each>	
						
						<!-- Now within that reading of that procedure, find all consolidation dossiers, there could be multiple -->
						<xsl:variable name="indexDCPL" select="concat('reds:hasEventType_DCPL_',substring-after($currentReading,'_'))"/>  
						<xsl:variable name="ConsolidationData" select="$currentProcedureItem
								/key[@name ='reds:hasRelations']
								/item[
									key[@name = 'reds:hasPredicate'] = $indexDCPL
									and
									key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue'] = $currentReading
									]"/>
						<xsl:for-each select="$ConsolidationData">
							<xsl:variable name="index" select="position()"/>
							<eli-dl:consists_of>	
								<eli-dl:LegislativeActivity
									rdf:about="{org-ep:URI-LegislativeActivity($procedureReference,concat(org-ep:readingReference($currentReading), '/', 'consolidation_', $index))}">						
							
									<elidl-ep:activityId><xsl:value-of select="substring-after(key[@name = 'reds:hasPredicate'],'_')"/></elidl-ep:activityId>
									<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType(substring-after(key[@name = 'reds:hasPredicate'],'_'))}"/>
									<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="substring(key[@name = 'reds:hasDate'],1,23)"/></eli-dl:activity_date>
						
								</eli-dl:LegislativeActivity>
							</eli-dl:consists_of>
						</xsl:for-each>
						
							
					</eli-dl:LegislativeActivity>
				</eli-dl:consists_of>
			</xsl:for-each>

			
			<!-- Process all properties -->
			<xsl:apply-templates select="key[@name ='reds:hasProperties']/item"/>
			
			<!-- Process all relations -->
			<xsl:apply-templates select="key[@name ='reds:hasRelations']/item" mode="dossier"/>
		 
		</eli-dl:LegislativeProcess>
	</xsl:template>	
	
	<!-- Match property reds:hasType -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:hasType']">
		<eli-dl:legislative_process_type
						rdf:resource="{org-ep:URI-LegislativeProcessType(key[@name='reds:hasValue'])}" />
	</xsl:template>
	
	<!-- Match property reds:hasNature -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:hasNature']">
		<elidl-ep:legislativeProcessNature
							rdf:resource="{org-ep:URI-LegislativeProcessNature(key[@name='reds:hasValue'])}" />
	</xsl:template>
	
	<!-- Match property reds:phase -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:phase']">
		<eli-dl:current_stage
							rdf:resource="{org-ep:URI-ProcessStage(substring-after(key[@name='reds:hasValue'],'_'))}" />
	</xsl:template>
	
	<!-- Match property eli-dl:latest_activity with reds:hasReading -->
	<!-- Attention: Il y a plusieur reds:hasReading -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:hasReading']">
		
		<xsl:variable name="procedureReference" select="../../key[@name = 'reds:reference']" />
		<xsl:variable name="hasReadingP" select="key[@name='reds:hasValue']"/>
		
		<xsl:variable name="hasReading" select="concat(lower-case(substring-before(substring-after(key[@name='reds:hasValue'],':'),'_')),'_',substring-after(substring-after(key[@name='reds:hasValue'],':'),'_'))"/>
		<eli-dl:latest_activity
							rdf:resource="{org-ep:URI-LegislativeActivity($procedureReference,$hasReading)}" />
	</xsl:template>	
	
	<!-- Match property reds:subPhase -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:subPhase']">
		<xsl:variable name="sNumberLeft" select="substring-before(substring-after(key[@name='reds:hasValue'],'_'),'-')"/>
		<xsl:variable name="sNumberRigth" select="substring-after(substring-after(key[@name='reds:hasValue'],'_'),'-')"/>
		<xsl:variable name="NumberLeft">
			<xsl:choose>
				<xsl:when test="number($sNumberLeft) &lt; 10">
					<xsl:value-of select="concat('0',$sNumberLeft)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sNumberLeft"/>
				</xsl:otherwise>
			</xsl:choose>				
		</xsl:variable>
		<xsl:variable name="NumberRigth">
			<xsl:choose>
				<xsl:when test="number($sNumberRigth) &lt; 10">
					<xsl:value-of select="concat('0',$sNumberRigth)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sNumberRigth"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="SubPhase" select="concat($NumberLeft,'-',$NumberRigth)"/>
		<elidl-ep:currentSubStage
							rdf:resource="{org-ep:URI-ProcessStage($SubPhase)}" />
	</xsl:template>
	
	<!-- Match property reds:LegislativeActType -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:LegislativeActType']">
		<eli-dl:foreseen_type_document
							rdf:resource="{org-ep:URI-LegalResourceType(key[@name='reds:hasValue'])}" />
	</xsl:template>
	
	<!-- Match property reds:legalBase -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:legalBase']">
		<xsl:message>Found reds:legalBase <xsl:value-of select="key[@name='reds:hasValue']" /></xsl:message>
		<xsl:variable name="currentLegalBase" select="key[@name='reds:hasValue']"/>
		<xsl:if test="$currentLegalBase != ''">
			<eli-dl:had_legal_basis rdf:resource="{org-ep:URI-LegislativeProcessLegalBase($currentLegalBase)}"/>	
		</xsl:if>		
	</xsl:template>
	
	<!-- Match relation to procedure creation -->
	<xsl:template match="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:hasEventType_PROCR']" mode="ProcedureCreation">
		<eli-dl:consists_of>
			<eli-dl:LegislativeActivity
				rdf:about="{org-ep:URI-LegislativeActivity(../../key[@name = 'reds:reference'], 'procedure-creation_1')}">
				<xsl:variable name="Data_ProcedureCreation" select="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:hasEventType_PROCR']"/>
				<elidl-ep:activityId><xsl:value-of select="substring-after(key[@name='reds:hasPredicate'],'_')"/></elidl-ep:activityId>
				<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType(substring-after(key[@name='reds:hasPredicate'],'_'))}"/>
				<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
					<xsl:value-of select="substring(key[@name='reds:hasDate'],1,23)"/>					
				</eli-dl:activity_date>
			</eli-dl:LegislativeActivity>
		</eli-dl:consists_of>
	</xsl:template>
	
	
	<xsl:template match="key[@name='reds:hasTitles']/item">
		<eli-dl:legislative_process_title
			xml:lang="{key[@name='reds:hasLanguage']}">
			<xsl:value-of select="key[@name='reds:hasValue']" />			
		</eli-dl:legislative_process_title>
	</xsl:template>
	
	<!-- Match relation to a MAIN dossier -->
	<xsl:template match="key[@name ='reds:hasRelations']/item[
			key[@name = 'reds:hasPredicate'] = 'reds:hasDirContDossier'
			and
			(
				key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MAIN'
				or
				key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MHE'
			)
	]">
		
		<xsl:variable name="currentIdentifier" select="key[@name = 'reds:hasObject']/key[@name = 'dc:identifier']" />
		<xsl:variable name="currentReference" select="key[@name = 'reds:hasObject']/key[@name = 'reds:reference']" />
		
		<xsl:message>  Dossier <xsl:value-of select="$currentIdentifier" /> / reference <xsl:value-of select="$currentReference" /></xsl:message>
		<xsl:variable name="idReading" select="./key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue']"/>
			

		<!-- Now we need to find the _index_ of this dossier within the same reading of the same procedure -->
		<!-- To do that we count the number of other dossiers in same procedure and same reading, that have an id before this one -->
		<!-- Test case : BUD-2019-2028 -->
		<xsl:variable name="index" select="
			count(
				../item[
					key[@name = 'reds:hasPredicate'] = 'reds:hasDirContDossier'
					and
					(
						key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MAIN'
						or
						key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MHE'
					)
					and
					key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue'] = $idReading
					and
					key[@name = 'reds:hasObject']/key[@name = 'dc:identifier'] &lt; $currentIdentifier				
				]			
			)
			+ 1
		" />	
		
		<xsl:message>  Index <xsl:value-of select="$index" /> </xsl:message>
		
		<xsl:variable name="ProcedureReference" select="../../key[@name = 'reds:reference']"/>
		
		
		
		<!-- The main dossier -->
		<eli-dl:consists_of>	
			<eli-dl:LegislativeActivity
				rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index))}">						
				
				<!-- Find the document in the dossier export -->
				<xsl:apply-templates select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]" mode="dossier" />	
				
				<!-- Code for the consist of main -->
				
				<!-- AppointmentOfRapporteur -->	
				<xsl:variable name="appRapporteur" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:hasEventType_NMCP']"/>	
				<xsl:for-each select="$appRapporteur">
					<eli-dl:consists_of>
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/app-rapporteur_',position()))}">
							<eli-dl:activity_label>Appointment of rapporteur</eli-dl:activity_label>
							<elidl-ep:activityId><xsl:value-of select="substring-after(key[@name='reds:hasPredicate'],'_')"/></elidl-ep:activityId>
							<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType(substring-after(key[@name='reds:hasPredicate'],'_'))}"/>
							<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="substring(key[@name='reds:hasDate'],1,23)"/></eli-dl:activity_date>
						</eli-dl:LegislativeActivity>
					</eli-dl:consists_of>
				</xsl:for-each>
				
				<!-- TablingDraftReport -->
				<xsl:variable name="idReference_OtherRAP" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name ='reds:hasRelations']/item[
						key[@name = 'reds:hasPredicate'] = 'reds:hasOther_RAP'
						and
						(
						key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasDocumentUse']
						and
						key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'BAC']
						)
					]/key[@name = 'reds:hasObject']/key[@name = 'reds:reference']"/>

				<xsl:for-each select="$idReference_OtherRAP">
					<xsl:sort select="." data-type="text" order="ascending"/>
					
					<xsl:variable name="currentIdReference" select="."/>
					<xsl:variable name="index_tabling" select="position()"/>
					<xsl:variable name="dataDRAFTRPANDAM" select="$EXPORT_DRAFTRPANDAM/all/item[key[@name = 'reds:reference'] = $currentIdReference]"/>
					
					<eli-dl:consists_of>
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/tabling-draft-report_',$index_tabling))}">
							<elidl-ep:activityId><xsl:value-of select="$currentIdReference"/></elidl-ep:activityId>
							<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('TABLING_DRAFT_REPORT')}"/>
							<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="substring($dataDRAFTRPANDAM/key[@name = 'reds:dateDeposit'],1,23)"/></eli-dl:activity_date>
							
							
							
							<xsl:variable name="WorkRole" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name ='reds:hasRelations']/item[
													key[@name = 'reds:hasPredicate'] = 'reds:hasOther_RAP'
													and
													(
													key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasDocumentUse']
													and
													key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'BAC']
													)
												]"/>
							<xsl:for-each select="$WorkRole">
								<xsl:variable name="currentRole_RAP" select="."/>
								<xsl:variable name="index_involved" select="position()"/>	
							 	<elidl-ep:hasOtherRap>
							 		<elidl-ep:InvolvedWork rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/tabling-draft-report_',$index_tabling,'/involved-work_',$index_involved))}">
										<elidl-ep:involvedWorkRole rdf:resource="{org-ep:URI-InvolvedWork($currentRole_RAP/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasDocumentUse']/key[@name= 'reds:hasValue'])}"/>
										<xsl:variable name="doctype" select="$currentRole_RAP/key[@name = 'reds:hasObject']/key[@name='reds:type']"/>
										<xsl:variable name="docId" select="$currentRole_RAP/key[@name = 'reds:hasObject']/key[@name='reds:reference']"/>
										<elidl-ep:hasWorkInvolved rdf:resource="{org-ep:URI-LegislativeProcessWork($ProcedureReference,substring-after($doctype,':'),$docId)}"/>
									</elidl-ep:InvolvedWork>
								</elidl-ep:hasOtherRap>								
							</xsl:for-each>
							
							<eli-dl:involved_work rdf:resource="{org-ep:URI-LegislativeProcessWork($ProcedureReference,substring-after($dataDRAFTRPANDAM/key[@name = 'reds:type'],':'),$dataDRAFTRPANDAM/key[@name = 'reds:reference'])}"/>
							
						</eli-dl:LegislativeActivity>
					</eli-dl:consists_of>					
				</xsl:for-each>
				
				<!-- TablingAmendments  -->
				<xsl:variable name="idReference_OtherAME" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name ='reds:hasRelations']/item[
						key[@name = 'reds:hasPredicate'] = 'reds:hasOther_AME'
						and
						(
						key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasDocumentUse']
						and
						key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = 'BAC']
						)
					]/key[@name = 'reds:hasObject']/key[@name = 'reds:reference']"/>
					
					<xsl:for-each select="$idReference_OtherAME">
						<xsl:sort select="." data-type="text" order="ascending"/>	
						
						<xsl:variable name="currentIdReference" select="."/>
						<xsl:variable name="index_OtherAME" select="position()"/>
						<xsl:variable name="dataDRAFTRPANDAM" select="$EXPORT_DRAFTRPANDAM/all/item[key[@name = 'reds:reference'] = $currentIdReference]"/>
						
						<eli-dl:consists_of>
							<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/tabling-amendment_',$index_OtherAME))}">
								<elidl-ep:activityId><xsl:value-of select="$currentIdReference"/></elidl-ep:activityId>
								<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('COMMITTEE_AMENDMENT')}"/>
								<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="substring($dataDRAFTRPANDAM/key[@name = 'reds:dateDeposit'],1,23)"/></eli-dl:activity_date>
								
								<!-- InvolvedWork of TablingAmendments -->
								<xsl:variable name="involvedWork_AME" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name ='reds:hasRelations']/item[
									key[@name = 'reds:hasPredicate'] = 'reds:hasOther_AME'
									and
									key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasDocumentUse']/key[@name = 'reds:hasValue'] = 'BAC'
									]"/>
									
								<xsl:for-each select="$involvedWork_AME">
									<xsl:variable name="index_involved" select="position()"/>
									<xsl:variable name="current_iw_AME" select="."/>
									<elidl-ep:hasOtherAme>
										<elidl-ep:InvolvedWork rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/tabling-amendment_',$index_OtherAME,'/involved-work_',$index_involved))}">
											   
											<elidl-ep:involvedWorkRole rdf:resource="{org-ep:URI-InvolvedWork($current_iw_AME/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasDocumentUse']/key[@name= 'reds:hasValue'])}"/>
											 
											<xsl:variable name="doctype" select="$current_iw_AME/key[@name = 'reds:hasObject']/key[@name='reds:type']"/>
											<xsl:variable name="docId" select="$current_iw_AME/key[@name = 'reds:hasObject']/key[@name='reds:reference']"/>
											<elidl-ep:hasWorkInvolved rdf:resource="{org-ep:URI-LegislativeProcessWork($ProcedureReference,substring-after($doctype,':'),$docId)}"/>
											
										</elidl-ep:InvolvedWork>
									</elidl-ep:hasOtherAme>
								</xsl:for-each>
								
								
								<eli-dl:involved_work rdf:resource="{org-ep:URI-LegislativeProcessWork($ProcedureReference,substring-after($dataDRAFTRPANDAM/key[@name = 'reds:type'],':'),$dataDRAFTRPANDAM/key[@name = 'reds:reference'])}"/>						    
							</eli-dl:LegislativeActivity>	
						</eli-dl:consists_of>
					</xsl:for-each>
					
					
				
				<!-- committee-debate -->
				<xsl:variable name="CommitteDebate" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name ='reds:hasObjectRelations']/item[
					key[@name = 'reds:hasPredicate'] = 'reds:hasMeetingDocument'
				]"/>
				<xsl:if test="$CommitteDebate">					
					<xsl:for-each select="$CommitteDebate">
						<xsl:sort select="key[@name = 'reds:hasSubject']/key[@name = 'reds:reference']" data-type="text" order="ascending"/>
						<xsl:variable name="currentCommitteDebate" select="."></xsl:variable>
							
						
						<eli-dl:consists_of>
							<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/committee-debate_',position()))}">
								<elidl-ep:activityId><xsl:value-of select="$currentCommitteDebate/key[@name = 'reds:hasSubject']/key[@name = 'reds:reference']"/></elidl-ep:activityId>
								<xsl:variable name="dateCommitte" as="xsd:dateTime">
									<xsl:analyze-string regex="[0-9]+\-[0-9]+\-[0-9]+\-[0-9]$" select="$currentCommitteDebate/key[@name = 'reds:hasSubject']/key[@name = 'reds:reference']">
										<xsl:matching-substring>
											<xsl:value-of select="concat(substring(.,1,10),'T00:00:00')"/>
										</xsl:matching-substring>
									</xsl:analyze-string>
								</xsl:variable>
								
								
								<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="format-dateTime($dateCommitte,'[Y]-[M00]-[D00]T[H00]:[m00]:[s00]')"/></eli-dl:activity_date>
								<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('COMMITTEE_DEBATE')}"/>
							</eli-dl:LegislativeActivity>
						</eli-dl:consists_of>
					</xsl:for-each>
				</xsl:if>
				
				
				<!-- committee-vote  -->
				<xsl:variable name="voteRelation" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name ='reds:hasRelations']/item[
						key[@name = 'reds:hasPredicate'] = 'reds:hasVoteResult'
						]"/>
				
				<xsl:variable name="voteObjectRelation" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name ='reds:hasObjectRelations']/item[
					key[@name = 'reds:hasPredicate'] = 'reds:hasDirContDossier'
					and
					key[@name = 'reds:hasSubject']/key[@name = 'reds:type'] = 'reds:iPlRp'
					and
					(
					key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']
					and
					key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasValue'] = $idReading]
					)				
				]"/>	
				<xsl:variable name="VoteResult_Committee" select="$voteRelation/key[@name= 'reds:hasProperties']"/>
				
				
				<eli-dl:consists_of>
					<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/committee-vote_1'))}">
							<elidl-ep:activityId>VOTE</elidl-ep:activityId>
							<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('COMMITTEE_VOTE')}"/>
							
							<xsl:if test="$voteRelation/key[@name = 'reds:hasDate']">
								<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="substring($voteRelation/key[@name = 'reds:hasDate'],1,23)"/></eli-dl:activity_date>
							</xsl:if>	
											
							<elidl-ep:activityHasVoteResults>
								<elidl-ep:Vote rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/committee-vote_1','/','result'))}">
									<xsl:if test="$voteRelation/key[@name = 'reds:hasDate']">
										<elidl-ep:voteDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="substring($voteRelation/key[@name = 'reds:hasDate'],1,23)"/></elidl-ep:voteDate>
									</xsl:if>
									<xsl:apply-templates select="$VoteResult_Committee/item" mode="vote" />
								</elidl-ep:Vote>
							</elidl-ep:activityHasVoteResults>
							
							<!-- We don't always have the reference to the document -->
							<xsl:if test="$voteObjectRelation">
								<eli-dl:created_a_realization_of rdf:resource="{org-ep:URI-Involved(
									$ProcedureReference,
									$voteObjectRelation/key[@name = 'reds:hasSubject']/key[@name = 'reds:type'],
									$voteObjectRelation/key[@name = 'reds:hasSubject']/key[@name = 'reds:reference']
								)}"/>
							</xsl:if>
					</eli-dl:LegislativeActivity>
				</eli-dl:consists_of>
				
				
				<!-- the section search all roles -->
				
				<xsl:variable name="CommitteeRoles" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRoles']/item[
					key[@name='reds:hasRoleBodyName']='reds:hasCommittee'
					and 
					key[@name='reds:hasBody']
				]"/>
				
				<xsl:variable name="dateDepositDossier" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:dateDeposit']"/>
				
				<!-- Responsible Activity Participation -->
				<xsl:for-each select="$CommitteeRoles">
					<!-- Look for the code of the organization -->
					<xsl:variable name="URI-Organization" select="org-ep:URI-Organization-FromMnemoCode(key[@name='reds:hasBody']/key[@name='reds:hasBodyCode'],$dateDepositDossier)"/>
					<elidl-ep:hasActivityParticipation>
						<elidl-ep:ActivityParticipation rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/activity-participation_',position()))}">	
							<elidl-ep:activityParticipationHasAgent rdf:resource="{$URI-Organization}"/>							
							<elidl-ep:activityParticipationRole rdf:resource="{org-ep:URI-ActiviteParticipation('committeeResponsible')}"/>
						</elidl-ep:ActivityParticipation>
					</elidl-ep:hasActivityParticipation>
				</xsl:for-each>
				<xsl:variable name="committeeRolesSize" select="count($CommitteeRoles)" />
				
				<!-- rapporteur Activity Participation -->
				<xsl:variable name="NMCP_RAP_Roles" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRoles']/item[
					key[@name='reds:hasRolePersonName']='reds:AuthRole_NMCP_RAP'
					and 
					key[@name='reds:hasPerson']/key[@name='reds:hasPersId']
				]"/>
				
				<xsl:for-each select="$NMCP_RAP_Roles">
					<xsl:variable name="i" select="position()+$committeeRolesSize" />	
					<xsl:variable name="URI-Organization" select="org-ep:URI-Organization-FromMnemoCode(./key[@name='reds:hasBody']/key[@name='reds:hasBodyCode'],$dateDepositDossier)"/>		
					<elidl-ep:hasActivityParticipation>
						<elidl-ep:ActivityParticipation rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/activity-participation_',$i))}">	
							<elidl-ep:activityParticipationHasAgent rdf:resource="{org-ep:URI-ActiviteParticipationResource(concat('person/',key[@name='reds:hasPerson']/key[@name='reds:hasPersId']))}"/>
							<elidl-ep:activityParticipationRole rdf:resource="{org-ep:URI-ActiviteParticipation('rapporteur')}"/>
							<elidl-ep:activityParticipationInNameOf	rdf:resource="{$URI-Organization}"/>
						</elidl-ep:ActivityParticipation>
					</elidl-ep:hasActivityParticipation>				
				</xsl:for-each>
				<xsl:variable name="rapRolesSize" select="count($NMCP_RAP_Roles)" />
				
				<!-- shadowRapporteur Activity Participation -->
				<xsl:variable name="Roles_NMSR" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRoles']/item[
					key[@name='reds:hasRolePersonName']='reds:AuthRole_NMSR' 
					and 
					key[@name='reds:hasPerson']/key[@name='reds:hasPersId']]"/>
				
				<xsl:for-each select="$Roles_NMSR">
					<xsl:variable name="i" select="position()+$committeeRolesSize+$rapRolesSize" />	
					<xsl:variable name="URI-Organization" select="org-ep:URI-Organization-FromMnemoCode(./key[@name='reds:hasBody']/key[@name='reds:hasBodyCode'],$dateDepositDossier)"/>
					<elidl-ep:hasActivityParticipation>
						<elidl-ep:ActivityParticipation rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/activity-participation_',$i))}"> 
							<elidl-ep:activityParticipationHasAgent rdf:resource="{org-ep:URI-ActiviteParticipationResource(concat('person/',./key[@name='reds:hasPerson']/key[@name='reds:hasPersId']))}"/>
							<elidl-ep:activityParticipationRole rdf:resource="{org-ep:URI-ActiviteParticipation('shadowRapporteur')}"/>
							<elidl-ep:activityParticipationInNameOf	rdf:resource="{$URI-Organization}"/>
						</elidl-ep:ActivityParticipation>
					</elidl-ep:hasActivityParticipation>					
				</xsl:for-each>			
			</eli-dl:LegislativeActivity>				
		</eli-dl:consists_of>
		
	</xsl:template>
	
	<!-- Matches a dossier in the export_dossier.xml file -->
	<xsl:template match="/all/item[key[@name = 'reds:type'] = 'reds:DirContDossier']" mode="dossier">
	
		<xsl:variable name="hasProperties" select="./key[@name='reds:hasProperties']"/>
	    	
		<elidl-ep:activityId>
			<xsl:value-of select="key[@name='reds:reference']"/>
		</elidl-ep:activityId>
		
		<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="substring(key[@name = 'reds:dateDeposit'],1,23)"/></eli-dl:activity_date>
		
		<!-- Activity Type -->
		<xsl:if test="$hasProperties/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MHE'">
			<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('MAIN_MHE_DOSSIER')}"/>
		</xsl:if>
		
		<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('MAIN_DOSSIER')}"/>
		
		<elidl-ep:activityContextPrecision rdf:resource="{org-ep:URI-Activity_ContextPrecision($hasProperties/item[key[@name='reds:hasName']='reds:hasPrecisionDossier']/key[@name='reds:hasValue'])}"/>
		<elidl-ep:activityNature rdf:resource="{org-ep:URI-Activity_ActivityNature($hasProperties/item[key[@name='reds:hasName']='reds:hasNature']/key[@name='reds:hasValue'])}"/>
		<eli-dl:occured_at_stage rdf:resource="{org-ep:URI-ProcessStage(substring-after($hasProperties/item[key[@name='reds:hasName']='reds:phase']/key[@name='reds:hasValue'],'_'))}"/>
		<elidl-ep:activityStatus rdf:resource="{org-ep:URI-Activity_Status(key[@name='reds:status'])}"/>	
		
		<xsl:if test="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:dateDeadlineAmd']/key[@name='reds:hasDate']">
		<elidl-ep:amendmentDeadlineDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="substring(key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:dateDeadlineAmd']/key[@name='reds:hasDate'],1,23)"/></elidl-ep:amendmentDeadlineDate>
		</xsl:if>					
	</xsl:template>
	
	<xsl:template match="item[key[@name= 'reds:hasName']='reds:VoteResult']" mode="vote">
		<elidl-ep:voteResult rdf:resource="{org-ep:URI-TypeVote(concat('vote-result/',substring-after(key[@name = 'reds:hasValue'],'_')))}"/>
	</xsl:template>
	
	<xsl:template match="item[key[@name= 'reds:hasName']='reds:voteAbst']" mode="vote">
		<elidl-ep:voteAbstention rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="key[@name = 'reds:hasValue']"/></elidl-ep:voteAbstention>
	</xsl:template>
	
	<xsl:template match="item[key[@name= 'reds:hasName']='reds:voteInFavour']" mode="vote">
		<elidl-ep:voteFavour rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="key[@name = 'reds:hasValue']"/></elidl-ep:voteFavour>
	</xsl:template>
	
	<xsl:template match="item[key[@name= 'reds:hasName']='reds:voteAgainst']" mode="vote">
		<elidl-ep:voteAgainst rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="key[@name = 'reds:hasValue']"/></elidl-ep:voteAgainst>
	</xsl:template>
		
</xsl:stylesheet>