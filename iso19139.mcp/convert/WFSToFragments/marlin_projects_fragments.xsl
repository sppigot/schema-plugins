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
			 This xslt transforms output from the WFS MarlinProjects database
	     into fragments for insertion into GeoNetwork
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

	<xsl:template match="*[@xlink:href]" priority="20">
		<xsl:variable name="linkid" select="substring-after(@xlink:href,'#')"/>
		<xsl:apply-templates select="//*[@gml:id=$linkid]"/>
	</xsl:template>

	<xsl:template name="addParties">
		<xsl:param name="id"/>
		<xsl:param name="name"/>
		<xsl:param name="gmlId"/>

		<mcp:responsibleParty>
			<mcp:CI_Responsibility>
				<mcp:role>
					<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="principalInvestigator"/>
				</mcp:role>

				<!-- NOTE: this is a link to the tempextent created below!!! -->
      	<mcp:extent xlink:href="#{concat($gmlId,'_tempextent')}"/>

				<mcp:party>
					<mcp:CI_Organisation>
			 			<mcp:name xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:org:',$id,'_organisation_name')}"/>
						<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:org:',$id,'_contact_info_mailing_address')}"/>
						<!--
						<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:org:',$id,'_contact_info_street_address')}"/>
						-->
					</mcp:CI_Organisation>
				</mcp:party>
				<mcp:party>
					<mcp:CI_Individual>
			 			<mcp:name>
							<xsl:call-template name="doStr">
								<xsl:with-param name="value" select="$name"/>
							</xsl:call-template>
						</mcp:name>
						<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:org:',$id,'_contact_info_mailing_address')}"/>
						<!--
						<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid={concat('urn:marine.csiro.au:org:',$id,'_contact_info_street_address')}"/>
						-->
						<mcp:positionName>
							<gco:CharacterString>Project Leader</gco:CharacterString>
						</mcp:positionName>
					</mcp:CI_Individual>
				</mcp:party>
			</mcp:CI_Responsibility>
		</mcp:responsibleParty>
	</xsl:template>

	<xsl:template name="doId">
		<xsl:param name="id"/>
		<xsl:param name="title"/>
		<xsl:param name="identifierName"/>
		<xsl:param name="date"/>

		<gmd:identifier>
			<gmd:MD_Identifier>
		  	<gmd:authority>
						<mcp:CI_Citation gco:isoType="gmd:CI_Citation">
							<gmd:title>
								<gco:CharacterString><xsl:value-of select="$title"/></gco:CharacterString>
							</gmd:title>
							<gmd:alternateTitle>
								<gco:CharacterString><xsl:value-of select="$identifierName"/></gco:CharacterString>
							</gmd:alternateTitle>
							<gmd:date>
								<gmd:CI_Date>
									<gmd:date>
										<gco:Date><xsl:value-of select="$date"/></gco:Date>
									</gmd:date>
									<gmd:dateType>
										<gmd:CI_DateTypeCode codeList="http://asdd.ga.gov.au/asdd/profileinfo/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
									</gmd:dateType>
								</gmd:CI_Date>
							</gmd:date>
							<mcp:responsibleParty>
								<mcp:CI_Responsibility>
									<mcp:role>
										<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact"/>
									</mcp:role>
									<mcp:role>
										<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="custodian"/>
									</mcp:role>
									<mcp:role>
										<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="owner"/>
									</mcp:role>
		
									<!-- NOTE: this is a link to the tempextent created below!!! -->
      						<mcp:extent xlink:href="#{concat(@gml:id,'_tempextent')}"/>
		
									<mcp:party>
										<mcp:CI_Organisation>
			 								<mcp:name xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:org:1_organisation_name"/>
											<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:org:1_contact_info_mailing_address"/>
											<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:org:1_contact_info_street_address"/>
										</mcp:CI_Organisation>
									</mcp:party>
								</mcp:CI_Responsibility>
							</mcp:responsibleParty>

						</mcp:CI_Citation>
				</gmd:authority>
				<gmd:code>
					<xsl:call-template name="doStr">
						<xsl:with-param name="value" select="$id"/>
					</xsl:call-template>
				</gmd:code>
			</gmd:MD_Identifier>
		</gmd:identifier>

	</xsl:template>


	<xsl:template match="gml:featureMember">
		<xsl:apply-templates select="app:MarlinProjects"/>
	</xsl:template>

	<xsl:template match="app:MarlinProjects">

		<record uuid="urn:marine.csiro.au:project:{app:project_id}">

			<!-- hierarchyLevel -->
			<fragment id="hierarchyLevel">
				<gmd:hierarchyLevel>
					<gmd:MD_ScopeCode codeList="http://asdd.ga.gov.au/asdd/profileinfo/GAScopeCodeList.xml#MD_ScopeCode" codeListValue="project"/>
				</gmd:hierarchyLevel>
			</fragment>

			<!-- metadata custodian/contact is CMAR data centre -->

			<fragment id="metadatacontactinfo">
				<mcp:metadataContactInfo>
					<mcp:CI_Responsibility>
						<mcp:role>
							<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact"/>
						</mcp:role>
						<mcp:role>
							<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="custodian"/>
						</mcp:role>
						<mcp:role>
							<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="owner"/>
						</mcp:role>

						<!-- NOTE: this is a link to the tempextent created below!!! -->
     				<mcp:extent xlink:href="#{concat(@gml:id,'_tempextent')}"/>

						<mcp:party>
							<mcp:CI_Organisation>
		 						<mcp:name xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:org:1_organisation_name"/>
								<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:org:1_contact_info_mailing_address"/>
								<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:org:1_contact_info_street_address"/>
           			<mcp:individual>
             			<mcp:CI_Individual>
										<mcp:contactInfo>
											<gmd:CI_Contact>
												<gmd:address>
													<gmd:CI_Address>
                 						<gmd:electronicMailAddress>
                   						<gco:CharacterString>cmar-metadata@csiro.au</gco:CharacterString>
                						</gmd:electronicMailAddress>
													</gmd:CI_Address>
												</gmd:address>
											</gmd:CI_Contact>
										</mcp:contactInfo>
                 		<mcp:positionName>
                   		<gco:CharacterString>Metadata Librarian</gco:CharacterString>
                 		</mcp:positionName>
             			</mcp:CI_Individual>
           			</mcp:individual>
							</mcp:CI_Organisation>
						</mcp:party>
					</mcp:CI_Responsibility>
				</mcp:metadataContactInfo>
			</fragment>

			<!-- citation -->

			<fragment id="citation">
				<mcp:CI_Citation gco:isoType="gmd:CI_Citation">
					<gmd:title>
						<xsl:call-template name="doStr">
							<xsl:with-param name="value" select="app:project_name"/>
						</xsl:call-template>
					</gmd:title>
					<xsl:if test="app:project_short_name">
						<gmd:alternateTitle>
							<xsl:call-template name="doStr">
								<xsl:with-param name="value" select="app:project_short_name"/>
							</xsl:call-template>
						</gmd:alternateTitle>
					</xsl:if>
					<gmd:date>
						<gmd:CI_Date>
							<gmd:date>
								<gco:Date>
									<xsl:value-of select="app:project_start_year"/>
								</gco:Date>
							</gmd:date>
							<gmd:dateType>
								<gmd:CI_DateTypeCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="creation"/>
							</gmd:dateType>
						</gmd:CI_Date>
					</gmd:date>

					<!-- citation identifiers -->

					<xsl:if test="app:project_leader1_ident">
						<xsl:call-template name="doId">
							<xsl:with-param name="id" select="app:project_leader1_ident"/>
							<xsl:with-param name="title" select="'Project leader neuxs identifier'"/>
							<xsl:with-param name="identifierName" select="'project_leader1_ident'"/>
							<xsl:with-param name="date" select="app:project_start_year"/>

						</xsl:call-template>
					</xsl:if>

					<xsl:if test="app:project_trim_identifiers">
						<xsl:call-template name="doId">
							<xsl:with-param name="id" select="app:project_trim_identifiers"/>
							<xsl:with-param name="title" select="'Project trim identifiers'"/>
							<xsl:with-param name="identifierName" select="'project_trim_identifiers'"/>
							<xsl:with-param name="date" select="app:project_start_year"/>
						</xsl:call-template>
					</xsl:if>

					<xsl:if test="app:project_pss_id">
						<xsl:call-template name="doId">
							<xsl:with-param name="id" select="app:project_pss_id"/>
							<xsl:with-param name="title" select="'Project PSS identifier'"/>
							<xsl:with-param name="identifierName" select="'project_pss_id'"/>
							<xsl:with-param name="date" select="app:project_start_year"/>
						</xsl:call-template>
					</xsl:if>

					<!-- project_organisation_1 -->
					<xsl:if test="app:project_organisation1">
						<xsl:call-template name="addParties">
							<xsl:with-param name="id" select="app:project_organisation1"/>
							<xsl:with-param name="name" select="concat(app:project_leader1_surname,', ',app:project_leader1_othname)"/>
							<xsl:with-param name="gmlId" select="@gml:id"/>
						</xsl:call-template>
					</xsl:if>

					<!-- project_organisation_2 -->
					<xsl:if test="app:project_organisation2">
						<xsl:call-template name="addParties">
							<xsl:with-param name="id" select="app:project_organisation2"/>
							<xsl:with-param name="name" select="concat(app:project_leader2_surname,', ',app:project_leader2_othname)"/>
							<xsl:with-param name="gmlId" select="@gml:id"/>
						</xsl:call-template>
					</xsl:if>

					<!-- project_organisation_3 -->
					<xsl:if test="app:project_organisation3">
						<xsl:call-template name="addParties">
							<xsl:with-param name="id" select="app:project_organisation3"/>
							<xsl:with-param name="name" select="concat(app:project_leader3_surname,', ',app:project_leader3_othname)"/>
							<xsl:with-param name="gmlId" select="@gml:id"/>
						</xsl:call-template>
					</xsl:if>

					<!-- add in customers as a user party -->
					<xsl:if test="app:customers">
						<mcp:responsibleParty>
							<mcp:CI_Responsibility>
								<mcp:role>
									<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="user"/>
								</mcp:role>
				
								<!-- NOTE: this is a link to the tempextent created below!!! -->
      					<mcp:extent xlink:href="#{concat(@gml:id,'_tempextent')}"/>
				
								<mcp:party>
									<mcp:CI_Individual>
			 							<mcp:name>
											<xsl:call-template name="doStr">
												<xsl:with-param name="value" select="app:customers"/>
											</xsl:call-template>
										</mcp:name>
									</mcp:CI_Individual>
								</mcp:party>
							</mcp:CI_Responsibility>
						</mcp:responsibleParty>
					</xsl:if>
					
					<!-- add in project_personnel as coinvestigators -->
					<xsl:if test="app:project_personnel">
						<mcp:responsibleParty>
							<mcp:CI_Responsibility>
								<mcp:role>
									<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="coInvestigator"/>
								</mcp:role>
				
								<!-- NOTE: this is a link to the tempextent created below!!! -->
      					<mcp:extent xlink:href="#{concat(@gml:id,'_tempextent')}"/>
				
								<mcp:party>
									<mcp:CI_Individual>
			 							<mcp:name>
											<xsl:call-template name="doStr">
												<xsl:with-param name="value" select="app:project_personnel"/>
											</xsl:call-template>
										</mcp:name>
									</mcp:CI_Individual>
								</mcp:party>
							</mcp:CI_Responsibility>
						</mcp:responsibleParty>
					</xsl:if>
					
				</mcp:CI_Citation>
			</fragment>

			<!-- abstract -->

			<fragment id="abstract">
				<xsl:variable name="desc">
						<xsl:value-of select="normalize-space(app:project_description)"/>
						<xsl:if test="app:project_full_description">
							<xsl:text>
							</xsl:text>
							<xsl:value-of select="normalize-space(app:project_full_description)"/>
							<xsl:if test="app:project_full_description2">
								<xsl:text>
								</xsl:text>
								<xsl:value-of select="normalize-space(app:project_full_description2)"/>
							</xsl:if>
						</xsl:if>
				</xsl:variable>
				<gmd:abstract>
					<xsl:choose>
						<xsl:when test="normalize-space($desc)='.'
												or normalize-space($desc)=''">
							<xsl:call-template name="doStr">
								<xsl:with-param name="value" select="concat('Project ',app:project_name,' has no description.')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="doStr">
								<xsl:with-param name="value" select="$desc"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</gmd:abstract>
			</fragment>

			<!-- temporal extent -->

			<fragment id="tempextent">
				<gmd:EX_Extent>
					<gmd:temporalElement>
						<gmd:EX_TemporalExtent>
							<gmd:extent>
								<gml:TimePeriod>
									<gml:beginPosition><xsl:value-of select="app:project_start_year"/></gml:beginPosition>
									<gml:endPosition><xsl:value-of select="app:project_end_year"/></gml:endPosition>
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
						<xsl:value-of select="app:project_start_year"/>
					</gco:Date>
				</gmd:dateStamp>
			</fragment>

			<!-- revision date -->

			<fragment id="revisiondate">
				<mcp:revisionDate>
					<gco:Date>
						<xsl:variable name="df">[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]</xsl:variable>
						<xsl:value-of select="format-dateTime(current-dateTime(),$df)"/>
					</gco:Date>
				</mcp:revisionDate>
			</fragment>

			<!-- add aggregates -->
			<xsl:if test="app:surveys">
        <replacementGroup id="aggregateInformation">

          <!-- surveys association -->

          <xsl:for-each select="app:surveys/*">
            <fragment id="aggregateInformation">
                <xsl:call-template name="addAggregate">
                  <xsl:with-param name="id" select="concat('urn:marine.csiro.au:survey:',app:survey_id)"/>
                  <xsl:with-param name="initiative" select="'survey'"/>
                </xsl:call-template>
            </fragment>
          </xsl:for-each>

        </replacementGroup>
			</xsl:if>

		</record>
	</xsl:template>


</xsl:stylesheet>
