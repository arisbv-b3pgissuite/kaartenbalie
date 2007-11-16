<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet
					version="1.0"
					xmlns="http://www.w3.org/1999/xhtml"
					xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					xmlns:xlink="http://www.w3.org/1999/xlink"					
					xmlns:gmd="http://www.isotc211.org/2005/gmd"
					xmlns:gco="http://www.isotc211.org/2005/gco"
					exclude-result-prefixes="gmd gco xlink"
					>

	<!-- This parameter must be set by the browser -->
	<xsl:param name="basePath"/>
	
	<!-- variable used by javascript function createSection -->
	<xsl:param name="customPosition" select="-1"/>

	<!-- template library to use for making element editable -->
	<xsl:include href="editableCore.xsl"/>	

	<xsl:output	
					doctype-public="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
					doctype-system="-//W3C//DTD XHTML 1.0 Strict//EN"
					method="xml" omit-xml-declaration="no" indent="yes"
					/>
					
	<xsl:template match="/">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:template>
	
	
				
</xsl:stylesheet>