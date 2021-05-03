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
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl"
	xmlns:ep="http://schema.org/">

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
		<eli-dl:LegislativeProcess
			rdf:about="{org-ep:URI-LegislativeProcess(key[@name = 'reds:reference'])}">

			<eli-dl:legislative_process_number>
				<xsl:value-of
					select="tokenize(key[@name = 'reds:reference'],'-')[last()]" />
			</eli-dl:legislative_process_number>
			<ep:legislativeProcessYear>
				<xsl:value-of
					select="tokenize(key[@name = 'reds:reference'],'-')[2]" />
			</ep:legislativeProcessYear>
			<ep:creationDate
				rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
				<xsl:value-of select="key[@name ='reds:dateDeposit']" />
			</ep:creationDate>

			<!--  TODO : générer la bonne URI -->
			<eli-dl:legislative_process-status>
				<xsl:value-of select="key[@name = 'reds:status']" />
			</eli-dl:legislative_process-status>

			<!-- always create the activity of procedure-creation -->
			<eli-dl:consists_of>
				<eli-dl:LegislativeActivity
					rdf:about="{org-ep:URI-LegislativeActivity(key[@name = 'reds:reference'], 'procedure-creation_1')}">
				</eli-dl:LegislativeActivity>
			</eli-dl:consists_of>

			<xsl:apply-templates />
		</eli-dl:LegislativeProcess>
	</xsl:template>

	<xsl:template match="key[@name='reds:hasProperties']">
		<xsl:for-each select="item">
			<xsl:variable name="value_type"
				select="key[@name='reds:hasName']" />
			<xsl:choose>
				<xsl:when test="$value_type = 'reds:hasType'">
					<eli-dl:legislative_process_type
						rdf:resource="{org-ep:URI-LegislativeProcessType(key[@name='reds:hasValue'])}" />
				</xsl:when>
				<xsl:when test="$value_type = 'reds:hasNature'">
					<ep:legislativeProcessNature
						rdf:resource="{org-ep:URI-LegislativeProcessNature(key[@name='reds:hasValue'])}" />
				</xsl:when>
				<xsl:when test="$value_type = 'reds:phase'">
					<eli-dl:current_stage
						rdf:resource="{org-ep:URI-LegislativeProcessStage(key[@name='reds:hasValue'])}" />
				</xsl:when>
				<xsl:when test="$value_type = 'reds:subPhase'">
					<ep:currentSubStage
						rdf:resource="{org-ep:URI-LegislativeProcessStage(key[@name='reds:hasValue'])}" />
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="key[@name='reds:hasRelations']">

		<xsl:variable name="idReadingData"
			select="item[key[@name='reds:hasPredicate']='reds:hasDirContDossier']/key[@name='reds:hasProperties']/item[key[@name='reds:hasName']='reds:hasReading']/key[@name='reds:hasValue']" />
		<xsl:variable name="idActivityReading"
			select="item[key[@name='reds:hasPredicate']='reds:hasDirContDossier']/key[@name='reds:hasObject']/key[@name='reds:reference']"/>
		<xsl:variable name="dateCreation"
			select="item[key[@name='reds:hasPredicate']='reds:dateCreation']/key[@name='reds:hasDate']" />
		<xsl:variable name="hasBaseBase" select="item[key[@name='reds:hasPredicate']='reds:hasBase_BAS_I']/key[@name='reds:hasObject']/key[@name='reds:reference']"/>
		
		<!-- Main Dossier -->
		<xsl:variable name="ContextPrecision"
			select="item[key[@name='reds:hasPredicate']='reds:hasDirContDossier']/key[@name='reds:hasProperties']/item[key[@name='reds:hasName']='reds:hasPrecisionDossier']/key[@name='reds:hasValue']" />
		
		<xsl:message>
			<xsl:value-of select="$ContextPrecision" />
		</xsl:message>
		<!-- create the Reading section -->

		<xsl:if test="$idReadingData !=''">
			<eli-dl:consists_of>
				<!-- TODO : utiliser fonction org-ep:readingReference dans uris.xsl -->
				<xsl:variable name="idReading" select="concat(lower-case(substring-before(substring-after($idReadingData,':'),'_')),'_',substring-after(substring-after($idReadingData,':'),'_'))"/>
				<eli-dl:LegislativeActivity
					rdf:about="{org-ep:URI-LegislativeActivity(../key[@name = 'reds:reference'],$idReading)}">

					<elidl-ep:activityType
						rdf:resource="{org-ep:URI-LegislativeProcessActiviteType($idReading)}" />
						
					<elidl-ep:activityId>
						<xsl:value-of
							select="$idActivityReading" />
					</elidl-ep:activityId>
					
					<eli-dl:activity_date>
						<xsl:value-of select="$dateCreation" />
					</eli-dl:activity_date>
					
					
					<!-- this section contain main folder -->
					<eli-dl:consists_of>
						<xsl:variable name="ActivityNature" select="../key[@name='reds:hasProperties']/item[key[@name='reds:hasName']='reds:hasNature']/key[@name='reds:hasValue']"/>
						<xsl:variable name="Stage" select="../key[@name='reds:hasProperties']/item[key[@name='reds:hasName']='reds:phase']/key[@name='reds:hasValue']"/>
						<xsl:variable name="ActivityStatus" select="../key[@name='reds:status']"/>
					
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivityMainDossier(../key[@name = 'reds:reference'],$idReading)}">
							<elidl-ep:activityId>
								<xsl:value-of select="$idActivityReading"/>
							</elidl-ep:activityId>
							
							<elidl-ep:activityType rdf:resource="{org-ep:URI-LegislativeProcessActiviteType('MAIN_DOSSIER')}"/>							
							
							<eli-dl:activity_date><xsl:value-of select="../key[@name = 'reds:dateDeposit']"/></eli-dl:activity_date>
							
							<elidl-ep:activityContextPrecision rdf:resource="{org-ep:URI-LegislativeActivityMainDossier_ContextPrecision($ContextPrecision)}"/>
							
							<elidl-ep:activityNature rdf:resource="{org-ep:URI-LegislativeActivityMainDossier_ActivityNature($ActivityNature)}"/>
							
							<eli-dl:occured_at_stage rdf:resource="{org-ep:URI-LegislativeProcessStage($Stage)}"/>
							
							<elidl-ep:activityStatus rdf:resource="{org-ep:URI-LegislativeActivityMainDossier_Status($ActivityStatus)}"/>
							
							<!-- où on puet trouve la valeur ?
							<elidl-ep:amendmentDeadlineDate><xsl:value-of select=""/></elidl-ep:amendmentDeadlineDate>  -->
							
						</eli-dl:LegislativeActivity>
					</eli-dl:consists_of>
					
					<!-- this section contain plenary folder -->
					<eli-dl:consists_of>
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivityMainDossier(../key[@name = 'reds:reference'],$idReading)}">
						</eli-dl:LegislativeActivity>
					</eli-dl:consists_of>
					
					<!-- this section contain consolidation folder -->
					<eli-dl:consists_of>
						<eli-dl:LegislativeActivity rdf:about="{org-ep:URI-LegislativeActivityMainDossier(../key[@name = 'reds:reference'],$idReading)}">
						</eli-dl:LegislativeActivity>
					</eli-dl:consists_of>
					
					
					<elidl-ep:hasBaseBas_1 rdf:resource="{org-ep:URI-LegislativeActivityBaseBas(../key[@name = 'reds:reference'],$hasBaseBase)}"/>
					
				</eli-dl:LegislativeActivity>
			</eli-dl:consists_of>
		</xsl:if>
	</xsl:template>


	<xsl:template match="key[@name='reds:hasTitles']">
		<xsl:for-each select="item">
			<eli-dl:legislative_process_title
				xml:lang="{key[@name='reds:hasLanguage']}">
				<xsl:value-of select="key[@name='reds:hasValue']" />
			</eli-dl:legislative_process_title>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>