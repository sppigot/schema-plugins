<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
		xmlns:app="http://www.deegree.org/app"
		xmlns:gco="http://www.isotc211.org/2005/gco"
		xmlns:gmd="http://www.isotc211.org/2005/gmd"
		xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
		xmlns:gml="http://www.opengis.net/gml"
		xmlns:gmx="http://www.isotc211.org/2005/gmx"
		xmlns:wfs="http://www.opengis.net/wfs"
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"		
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:param name="siteUrl"/>

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

	<xsl:include href="marlin_globals.xsl"/>

	<!-- 
			 This xslt transforms GetFeature outputs from the WFS Marlin database
	     into ISO metadata fragments. The fragments are used by GeoNetwork to 
			 build ISO metadata records.
	 -->

	<xsl:template match="wfs:FeatureCollection">
		<xsl:message>Processing <xsl:value-of select="@numberOfFeatures"/></xsl:message>
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

			<xsl:apply-templates select="gml:featureMember"/>
		</records>
	</xsl:template>

	<xsl:template name="doSurveyDate">
		<xsl:param name="yr" select="''"/>
		<xsl:param name="mn" select="''"/>
		<xsl:param name="dy" select="''"/>
		<xsl:choose>
			<xsl:when test="$yr!='' and $mn!='' and $dy!=''">
				<xsl:value-of select="concat($yr,'-',format-number(number($mn),'00'),'-',format-number(number($dy),'00'))"/>
			</xsl:when>
			<xsl:when test="$yr!='' and $mn!='' and $dy=''">
				<xsl:value-of select="concat($yr,'-',format-number(number($mn),'00'))"/>
			</xsl:when>
			<xsl:when test="$yr!='' and $mn='' and $dy=''">
				<xsl:value-of select="$yr"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="addSurveyLeaderParty">
		<xsl:param name="name"/>
		<xsl:param name="org" select="''"/>
		<xsl:param name="roleCode"/>

			<mcp:CI_Responsibility>
				<mcp:role>
					<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="{$roleCode}"/>
				</mcp:role>

				<mcp:party>
					<mcp:CI_Organisation>
			 			<mcp:name>
							<xsl:call-template name="doStr">
								<xsl:with-param name="value" select="$org"/>
							</xsl:call-template>
			 			</mcp:name>
						<mcp:individual>
							<mcp:CI_Individual>
			 					<mcp:name>
									<xsl:call-template name="doStr">
										<xsl:with-param name="value" select="$name"/>
									</xsl:call-template>
			 					</mcp:name>
								<mcp:positionName>
									<gco:CharacterString>Survey Leader</gco:CharacterString>
								</mcp:positionName>
							</mcp:CI_Individual>
						</mcp:individual>
					</mcp:CI_Organisation>
				</mcp:party>
			</mcp:CI_Responsibility>
	</xsl:template>

	<xsl:template name="addSourceKeyword">

			<gmd:descriptiveKeywords>
				<gmd:MD_Keywords>
					<xsl:for-each select="app:source_id">
						<xsl:variable name="source"        select="concat('urn:marine.csiro.au:source:',string(.))"/>

						<xsl:variable name="sourceKeyword" select="document(concat($siteUrl,'/srv/eng/xml.search.keywords?pNewSearch=true&amp;pTypeSearch=1&amp;pKeyword=',$source,'&amp;pThesaurus=register.dataSource.',$sourceThe,'&amp;pMode=searchBox&amp;maxResults=1'))"/>
						<xsl:if test="count($sourceKeyword/*) > 0">
							<gmd:keyword>
								<gmx:Anchor xlink:href="{$siteUrl}/srv/eng/xml.keyword.get?thesaurus=register.dataSource.{$sourceThe}&amp;id={$sourceThe}:concept:{string(.)}"><xsl:value-of select="$sourceKeyword//descKeys/keyword/definition"/></gmx:Anchor>
							</gmd:keyword>
						</xsl:if>
					</xsl:for-each>
					<gmd:type>
						<gmd:MD_KeywordTypeCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="dataSource"/>
					</gmd:type>
					<xsl:comment>thesaurus name for MarLIN Sources/Platforms</xsl:comment>
					<gmd:thesaurusName>
						<xsl:call-template name="addTheCitation">
        			<xsl:with-param name="title" select="'MarLIN Source Register'"/>
        			<xsl:with-param name="edition" select="''"/>
        			<xsl:with-param name="thesaurus" select="$sourceThe"/>
        			<xsl:with-param name="thesaurusType" select="'dataSource'"/>
        			<xsl:with-param name="siteUrl" select="$siteUrl"/>
						</xsl:call-template>
					</gmd:thesaurusName>
				</gmd:MD_Keywords>
			</gmd:descriptiveKeywords>
	</xsl:template>

	<xsl:template match="gml:featureMember">
		<xsl:apply-templates select="app:MarlinSurveys"/>
	</xsl:template>

	<xsl:template match="app:MarlinSurveys">
		<record>
			<xsl:attribute name="uuid">
				<xsl:value-of select="concat('urn:marine.csiro.au:survey:',app:survey_id)"/>
			</xsl:attribute>

			<!-- boundingBox -->

			<xsl:if test="app:survey_start_lon!='' and
										app:survey_start_lat!='' and
										app:survey_end_lon!='' and
										app:survey_end_lat!=''">

				<xsl:variable name="lats" select="if (app:survey_start_lat > app:survey_end_lat) then concat(app:survey_end_lat,  '|',app:survey_start_lat) 
				  else concat(app:survey_start_lat,'|',app:survey_end_lat)"/>
				<xsl:variable name="lons" select="if (app:survey_start_lon > app:survey_end_lon) then concat(app:survey_end_lon,  '|',app:survey_start_lon)
					else concat(app:survey_start_lon,'|',app:survey_end_lon)"/>

				<xsl:variable name="north_bounding_coord" select="substring-before($lats,'|')"/>
				<xsl:variable name="south_bounding_coord" select="substring-after($lats,'|')"/>
				<xsl:variable name="west_bounding_coord" select="substring-before($lons,'|')"/>
				<xsl:variable name="east_bounding_coord" select="substring-after($lons,'|')"/>

				<replacementGroup id="boundingbox">
					<fragment id="boundingbox">
						<gmd:EX_Extent>
							<gmd:geographicElement>
								<gmd:EX_GeographicBoundingBox>
									<gmd:westBoundLongitude>
										<gco:Decimal><xsl:value-of select="number($west_bounding_coord)"/></gco:Decimal>
									</gmd:westBoundLongitude>
									<gmd:eastBoundLongitude>
										<gco:Decimal><xsl:value-of select="number($east_bounding_coord)"/></gco:Decimal>
									</gmd:eastBoundLongitude>
									<gmd:southBoundLatitude>
										<gco:Decimal><xsl:value-of select="number($south_bounding_coord)"/></gco:Decimal>
									</gmd:southBoundLatitude>
									<gmd:northBoundLatitude>
										<gco:Decimal><xsl:value-of select="number($north_bounding_coord)"/></gco:Decimal>
									</gmd:northBoundLatitude>
								</gmd:EX_GeographicBoundingBox>
							</gmd:geographicElement>
						</gmd:EX_Extent>	
					</fragment>
					<xsl:if test="normalize-space(app:survey_region)!=''">
						<fragment id="boundingbox">
							<gmd:EX_Extent>
								<gmd:description>
									<gco:CharacterString>Survey Region</gco:CharacterString>
								</gmd:description>
								<gmd:geographicElement>
									<gmd:EX_GeographicDescription>
										<gmd:geographicIdentifier>
											<gmd:MD_Identifier>
                    		<gmd:code>
													<gco:CharacterString><xsl:value-of select="app:survey_region"/></gco:CharacterString>
                    		</gmd:code>
											</gmd:MD_Identifier>
										</gmd:geographicIdentifier>
									</gmd:EX_GeographicDescription>
								</gmd:geographicElement>	
							</gmd:EX_Extent>	
						</fragment>
					</xsl:if>
					<xsl:if test="normalize-space(app:survey_start_location)!=''">
						<fragment id="boundingbox">
							<gmd:EX_Extent>
								<gmd:description>
									<gco:CharacterString>Start Location</gco:CharacterString>
								</gmd:description>
								<gmd:geographicElement>
									<gmd:EX_GeographicDescription>
										<gmd:geographicIdentifier>
											<gmd:MD_Identifier>
                    		<gmd:code>
													<gco:CharacterString><xsl:value-of select="app:survey_start_location"/></gco:CharacterString>
                    		</gmd:code>
											</gmd:MD_Identifier>
										</gmd:geographicIdentifier>
									</gmd:EX_GeographicDescription>
								</gmd:geographicElement>	
							</gmd:EX_Extent>	
						</fragment>
					</xsl:if>
					<xsl:if test="normalize-space(app:survey_end_location)!=''">
						<fragment id="boundingbox">
							<gmd:EX_Extent>
								<gmd:description>
									<gco:CharacterString>End Location</gco:CharacterString>
								</gmd:description>
								<gmd:geographicElement>
									<gmd:EX_GeographicDescription>
										<gmd:geographicIdentifier>
											<gmd:MD_Identifier>
                    		<gmd:code>
													<gco:CharacterString><xsl:value-of select="app:survey_end_location"/></gco:CharacterString>
                    		</gmd:code>
											</gmd:MD_Identifier>
										</gmd:geographicIdentifier>
									</gmd:EX_GeographicDescription>
								</gmd:geographicElement>	
							</gmd:EX_Extent>	
						</fragment>
					</xsl:if>
				</replacementGroup>
			</xsl:if>

			<!-- pointOfContact for survey - put together from 
					 app:survey_leader_affiliation
					 app:survey_leader_firstname
					 app:survey_leader_surname
					 -->

			<xsl:if test="app:survey_leader_affiliation">
				<replacementGroup id="contactinfo">
					<fragment id="contactinfo">
						<mcp:resourceContactInfo>
							<xsl:call-template name="addSurveyLeaderParty">
								<xsl:with-param name="name" select="concat(app:survey_leader_firstname,' ',app:survey_leader_surname)"/>
								<xsl:with-param name="org"  select="app:survey_leader_affiliation"/>
								<xsl:with-param name="roleCode" select="'pointOfContact'"/>
							</xsl:call-template>
						</mcp:resourceContactInfo>
					</fragment>
				</replacementGroup>
			</xsl:if>

			<!-- citation -->

			<fragment id="citation">
				<mcp:CI_Citation gco:isoType="gmd:CI_Citation">
					<gmd:title>
						<gco:CharacterString>
							<xsl:value-of select="app:survey_name"/>
						</gco:CharacterString>
					</gmd:title>

					<xsl:if test="normalize-space(survey_name_special)!=''">
						<gmd:alternateTitle>
							<gco:CharacterString>
								<xsl:value-of select="app:survey_name_special"/>
							</gco:CharacterString>
						</gmd:alternateTitle>
					</xsl:if>

					<xsl:if test="normalize-space(survey_label)!=''">
						<gmd:alternateTitle>
							<gco:CharacterString>
								<xsl:value-of select="app:survey_label"/>
							</gco:CharacterString>
						</gmd:alternateTitle>
					</xsl:if>

					<gmd:date gco:nilReason="unknown"/>

					<!-- add in survey_label if available -->
					<xsl:if test="app:survey_label">
						<gmd:identifier>
							<gmd:MD_Identifier>
								<gmd:code>
									<gco:CharacterString><xsl:value-of select="app:survey_label"/></gco:CharacterString>
								</gmd:code>
							</gmd:MD_Identifier>
						</gmd:identifier>
					</xsl:if>

					<!-- add in survey_documentation as other citation details -->
					<xsl:if test="app:survey_documentation">
						<gmd:otherCitationDetails>
							<gco:CharacterString><xsl:value-of select="app:survey_documentation"/></gco:CharacterString>
						</gmd:otherCitationDetails>
					</xsl:if>
				</mcp:CI_Citation>
			</fragment>

			<!-- abstract -->

			<fragment id="abstract">
				<gmd:abstract>
					<gco:CharacterString>
						<xsl:value-of select="app:survey_description"/>
					</gco:CharacterString>
				</gmd:abstract>
			</fragment>

			<!-- temporal extent -->

			<fragment id="tempextent">
				<gmd:temporalElement>
					<gmd:EX_TemporalExtent>
						<gmd:extent>
							<gml:TimePeriod gml:id="">
								<gml:beginPosition>
									<xsl:call-template name="doSurveyDate">
										<xsl:with-param name="yr" select="normalize-space(app:survey_start_year)"/>
										<xsl:with-param name="mn" select="normalize-space(app:survey_start_month)"/>
										<xsl:with-param name="dy" select="normalize-space(app:survey_start_day)"/>
									</xsl:call-template>
								</gml:beginPosition>
								<gml:endPosition>
									<xsl:call-template name="doSurveyDate">
										<xsl:with-param name="yr" select="normalize-space(app:survey_end_year)"/>
										<xsl:with-param name="mn" select="normalize-space(app:survey_end_month)"/>
										<xsl:with-param name="dy" select="normalize-space(app:survey_end_day)"/>
									</xsl:call-template>
								</gml:endPosition>
							</gml:TimePeriod>
						</gmd:extent>
					</gmd:EX_TemporalExtent>
				</gmd:temporalElement>
			</fragment>

			<!-- additional metadata -->

			<xsl:if test="app:author_comments">
				<fragment id="additionalMetadata">
					<gmd:supplementalInformation>
						<gco:CharacterString>
							<xsl:value-of select="app:author_comments"/>
						</gco:CharacterString>
					</gmd:supplementalInformation>
				</fragment>
			</xsl:if>

			<!-- source (platform) is stored as a keyword -->
	
			<xsl:if test="app:source_id">
				<replacementGroup id="keywords">
					<fragment id="keywords">
						<xsl:call-template name="addSourceKeyword"/>
					</fragment>
				</replacementGroup>
			</xsl:if>

			<xsl:if test="app:survey_report_url or app:survey_plan_url or app:voyage_track_url">
				<replacementGroup id="onlineResource">

					<!-- survey_report_url online resource -->

					<xsl:if test="app:survey_report_url">
						<fragment id="onlineResource">
							<gmd:onLine>
					  		<gmd:CI_OnlineResource>
									<gmd:linkage>
										<gmd:URL><xsl:value-of select="app:survey_report_url"/></gmd:URL>
									</gmd:linkage>
									<gmd:protocol>
										<gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
									</gmd:protocol>
									<gmd:description>
										<gco:CharacterString><xsl:value-of select="concat('Survey report for ',app:survey_name)"/></gco:CharacterString>
									</gmd:description>
					 			</gmd:CI_OnlineResource>
							</gmd:onLine>
						</fragment>
					</xsl:if>

					<!-- survey_plan_url online resource -->

					<xsl:if test="app:survey_plan_url">
						<fragment id="onlineResource">
							<gmd:onLine>
					  		<gmd:CI_OnlineResource>
									<gmd:linkage>
										<gmd:URL><xsl:value-of select="app:survey_plan_url"/></gmd:URL>
									</gmd:linkage>
									<gmd:protocol>
										<gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
									</gmd:protocol>
									<gmd:description>
										<gco:CharacterString><xsl:value-of select="concat('Survey plan for ',app:survey_name)"/></gco:CharacterString>
									</gmd:description>
					 			</gmd:CI_OnlineResource>
							</gmd:onLine>
						</fragment>
					</xsl:if>

					<!-- voyage_track_url online resource -->

					<xsl:if test="app:voyage_track_url">
						<fragment id="onlineResource">
							<gmd:onLine>
					  		<gmd:CI_OnlineResource>
									<gmd:linkage>
										<gmd:URL><xsl:value-of select="app:voyage_track_url"/></gmd:URL>
									</gmd:linkage>
									<gmd:protocol>
										<gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
									</gmd:protocol>
									<gmd:description>
										<gco:CharacterString><xsl:value-of select="concat('Voyage track for ',app:survey_name)"/></gco:CharacterString>
									</gmd:description>
					 			</gmd:CI_OnlineResource>
							</gmd:onLine>
						</fragment>
					</xsl:if>
				</replacementGroup>
			</xsl:if>


			<xsl:if test="app:project_id or app:global_project_id or app:data_set_id">
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
	
          <!-- datasets association - set intiative to collection as this is
					     a collection of datasets associated with the survey -->

          <xsl:for-each select="app:data_set_id">
            <fragment id="aggregateInformation">
                <xsl:call-template name="addAggregate">
                  <xsl:with-param name="id" select="concat('urn:marine.csiro.au:dataset:',string(.))"/>
                  <xsl:with-param name="initiative" select="'collection'"/>
                </xsl:call-template>
            </fragment>
          </xsl:for-each>

				</replacementGroup>
			</xsl:if>

      <fragment id="dateStamp">
        <gco:DateTime><xsl:value-of select="format-dateTime(current-dateTime(),$df)"/></gco:DateTime>
      </fragment>
		</record>
	</xsl:template>


</xsl:stylesheet>
