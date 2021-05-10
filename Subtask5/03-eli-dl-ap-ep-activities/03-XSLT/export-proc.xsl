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
			
			<eli-dl:legislative_process_status rdf:resource="{org-ep:URI-LegislativeActivity_ProcessStatus(key[@name = 'reds:status'])}"/>
			
			<!-- always create the activity of procedure-creation -->
			<eli-dl:consists_of>
				<eli-dl:LegislativeActivity
					rdf:about="{org-ep:URI-LegislativeActivity(key[@name = 'reds:reference'], 'procedure-creation_1')}">
				</eli-dl:LegislativeActivity>
			</eli-dl:consists_of>
			
			<xsl:variable name="legalBasis" select="key[@name='reds:hasRelations']/item[key[@name='reds:hasPredicate']='reds:hasEpRule']/key[@name='reds:hasObject']"/>
			<!--
			<eli-dl:had_legal_basis rdf:resource="{org-ep:URI-LegislativeProcessLegalBasis($legalBasis/key[@name='reds:type'],$legalBasis/key[@name='reds:reference'])}"/>
			-->
			 
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
				<eli-dl:consists_of>
					<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivity($procedureReference,org-ep:readingReference($currentReading))}">
						<elidl-ep:activityType rdf:resource="{org-ep:URI-LegislativeProcessActiviteType($currentReading)}" />
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
						
						<!-- TODO 
						<xsl:variable name="idBaseBas" select="../key[@name='reds:hasRelations']/item[key[@name = 'reds:hasPredicate']='reds:hasBase_BAS_I']/key[@name='reds:hasObject']/key[@name='reds:reference']"/>
						<elidl-ep:hasBaseBas_1 rdf:resource="{org-ep:URI-LegislativeActivityBaseBas('CNS-2018-0413',$idBaseBas)}"/>
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
							rdf:resource="{org-ep:URI-LegislativeProcessStage(key[@name='reds:hasValue'])}" />
	</xsl:template>
	
	<!-- Match property reds:subPhase -->
	<xsl:template match="key[@name='reds:hasProperties']/item[key[@name='reds:hasName'] = 'reds:subPhase']">
		<elidl-ep:currentSubStage
							rdf:resource="{org-ep:URI-LegislativeProcessStage(key[@name='reds:hasValue'])}" />
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

		<eli-dl:consists_of>	
			<eli-dl:LegislativeActivity
				rdf:about="{org-ep:URI-LegislativeActivity(../../key[@name = 'reds:reference'],concat(org-ep:readingReference($idReading), '/', 'main-dossier_', $index))}">						
				
				<!-- Find the document in the dossier export -->
				<xsl:apply-templates select="$EXPORT_DOSSIER/all/item[key[@name = 'reds:reference'] = $currentReference]" />
							
			</eli-dl:LegislativeActivity>				
		</eli-dl:consists_of>	
	</xsl:template>


	<!-- Matches a dossier in the export_dossier.xml file -->
	<xsl:template match="item[key[@name = 'reds:type'] = 'reds:DirContDossier']">
		<eli-dl:activity_date><xsl:value-of select="key[@name = 'reds:dateDeposit']"/></eli-dl:activity_date>
	</xsl:template>



		<!--  
		<xsl:variable name="dateCreation"
			select="item[key[@name='reds:hasPredicate']='reds:dateCreation']/key[@name='reds:hasDate']" />
		<xsl:variable name="hasBaseBase" select="item[key[@name='reds:hasPredicate']='reds:hasBase_BAS_I']/key[@name='reds:hasObject']/key[@name='reds:reference']"/>
		
		-->
		<!-- Main Dossier
		<xsl:variable name="ContextPrecision"
			select="item[key[@name='reds:hasPredicate']='reds:hasDirContDossier']/key[@name='reds:hasProperties']/item[key[@name='reds:hasName']='reds:hasPrecisionDossier']/key[@name='reds:hasValue']" />
		 -->
		
		
		<!-- create the Reading section 

						
					<eli-dl:activity_date>
						<xsl:value-of select="$dateCreation" />
					</eli-dl:activity_date>
					-->
					
					<!-- this section contain main folder 
					<eli-dl:consists_of>
						<xsl:variable name="ActivityNature" select="../key[@name='reds:hasProperties']/item[key[@name='reds:hasName']='reds:hasNature']/key[@name='reds:hasValue']"/>
						<xsl:variable name="Stage" select="../key[@name='reds:hasProperties']/item[key[@name='reds:hasName']='reds:phase']/key[@name='reds:hasValue']"/>
						<xsl:variable name="ActivityStatus" select="../key[@name='reds:status']"/>
					
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivityMainDossier(../key[@name = 'reds:reference'],$idReading)}">
						
							<- TODO : tous ces attributs sont générés à partir du _DOSSIER_ dans la XSL export-dossier.xsl ->
						
							<elidl-ep:activityId>
								<xsl:value-of select="$idActivityReading"/>
							</elidl-ep:activityId>
							
							<elidl-ep:activityType rdf:resource="{org-ep:URI-LegislativeProcessActiviteType('MAIN_DOSSIER')}"/>							
							
							<eli-dl:activity_date><xsl:value-of select="../key[@name = 'reds:dateDeposit']"/></eli-dl:activity_date>
							
							<elidl-ep:activityContextPrecision rdf:resource="{org-ep:URI-LegislativeActivityMainDossier_ContextPrecision($ContextPrecision)}"/>
							
							<elidl-ep:activityNature rdf:resource="{org-ep:URI-LegislativeActivityMainDossier_ActivityNature($ActivityNature)}"/>
							
							<eli-dl:occured_at_stage rdf:resource="{org-ep:URI-LegislativeProcessStage($Stage)}"/>
							
							<elidl-ep:activityStatus rdf:resource="{org-ep:URI-LegislativeActivityMainDossier_Status($ActivityStatus)}"/>
							-->
							<!-- où on puet trouve la valeur ?
							<elidl-ep:amendmentDeadlineDate><xsl:value-of select=""/></elidl-ep:amendmentDeadlineDate>  
							
						</eli-dl:LegislativeActivity>
					</eli-dl:consists_of>-->
					
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
					
					
					
					
				</eli-dl:LegislativeActivity>
			</eli-dl:consists_of>
		</xsl:if>
	</xsl:template>-->


	<xsl:template match="key[@name='reds:hasTitles']">
		<xsl:for-each select="item">
			<eli-dl:legislative_process_title
				xml:lang="{key[@name='reds:hasLanguage']}">
				<xsl:value-of select="key[@name='reds:hasValue']" />
			</eli-dl:legislative_process_title>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>