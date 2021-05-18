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

			<eli-dl:legislative_process_number>
				<xsl:value-of
					select="tokenize(key[@name = 'reds:reference'],'-')[last()]" />
			</eli-dl:legislative_process_number>
			<elidl-ep:legislativeProcessYear>
				<xsl:value-of
					select="tokenize(key[@name = 'reds:reference'],'-')[2]" />
			</elidl-ep:legislativeProcessYear>
			<elidl-ep:creationDate
				rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
				<xsl:value-of select="key[@name ='reds:dateDeposit']" />
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
				<xsl:when test="count($legalBasis) = 0">
					<!-- if not found the value return art_51 -->
					<eli-dl:had_legal_basis rdf:resource="{org-ep:URI-LegislativeProcessLegalBasis('RULES-0-0000-00-000000000000')}"/>
				</xsl:when>
			</xsl:choose>
			
			
			
			<!-- LegalBase -->
			<xsl:variable name="LegalBase" select="key[@name='reds:hasProperties']/item[key[@name='reds:hasName']='reds:legalBase']/key[@name='reds:hasValue']"/>
			<xsl:message><xsl:value-of select="$LegalBase"/></xsl:message>
			<xsl:if test="$LegalBase != ''">
				<xsl:for-each select="$LegalBase">
					<xsl:variable name="currentLegalBase" select="."/>
					<eli-dl:had_legal_basis rdf:resource="{org-ep:URI-LegislativeProcessLegalBase($currentLegalBase)}"/>
				</xsl:for-each>
			</xsl:if>
						 
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
						<xsl:apply-templates select="$currentProcedureItem
								/key[@name ='reds:hasRelations']
								/item[
									key[@name = 'reds:hasPredicate'] = 'reds:hasEventType_PRVPL_I'
									and
									key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue'] = $currentReading
						]"/>
						
						<!-- Now within that reading of that procedure, find all consolidation dossiers, there could be multiple -->
						<xsl:apply-templates select="$currentProcedureItem
								/key[@name ='reds:hasRelations']
								/item[
									key[@name = 'reds:hasPredicate'] = 'reds:hasEventType_DCPL_I'
									and
									key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue'] = $currentReading
						]"/>
						
						
						<!-- TODO : process PRVPL_I, DCPL_I and BAS to generate other subactivities -->
						
						
						<!--  
						<xsl:variable name="idBaseBas" select="../key[@name='reds:hasRelations']/item[key[@name = 'reds:hasPredicate']='reds:hasBase_BAS_I']/key[@name='reds:hasObject']/key[@name='reds:reference']"/>
						<elidl-ep:hasBaseBas_1 rdf:resource="{org-ep:URI-LegislativeActivityBaseBas($procedureReference,$idBaseBas)}"/>
						-->
							
					</eli-dl:LegislativeActivity>
				</eli-dl:consists_of>
			</xsl:for-each>

			
			<!-- Process all properties -->
			<xsl:apply-templates select="key[@name ='reds:hasProperties']/item"/>
			
			<!-- Process all relations -->
			<xsl:apply-templates select="key[@name ='reds:hasRelations']/item" mode="dossier"/>
			<xsl:apply-templates select="key[@name ='reds:hasRelations']/item" mode="plenary_dossier"/>			
			
		 
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
							rdf:resource="{org-ep:URI-LegislativeProcessActivityType(key[@name='reds:hasValue'])}" />
	</xsl:template>
	
	<!-- Match property reds:legalBase -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:legalBase']">
		<xsl:message>Found reds:legalBase <xsl:value-of select="key[@name='reds:hasValue']" /></xsl:message>
	</xsl:template>
	
	<!-- Match relation to procedure creation -->
	<xsl:template match="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:hasEventType_PROCR']">
		<eli-dl:consists_of>
			<eli-dl:LegislativeActivity
				rdf:about="{org-ep:URI-LegislativeActivity(../../key[@name = 'reds:reference'], 'procedure-creation_1')}">
				<xsl:variable name="Data_ProcedureCreation" select="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:hasEventType_PROCR']"/>
				<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType(substring-after(key[@name='reds:hasPredicate'],'_'))}"/>
				<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
					<xsl:value-of select="key[@name='reds:hasDate']"/>
				</eli-dl:activity_date>
			</eli-dl:LegislativeActivity>
		</eli-dl:consists_of>
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
				<eli-dl:consists_of>
					<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/app-rapporteur_',$index))}">
						<eli-dl:activity_label><xsl:value-of select="'Appointment of rapporteur'"/></eli-dl:activity_label>
						<elidl-ep:activityId><xsl:value-of select="substring-after($appRapporteur/key[@name='reds:hasPredicate'],'_')"/></elidl-ep:activityId>
						<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType(substring-after($appRapporteur/key[@name='reds:hasPredicate'],'_'))}"/>
						<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="$appRapporteur/key[@name='reds:hasDate']"/></eli-dl:activity_date>
					</eli-dl:LegislativeActivity>
				</eli-dl:consists_of>
				
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
					<xsl:variable name="currentIdReference" select="."/>
					<xsl:variable name="dataDRAFTRPANDAM" select="$EXPORT_DRAFTRPANDAM/all/item[key[@name = 'reds:reference'] = $currentIdReference]"/>
					<eli-dl:consists_of>
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/tabling-draft-report_',position()))}">
							<elidl-ep:activityId><xsl:value-of select="$currentIdReference"/></elidl-ep:activityId>
							<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('TABLING_DRAFT_REPORT')}"/>
							<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="$dataDRAFTRPANDAM/key[@name = 'reds:dateDeposit']"/></eli-dl:activity_date>
							
							<elidl-ep:hasOtherRap></elidl-ep:hasOtherRap>
							
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
					<xsl:variable name="currentIdReference" select="."/>
					<xsl:variable name="dataDRAFTRPANDAM" select="$EXPORT_DRAFTRPANDAM/all/item[key[@name = 'reds:reference'] = $currentIdReference]"/>
					<eli-dl:consists_of>
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/tabling-amendment_',position()))}">
							<elidl-ep:activityId><xsl:value-of select="$currentIdReference"/></elidl-ep:activityId>
							<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('COMMITTEE_AMENDMENT')}"/>
							<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="$dataDRAFTRPANDAM/key[@name = 'reds:dateDeposit']"/></eli-dl:activity_date>
							<elidl-ep:hasOtherAme></elidl-ep:hasOtherAme>
							<eli-dl:involved_work rdf:resource="{org-ep:URI-LegislativeProcessWork($ProcedureReference,substring-after($dataDRAFTRPANDAM/key[@name = 'reds:type'],':'),$dataDRAFTRPANDAM/key[@name = 'reds:reference'])}"/>						    
						</eli-dl:LegislativeActivity>	
					</eli-dl:consists_of>
				</xsl:for-each>	
					
				
				
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
				<xsl:variable name="VoteResult_Committee" select="$voteRelation/key[@name= 'reds:hasProperties']/item"/>
				<eli-dl:consists_of>
					<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/committee-vote_',$index))}">
						<elidl-ep:activityId>VOTE</elidl-ep:activityId>
						<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('COMMITTEE_VOTE')}"/>
						<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="$voteRelation/key[@name = 'reds:hasDate']"/></eli-dl:activity_date>
						<elidl-ep:activityHasVoteResult rdf:resource="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/committee-vote_',$index,'/','result'))}"/>
						<eli-dl:created_a_realization_of rdf:resource="{org-ep:URI-Involved($ProcedureReference,$voteObjectRelation/key[@name = 'reds:hasSubject']/key[@name = 'reds:type'],$voteObjectRelation/key[@name = 'reds:hasSubject']/key[@name = 'reds:reference'])}"/>
					</eli-dl:LegislativeActivity>
				</eli-dl:consists_of>
				
				<elidl-ep:activityHasVoteResult>
					<elidl-ep:Vote rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/committee-vote_',$index,'/','result'))}">
						<elidl-ep:voteDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="$voteRelation/key[@name = 'reds:hasDate']"/></elidl-ep:voteDate>
						<elidl-ep:voteResult rdf:resource="{org-ep:URI-TypeVote(concat('vote-result/',substring-after($VoteResult_Committee[key[@name= 'reds:hasName']='reds:VoteResult']/key[@name = 'reds:hasValue'],'_')))}"/>
								
						<xsl:if test="$VoteResult_Committee[key[@name= 'reds:hasName']='reds:voteAbst']/key[@name = 'reds:hasValue'] != 0">
							<elidl-ep:voteAbstention><xsl:value-of select="$VoteResult_Committee[key[@name= 'reds:hasName']='reds:voteAbst']/key[@name = 'reds:hasValue']"/></elidl-ep:voteAbstention>
						</xsl:if>
						<xsl:if test="$VoteResult_Committee[key[@name= 'reds:hasName']='reds:voteInFavour']/key[@name = 'reds:hasValue'] != 0">
							<elidl-ep:voteFavour><xsl:value-of select="$VoteResult_Committee[key[@name= 'reds:hasName']='reds:voteInFavour']/key[@name = 'reds:hasValue']"/></elidl-ep:voteFavour>
						</xsl:if>
						<xsl:if test="$VoteResult_Committee[key[@name= 'reds:hasName']='reds:voteAgainst']/key[@name = 'reds:hasValue'] != 0">
							<elidl-ep:voteAgainst><xsl:value-of select="$VoteResult_Committee[key[@name= 'reds:hasName']='reds:voteAgainst']/key[@name = 'reds:hasValue']"/></elidl-ep:voteAgainst>
						</xsl:if>
					</elidl-ep:Vote>
				</elidl-ep:activityHasVoteResult>
				
				<!-- the section search all roles -->
				
				<xsl:variable name="CommitteeRoles" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRoles']/item[
					key[@name='reds:hasRoleBodyName']='reds:hasCommittee' and 
					key[@name='reds:hasBody']]"/>
				<!-- Look for the code of the organization -->
				<xsl:variable name="dateDepositDossier" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:dateDeposit']"/>
				<xsl:variable name="CodeIdOrganization" select="org-ep:URI-CodeOrganization($CommitteeRoles/key[@name='reds:hasBody']/key[@name='reds:hasBodyCode'],$dateDepositDossier)"/>
				
				<!-- Responsable Activity Participation -->				
				<xsl:if test="$CommitteeRoles != ''">
					<eli-dl:hasActivityParticipation>
						<elidl-ep:ActivityParticipation rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/activity-participation_','1'))}">	
							
							<!-- Warning!! voir solution proposer par Annick -->
							<xsl:for-each select="$CommitteeRoles/key[@name='reds:hasBody']/key[@name='reds:hasBodyCode']">
								<xsl:message>'Has Agent '<xsl:value-of select="$CommitteeRoles/key[@name='reds:hasBody']/key[@name='reds:hasBodyCode']" separator=""/></xsl:message>
								<xsl:text>&#xA;</xsl:text>
								<elidl-ep:activityParticipationHasAgent rdf:resource="{org-ep:URI-ActiviteParticipationResource(concat('org/',.,'-',$CodeIdOrganization))}"/>
							</xsl:for-each>
							
							<elidl-ep:activityParticipationRole rdf:resource="{org-ep:URI-ActiviteParticipation('committeeResponsible')}"/>
						</elidl-ep:ActivityParticipation>
					</eli-dl:hasActivityParticipation>
				</xsl:if>
				
				<!-- rapporteur Activity Participation -->
				<xsl:variable name="NMCP_RAP_Roles" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRoles']/item[
					key[@name='reds:hasRolePersonName']='reds:AuthRole_NMCP_RAP' and 
					key[@name='reds:hasPerson']/key[@name='reds:hasPersId']]"/>
					
				<xsl:if test="$NMCP_RAP_Roles != ''">
					<eli-dl:hasActivityParticipation>
						<elidl-ep:ActivityParticipation rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/activity-participation_','2'))}">	
							<elidl-ep:activityParticipationHasAgent rdf:resource="{org-ep:URI-ActiviteParticipationResource(concat('person/',$NMCP_RAP_Roles/key[@name='reds:hasPerson']/key[@name='reds:hasPersId']))}"/>
							<elidl-ep:activityParticipationRole rdf:resource="{org-ep:URI-ActiviteParticipation('rapporteur')}"/>
							<elidl-ep:activityParticipationInNameOf	rdf:resource="{org-ep:URI-ActiviteParticipationResource(concat('org/',$NMCP_RAP_Roles/key[@name='reds:hasBody']/key[@name='reds:hasBodyCode'],'-',$CodeIdOrganization))}"/>
						</elidl-ep:ActivityParticipation>
					</eli-dl:hasActivityParticipation>
				</xsl:if>
				
				<!-- shadowRapporteur Activity Participation -->
				<xsl:variable name="Roles_NMSR" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRoles']/item[
					key[@name='reds:hasRolePersonName']='reds:AuthRole_NMSR' 
					and 
					key[@name='reds:hasPerson']/key[@name='reds:hasPersId']]"/>
				
				<xsl:for-each select="$Roles_NMSR">
					<xsl:variable name="i" select="position()+2" />	
					<xsl:variable name="CodeIdOrganization" select="org-ep:URI-CodeOrganization(./key[@name='reds:hasBody']/key[@name='reds:hasBodyCode'],$dateDepositDossier)"/>
					<eli-dl:hasActivityParticipation>
						<elidl-ep:ActivityParticipation rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/activity-participation_',$i))}"> 
							<elidl-ep:activityParticipationHasAgent rdf:resource="{org-ep:URI-ActiviteParticipationResource(concat('person/',./key[@name='reds:hasPerson']/key[@name='reds:hasPersId']))}"/>
							<elidl-ep:activityParticipationRole rdf:resource="{org-ep:URI-ActiviteParticipation('shadowRapporteur')}"/>
							<elidl-ep:activityParticipationInNameOf	rdf:resource="{org-ep:URI-ActiviteParticipationResource(concat('org/',./key[@name='reds:hasBody']/key[@name='reds:hasBodyCode'],'-',$CodeIdOrganization))}"/>
						</elidl-ep:ActivityParticipation>
					</eli-dl:hasActivityParticipation>					
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
		
		<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="key[@name = 'reds:dateDeposit']"/></eli-dl:activity_date>
		
		<!-- Activity Type -->
		<xsl:choose>
			<xsl:when test="item[key[@name = 'reds:hasValue'] = 'red:ComRole_MHE']">
				<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('MAIN_MHE_DOSSIER')}"/>
			</xsl:when>
			<xsl:otherwise>
				<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType('MAIN_DOSSIER')}"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<elidl-ep:activityContextPrecision rdf:resource="{org-ep:URI-Activity_ContextPrecision($hasProperties/item[key[@name='reds:hasName']='reds:hasPrecisionDossier']/key[@name='reds:hasValue'])}"/>
		<elidl-ep:activityNature rdf:resource="{org-ep:URI-Activity_ActivityNature($hasProperties/item[key[@name='reds:hasName']='reds:hasNature']/key[@name='reds:hasValue'])}"/>
		<eli-dl:occured_at_stage rdf:resource="{org-ep:URI-ProcessStage(substring-after($hasProperties/item[key[@name='reds:hasName']='reds:phase']/key[@name='reds:hasValue'],'_'))}"/>
		<elidl-ep:activityStatus rdf:resource="{org-ep:URI-Activity_Status(key[@name='reds:status'])}"/>	
		<elidl-ep:amendmentDeadlineDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
			<xsl:value-of select="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:dateDeadlineAmd']/key[@name='reds:hasDate']"/>
		</elidl-ep:amendmentDeadlineDate>							
	</xsl:template>
	
	
	<!-- Match relation to a Plenary dossier -->
	<xsl:template match="key[@name ='reds:hasRelations']/item[
			key[@name = 'reds:hasPredicate'] = 'reds:hasEventType_PRVPL_I'
			and
			key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']			
	]">
	
		<xsl:variable name="DirContDossier" select="../item[key[@name = 'reds:hasPredicate'] = 'reds:hasDirContDossier'
			and
			(
				key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MAIN'
				or
				key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasRoleDossier']/key[@name = 'reds:hasValue'] = 'red:ComRole_MHE'
			)]"/>
		
		<xsl:variable name="currentIdentifier" select="$DirContDossier/key[@name = 'reds:hasObject']/key[@name = 'dc:identifier']" />
		<xsl:variable name="currentReference" select="$DirContDossier/key[@name = 'reds:hasObject']/key[@name = 'reds:reference']" />
		
		<xsl:message> Plenary Dossier <xsl:value-of select="$currentIdentifier" /> / reference <xsl:value-of select="$currentReference" /></xsl:message>
		<xsl:variable name="idReading" select="./$DirContDossier/key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue']"/>
		
		<!-- Now we need to find the _index_ of this dossier within the same reading of the same procedure -->
		<!-- To do that we count the number of other dossiers in same procedure and same reading, that have an id before this one -->
		<!-- Test case : BUD-2019-2028 -->
		<xsl:variable name="index" select="
			count(
				../item[
					key[@name = 'reds:hasPredicate'] = 'reds:hasEventType_PRVPL_I'
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
		
		<!-- The plenaey dossier -->
		<eli-dl:consists_of>	
			<eli-dl:LegislativeActivity
				rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'plenary-dossier_', $index))}">						
				
				<!-- Find the document in the dossier export -->
				<xsl:apply-templates select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]" mode="plenary_dossier" />	
				
			</eli-dl:LegislativeActivity>				
		</eli-dl:consists_of>
	</xsl:template>
	
	<!-- Matches a dossier in the export_dossier.xml file plenary dossier -->
	<xsl:template match="/all/item[key[@name = 'reds:type'] = 'reds:DirContDossier']" mode="plenary_dossier">	
		<elidl-ep:activityId>
			<xsl:value-of select="key[@name='reds:reference']"/>
		</elidl-ep:activityId>		
		<xsl:variable name="type" select="key[@name ='reds:hasRelations']/item[key[@name = 'reds:hasPredicate']='reds:hasEventType_PRVPL_I']"/>
		<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="$type/key[@name = 'reds:hasDate']"/></eli-dl:activity_date>
		<!--  
		<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType(substring-after($type/key[@name = 'reds:hasPredicate'],'_'))}"/>
		-->									
	</xsl:template>
	
	<!-- Match relation to a Consolidation dossier -->
	<xsl:template match="key[@name ='reds:hasRelations']/item[
			key[@name = 'reds:hasPredicate'] = 'reds:hasEventType_DCPL_I'
			and
			key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']			
			]">
			
		<xsl:variable name="currentIdentifier" select="../../key[@name = 'reds:hasObject']/key[@name = 'dc:identifier']" />
		<xsl:variable name="currentReference" select="../../key[@name = 'reds:hasObject']/key[@name = 'reds:reference']" />
		
		<xsl:message> Consolidation Dossier <xsl:value-of select="$currentIdentifier" /> / reference <xsl:value-of select="$currentReference" /></xsl:message>
		<xsl:variable name="idReading" select="./../key[@name = 'reds:hasProperties']/item[key[@name = 'reds:hasName'] = 'reds:hasReading']/key[@name = 'reds:hasValue']"/>
			
		<!-- Now we need to find the _index_ of this dossier within the same reading of the same procedure -->
		<!-- To do that we count the number of other dossiers in same procedure and same reading, that have an id before this one -->
		<!-- Test case : BUD-2019-2028 -->
		<xsl:variable name="index" select="
			count(
				../item[
					key[@name = 'reds:hasPredicate'] = 'reds:hasEventType_DCPL_I'
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
		
	</xsl:template>
	
	
	
	
	
	
	
	<xsl:template match="key[@name='reds:hasTitles']/item">
		<eli-dl:legislative_process_title
			xml:lang="{key[@name='reds:hasLanguage']}">
			<xsl:value-of select="key[@name='reds:hasValue']" />			
		</eli-dl:legislative_process_title>
	</xsl:template>
	
</xsl:stylesheet>