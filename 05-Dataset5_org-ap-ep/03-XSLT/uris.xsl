<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:ep="http://data.europarl.europa.eu/"
>

	<xsl:function name="ep:URI-MEP">
		<xsl:param name="mepId" />
		<xsl:value-of select="ep:URI-Person(concat('mep_', $mepId))" />
	</xsl:function>

	<xsl:function name="ep:URI-Person">
		<xsl:param name="personId" />
		<xsl:value-of select="concat('http://data.europarl.europa.eu/person/', encode-for-uri($personId))" />
	</xsl:function>
	
</xsl:stylesheet>