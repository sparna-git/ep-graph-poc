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
	<!-- Read source file from CV -->
	<xsl:param name="EXPORT_DOSSIER" select="document($EXPORT_DOSSIER_PATH)" />

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
			
			<eli-dl:legislative_process_status rdf:resource="{org-ep:URI-Activity_ProcessStatus(key[@name = 'reds:status'])}"/>
			
			<!-- always create the activity of procedure-creation -->
			<eli-dl:consists_of>
				<eli-dl:LegislativeActivity
					rdf:about="{org-ep:URI-LegislativeActivity(key[@name = 'reds:reference'], 'procedure-creation_1')}">
					<xsl:variable name="Data_ProcedureCreation" select="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:hasEventType_PROCR']"/>
					<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType(substring-after($Data_ProcedureCreation/key[@name='reds:hasPredicate'],'_'))}"/>
					<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
						<xsl:value-of select="$Data_ProcedureCreation/key[@name='reds:hasDate']"/>
					</eli-dl:activity_date>
				</eli-dl:LegislativeActivity>				
			</eli-dl:consists_of>
			
			
			<!-- This section does reds:hasEpRule -->
			<xsl:variable name="legalBasis" select="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:hasEpRule']/key[@name='reds:hasObject']"/>
			<xsl:if test="count($legalBasis) &gt; 1">
				<xsl:message>'# Legal Basis' <xsl:value-of select="count($legalBasis)"/></xsl:message>
			</xsl:if>
			<eli-dl:had_legal_basis rdf:resource="{org-ep:URI-LegislativeProcessLegalBasis($legalBasis/key[@name='reds:reference'])}"/>
			
			<!-- LegalBase 
			<xsl:variable name="LegalBase" select="key[@name='reds:hasProperties']/item[key[@name='reds:hasName']='reds:legalBase']/key[@name='reds:hasValue']"/>
			<xsl:if test="$LegalBase != ''">
				<eli-dl:had_legal_basis rdf:resource="{org-ep:URI-LegislativeProcessLegalBasis($legalBasis/key[@name='reds:reference'])}"/>
			</xsl:if>-->
			
			
			 
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
						<elidl-ep:activityType rdf:resource="{org-ep:URI-ActiviteType($currentReading)}" />
						<elidl-ep:activityId>
							<xsl:value-of select="$currentReading" />
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
			<!-- 
			<xsl:apply-templates select="key[@name ='reds:hasRelations']/item"/>
			-->

			 
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
							rdf:resource="{org-ep:URI-ProcessStage(key[@name='reds:hasValue'])}" />
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
		<xsl:variable name="SubPhase" select="concat(substring-before(key[@name='reds:hasValue'],'_'),'_',$NumberLeft,'-',$NumberRigth)"/>
		<elidl-ep:currentSubStage
							rdf:resource="{org-ep:URI-ProcessStage($SubPhase)}" />
	</xsl:template>
	
	<!-- Match property reds:LegislativeActType -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:LegislativeActType']">
		<eli-dl:foreseen_type_document
							rdf:resource="{org-ep:URI-ActiviteType(key[@name='reds:hasValue'])}" />
	</xsl:template>
	
	<!-- Match property reds:legalBase -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:legalBase']">
		<xsl:message>Found reds:legalBase <xsl:value-of select="key[@name='reds:hasValue']" /></xsl:message>
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

		<eli-dl:consists_of>	
			<eli-dl:LegislativeActivity
				rdf:about="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index))}">						
				
				<!-- Find the document in the dossier export -->
				<xsl:apply-templates select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]" />				
				
				<!-- the section search all roles -->
				<xsl:variable name="CommitteeRoles" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRoles']/item[
					key[@name='reds:hasRoleBodyName']='reds:hasCommittee' and 
					key[@name='reds:hasBody']]"/>
				<xsl:if test="$CommitteeRoles != ''">
					<eli-dl:hasActivityParticipation rdf:resource="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/activity-participation_','1'))}"/>
				</xsl:if>
				
				<xsl:variable name="NMCP_RAP_Roles" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRoles']/item[
					key[@name='reds:hasRolePersonName']='reds:AuthRole_NMCP_RAP' and 
					key[@name='reds:hasPerson']/key[@name='reds:hasPersId']]"/>
				<xsl:if test="$NMCP_RAP_Roles != ''">
					<eli-dl:hasActivityParticipation rdf:resource="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/activity-participation_','2'))}"/>
				</xsl:if>
				
				<xsl:variable name="Roles_NMSR" select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]/key[@name='reds:hasRoles']/item[
					key[@name='reds:hasRolePersonName']='reds:AuthRole_NMSR' 
					and 
					key[@name='reds:hasPerson']/key[@name='reds:hasPersId']]"/>
				<xsl:for-each select="$Roles_NMSR">
					<xsl:variable name="i" select="position()+2" />					
					<eli-dl:hasActivityParticipation rdf:resource="{org-ep:URI-LegislativeActivity($ProcedureReference,concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index,'/activity-participation_',$i))}"/>					
				</xsl:for-each>			
			</eli-dl:LegislativeActivity>				
		</eli-dl:consists_of>	
	</xsl:template>


	<!-- Matches a dossier in the export_dossier.xml file -->
	<xsl:template match="item[key[@name = 'reds:type'] = 'reds:DirContDossier']">
	    <xsl:variable name="hasProperties" select="./key[@name='reds:hasProperties']"/>
	    	
		<eli-dl:activity_date rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="key[@name = 'reds:dateDeposit']"/></eli-dl:activity_date>		
		<elidl-ep:activityId>
			<xsl:value-of select="key[@name='reds:reference']"/>
		</elidl-ep:activityId>
		
		
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

		
		
		
					
					<!-- this section contain plenary folder 
					<eli-dl:consists_of>
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivityMainDossier(../key[@name = 'reds:reference'],$idReading)}">
						</eli-dl:LegislativeActivity>
					</eli-dl:consists_of>-->
					
					<!-- this section contain consolidation folder 
					<eli-dl:consists_of>
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivityMainDossier(../key[@name = 'reds:reference'],$idReading)}">
						</eli-dl:LegislativeActivity>
					</eli-dl:consists_of>
					
					-->


	<xsl:template match="key[@name='reds:hasTitles']/item">
		<eli-dl:legislative_process_title
			xml:lang="{key[@name='reds:hasLanguage']}">
			<xsl:value-of select="key[@name='reds:hasValue']" />
		</eli-dl:legislative_process_title>
	</xsl:template>
	
</xsl:stylesheet>