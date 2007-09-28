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

	<!-- template library to use for making element editable -->
	<xsl:include href="includes/editableElements.xsl"/>
	<xsl:include href="picklists/metadataPicklists.xsl"/>
	<!-- template library to use for showing basic types of ISO 19139 -->
	<!--<xsl:include href="includes/editableBasicTypes.xsl"/>-->

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
			<div>
				<table id="main-menu" width="300" height="30" cellspacing="0" cellpadding="0">
					<tr>
						<td id="overzicht-tab" class="tab-unselected" onmouseover="tabHover(this)" onclick="changeTab(this)" title="Klik hier voor een overzicht van de dataset">Overzicht</td>
						<td id="attributen-tab" class="tab-unselected" onmouseover="tabHover(this)" onclick="changeTab(this)" title="Klik hier voor informatie over de attributen van de dataset">Attributen</td>
						<td id="specificaties-tab" class="tab-unselected" onmouseover="tabHover(this)" onclick="changeTab(this)" title="Klik hier voor informatie over de specificaties van de dataset">Specificaties</td>
					</tr>
				</table>
			</div>
			
			<div id="properties-box">
				<xsl:call-template name="overzicht-tab"/>
				<xsl:call-template name="attributen-tab"/>
				<xsl:call-template name="specificaties-tab"/>
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

			<xsl:for-each select="/gmd:MD_Metadata/gmd:contact">
				<xsl:call-template name="metadataVerantwoordelijkeOrganisatie"/>
			</xsl:for-each>
			<xsl:for-each select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact">
				<xsl:call-template name="datasetVerantwoordelijkeOrganisatie"/>
			</xsl:for-each>
			<xsl:for-each select="/gmd:MD_Metadata/gmd:distributionInfo//gmd:distributor//gmd:distributorContact">
				<xsl:call-template name="distribuerendeOrganisatie"/>
			</xsl:for-each>

			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:dateStamp"/>
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:metadataStandardName"/>			
			<xsl:apply-templates select="/gmd:MD_Metadata/gmd:metadataStandardVersion"/>
			
			<xsl:call-template name="referentieSysteem"/>
			
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

			<xsl:call-template name="omgrenzendeRechthoek"/>
			
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
	

	<!-- ============ -->
	<!-- TAB CONTENT -->
	<!-- ============ -->

	

	<!-- OVERZICHT TAB -->

	<!-- 
			Overweging: ISO nummers zijn in principe algemeen en kunnen worden hergebruikt. 
			In de huidige implementatie ga ik er van uit dat de de ISO nummers niet worden hergebruikt.
			De titel is namelijk specifiek.
	-->
	
	<!-- ISO nr. 3 -->
	<xsl:template match="gmd:MD_Metadata/gmd:language/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Metadata taal</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 4 -->
	<xsl:template match="gmd:MD_Metadata/gmd:characterSet/gmd:MD_CharacterSetCode">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Metadata karakterset</xsl:with-param>
			<xsl:with-param name="picklist">picklist_MD_CharacterSetCode</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 9 -->
	<xsl:template match="gmd:MD_Metadata/gmd:dateStamp/gco:Date">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Metadata wijzigingsdatum</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 10 -->
	<xsl:template match="gmd:metadataStandardName/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Naam metadata standaard</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 11 -->
	<xsl:template match="gmd:metadataStandardVersion/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Versie metadata standaard</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 25 -->
	<xsl:template match="gmd:abstract/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Samenvatting</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 28 -->
	<xsl:template match="gmd:status/gmd:MD_ProgressCode">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Status</xsl:with-param>
			<xsl:with-param name="picklist">picklist_MD_ProgressCode</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr.37 -->
	<xsl:template match="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Ruimtelijk schema</xsl:with-param>
			<xsl:with-param name="picklist">picklist_MD_SpatialRepresentationTypeCode</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 39 -->
	<xsl:template match="gmd:identificationInfo//gmd:language/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Dataset taal</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 40 -->
	<xsl:template match="gmd:identificationInfo//gmd:characterSet">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Dataset karakterset</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 41 -->
	<xsl:template match="gmd:identificationInfo//gmd:topicCategory/gmd:MD_TopicCategoryCode">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Thema</xsl:with-param>
			<xsl:with-param name="picklist">picklist_MD_TopicCategoryCode</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 53 -->
	<!-- TODO: meerdere trefwoorden netjes weergeven -->
	<xsl:template match="gmd:keyword">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Trefwoorden</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 68 -->
	<xsl:template match="gmd:useLimitation">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Gebruiksbeperkingen</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 70  bestaat niet?????? is vervangen door de volgende, lijkt me -->
	<xsl:template match="gmd:MD_SecurityConstraints/gmd:classification/gmd:MD_ClassificationCode">
		<xsl:call-template name="element">
			<xsl:with-param name="title">(Juridische) toegangsrestricties</xsl:with-param>
			<xsl:with-param name="picklist">picklist_MD_ClassificationCode</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
		<!-- (Niet helemaal ISO nr. 13/186 referentieSysteem) -->
	<xsl:template name="referentieSysteem">
		<div class="section">
			<xsl:call-template name="section-title">
				<xsl:with-param name="title">Referentie systeem</xsl:with-param>
			</xsl:call-template>
			<div class="section-content">
				<xsl:apply-templates select="/gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem//gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code"/>
				<xsl:apply-templates select="/gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem//gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:codeSpace"/>
			</div>
		</div>
		<xsl:call-template name="br"/>		
	</xsl:template>

	<!-- ISO nr. 207 -->
	<xsl:template match="gmd:code/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Code referentiesysteem</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 208.1 ? -->
	<xsl:template match="gmd:codeSpace/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">ID namespace referentiesysteem</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- TODO: ?alle? nodes (mogelijk) werkend met xlink -->
	<xsl:template name="metadataVerantwoordelijkeOrganisatie">
		<div class="section">
			<xsl:call-template name="section-title">
				<xsl:with-param name="title">Organisatie verantwoordelijk voor metadata</xsl:with-param>
			</xsl:call-template>
			<div class="section-content">
				<xsl:apply-templates select="gmd:CI_ResponsibleParty"/>
			</div>
		</div>
		<xsl:call-template name="br"/>
	</xsl:template>

	<xsl:template name="datasetVerantwoordelijkeOrganisatie">
		<div class="section">
			<xsl:call-template name="section-title">
				<xsl:with-param name="title">Organisatie verantwoordelijk voor dataset</xsl:with-param>
			</xsl:call-template>
			<div class="section-content">
				<xsl:apply-templates select="gmd:CI_ResponsibleParty"/>
			</div>
		</div>
		<xsl:call-template name="br"/>
	</xsl:template>

	<xsl:template name="distribuerendeOrganisatie">
		<div class="section">
			<xsl:call-template name="section-title">
				<xsl:with-param name="title">Distribuerende organisatie</xsl:with-param>
			</xsl:call-template>
			<div class="section-content">
				<xsl:apply-templates select="gmd:CI_ResponsibleParty"/>
			</div>
		</div>
		<xsl:call-template name="br"/>
	</xsl:template>
	
	<xsl:template match="gmd:CI_ResponsibleParty">
		<xsl:apply-templates select="gmd:organisationName"/>
		<xsl:apply-templates select="gmd:role"/>		
		<xsl:apply-templates select="gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage"/>
	</xsl:template>

	<!-- ISO nr. 360 --> <!-- gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/-->
	<xsl:template match="gmd:title/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Dataset titel</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 362/394 -->
	<xsl:template match="gmd:date/gco:Date">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Dataset referentie datum</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 376 -->
	<xsl:template match="gmd:organisationName/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Naam organisatie</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 379 -->
	<xsl:template match="gmd:role/gmd:CI_RoleCode">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Rol organisatie</xsl:with-param>
			<xsl:with-param name="picklist">picklist_CI_RoleCode</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 397 -->
	<xsl:template name="link">
		<xsl:call-template name="element">
			<xsl:with-param name="title">URL organisatie</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 397 -->
	<xsl:template match="gmd:linkage/gmd:URL">
		<xsl:call-template name="element">
			<xsl:with-param name="title">URL organisatie</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Omgrenzende rechthoek (is vervangen door polygon in ISO19139 !?!)-->
	<xsl:template name="omgrenzendeRechthoek">
		<div class="section">
			<xsl:call-template name="section-title">
				<xsl:with-param name="title">Omgrenzende rechthoek</xsl:with-param>
			</xsl:call-template>
			<div class="section-content">
				<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:extent//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"/>
				<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:extent//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"/>
				<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:extent//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/>							
				<xsl:apply-templates select="/gmd:MD_Metadata/gmd:identificationInfo//gmd:extent//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal"/>
			</div>
		</div>
		<xsl:call-template name="br"/>
	</xsl:template>

	<!-- ISO nr. 139 -->
	<xsl:template match="gmd:dataQualityInfo//gmd:level/gmd:MD_ScopeCode">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Data kwaliteitsniveau</xsl:with-param>
			<xsl:with-param name="picklist">picklist_MD_ScopeCode</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 137 -->
	<xsl:template match="gmd:dataQualityInfo//gmd:DQ_QuantitativeResult//gmd:value">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Geometrische nauwkeurigheid</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ISO nr. 83 -->
	<xsl:template match="gmd:lineage//gmd:statement/gco:CharacterString">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Algemene beschrijving herkomst</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 344 -->
	<xsl:template match="gmd:identificationInfo//gmd:extent//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Minimum x</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 345 -->
	<xsl:template match="gmd:identificationInfo//gmd:extent//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Maximum x</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 346 -->
	<xsl:template match="gmd:identificationInfo//gmd:extent//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Minimum y</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ISO nr. 347 -->
	<xsl:template match="gmd:identificationInfo//gmd:extent//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal">
		<xsl:call-template name="element">
			<xsl:with-param name="title">Maximum y</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	

</xsl:stylesheet>
