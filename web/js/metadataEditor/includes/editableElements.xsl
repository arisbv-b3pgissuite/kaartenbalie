<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet 					
					version="1.0"
					xmlns="http://www.w3.org/1999/xhtml"
					xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					>



	<!-- 	
		Auteur: Erik van de Pol. B3Partners.

		Dependencies (for this XSL):
			functions.xsl = some basic XML functions
	
		 Dependencies (of resulting HTML page):
			(These dependencies should all be handled by the calling stylesheet)
			* Javascript code for handling dhtml
	-->
	
	<!-- XSL script and function library -->
	<!--<xsl:import href="functions.xsl"/>-->
	<xsl:include href="functions.xsl"/>	
	
	<!-- self reference text ('this' for JavaScript, 'me' for VBScript -->
	<xsl:variable name="SELF_REF">this</xsl:variable>

	<!-- default text for elements with no default value specified -->
	<xsl:variable name="GLOBAL_DEFAULT">Klik hier om deze tekst te bewerken.</xsl:variable>

	<!-- add/delete elements/sections menu text -->
	<xsl:variable name="ADD_ELEMENT_ABOVE_TEXT">Voeg element hierboven toe</xsl:variable>
	<xsl:variable name="ADD_ELEMENT_BELOW_TEXT">Voeg element hieronder toe</xsl:variable>
	<xsl:variable name="DELETE_ELEMENT_TEXT">Verwijder dit element</xsl:variable>
	<xsl:variable name="ADD_SECTION_ABOVE_TEXT">Voeg sectie hierboven toe</xsl:variable>
	<xsl:variable name="ADD_SECTION_BELOW_TEXT">Voeg sectie hieronder toe</xsl:variable>
	<xsl:variable name="DELETE_SECTION_TEXT">Verwijder deze sectie</xsl:variable>
	<xsl:variable name="ADD_CHILD_TEXT">Voeg nieuw kind toe</xsl:variable>
	
	<!-- expand/collapse section and menu image paths -->
	<xsl:variable name="EXPAND_TEXT">Klap deze sectie in/uit</xsl:variable>
	
	<xsl:variable name="PLUS_IMAGE"><xsl:value-of select="$basePath"/>images/xp_plus.gif</xsl:variable>
	<xsl:variable name="MINUS_IMAGE"><xsl:value-of select="$basePath"/>images/xp_minus.gif</xsl:variable>
	<xsl:variable name="MENU_IMAGE"><xsl:value-of select="$basePath"/>images/arrow.gif</xsl:variable>
	
	<xsl:variable name="MENU_TOOLTIP">Klik om opties te zien</xsl:variable>
	
	
	
	
	<!-- ============================================ -->
	<!-- TEMPLATE FUNCTIONS FOR FULLXML STYLESHEETS -->
	<!-- ============================================ -->


	<!-- TEMPLATE: voor een element dat verandert kan worden door de gebruiker. Het kiest per default het huidige pad als element dat geëdit kan worden -->
	<xsl:template name="element">
		<xsl:param name="title"/> <!-- verplicht voor mooie weergave -->
		<xsl:param name="picklist"/>
		<xsl:param name="path" select="."/>
		<xsl:param name="default-value"/>
		<xsl:param name="optionality" select="'optional'"/><!-- 'mandatory' of 'optional' of leeg (= mandatory). Mandatory wordt altijd opgeslagen -->
		<xsl:param name="help-text"/>
		
		<xsl:variable name="class">
			<xsl:choose>
				<xsl:when test="$optionality = 'mandatory'">
					<xsl:text>element-mandatory</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>element</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<p class="{$class}">
			<xsl:if test="$title != ''">
				<span class="key"><xsl:value-of select="$title"/>: </span>
			</xsl:if>
			<xsl:element name="span">
				<xsl:attribute name="fullPath">
					<xsl:call-template name="full-path">					
						<xsl:with-param name="theParmNodes" select="$path"/>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="title"><xsl:value-of select="$help-text"/></xsl:attribute>
				<xsl:attribute name="default"><xsl:value-of select="$default-value"/></xsl:attribute>
				<xsl:attribute name="optionality"><xsl:value-of select="$optionality" /></xsl:attribute>
				<xsl:attribute name="onclick">startEdit(event)</xsl:attribute>
				<xsl:if test="$picklist != ''">
					<xsl:attribute name="picklist"><xsl:value-of select="$picklist"/></xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<!-- check of de inhoud van $element_path leeg is -->
					<xsl:when test="normalize-space($path)">
						<xsl:attribute name="class">unchanged-value</xsl:attribute>
						
						<!-- HIER uitkijken: types moeten hieruit gedestilleerd worden -->
						<!--<xsl:value-of select="$element_path"/>-->
						<xsl:value-of select="normalize-space($path)"/>
						<!--<xsl:apply-templates select=".//"/> -->
						
					</xsl:when>
					<xsl:when test="@codeListValue != '' ">
						<xsl:attribute name="class">unchanged-value</xsl:attribute>
						<xsl:value-of select="normalize-space(@codeListValue)"/>
					</xsl:when>							
					<xsl:otherwise>
						<!-- set value to default, set changed to true; ?Niet doen: default values niet opslaan dus? inderdaad-->
						<xsl:attribute name="class">default-value</xsl:attribute>
						<xsl:attribute name="changed">false</xsl:attribute>
						<xsl:choose>
							<xsl:when test="$default-value != ''">
								<xsl:value-of select="$default-value"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$GLOBAL_DEFAULT"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</p>

	</xsl:template>
	
	
	
	<!-- TEMPLATE: for (repeating) section -->
	<xsl:template name="section">
		<xsl:param name="title"/>
		<xsl:param name="section-path" select="."/>
		<xsl:param name="expanding" select="'true'"/>
		<xsl:param name="expanded" select="'true'"/>
		<xsl:param name="repeatable" select="'false'"/>
		<xsl:param name="add-child"/>
		

		<!-- display each repeating section -->
		<div class="section" section-path="{$section-path}" id="{$section-path}">

			<xsl:call-template name="section-title">
				<xsl:with-param name="title" select="$title"/>
				<xsl:with-param name="section-path" select="$section-path"/>
				<xsl:with-param name="expanding" select="$expanding"/>
				<xsl:with-param name="expanded" select="$expanded"/>
				<xsl:with-param name="repeatable" select="$repeatable"/>
				<xsl:with-param name="add-child" select="$add-child"/>
			</xsl:call-template>

			<!-- add subelements of section within a "section-content" DIV-->
			<xsl:element name="div">
				<xsl:attribute name="class">section-content</xsl:attribute>
				<!-- start collapsed? -->
				<xsl:if test="$expanded != 'true'">
					<xsl:attribute name="style">display:none;</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<!-- valid local name? -->
					<xsl:when test="local-name()">
						<xsl:element name="{local-name()}">
							<xsl:apply-templates/>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<!-- error, missing local-name, display message -->

						<h2 class="error">Transform error: Local name is blank</h2>
						<p class="error">local-name() = <xsl:value-of select="local-name()" /></p>
						<p class="error">name() = <xsl:value-of select="name()"/></p>

					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

		</div>
	

	</xsl:template>
	




	<!-- TEMPLATE: for section-title -->
	<!-- 
	Gebruik in plaats van "section" "section-title" in combinatie met een <div class="content"/> met daarin de content van de section
	om custom content toe te voegen aan de sectie (of in de praktijk vaak om de volgorde van de content-tags te veranderen).
	Template "section" verkrijgt zijn content door <xsl:apply-templates/> aan te roepen.
	-->
	<xsl:template name="section-title">
		<xsl:param name="title"/>
		<xsl:param name="section-path" select="."/>
		<xsl:param name="expanding" select="'true'"/>
		<xsl:param name="expanded" select="'true'"/>
		<xsl:param name="repeatable" select="'false'"/>
		<xsl:param name="add-child"/>
		
		<xsl:choose>
			<xsl:when test="$expanding = 'true'"> 
				<a href="javascript:void(0)" onclick="expandNode(this);return false;" class="expandable" title="{$EXPAND_TEXT}">
					<!-- start expanded or collapsed? -->
					<xsl:choose>
						<xsl:when test="$expanded = 'true'">
							<img class="plus-minus" src="{$MINUS_IMAGE}"/>
						</xsl:when>
						<xsl:otherwise>
							<img class="plus-minus" src="{$PLUS_IMAGE}"/>
						</xsl:otherwise>
					</xsl:choose>

					<span class="section-title" onmouseover="sectionTitleHover(this);"><xsl:value-of select="$title"/></span>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<span class="section-title"><xsl:value-of select="$title"/></span>
			</xsl:otherwise>
		</xsl:choose>
		
		<!-- add popup menu for repeat section options -->
		<xsl:if test="$repeatable = 'true' ">
			<xsl:variable name="imgclass">
				<xsl:choose>
					<xsl:when test="$expanding = 'true'">
						<xsl:text>menuimg</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text></xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<span class="{$imgclass}" onclick="showMenu(event);" onmouseout="hideMenu(event);" onmouseleave="hideMenuIE(event);">
				<xsl:element name="img">
					<xsl:attribute name="src"><xsl:value-of select="$MENU_IMAGE"/></xsl:attribute>
					<xsl:attribute name="title"><xsl:value-of select="$MENU_TOOLTIP"/></xsl:attribute>
				</xsl:element>
				<ul class="menu">
					<li class="menuaddabove">
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:void(0)</xsl:attribute>
							<xsl:attribute name="onclick">addSection(<xsl:value-of select="$SELF_REF"/>,'<xsl:value-of select="$section-path"/>',true)</xsl:attribute>
							<xsl:value-of select="$ADD_SECTION_ABOVE_TEXT"/>
						</xsl:element>
					</li>
					<li class="menuaddbelow">
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:void(0)</xsl:attribute>
							<xsl:attribute name="onclick">addSection(<xsl:value-of select="$SELF_REF"/>,'<xsl:value-of select="$section-path"/>',false)</xsl:attribute>
							<xsl:value-of select="$ADD_SECTION_BELOW_TEXT"/>
						</xsl:element>
					</li>
					<li class="menudelete">
						<xsl:element name="a">
							<xsl:attribute name="href">javascript:void(0)</xsl:attribute>
							<xsl:attribute name="onclick">deleteSection(<xsl:value-of select="$SELF_REF"/>,'<xsl:value-of select="$section-path"/>')</xsl:attribute>
							<xsl:value-of select="$DELETE_SECTION_TEXT"/>
						</xsl:element>
					</li>
					<!-- add menu option for add child? -->
					<xsl:if test="$add-child = 'true'">
						<li class="menuaddchild">
							<xsl:element name="a">
								<xsl:attribute name="href">javascript:void(0)</xsl:attribute>
								<xsl:attribute name="onclick">addChild(<xsl:value-of select="$SELF_REF"/>,'<xsl:value-of select="$section-path"/>')</xsl:attribute>
								<xsl:value-of select="$ADD_CHILD_TEXT"/>
							</xsl:element>
						</li>
					</xsl:if>
				</ul>
			</span>
		</xsl:if>

	</xsl:template>
	

	<!-- TEMPLATE: geeft een separator weer in fullXML mode -->
	<xsl:template name="separator">
		<div class="separator">_________________</div>
	</xsl:template>
	
	<xsl:template name="br">
		<br/>
	</xsl:template>
	
	<!-- TEMPLATE: geeft een anchor weer -->
	<xsl:template name="anchor">
		<xsl:param name="href" select="."/>
		<xsl:param name="name-shown">no name</xsl:param>
		<xsl:param name="target">viewer</xsl:param>

		<xsl:element name="a">
			<!--<xsl:attribute name="xmlns">http://www.w3.org/1999/xhtml</xsl:attribute>-->
			<xsl:attribute name="href"><xsl:value-of select="$href"/></xsl:attribute>
			<xsl:attribute name="target"><xsl:value-of select="$target"/></xsl:attribute>
			<xsl:value-of select="$name-shown"/>
		</xsl:element>

	</xsl:template>
	
	<!-- TEMPLATE: geeft een mailto-anchor weer -->
	<xsl:template name="mailtoAnchor">
		<xsl:param name="email" select="."/>
		<xsl:param name="name-shown">no name</xsl:param>

		<xsl:element name="a">
			<!--<xsl:attribute name="xmlns">http://www.w3.org/1999/xhtml</xsl:attribute>-->
			<xsl:attribute name="href">mailto:<xsl:value-of select="$email"/></xsl:attribute>
			<xsl:value-of select="$name-shown"/>
		</xsl:element>

	</xsl:template>
	

</xsl:stylesheet>
