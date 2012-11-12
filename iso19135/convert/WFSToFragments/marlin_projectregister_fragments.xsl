<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
		xmlns:app="http://www.deegree.org/app"
		xmlns:gco="http://www.isotc211.org/2005/gco"
		xmlns:grg="http://www.isotc211.org/2005/grg"
		xmlns:gnreg="http://geonetwork-opensource.org/register"
		xmlns:gmd="http://www.isotc211.org/2005/gmd"
		xmlns:gmx="http://www.isotc211.org/2005/gmx"
		xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
		xmlns:gml="http://www.opengis.net/gml"
		xmlns:wfs="http://www.opengis.net/wfs"
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"		
		xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

	<!-- 
			 This xslt transforms GetFeature outputs from the WFS Marlin database
	     into ISO metadata fragments. The fragments are used by GeoNetwork to 
			 build ISO metadata records.
	 -->

	<xsl:template match="wfs:FeatureCollection">
		<records>
			<xsl:message>Processing <xsl:value-of select="@numberOfFeatures"/></xsl:message>
			<xsl:if test="boolean( ./@timeStamp )">
				<xsl:attribute name="timeStamp">
					<xsl:value-of select="./@timeStamp"></xsl:value-of>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="boolean( ./@lockId )">
				<xsl:attribute name="lockId">
					<xsl:value-of select="./@lockId"></xsl:value-of>
				</xsl:attribute>
			</xsl:if>

			<xsl:variable name="uuid">
				<xsl:choose>
					<xsl:when test="gml:featureMember/app:MarlinProjects">
						<xsl:value-of select="'urn:marine.csiro.au:projectregister'"/>
					</xsl:when>
					<xsl:when test="gml:featureMember/app:MarlinGlobalProjects">
						<xsl:value-of select="'urn:marine.csiro.au:globalprojectregister'"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<record uuid="{$uuid}">
				<replacementGroup id="register_item">
					<xsl:apply-templates select="gml:featureMember">
						<xsl:with-param name="uuid" select="$uuid"/>
					</xsl:apply-templates>
				</replacementGroup>
			</record>
		</records>
	</xsl:template>

	<xsl:template match="*[@xlink:href]" priority="20">
		<xsl:variable name="linkid" select="substring-after(@xlink:href,'#')"/>
		<xsl:apply-templates select="//*[@gml:id=$linkid]"/>
	</xsl:template>

	<!-- process a record from the MarLIN projects table -->
	<xsl:template name="addProjectRegisterItem">
		<xsl:param name="keywordUuid"/>

		<fragment id="register_item" uuid="{$keywordUuid}" title="{substring(normalize-space(app:project_name),1,200)}">
			<grg:containedItem>
				<gnreg:RE_RegisterItem>
					<grg:itemIdentifier>
						<gco:Integer><xsl:value-of select="app:project_id"/></gco:Integer>
					</grg:itemIdentifier>
					<grg:name>
						<gco:CharacterString><xsl:value-of select="concat('urn:marine.csiro.au:project:',app:project_id)"/></gco:CharacterString>
					</grg:name>
					<grg:status>
						<grg:RE_ItemStatus>valid</grg:RE_ItemStatus>
					</grg:status>
					<grg:dateAccepted>
						<gco:Date>2012-06-30</gco:Date>
					</grg:dateAccepted>
					<grg:definition>
						<gco:CharacterString><xsl:value-of select="app:project_name"/></gco:CharacterString>
					</grg:definition>
					<grg:fieldOfApplication>
						<grg:RE_FieldOfApplication>
							<grg:name>
								<gco:CharacterString>CSIRO Marine and Atmospheric Research Metadata</gco:CharacterString>
							</grg:name>
							<grg:description>
								<gco:CharacterString>CSIRO Marine and Atmospheric Research Metadata</gco:CharacterString>
							</grg:description>
						</grg:RE_FieldOfApplication>
					</grg:fieldOfApplication>
          <grg:additionInformation>
            <grg:RE_AdditionInformation>
               <grg:dateProposed>
                  <gco:Date>2012-06-30</gco:Date>
               </grg:dateProposed>
               <grg:justification>
                  <gco:CharacterString>Assembling ISO19135 register to describe this thesaurus</gco:CharacterString>
               </grg:justification>
               <grg:status>
                  <grg:RE_DecisionStatus>final</grg:RE_DecisionStatus>
               </grg:status>
               <grg:sponsor xlink:href="#CMAR_Submitter"/>
            </grg:RE_AdditionInformation>
          </grg:additionInformation>
					<gnreg:itemIdentifier>
						<gco:CharacterString><xsl:value-of select="$keywordUuid"/></gco:CharacterString>
					</gnreg:itemIdentifier>
				</gnreg:RE_RegisterItem>
			</grg:containedItem>
		</fragment>
	</xsl:template>

	<!-- process a record from the MarLIN global projects table -->
	<xsl:template name="addGlobalProjectRegisterItem">
		<xsl:param name="keywordUuid"/>

		<fragment id="register_item" uuid="{$keywordUuid}" title="{substring(normalize-space(app:global_project_full_name),1,200)}">
			<grg:containedItem>
				<grg:RE_RegisterItem>
					<grg:itemIdentifier>
						<gco:Integer><xsl:value-of select="app:global_project_id"/></gco:Integer>
					</grg:itemIdentifier>
					<grg:name>
						<gco:CharacterString><xsl:value-of select="concat('urn:marine.csiro.au:globalproject:',app:global_project_id)"/></gco:CharacterString>
					</grg:name>
					<grg:status>
						<grg:RE_ItemStatus>valid</grg:RE_ItemStatus>
					</grg:status>
					<grg:dateAccepted>
						<gco:Date>2011-07-06</gco:Date>
					</grg:dateAccepted>
					<grg:definition>
						<gco:CharacterString><xsl:value-of select="concat(app:global_project_full_name,' (', app:global_project_abbr, ')')"/></gco:CharacterString>
					</grg:definition>
					<grg:fieldOfApplication>
						<grg:RE_FieldOfApplication>
							<grg:name>
								<gco:CharacterString>CSIRO Marine and Atmospheric Research Metadata</gco:CharacterString>
							</grg:name>
							<grg:description>
								<gco:CharacterString>CSIRO Marine and Atmospheric Research Metadata</gco:CharacterString>
							</grg:description>
						</grg:RE_FieldOfApplication>
					</grg:fieldOfApplication>
          <grg:additionInformation>
            <grg:RE_AdditionInformation>
               <grg:dateProposed>
                  <gco:Date>2012-06-30</gco:Date>
               </grg:dateProposed>
               <grg:justification>
                  <gco:CharacterString>Assembling ISO19135 register to describe this thesaurus</gco:CharacterString>
               </grg:justification>
               <grg:status>
                  <grg:RE_DecisionStatus>final</grg:RE_DecisionStatus>
               </grg:status>
               <grg:sponsor xlink:href="#CMAR_Submitter"/>
            </grg:RE_AdditionInformation>
          </grg:additionInformation>
					<grg:itemClass xlink:href="#Item_Class"/>
					<gnreg:itemIdentifier>
						<gco:CharacterString><xsl:value-of select="$keywordUuid"/></gco:CharacterString>
					</gnreg:itemIdentifier>
				</grg:RE_RegisterItem>
			</grg:containedItem>
		</fragment>
	</xsl:template>

	<!-- process the featureMember elements in WFS response -->
	<xsl:template match="gml:featureMember">
		<xsl:param name="uuid"/>
		
		<xsl:apply-templates select="app:MarlinProjects">
			<xsl:with-param name="uuid" select="$uuid"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="app:MarlinGlobalProjects">
			<xsl:with-param name="uuid" select="$uuid"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- process the MarlinProjects in WFS response -->
	<xsl:template match="app:MarlinProjects">
			<xsl:param name="uuid"/>

			<xsl:call-template name="addProjectRegisterItem">
				<xsl:with-param name="keywordUuid" select="concat($uuid,':concept:',app:project_id)"/>
			</xsl:call-template>

	</xsl:template>

	<!-- process the MarlinGlobalProjects in WFS response -->
	<xsl:template match="app:MarlinGlobalProjects">
			<xsl:param name="uuid"/>

			<xsl:call-template name="addGlobalProjectRegisterItem">
				<xsl:with-param name="keywordUuid" select="concat($uuid,':concept:',app:global_project_id)"/>
			</xsl:call-template>

	</xsl:template>


</xsl:stylesheet>
