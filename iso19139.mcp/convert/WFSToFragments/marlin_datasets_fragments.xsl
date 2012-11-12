<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
		xmlns:app="http://www.deegree.org/app"
		xmlns:gco="http://www.isotc211.org/2005/gco"
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
	<xsl:param name="siteUrl"/>

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

	<xsl:include href="marlin_globals.xsl"/>

	<!-- <xsl:variable name="geoserver" select="document('geoserver.dc.xml')"/> -->
	<xsl:variable name="geoserver" select="wfs:FeatureCollection/*[1]"/>

	<!-- 
			 This xslt transforms GetFeature outputs from the WFS Marlin database
	     into ISO metadata fragments. The fragments are used by GeoNetwork to 
			 build ISO metadata records.
	 -->

	<xsl:template match="wfs:FeatureCollection">
		<records>
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

			<xsl:message>Processing <xsl:value-of select="@numberOfFeatures"/></xsl:message>
			<xsl:apply-templates select="gml:featureMember"/>
		</records>
	</xsl:template>

	<xsl:template match="app:MarlinUnits">
		<xsl:choose>
			<xsl:when test="app:unit_abbreviation!=''">
				<xsl:value-of select="app:unit_abbreviation"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'unknown'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="addExtentKeywordsSection">
		<xsl:param name="title"/>

		<xsl:variable name="uuidThe" select="'urn:marine.csiro.au:keywords:region'"/>
		<fragment id="keywords">
			<gmd:descriptiveKeywords>
				<gmd:MD_Keywords>
					<xsl:for-each select="app:region/app:MarlinDatasetRegions">
						<xsl:choose>
							<xsl:when test="app:anzlic_jurisdiction and app:anzlic_category and app:anzlic_name">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.place.{$uuidThe}&amp;id={$uuidThe}:concept:{app:defined_region_id}"><xsl:value-of select="concat(app:anzlic_jurisdiction,' > ',app:anzlic_category,' > ',app:anzlic_name)"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
							<xsl:when test="app:defined_region_name">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.place.{$uuidThe}&amp;id={$uuidThe}:concept:{app:defined_region_id}"><xsl:value-of select="app:defined_region_name"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
					<gmd:type>
						<gmd:MD_KeywordTypeCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="place"/>
					</gmd:type>
					<xsl:comment>thesaurus name for MarLIN Defined Regions</xsl:comment>
					<gmd:thesaurusName>
						<xsl:call-template name="addTheCitation">
        			<xsl:with-param name="title" select="'MarLIN Defined Regions Register'"/>
        			<xsl:with-param name="edition" select="''"/>
        			<xsl:with-param name="thesaurus" select="$uuidThe"/>
        			<xsl:with-param name="thesaurusType" select="'place'"/>
        			<xsl:with-param name="otherCit" select="'At some stage these defined regions have been based on those supplied in the ANZLIC Geographic Extent Names Register'"/>
        			<xsl:with-param name="siteUrl" select="$siteUrl"/>
						</xsl:call-template>
					</gmd:thesaurusName>
				</gmd:MD_Keywords>
			</gmd:descriptiveKeywords>
		</fragment>
	</xsl:template>

	<xsl:template name="addTypeAndName">
		<xsl:param name="title"/>
		<xsl:param name="edition"/>
		<xsl:param name="thesaurus"/>
		<xsl:param name="thesaurusType" select="'theme'"/>
		<xsl:param name="orgName" select="'CSIRO Marine and Atmospheric Research Data Centre'"/>
		<xsl:param name="otherCit" select="''"/>

		<gmd:type>
			<gmd:MD_KeywordTypeCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="{$thesaurusType}"/>
		</gmd:type>
		<gmd:thesaurusName>
			<xsl:call-template name="addTheCitation">
				<xsl:with-param name="title" select="$title"/>
				<xsl:with-param name="edition" select="$edition"/>
				<xsl:with-param name="thesaurus" select="$thesaurus"/>
				<xsl:with-param name="thesaurusType" select="$thesaurusType"/>
				<xsl:with-param name="orgName" select="$orgName"/>
				<xsl:with-param name="otherCit" select="$otherCit"/>
        <xsl:with-param name="siteUrl" select="$siteUrl"/>
			</xsl:call-template>
		</gmd:thesaurusName>
	</xsl:template>

	<xsl:template name="addKeywordsSection">
		<xsl:param name="type"/>
		<xsl:param name="title"/>

		<fragment id="keywords">
			<gmd:descriptiveKeywords>
				<gmd:MD_Keywords>
					<xsl:for-each select="current-group()">
						<xsl:choose>
							<xsl:when test="$type='C'">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.theme.{$cmarAOIThe}&amp;id={$cmarAOIThe}:concept:{app:keyword_id}"><xsl:value-of select="app:description"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
							<xsl:when test="$type='T'">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.theme.{$taxonomicGroupThe}&amp;id={$taxonomicGroupThe}:concept:{app:keyword_id}"><xsl:value-of select="app:description"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
							<xsl:when test="$type='H'">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.theme.{$habitatThe}&amp;id={$habitatThe}:concept:{app:keyword_id}"><xsl:value-of select="app:description"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
							<xsl:when test="$type='Q'">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.theme.{$standardDataTypeThe}&amp;id={$standardDataTypeThe}:concept:{app:keyword_id}"><xsl:value-of select="app:description"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
							<xsl:when test="$type='P'">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.theme.{$gcmdThe}&amp;id={$gcmdThe}:concept:{app:keyword_id}"><xsl:value-of select="app:description"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
							<xsl:when test="$type='E'">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.equipment.{$equipThe}&amp;id={$equipThe}:concept:{app:keyword_id}"><xsl:value-of select="app:description"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
							<xsl:when test="$type='D'">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.dataSource.{$dataSourceThe}&amp;id={$dataSourceThe}:concept:{app:keyword_id}"><xsl:value-of select="app:description"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
							<xsl:when test="$type='S'">
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.theme.{$subjectThe}&amp;id={$subjectThe}:concept:{app:keyword_id}"><xsl:value-of select="app:description"/></gmx:Anchor>
								</gmd:keyword>
							</xsl:when>
							<xsl:when test="$type='A'">
								<xsl:variable name="anzlicSearchWord">
									<xsl:choose>
										<xsl:when test="normalize-space(app:anzlic_qualifier)!=''">
											<xsl:value-of select="concat(app:anzlic_search_word,'-',app:anzlic_qualifier)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="app:anzlic_search_word"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<gmd:keyword>
									<gmx:Anchor xlink:href="{$siteUrl}/srv/en/xml.keyword.get?thesaurus=register.theme.{$anzlicThe}&amp;id={$anzlicThe}:concept:{app:keyword_id}"><xsl:value-of select="$anzlicSearchWord"/></gmx:Anchor>	
								</gmd:keyword>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>

					<xsl:choose>
						<xsl:when test="$type='C'">
							<xsl:comment>MarLIN Area of Interest Thesaurus</xsl:comment>
							<xsl:call-template name="addTypeAndName">
								<xsl:with-param name="title" select="'MarLIN Area of Interest Keyword Thesaurus'"/>
								<xsl:with-param name="edition" select="concat($cmarAOIThe,':conceptscheme#0.0')"/>
								<xsl:with-param name="thesaurus" select="$cmarAOIThe"/>
							</xsl:call-template>
						</xsl:when>

						<xsl:when test="$type='T'">
							<xsl:comment>MarLIN Taxonomic Group Thesaurus</xsl:comment>
							<xsl:call-template name="addTypeAndName">
								<xsl:with-param name="title" select="'MarLIN Taxonomic Group Keyword Thesaurus'"/>
								<xsl:with-param name="edition" select="concat($taxonomicGroupThe,':conceptscheme#0.0')"/>
								<xsl:with-param name="thesaurus" select="$taxonomicGroupThe"/>
							</xsl:call-template>
						</xsl:when>

						<xsl:when test="$type='H'">
							<xsl:comment>MarLIN Habitat Thesaurus</xsl:comment>
							<xsl:call-template name="addTypeAndName">
								<xsl:with-param name="title" select="'MarLIN Habitat Keyword Thesaurus'"/>
								<xsl:with-param name="edition" select="concat($habitatThe,':conceptscheme#0.0')"/>
								<xsl:with-param name="thesaurus" select="$habitatThe"/>
							</xsl:call-template>
						</xsl:when>

						<xsl:when test="$type='Q'">
							<xsl:comment>MarLIN Standard Data Type Thesaurus</xsl:comment>
							<xsl:call-template name="addTypeAndName">
								<xsl:with-param name="title" select="'MarLIN Standard Data Type Keyword Thesaurus'"/>
								<xsl:with-param name="edition" select="concat($standardDataTypeThe,':conceptscheme#0.0')"/>
								<xsl:with-param name="thesaurus" select="$standardDataTypeThe"/>
							</xsl:call-template>
						</xsl:when>

						<xsl:when test="$type='A'">
							<xsl:comment>MarLIN extended ANZLIC search words Thesaurus</xsl:comment> 
							<xsl:call-template name="addTypeAndName">
								<xsl:with-param name="title" select="'MarLIN extensions to Search words register from Australia New-Zealand Land Information Council - ANZLIC'"/>
								<xsl:with-param name="edition" select="concat($anzlicThe,':conceptscheme#0.0')"/>
								<xsl:with-param name="thesaurus" select="$anzlicThe"/>
							</xsl:call-template>
						</xsl:when>

						<xsl:when test="$type='P'">
							<xsl:comment>thesaurus name for GCMD</xsl:comment>
							<xsl:call-template name="addTypeAndName">
								<xsl:with-param name="title" select="'MarLIN Global Change Master Directory Earth Science Keywords'"/>
								<xsl:with-param name="edition" select="concat($gcmdThe,':conceptscheme#5.3.8+MarLIN')"/>
								<xsl:with-param name="thesaurus" select="$gcmdThe"/>
								<xsl:with-param name="orgName" select="'National Aeronautics and Space Administration (NASA)'"/>
								<xsl:with-param name="otherCit" select="'MarLIN extensions and the GCMD Earth Science Keywords from Olsen, L.M., G. Major, K. Shein, J. Scialdone, R. Vogel, S. Leicester, H. Weir, S. Ritz, T. Stevens, M. Meaux, C.Solomon, R. Bilodeau, M. Holland, T. Northcutt, R. A. Restrepo, 2007 .NASA/Global Change Master Directory (GCMD) Earth Science Keywords.'"/>
							</xsl:call-template>
						</xsl:when>

						<xsl:when test="$type='E'">
							<xsl:comment>MarLIN Equipment Thesaurus</xsl:comment>
							<xsl:call-template name="addTypeAndName">
								<xsl:with-param name="title" select="'MarLIN Equipment Keyword Thesaurus'"/>
								<xsl:with-param name="edition" select="concat($equipThe,':conceptscheme#0.0')"/>
								<xsl:with-param name="thesaurus" select="$equipThe"/>
								<xsl:with-param name="thesaurusType" select="'equipment'"/>
							</xsl:call-template>
						</xsl:when>

						<xsl:when test="$type='S'">
							<xsl:comment>MarLIN Subject Thesaurus</xsl:comment>
							<xsl:call-template name="addTypeAndName">
								<xsl:with-param name="title" select="'MarLIN Subject Keyword Thesaurus'"/>
								<xsl:with-param name="edition" select="concat($subjectThe,':conceptscheme#0.0')"/>
								<xsl:with-param name="thesaurus" select="$subjectThe"/>
							</xsl:call-template>
						</xsl:when>

						<xsl:when test="$type='D'">
							<xsl:comment>MarLIN Data Source Thesaurus</xsl:comment>
							<xsl:call-template name="addTypeAndName">
								<xsl:with-param name="title" select="'MarLIN Data Source Keyword Thesaurus'"/>
								<xsl:with-param name="edition" select="concat($dataSourceThe,':conceptscheme#0.0')"/>
								<xsl:with-param name="thesaurus" select="$dataSourceThe"/>
								<xsl:with-param name="thesaurusType" select="'dataSource'"/>
							</xsl:call-template>
						</xsl:when>

					</xsl:choose>
				</gmd:MD_Keywords>
			</gmd:descriptiveKeywords>
		</fragment>
	</xsl:template>

	<xsl:template name="addPersonParty">
		<xsl:param name="id"/>
		<xsl:param name="roleCode"/>

			<mcp:CI_Responsibility>
				<mcp:role>
					<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="{$roleCode}"/>
				</mcp:role>

				<mcp:party xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:person:',$id,'_person_organisation')}"/>
			</mcp:CI_Responsibility>
	</xsl:template>

	<xsl:template name="addUserParty">
		<xsl:param name="id"/>
		<xsl:param name="roleCode"/>

			<mcp:CI_Responsibility>
				<mcp:role>
					<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="{$roleCode}"/>
				</mcp:role>

				<mcp:party xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:user:',$id,'_user_organisation')}"/>
			</mcp:CI_Responsibility>
	</xsl:template>

	<xsl:template name="addOrganisationParty">
		<xsl:param name="id"/>
		<xsl:param name="roleCode"/>

			<mcp:CI_Responsibility>
				<mcp:role>
					<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="{$roleCode}"/>
				</mcp:role>

				<mcp:party>
					<mcp:CI_Organisation>
			 			<mcp:name xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:org:',$id,'_organisation_name')}"/>
						<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:org:',$id,'_contact_info_mailing_address')}"/>
						<!--
						<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:org:',$id,'_contact_info_street_address')}"/>
						-->
					</mcp:CI_Organisation>
				</mcp:party>
			</mcp:CI_Responsibility>
	</xsl:template>

	<xsl:template name="addDQReport">
		<xsl:param name="explanation"/>

		<gmd:report>
			<gmd:DQ_AbsoluteExternalPositionalAccuracy>
				<gmd:result>
           <gmd:DQ_ConformanceResult>
						<gmd:specification>
							<xsl:call-template name="addCMARCitation"/>
						</gmd:specification>
						<gmd:explanation>
							<gco:CharacterString>
								<xsl:value-of select="$explanation"/>
							</gco:CharacterString>
						</gmd:explanation>
						<gmd:pass>
							<gco:Boolean>true</gco:Boolean>
						</gmd:pass>
          </gmd:DQ_ConformanceResult>
       	</gmd:result>
     	</gmd:DQ_AbsoluteExternalPositionalAccuracy>
  	</gmd:report>
	</xsl:template>

	<xsl:template match="gml:featureMember">
		<xsl:apply-templates select="app:MarlinDatasets"/>
	</xsl:template>

	<xsl:template match="app:MarlinDatasets">
		<record>
			<xsl:attribute name="uuid">
				<!--
				<xsl:choose>
					<xsl:when test="app:mest_uuid and normalize-space(app:mest_uuid)!=''">
						<xsl:value-of select="app:mest_uuid"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('urn:marine.csiro.au:dataset:',app:data_set_id)"/>
					</xsl:otherwise>
				</xsl:choose>
				-->
				<xsl:value-of select="concat('urn:marine.csiro.au:dataset:',app:data_set_id)"/>
			</xsl:attribute>

			<!-- boundingBox -->

			<xsl:if test="app:west_bounding_coord!='' and
										app:east_bounding_coord!='' and
										app:south_bounding_coord!='' and
										app:north_bounding_coord">
				<fragment id="boundingbox">
					<gmd:EX_Extent>
						<gmd:geographicElement>
							<gmd:EX_GeographicBoundingBox>
								<gmd:westBoundLongitude>
									<gco:Decimal><xsl:value-of select="app:west_bounding_coord"/></gco:Decimal>
								</gmd:westBoundLongitude>
								<gmd:eastBoundLongitude>
									<gco:Decimal><xsl:value-of select="app:east_bounding_coord"/></gco:Decimal>
								</gmd:eastBoundLongitude>
								<gmd:southBoundLatitude>
									<gco:Decimal><xsl:value-of select="app:south_bounding_coord"/></gco:Decimal>
								</gmd:southBoundLatitude>
								<gmd:northBoundLatitude>
									<gco:Decimal><xsl:value-of select="app:north_bounding_coord"/></gco:Decimal>
								</gmd:northBoundLatitude>
							</gmd:EX_GeographicBoundingBox>
						</gmd:geographicElement>
						<xsl:for-each select="app:data_coverage/app:MarlinDataCoverage">
							<xsl:variable name="csq" select="concat(app:csquares_refs,
																	app:csquares_refs2,app:csquares_refs3,
																	app:csquares_refs4,app:csquares_refs5,
																	app:csquares_refs6,app:csquares_refs7,
																	app:csquares_refs8)"/>
							<gmd:geographicElement>
								<gmd:EX_GeographicDescription>
									<gmd:geographicIdentifier>
										<gmd:MD_Identifier>
											<gmd:authority>
												<xsl:call-template name="addCSquaresCitation"/>
											</gmd:authority>
											<gmd:code>
												<gco:CharacterString><xsl:value-of select="$csq"/></gco:CharacterString>
											</gmd:code>
										</gmd:MD_Identifier>
									</gmd:geographicIdentifier>
								</gmd:EX_GeographicDescription>
							</gmd:geographicElement>
						</xsl:for-each>
					</gmd:EX_Extent>	
				</fragment>
			</xsl:if>

			<!-- pointOfContact for dataset -->

			<replacementGroup id="contactinfo">
				<xsl:for-each select="app:contact_org_id">
					<xsl:variable name="contact_id" select="."/>
					<fragment id="contactinfo">
						<mcp:resourceContactInfo>
							<xsl:call-template name="addOrganisationParty">
								<xsl:with-param name="id" select="$contact_id"/>
								<xsl:with-param name="roleCode" select="'pointOfContact'"/>
							</xsl:call-template>
						</mcp:resourceContactInfo>
					</fragment>
				</xsl:for-each>
	
				<xsl:for-each select="app:contact_person_id">
					<xsl:variable name="contact_id" select="."/>
					<fragment id="contactinfo">
						<mcp:resourceContactInfo>
							<xsl:call-template name="addPersonParty">
								<xsl:with-param name="id" select="$contact_id"/>
								<xsl:with-param name="roleCode" select="'pointOfContact'"/>
							</xsl:call-template>
						</mcp:resourceContactInfo>
					</fragment>
				</xsl:for-each>
			</replacementGroup>

			<!-- keywords -->

			<replacementGroup id="keywords">
				<xsl:variable name="title" select="concat(app:data_set_title,':',app:data_set_id,':keywords')"/>
				<xsl:for-each-group select="app:keyword/app:MarlinKeywords" group-by="app:keyword_type">

					<xsl:if test="current-grouping-key() = 'A' or
												current-grouping-key() = 'S' or
												current-grouping-key() = 'P' or
												current-grouping-key() = 'E' or
												current-grouping-key() = 'D' or
												current-grouping-key() = 'H' or
												current-grouping-key() = 'T' or
												current-grouping-key() = 'C' or
												current-grouping-key() = 'Q'">
						<xsl:call-template name="addKeywordsSection">
							<xsl:with-param name="type" select="current-grouping-key()"/>
							<xsl:with-param name="title" select="$title"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:for-each-group>

				<xsl:variable name="regtitle" select="concat(app:data_set_title,':',app:data_set_id,':region:keywords')"/>
				<xsl:if test="count(app:region/app:MarlinDatasetRegions)>0">
					<xsl:call-template name="addExtentKeywordsSection">
						<xsl:with-param name="title" select="$regtitle"/>
					</xsl:call-template>
				</xsl:if>
			</replacementGroup>

			<!-- citation -->

			<fragment id="citation">
				<mcp:CI_Citation gco:isoType="gmd:CI_Citation">
					<gmd:title>
						<gco:CharacterString>
							<xsl:value-of select="app:data_set_title"/>
						</gco:CharacterString>
					</gmd:title>

					<xsl:if test="app:data_set_short_title and
												normalize-space(data_set_short_title)!=''">
						<gmd:alternateTitle>
							<gco:CharacterString>
								<xsl:value-of select="app:data_set_short_title"/>
							</gco:CharacterString>
						</gmd:alternateTitle>
					</xsl:if>

					<xsl:if test="app:publication_date">
						<gmd:date>
							<gmd:CI_Date>
								<gmd:date>
									<gco:Date><xsl:value-of select="app:publication_date"/></gco:Date>
								</gmd:date>
								<gmd:dateType>
									<gmd:CI_DateTypeCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
								</gmd:dateType>
							</gmd:CI_Date>
						</gmd:date>
					</xsl:if>

					<!-- add in anzlic_identifier if available -->
					<xsl:if test="app:anzlic_identifier">
						<gmd:identifier>
							<gmd:MD_Identifier>
								<gmd:authority>
									<xsl:call-template name="addCMARCitation"/>
								</gmd:authority>
								<gmd:code>
									<gco:CharacterString><xsl:value-of select="app:anzlic_identifier"/></gco:CharacterString>
								</gmd:code>
							</gmd:MD_Identifier>
						</gmd:identifier>
					</xsl:if>

					<!-- add in custodian_organisation_id -->
					<xsl:if test="app:custodian_org_id">
						<mcp:responsibleParty>
							<xsl:call-template name="addOrganisationParty">
								<xsl:with-param name="id" select="app:custodian_org_id"/>
								<xsl:with-param name="roleCode" select="'custodian'"/>
							</xsl:call-template>
						</mcp:responsibleParty>
					</xsl:if>

					<!-- add in reference_information -->
					<xsl:if test="app:reference_information">
						<gmd:otherCitationDetails>
							<gco:CharacterString><xsl:value-of select="app:reference_information"/></gco:CharacterString>
						</gmd:otherCitationDetails>
					</xsl:if>
				</mcp:CI_Citation>
			</fragment>

			<!-- abstract -->

			<fragment id="abstract">
				<gmd:abstract>
					<gco:CharacterString>
						<xsl:value-of select="app:abstract"/>
					</gco:CharacterString>
				</gmd:abstract>
			</fragment>

			<!-- temporal extent -->

			<fragment id="tempextent">
				<gmd:EX_Extent>
					<gmd:temporalElement>
						<gmd:EX_TemporalExtent>
							<gmd:extent>
								<gml:TimePeriod gml:id="">
									<gml:beginPosition><xsl:value-of select="app:beginning_date"/></gml:beginPosition>
									<gml:endPosition><xsl:value-of select="app:ending_date"/></gml:endPosition>
								</gml:TimePeriod>
							</gmd:extent>
						</gmd:EX_TemporalExtent>
					</gmd:temporalElement>
				</gmd:EX_Extent>
			</fragment>

			<!-- date stamp -->

			<fragment id="datestamp">
				<gmd:dateStamp>
					<gco:Date>
						<xsl:value-of select="app:metadata_inserted_on"/>
					</gco:Date>
				</gmd:dateStamp>
			</fragment>

			<!-- revision date -->

			<fragment id="revisiondate">
				<mcp:revisionDate>
					<gco:Date>
						<xsl:value-of select="app:metadata_last_updated"/>
					</gco:Date>
				</mcp:revisionDate>
			</fragment>

			<!-- additional metadata -->

			<fragment id="additionalMetadata">
				<gmd:supplementalInformation>
					<gco:CharacterString>
						<xsl:value-of select="app:additional_metadata"/>
					</gco:CharacterString>
				</gmd:supplementalInformation>
			</fragment>

			<replacementGroup id="metadatacontactinfo">

				<!-- metadata custodian -->

				<xsl:for-each select="app:metadata_owner">
					<xsl:variable name="contact_id" select="."/>
					<fragment id="metadatacontactinfo">
						<mcp:metadataContactInfo>
							<xsl:call-template name="addUserParty">
								<xsl:with-param name="id" select="$contact_id"/>
								<xsl:with-param name="roleCode" select="'custodian'"/>
							</xsl:call-template>
						</mcp:metadataContactInfo>
					</fragment>
				</xsl:for-each>
	
				<!-- metadata originator organisation -->
	
				<xsl:for-each select="app:originator_org_id">
					<xsl:variable name="contact_id" select="."/>
					<fragment id="metadatacontactinfo">
						<mcp:metadataContactInfo>
							<xsl:call-template name="addOrganisationParty">
								<xsl:with-param name="id" select="$contact_id"/>
								<xsl:with-param name="roleCode" select="'originator'"/>
							</xsl:call-template>
						</mcp:metadataContactInfo>
					</fragment>
				</xsl:for-each>

				<!-- metadata author -->

				<xsl:for-each select="app:metadata_inserted_by">
					<xsl:variable name="contact_id" select="."/>
					<fragment id="metadatacontactinfo">
						<mcp:metadataContactInfo>
							<xsl:call-template name="addUserParty">
								<xsl:with-param name="id" select="$contact_id"/>
								<xsl:with-param name="roleCode" select="'originator'"/>
							</xsl:call-template>
						</mcp:metadataContactInfo>
					</fragment>
				</xsl:for-each>

				<!-- metadata author -->

				<xsl:for-each select="app:metadata_updated_by">
					<xsl:variable name="contact_id" select="."/>
					<fragment id="metadatacontactinfo">
						<mcp:metadataContactInfo>
							<xsl:call-template name="addUserParty">
								<xsl:with-param name="id" select="$contact_id"/>
								<xsl:with-param name="roleCode" select="'author'"/>
							</xsl:call-template>
						</mcp:metadataContactInfo>
					</fragment>
				</xsl:for-each>

				<!-- metadata author -->

				<xsl:for-each select="app:enterer_id">
					<xsl:variable name="contact_id" select="."/>
					<fragment id="metadatacontactinfo">
						<mcp:metadataContactInfo>
							<xsl:call-template name="addUserParty">
								<xsl:with-param name="id" select="$contact_id"/>
								<xsl:with-param name="roleCode" select="'author'"/>
							</xsl:call-template>
						</mcp:metadataContactInfo>
					</fragment>
				</xsl:for-each>
	
				<!-- metadata author -->

				<xsl:for-each select="app:updating_organisation_id">
					<xsl:variable name="contact_id" select="."/>
					<fragment id="metadatacontactinfo">
						<mcp:metadataContactInfo>
							<xsl:call-template name="addOrganisationParty">
								<xsl:with-param name="id" select="$contact_id"/>
								<xsl:with-param name="roleCode" select="'author'"/>
							</xsl:call-template>
						</mcp:metadataContactInfo>
					</fragment>
				</xsl:for-each>
			</replacementGroup>
	
			<xsl:if test="app:data_set_urls/app:MarlinDatasetUrls or string-length(app:mest_uuid)!=0 or app:gis_warehouse_data or app:netcdf_warehouse_data or
			             app:adcpship_warehouse_data or app:ctd_warehouse_data or
									 app:hyd_warehouse_data or app:uwy_warehouse_data or
									 app:moored_warehouse_data or app:catch_warehouse_data">
				<replacementGroup id="onlineResource">

					<!-- online resource -->

					<xsl:for-each select="app:data_set_urls/app:MarlinDatasetUrls">
						<fragment id="onlineResource">
							<gmd:onLine>
					  		<gmd:CI_OnlineResource>
									<gmd:linkage>
										<gmd:URL><xsl:value-of select="app:link_url"/></gmd:URL>
									</gmd:linkage>
									<gmd:protocol>
										<gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
									</gmd:protocol>
									<gmd:description>
										<gco:CharacterString><xsl:value-of select="app:source_description"/></gco:CharacterString>
									</gmd:description>
					 			</gmd:CI_OnlineResource>
							</gmd:onLine>
						</fragment>
					</xsl:for-each>

					<!-- online resource - warehouse data that is not publicly 
					     available -->

					<xsl:variable name="warehouse_class">
						<xsl:for-each select="*/app:WarehouseCodelists">
							<xsl:if test="
	(../../app:keyword_id='3505' and name(..)='app:gis_warehouse_data') or
	(../../app:keyword_id='3507' and name(..)='app:netcdf_warehouse_data') or
	(../../app:keyword_id='3510' and name(..)='app:adcpship_warehouse_data') or
	(../../app:keyword_id='3511' and name(..)='app:ctd_warehouse_data') or
	(../../app:keyword_id='3512' and name(..)='app:ctd_warehouse_data') or
	(../../app:keyword_id='3513' and name(..)='app:hyd_warehouse_data') or
	(../../app:keyword_id='3514' and name(..)='app:uwy_warehouse_data') or
	(../../app:keyword_id='3516' and name(..)='app:moored_warehouse_data') or
	(../../app:keyword_id='3518' and name(..)='app:catch_warehouse_data')
							              ">
								<xsl:value-of select="app:code_value_description"/><xsl:text> </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>

					<xsl:if test="normalize-space($warehouse_class)!=''">
						<fragment id="onlineResource">
							<gmd:onLine>
					  		<gmd:CI_OnlineResource>
									<gmd:linkage>
										<gmd:URL>http://www.marine.csiro.au/warehouse/jsp/loginpage.jsp</gmd:URL>
									</gmd:linkage>
									<gmd:protocol>
										<gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
									</gmd:protocol>
									<gmd:description>
										<gco:CharacterString><xsl:value-of select="concat('Data Trawler: ',normalize-space($warehouse_class))"/></gco:CharacterString>
									</gmd:description>
					 			</gmd:CI_OnlineResource>
							</gmd:onLine>
						</fragment>
					</xsl:if>

					<xsl:if test="string-length(app:mest_uuid)!=0">
						<xsl:variable name="uuid" select="app:mest_uuid"/>
						<xsl:variable name="geoserverUrl" select="$geoserver/*/Service/OnlineResource/@xlink:href"/>	
						<xsl:for-each select="$geoserver//Layer">
							<xsl:variable name="md" select="MetadataURL/OnlineResource/@xlink:href"/>
							<xsl:if test="contains($md,concat('uuid=',$uuid))">
								<gmd:onLine>
					  			<gmd:CI_OnlineResource>
										<gmd:linkage>
											<gmd:URL><xsl:value-of select="$geoserverUrl"/></gmd:URL>
										</gmd:linkage>
										<gmd:protocol>
											<gco:CharacterString>OGC:WMS-1.1.1-http-get-map</gco:CharacterString>
										</gmd:protocol>
										<gmd:name>
											<gco:CharacterString><xsl:value-of select="Name"/></gco:CharacterString>
										</gmd:name>
										<gmd:description>
											<gco:CharacterString><xsl:value-of select="concat('Web Map Service Layer ',Name)"/></gco:CharacterString>
										</gmd:description>
					 				</gmd:CI_OnlineResource>
								</gmd:onLine>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</replacementGroup>
			</xsl:if>


			<xsl:if test="app:project_id or app:global_project_id or app:survey_id">
				<replacementGroup id="aggregateInformation">

					<!-- project association -->

					<xsl:if test="app:project_id">
						<fragment id="aggregateInformation">
								<xsl:call-template name="addAggregate">
									<xsl:with-param name="id" select="concat('urn:marine.csiro.au:project:',app:project_id)"/>
									<xsl:with-param name="initiative" select="'project'"/>
								</xsl:call-template>
						</fragment>
					</xsl:if>

					<!-- global project association -->

					<xsl:if test="app:global_project_id">
						<fragment id="aggregateInformation">
							<xsl:call-template name="addAggregate">
								<xsl:with-param name="id" select="concat('urn:marine.csiro.au:globalproject:',app:global_project_id)"/>
								<xsl:with-param name="initiative" select="'project'"/>
							</xsl:call-template>
						</fragment>
					</xsl:if>
	
					<!-- survey_id -->
	
					<xsl:for-each select="app:survey_id">
						<fragment id="aggregateInformation">
							<xsl:call-template name="addAggregate">
								<xsl:with-param name="id" select="concat('urn:marine.csiro.au:survey:',string(.))"/>
								<xsl:with-param name="initiative" select="'survey'"/>
							</xsl:call-template>
						</fragment>
					</xsl:for-each>
	
				</replacementGroup>
			</xsl:if>

			<!-- project association as parent record -->

			<xsl:if test="app:project_id">
				<fragment id="parentIdentifier">
					<gmd:parentIdentifier>
						<gco:CharacterString><xsl:value-of select="concat('urn:marine.csiro.au:project:',app:project_id)"/></gco:CharacterString>
					</gmd:parentIdentifier>
				</fragment>
			</xsl:if>

			<!-- access constraint -->

			<xsl:if test="app:access_constraint">
				<fragment id="accessConstraint">
					<gmd:resourceConstraints>
						<gmd:MD_LegalConstraints>
            	<gmd:useLimitation>
                	<gco:CharacterString><xsl:value-of select="app:access_constraint"/></gco:CharacterString>
            	</gmd:useLimitation>
            	<gmd:accessConstraints>
                	<gmd:MD_RestrictionCode codeList="http://asdd.ga.gov.au/asdd/profileinfo/gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions"/>
            	</gmd:accessConstraints>
            	<gmd:useConstraints>
                	<gmd:MD_RestrictionCode codeList="http://asdd.ga.gov.au/asdd/profileinfo/gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions"/>
            	</gmd:useConstraints>
            	<gmd:otherConstraints>
                	<gco:CharacterString><xsl:value-of select="app:access_constraint"/></gco:CharacterString>
            	</gmd:otherConstraints>
        		</gmd:MD_LegalConstraints>
    			</gmd:resourceConstraints>	
				</fragment>
			</xsl:if>

			<!-- progress -->

			<xsl:if test="app:progress or app:data_set_status">
				<replacementGroup id="status">
					<xsl:if test="app:progress">
						<fragment id="status">
							<gmd:status>
								<xsl:variable name="p" select="normalize-space(app:progress)"/>
								<xsl:variable name="newP">
									<xsl:choose>
										<xsl:when test="$p='Complete'">completed</xsl:when>
										<xsl:when test="$p='In Progress'">onGoing</xsl:when>
										<xsl:when test="$p='Planned'">planned</xsl:when>
									</xsl:choose>
								</xsl:variable>
								<gmd:MD_ProgressCode codeList="http://asdd.ga.gov.au/asdd/profileinfo/gmxCodelists.xml#MD_ProgressCode" codeListValue="{$newP}"/>
							</gmd:status>
						</fragment>
					</xsl:if>
	
					<!-- data_set_status -->

					<xsl:if test="app:data_set_status and not(app:progress)">
						<fragment id="status">
							<gmd:status>
								<xsl:variable name="s" select="normalize-space(app:data_set_status)"/>
								<xsl:variable name="newS">
									<xsl:choose>
										<xsl:when test="$s='Active'">underDevelopment</xsl:when>
										<xsl:otherwise>obsolete</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<gmd:MD_ProgressCode codeList="http://asdd.ga.gov.au/asdd/profileinfo/gmxCodelists.xml#MD_ProgressCode" codeListValue="{$newS}"/>
							</gmd:status>
						</fragment>
					</xsl:if>
				</replacementGroup>
			</xsl:if>

			<!-- resource maintenance -->

			<xsl:if test="app:date_to_review_text and 
										app:date_to_review_text != 'Not known'">
				<fragment id="resourceMaintenance">
					<gmd:resourceMaintenance>
						<gmd:MD_MaintenanceInformation>
							<gmd:maintenanceAndUpdateFrequency>
								<gmd:MD_MaintenanceFrequencyCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_MaintenanceFrequencyCode" codeListValue="asNeeded"/>
							</gmd:maintenanceAndUpdateFrequency>
							<gmd:dateOfNextUpdate>
								<gco:Date><xsl:value-of select="app:data_to_review_text"/></gco:Date>
							</gmd:dateOfNextUpdate>
						</gmd:MD_MaintenanceInformation>
					</gmd:resourceMaintenance>
				</fragment>
			</xsl:if>

			<xsl:if test="app:acknowledgements or app:contributors">
				<replacementGroup id="credit">

					<!-- acknowledgements -->

					<xsl:if test="app:acknowledgements">
						<fragment id="credit">
							<gmd:credit>
								<gco:CharacterString><xsl:value-of select="app:acknowledgements"/></gco:CharacterString>
							</gmd:credit>
						</fragment>
					</xsl:if>

					<!-- contributors -->

					<xsl:if test="app:contributors">
						<fragment id="credit">
							<gmd:credit>
								<gco:CharacterString><xsl:value-of select="app:contributors"/></gco:CharacterString>
							</gmd:credit>
						</fragment>
					</xsl:if>
				</replacementGroup>
			</xsl:if>

			<!-- lineage -->

			<xsl:if test="app:lineage">
				<fragment id="dqLineage">
					<gmd:lineage>
						<gmd:LI_Lineage>
							<gmd:statement>
								<gco:CharacterString><xsl:value-of select="app:lineage"/></gco:CharacterString>
							</gmd:statement>
						</gmd:LI_Lineage>
					</gmd:lineage>
				</fragment>
			</xsl:if>

			<xsl:if test="app:completeness or app:logical_consistency or
			              (normalize-space(app:positional_accuracy)!=''
	    and normalize-space(app:positional_accuracy)!='Refer to documentation')">
				<replacementGroup id="dqReport">

					<!-- completeness -->

					<xsl:if test="app:completeness">
						<fragment id="dqReport">
							<xsl:call-template name="addDQReport">
								<xsl:with-param name="explanation" select="app:completeness"/>
							</xsl:call-template>
						</fragment>
					</xsl:if>
		
					<!-- logical_consistency -->
		
					<xsl:if test="app:logical_consistency">
						<fragment id="dqReport">
							<xsl:call-template name="addDQReport">
								<xsl:with-param name="explanation" select="app:logical_consistency"/>
							</xsl:call-template>
						</fragment>
					</xsl:if>
	
					<!-- positional_accuracy -->
	
					<xsl:if test="normalize-space(app:positional_accuracy)!=''
	  		and normalize-space(app:positional_accuracy)!='Refer to documentation'">
						<fragment id="dqReport">
							<xsl:call-template name="addDQReport">
								<xsl:with-param name="explanation" select="app:positional_accuracy"/>
							</xsl:call-template>
						</fragment>
					</xsl:if>
				</replacementGroup>
			</xsl:if>

			<!-- spatial representation type and spatial resolution -->

			<xsl:if test="app:cell_size and app:cell_size_unit">
				<fragment id="spatialRep">
					<gmd:spatialRepresentationType>
						<gmd:MD_SpatialRepresentationTypeCode codeList="http://asdd.ga.gov.au/asdd/profileinfo/gmxCodelists.xml#MD_SpatialRepresentationTypeCode" codeListValue="grid"/>
					</gmd:spatialRepresentationType>
				</fragment>

				<fragment id="spatialRes">
    			<gmd:spatialResolution>
						<gmd:MD_Resolution>
							<gmd:distance>
								<gco:Distance>
									<xsl:attribute name="uom">
										<xsl:apply-templates select="app:cell_size_unit/app:MarlinUnits"/>
									</xsl:attribute>
									<xsl:value-of select="app:cell_size"/>
								</gco:Distance>
							</gmd:distance>
						</gmd:MD_Resolution>
					</gmd:spatialResolution>	
				</fragment>
			</xsl:if>

			<!-- min_depth and max_depth -->

			<xsl:if test="app:min_depth and app:max_depth">
				<fragment id="verticalExtent">
					<gmd:EX_Extent>
						<gmd:verticalElement>
							<gmd:EX_VerticalExtent>
								<gmd:minimumValue>
									<gco:Real><xsl:value-of select="app:min_depth"/></gco:Real>
								</gmd:minimumValue>
								<gmd:maximumValue>
									<gco:Real><xsl:value-of select="app:max_depth"/></gco:Real>
								</gmd:maximumValue>
               </gmd:EX_VerticalExtent>
						</gmd:verticalElement>
					</gmd:EX_Extent>
				</fragment>
			</xsl:if>
			
			<!-- taxonomic concepts -->

			<xsl:if test="app:taxonomy/*">
			<replacementGroup id="taxonomicExtent">
				<xsl:for-each select="app:taxonomy/*">
					<xsl:variable name="caab" select="concat(app:category_code,app:family_code,app:species_number)"/>
					<xsl:variable name="speckeyword"    select="document(concat($siteUrl,'/srv/eng/xml.keyword.get?id=urn:marine.csiro.au:caab:concept:',$caab,'&amp;thesaurus=external.taxon.urn:marine.csiro.au:caabregister'))"/>
					<xsl:if test="count($speckeyword/*) > 0">
						<fragment id="taxonomicExtent">
						<mcp:EX_Extent>
							<mcp:taxonomicElement>
								<mcp:EX_TaxonomicCoverage>
									<mcp:taxonConcepts>
										<ibisapp:documents xmlns:ibisapp="http://biodiversity.org.au/xml/servicelayer/content" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:cfg="http://biodiversity.org.au/xml/servicelayer/configuration" xmlns:ibis="http://biodiversity.org.au/xml/ibis">
											<ibis:TaxonName ibis:lsid="urn:marine.csiro.au:caab:concept:{$caab}" ibis:uri="http://www.marine.csiro.au/caabsearch/caab_search.caab_report?spcode={$caab}" ibis:thesaurusUri="geonetwork.thesaurus.external.taxon.urn:marine.csiro.au:caabregister">
												<ibis:NameComplete><xsl:value-of select="$speckeyword//gmd:keyword/gmx:Anchor"/></ibis:NameComplete>
											</ibis:TaxonName>
               			</ibisapp:documents>
									</mcp:taxonConcepts>
								</mcp:EX_TaxonomicCoverage>
							</mcp:taxonomicElement>
						</mcp:EX_Extent>
						</fragment>
					</xsl:if>
				</xsl:for-each>
			</replacementGroup>
			</xsl:if>
			
		</record>
	</xsl:template>


</xsl:stylesheet>
