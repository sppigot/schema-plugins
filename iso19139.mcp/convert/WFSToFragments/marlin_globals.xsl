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
		xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

	<xsl:include href="../../../iso19135/convert/WFSToFragments/marlin_keywords_globals.xsl"/>

	<xsl:variable name="df">[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]</xsl:variable>

	<xsl:template name="addCSquaresCitation">
		<mcp:CI_Citation>
			<gmd:title>
				<gco:CharacterString>c-squares</gco:CharacterString>
			</gmd:title>
			<gmd:date>
				<gmd:CI_Date>
					<gmd:date>
						<gco:Date>2001-12-13</gco:Date>
					</gmd:date>
					<gmd:dateType>
						<gmd:CI_DateTypeCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="creation"/>
					</gmd:dateType>
				</gmd:CI_Date>
			</gmd:date>
			<gmd:otherCitationDetails>
				<gmx:Anchor xlink:href="http://www.marine.csiro.au/csquares/index.html">C-squares website</gmx:Anchor>
			</gmd:otherCitationDetails>
      <mcp:responsibleParty>
				<mcp:CI_Responsibility>
        	<mcp:role>
          	<gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="owner"/>
       		</mcp:role>
					<!-- person number 1 is Tony Rees, the c-squares man -->
        	<mcp:party xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:person:1_person_organisation"/>
      	</mcp:CI_Responsibility>
			</mcp:responsibleParty>
    </mcp:CI_Citation> 	
	</xsl:template>

	<xsl:template name="addTheCitation">
		<xsl:param name="title"/>
		<xsl:param name="edition"/>
		<xsl:param name="thesaurus"/>
		<xsl:param name="thesaurusType" select="'theme'"/>
		<xsl:param name="thesaurusSource" select="'register'"/>
		<xsl:param name="siteUrl"/>
		<xsl:param name="orgName" select="'CSIRO Marine and Atmospheric Research Data Centre'"/>
		<xsl:param name="otherCit" select="''"/>

		<gmd:CI_Citation>
 			<gmd:title>
     		<gco:CharacterString><xsl:value-of select="$title"/></gco:CharacterString>
 			</gmd:title>
			<gmd:date gco:nilReason="missing"/>
			<gmd:edition>
				<gco:CharacterString><xsl:value-of select="$edition"/></gco:CharacterString>
			</gmd:edition>
			<!-- FIXME: Today's date please -->
			<gmd:editionDate>
				<gco:Date>2012-06-18</gco:Date>
			</gmd:editionDate>
			<gmd:identifier>
				<gmd:MD_Identifier>
					<gmd:code>
             <gmx:Anchor xlink:href="{$siteUrl}/srv/en/?uuid={$thesaurus}"><xsl:value-of select="concat('geonetwork.thesaurus.',$thesaurusSource,'.',$thesaurusType,'.',$thesaurus)"/></gmx:Anchor>
					</gmd:code>
				</gmd:MD_Identifier>
			</gmd:identifier>
			<gmd:citedResponsibleParty>
				<gmd:CI_ResponsibleParty>
					<gmd:organisationName>
              <gco:CharacterString><xsl:value-of select="$orgName"/></gco:CharacterString>
					</gmd:organisationName>
					<gmd:role>
              <gmd:CI_RoleCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="custodian">custodian</gmd:CI_RoleCode>
					</gmd:role>
				</gmd:CI_ResponsibleParty>
			</gmd:citedResponsibleParty>
			<xsl:if test="normalize-space($otherCit)!=''">
				<gmd:otherCitationDetails>
					<gco:CharacterString><xsl:value-of select="$otherCit"/></gco:CharacterString>
				</gmd:otherCitationDetails>
			</xsl:if>
		</gmd:CI_Citation>
	</xsl:template>

	<xsl:template name="addAggregate">
		<xsl:param name="id"/>
		<xsl:param name="initiative"/>

		<xsl:variable name="the">
			<xsl:choose>
				<xsl:when test="contains($id,'globalproject')">
					<xsl:value-of select="$globalProjectThe"/>
				</xsl:when>
				<xsl:when test="contains($id,'project')">
					<xsl:value-of select="$projectThe"/>
				</xsl:when>
				<xsl:when test="contains($id,'survey')">
					<xsl:value-of select="$surveyThe"/>
				</xsl:when>
				<xsl:when test="contains($id,'source')">
					<xsl:value-of select="$sourceThe"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<gmd:aggregationInfo>
    	<gmd:MD_AggregateInformation>
				<gmd:aggregateDataSetIdentifier>
					<gmd:MD_Identifier>
						<xsl:if test="normalize-space($the)!=''">
							<gmd:authority>
								<xsl:call-template name="addTheCitation">
									<xsl:with-param name="title">
										<xsl:choose>
											<xsl:when test="contains($id,'globalproject')">
												<xsl:value-of select="$globalProjectTheTitle"/>
											</xsl:when>
											<xsl:when test="contains($id,'project')">
												<xsl:value-of select="$projectTheTitle"/>
											</xsl:when>
											<xsl:when test="contains($id,'survey')">
												<xsl:value-of select="$surveyTheTitle"/>
											</xsl:when>
											<xsl:when test="contains($id,'source')">
												<xsl:value-of select="$sourceTheTitle"/>
											</xsl:when>
										</xsl:choose>
									</xsl:with-param>
									<xsl:with-param name="edition" select="concat($the,':conceptscheme#0.0')"/>
									<xsl:with-param name="thesaurus" select="$the"/>
									<xsl:with-param name="thesaurusType">
										<xsl:choose>
											<xsl:when test="contains($id,'survey')">
												<xsl:value-of select="'survey'"/>
											</xsl:when>
											<xsl:when test="contains($id,'source')">
												<xsl:value-of select="'source'"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="'project'"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:with-param>
								</xsl:call-template>
							</gmd:authority>
						</xsl:if>
						<gmd:code>
							<gco:CharacterString><xsl:value-of select="$id"/></gco:CharacterString>
						</gmd:code>
					</gmd:MD_Identifier>
				</gmd:aggregateDataSetIdentifier>
				<gmd:associationType>
					<gmd:DS_AssociationTypeCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#DS_AssociationTypeCode" codeListValue="crossReference">crossReference</gmd:DS_AssociationTypeCode>
				</gmd:associationType>
				<gmd:initiativeType>
					<gmd:DS_InitiativeTypeCode codeList="http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/resources/Codelist/gmxCodelists.xml#DS_InitiativeTypeCode" codeListValue="{$initiative}"><xsl:value-of select="$initiative"/></gmd:DS_InitiativeTypeCode>
				</gmd:initiativeType>
			</gmd:MD_AggregateInformation>
		</gmd:aggregationInfo>
	</xsl:template>

	<xsl:template name="doStr">
    <xsl:param name="value"/>
    <xsl:choose>
      <xsl:when test="normalize-space($value)=''">
        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
        <gco:CharacterString/>
      </xsl:when>
      <xsl:otherwise>
        <gco:CharacterString><xsl:value-of select="$value"/></gco:CharacterString>
      </xsl:otherwise>
    </xsl:choose>	
	</xsl:template>

	<xsl:template name="addCMARCitation">
		<xsl:param name="title" select="''"/>

		<mcp:CI_Citation gco:isoType="gmd:CI_Citation">
			<gmd:title>
				<xsl:call-template name="doStr">
					<xsl:with-param name="value" select="$title"/>
				</xsl:call-template>
			</gmd:title>
			<gmd:date gco:nilReason="unknown"/>
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
	
					<mcp:party>
						<mcp:CI_Organisation>
							<mcp:name xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:org:1_organisation_name"/>
							<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:org:1_contact_info_mailing_address"/>
							<!-- FIXME: Leave out the street address for the time being
							<mcp:contactInfo xlink:href="http://localhost:8080/geonetwork/srv/en/xml.metadata.get?uuid=urn:marine.csiro.au:org:1_contact_info_street_address"/>
							-->
						</mcp:CI_Organisation>
					</mcp:party>
				</mcp:CI_Responsibility>
			</mcp:responsibleParty>
		</mcp:CI_Citation>
	</xsl:template>

</xsl:stylesheet>

