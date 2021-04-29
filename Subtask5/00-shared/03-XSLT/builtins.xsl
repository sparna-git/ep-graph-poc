<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
>

	<!-- Overwrite built-in template to match all unmatched elements and discard them -->
	<xsl:template match="*" mode="#all" />
	
	<!-- Overwrite built-in template to match all text nodes -->
	<!-- Otherwise line breaks are inserted in resulting XML files -->
	<!-- Note the #all special keyword to apply this template to all modes -->
	<xsl:template match="text()|@*" mode="#all"></xsl:template>
		
</xsl:stylesheet>