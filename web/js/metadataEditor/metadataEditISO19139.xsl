<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet
					version="1.0"
					xmlns="http://www.w3.org/1999/xhtml"
					xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					xmlns:xlink="http://www.w3.org/1999/xlink"					
					xmlns:gmd="http://www.isotc211.org/2005/gmd"
					xmlns:gco="http://www.isotc211.org/2005/gco"
					exclude-result-prefixes="gmd gco"
					>

	<!-- This parameter must be set by the browser -->
	<xsl:param name="basePath"/>
	
	<!-- variable used by javascript function createSection -->
	<xsl:param name="customPosition" select="-1"/>

	<!-- template library to use for making element editable -->
	<xsl:include href="picklists/metadataPicklists.xsl"/>
	<xsl:include href="includes/editableCore.xsl"/>	

	<xsl:output	
					doctype-public="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
					doctype-system="-//W3C//DTD XHTML 1.0 Strict//EN"
					method="xml" omit-xml-declaration="no" indent="yes"
					/>
	
				
				

	<!--
	Auteur: Erik van de Pol. B3Partners.

	Beschrijving stylesheet:
	In het algemeen geldt dat voor elke property (waarde/xml-node/xml-tag) een apart template is gemaakt.
	-->
	
	<xsl:template match="node()[@xlink:href]">
		<xsl:apply-templates select="id(@xlink:href)"/>
	</xsl:template>

	
	<xsl:template match="/">
		<xsl:call-template name="gmd:MD_Metadata"/>
	</xsl:template>


	<xsl:template name="gmd:MD_Metadata">
		<div id="edit-doc-root" changed="false">
			
			<div id="properties-box">
				<xsl:call-template name="overzicht-tab"/>
			</div>
			
			<!-- picklists -->
			<div class="hidden">
				<xsl:call-template name="picklist_CI_DateTypeCode"/>
				<xsl:call-template name="picklist_CI_OnLineFunctionCode"/>
				<xsl:call-template name="picklist_CI_PresentationFormCode"/>
				<xsl:call-template name="picklist_CI_RoleCode"/>
				<xsl:call-template name="picklist_DQ_EvaluationMethodTypeCode"/>
				<xsl:call-template name="picklist_DS_AssociationTypeCode"/>
				<xsl:call-template name="picklist_DS_InitiativeTypeCode"/>
				<xsl:call-template name="picklist_MD_CellGeometryCode"/>
				<xsl:call-template name="picklist_MD_CharacterSetCode"/>
				<xsl:call-template name="picklist_MD_ClassificationCode"/>
				<xsl:call-template name="picklist_MD_CoverageContentTypeCode"/>
				<xsl:call-template name="picklist_MD_DatatypeCode"/>
				<xsl:call-template name="picklist_MD_DimensionNameTypeCode"/>
				<xsl:call-template name="picklist_MD_GeometricObjectTypeCode"/>
				<xsl:call-template name="picklist_MD_ImagingConditionCode"/>
				<xsl:call-template name="picklist_MD_KeywordTypeCode"/>
				<xsl:call-template name="picklist_MD_MaintenanceFrequencyCode"/>
				<xsl:call-template name="picklist_MD_MediumFormatCode"/>
				<xsl:call-template name="picklist_MD_MediumNameCode"/>
				<xsl:call-template name="picklist_MD_ObligationCode"/>
				<xsl:call-template name="picklist_MD_PixelOrientationCode"/>
				<xsl:call-template name="picklist_MD_ProgressCode"/>
				<xsl:call-template name="picklist_MD_RestrictionCode"/>
				<xsl:call-template name="picklist_MD_ScopeCode"/>
				<xsl:call-template name="picklist_MD_SpatialRepresentationTypeCode"/>
				<xsl:call-template name="picklist_MD_TopicCategoryCode"/>
				<xsl:call-template name="picklist_MD_TopologyLevelCode"/>
			</div>
			
		</div>
	</xsl:template>
	
	<!-- ============== -->
	<!-- TAB DEFINITIONS -->
	<!-- ============== -->

	<xsl:template name="overzicht-tab">
		<div id="overzicht" style="display:block">
		
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:language"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:characterSet"/>

			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:contact"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:distributionInfo//gmd:distributor"/>

			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:dateStamp"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:metadataStandardName"/>			
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:metadataStandardVersion"/>
			
			<!-- Als het goed is, is er maar één sectie hiervan. Maar als er meerdere zijn printen we ze op een mooie manier -->
			<xsl:for-each select="/gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
				<xsl:call-template name="referentieSysteem"/>
			</xsl:for-each>				
			
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date"/>

			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:status"/>
			
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:descriptiveKeywords//gmd:keyword"/>			
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:useLimitation"/>
			<!--<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:accessConstraints"/>-->
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:metadataConstraints/gmd:MD_SecurityConstraints/gmd:classification"/>
			
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:characterSet"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory"/>

			<!-- Als het goed is, is er maar één sectie hiervan. Maar als er meerdere zijn printen we ze op een mooie manier -->
			<xsl:for-each select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:extent//gmd:EX_GeographicBoundingBox">
				<xsl:call-template name="omgrenzendeRechthoek"/>
			</xsl:for-each>
			
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:dataQualityInfo//gmd:scope//gmd:level"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:dataQualityInfo//gmd:DQ_QuantitativeResult//gmd:value"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:dataQualityInfo//gmd:lineage//gmd:statement"/>
			
		</div>
	</xsl:template>
	
	<xsl:template name="attributen-tab">
		<div id="attributen" style="display:block">

		</div>
	</xsl:template>
	
	<xsl:template name="specificaties-tab">
		<div id="specificaties" style="display:block">

		</div>
	</xsl:template>

</xsl:stylesheet>
