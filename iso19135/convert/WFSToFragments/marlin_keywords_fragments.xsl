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
	<xsl:param name="siteUrl"/>

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

	<xsl:include href="marlin_keywords_globals.xsl"/>

	<!-- 
			 This xslt transforms GetFeature outputs from the WFS Marlin database
	     into ISO metadata fragments. The fragments are used by GeoNetwork to 
			 build ISO metadata records.
	 -->

	<!-- these thesauri are the references we use to look up MarLIN versions and
	     retrieve similarities -->
	<xsl:variable name="anzlicGENThesaurus"   select="'4b63b0fd-fbb5-4ef7-b568-cea96d42ba63'"/>
	<xsl:variable name="anzlicGEN"    select="document(concat($siteUrl,'/srv/eng/xml.metadata.get?uuid=',$anzlicGENThesaurus))"/>
	<xsl:variable name="anzlicSearch" select="document(concat($siteUrl,'/srv/eng/xml.metadata.get?uuid=b920278d-fafa-4d75-898f-cd55bce8f04f'))"/>

	<xsl:template name="returnType">
		<xsl:variable name="keywordType" select="//app:keyword_type"/>

		<!--
			b - ????? - not handled
			Y - Stored Data Format - not handled
			Q - Standard Data Types - y
			h - Habitats?????????? - not handled
			t - Taxonomic Groups????????? - not handled
			H - Habitats - y
			T - Taxonomic Groups - y
			W - Update times - not handled
			A - ANZLIC search term
			Z - not known - not handled
			p - ??? - not handled

			E - equipment - y
			P - GCMD
			L - Languages - not handled
			D - data source - y
			C - CMAR Areas of Interest
			V - Dataset status - not handled
			S - Subject - y
			X - Available Data Format - not handled
			G - Projections - not handled
			I - ISO Topic Categories - not necessary?
		-->
		<xsl:choose>
			<xsl:when test="normalize-space($keywordType[1]) = 'S'">
				<xsl:text>subject</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space($keywordType[1]) = 'P'">
				<xsl:text>gcmd</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space($keywordType[1]) = 'E'">
				<xsl:text>equipment</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space($keywordType[1]) = 'D'">
				<xsl:text>dataSource</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space($keywordType[1]) = 'Q'">
				<xsl:text>standardDataType</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space($keywordType[1]) = 'H'">
				<xsl:text>habitat</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space($keywordType[1]) = 'T'">
				<xsl:text>taxonomicGroup</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space($keywordType[1]) = 'C'">
				<xsl:text>cmarAOI</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space($keywordType[1]) = 'A'">
				<xsl:text>anzlicSearch</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

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
					<xsl:when test="gml:featureMember/app:MarlinKeywords">
						<xsl:variable name="type">
							<xsl:call-template name="returnType"/>
						</xsl:variable>
						<xsl:value-of select="concat($keywordThe,':',$type)"/>
					</xsl:when>
					<xsl:when test="gml:featureMember/app:MarlinDatasetRegions">
						<xsl:value-of select="concat($keywordThe,':region')"/>
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

	<xsl:template name="processBroaderLineage">
		<xsl:if test="app:keyword_type='P' or app:keyword_type='T' 
								  or app:keyword_type='H'">
				<xsl:variable name="var"   select="app:gcmd_variable"/>
				<xsl:variable name="term"  select="app:gcmd_term"/>
				<xsl:variable name="topic" select="app:gcmd_topic"/>
				<xsl:variable name="categ" select="app:gcmd_category"/>
				<xsl:variable name="broaderIdentifier">
				<xsl:choose>
					<xsl:when test="normalize-space(app:detailed_variable)!=''">
						<xsl:variable name="found" select="//app:MarlinKeywords[app:gcmd_variable=$var and app:gcmd_term=$term and app:gcmd_topic=$topic and app:gcmd_category=$categ and not(app:detailed_variable)]"/>
						<!--
						<xsl:message>DV Found '<xsl:value-of select="$found/app:gcmd_variable"/>'         for        '<xsl:value-of select="app:detailed_variable"/>'      in         '<xsl:value-of select="app:description"/>'</xsl:message>
						-->
						<xsl:value-of select="$found/app:keyword_id"/>
					</xsl:when>
					<xsl:when test="normalize-space(app:gcmd_variable)!=''">
						<xsl:variable name="found" select="//app:MarlinKeywords[app:gcmd_term=$term and app:gcmd_topic=$topic and app:gcmd_category=$categ and not(app:gcmd_variable)]"/>
						<!--
						<xsl:message>VA Found '<xsl:value-of select="$found/app:gcmd_term"/>'             for       '<xsl:value-of select="$var"/>'                in           '<xsl:value-of select="app:description"/>'</xsl:message>
						-->
						<xsl:value-of select="$found/app:keyword_id"/>
					</xsl:when>
					<xsl:when test="normalize-space(app:gcmd_term)!=''">
						<xsl:variable name="found" select="//app:MarlinKeywords[app:gcmd_topic=$topic and not(app:gcmd_term)]"/> 
						<!--
						<xsl:message>TE Found '<xsl:value-of select="$found/app:gcmd_topic"/>'      for       '<xsl:value-of select="$topic"/>'           in           '<xsl:value-of select="app:description"/>'</xsl:message>
						-->
						<xsl:value-of select="$found/app:keyword_id"/>
					</xsl:when>
					<xsl:when test="normalize-space(app:gcmd_topic)!=''">
						<xsl:variable name="found" select="//app:MarlinKeywords[app:gcmd_category=$categ and not(app:gcmd_topic)]"/> 
						<!--
						<xsl:message>TO Found '<xsl:value-of select="$found/app:gcmd_category"/>'  for     '<xsl:value-of select="$categ"/>'              in              '<xsl:value-of select="app:description"/>'</xsl:message>
						-->
						<xsl:value-of select="$found/app:keyword_id"/>
					</xsl:when>
				</xsl:choose>
				</xsl:variable>

				<xsl:choose>
				<xsl:when test="normalize-space($broaderIdentifier)!=''">
					<grg:specificationLineage>
            <grg:RE_Reference>
               <grg:itemIdentifierAtSource>
                  <gco:CharacterString><xsl:value-of select="$broaderIdentifier"/></gco:CharacterString>
               </grg:itemIdentifierAtSource>
               <grg:similarity>
                  <grg:RE_SimilarityToSource codeListValue="generalization"
                                             codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#RE_SimilarityToSource"/>
               </grg:similarity>
            </grg:RE_Reference>
         	</grg:specificationLineage>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>ALARM: Keyword <xsl:value-of select="app:keyword_id"/> does not have a broader semantic relationship</xsl:message>
				</xsl:otherwise>
				</xsl:choose>

		</xsl:if>
	</xsl:template>

	<xsl:template name="processAnzlicEquals">

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
		<xsl:variable name="anzLookup" select="$anzlicSearch//grg:containedItem/*[grg:name/gco:CharacterString=$anzlicSearchWord]"/>	

		<xsl:if test="count($anzLookup)>0"> 
			<grg:specificationLineage uuidref="b920278d-fafa-4d75-898f-cd55bce8f04f">
        <grg:RE_Reference>
          <grg:itemIdentifierAtSource>
            <gco:CharacterString><xsl:value-of select="$anzLookup/grg:itemIdentifier/gco:Integer"/></gco:CharacterString>
          </grg:itemIdentifierAtSource>
          <grg:similarity>
            <grg:RE_SimilarityToSource codeListValue="identical"
                                       codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#RE_SimilarityToSource"/>
          </grg:similarity>
        </grg:RE_Reference>
     	</grg:specificationLineage>
		</xsl:if>
	</xsl:template>

	<!-- process a record from the MarLIN keywords table -->
	<xsl:template name="addKeywordRegisterItem">
		<xsl:param name="keywordUuid"/>

		<fragment id="register_item" uuid="{$keywordUuid}" title="{concat(normalize-space(app:keyword_type),':',app:description)}">
			<grg:containedItem>
				<gnreg:RE_RegisterItem>
					<grg:itemIdentifier>
						<gco:Integer><xsl:value-of select="app:keyword_id"/></gco:Integer>
					</grg:itemIdentifier>
					<grg:name>
						<gco:CharacterString>
							<xsl:choose>
							<xsl:when test="app:keyword_type='P' or app:keyword_type='T' 
								                or app:keyword_type='H'">
								<xsl:choose>
								<xsl:when test="normalize-space(app:detailed_variable)!=''">
									<xsl:value-of select="app:detailed_variable"/>
								</xsl:when>
								<xsl:when test="normalize-space(app:gcmd_variable)!=''">
									<xsl:value-of select="app:gcmd_variable"/>
								</xsl:when>
								<xsl:when test="normalize-space(app:gcmd_term)!=''">
									<xsl:value-of select="app:gcmd_term"/>
								</xsl:when>
								<xsl:when test="normalize-space(app:gcmd_topic)!=''">
									<xsl:value-of select="app:gcmd_topic"/>
								</xsl:when>
								<xsl:when test="normalize-space(app:gcmd_category)!=''">
									<xsl:value-of select="app:gcmd_category"/>
								</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="app:keyword_type='A'">
								<xsl:choose>
									<xsl:when test="normalize-space(app:anzlic_qualifier)!=''">
										<xsl:value-of select="concat(app:anzlic_search_word,'-',app:anzlic_qualifier)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="app:anzlic_search_word"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="app:description"/>
							</xsl:otherwise>
							</xsl:choose>
						</gco:CharacterString>
					</grg:name>
					<grg:status>
						<grg:RE_ItemStatus>valid</grg:RE_ItemStatus>
					</grg:status>
					<grg:dateAccepted>
						<gco:Date>2012-06-30</gco:Date>
					</grg:dateAccepted>
					<xsl:choose>
					<xsl:when test="app:keyword_type='P' or app:keyword_type='T' 
					                or app:keyword_type='H'">
						<grg:definition>
							<gco:CharacterString><xsl:value-of select="app:description"/></gco:CharacterString>
						</grg:definition>
					</xsl:when>
					<xsl:when test="app:keyword_type='A'">
						<grg:definition>
							<gco:CharacterString>
								<xsl:choose>
									<xsl:when test="normalize-space(app:anzlic_qualifier)!=''">
										<xsl:value-of select="concat(app:anzlic_search_word,'-',app:anzlic_qualifier)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="app:anzlic_search_word"/>
									</xsl:otherwise>
								</xsl:choose>
							</gco:CharacterString>
						</grg:definition>
					</xsl:when>
					<xsl:when test="normalize-space(app:notes)!=''">
						<grg:definition>
							<gco:CharacterString><xsl:value-of select="app:notes"/></gco:CharacterString>
						</grg:definition>
					</xsl:when>
					</xsl:choose>
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
					<xsl:choose>
						<xsl:when test="app:keyword_type='P' or app:keyword_type='T' 
					                or app:keyword_type='H'">
							<xsl:call-template name="processBroaderLineage"/>
						</xsl:when>
						<xsl:when test="app:keyword_type='A'">
							<xsl:call-template name="processAnzlicEquals"/>
						</xsl:when>
					</xsl:choose>
					<gnreg:itemIdentifier>
						<gco:CharacterString><xsl:value-of select="$keywordUuid"/></gco:CharacterString>
					</gnreg:itemIdentifier>
				</gnreg:RE_RegisterItem>
			</grg:containedItem>
		</fragment>
	</xsl:template>

	<!-- process a record from the MarLIN keywords table -->
	<xsl:template name="addRegionRegisterItem">
		<xsl:param name="keywordUuid"/>

		<fragment id="register_item" uuid="{$keywordUuid}" title="{concat(app:defined_region_id,':',app:defined_region_name)}">
			<grg:containedItem>
				<grg:RE_RegisterItem uuid="{$keywordUuid}">
					<grg:itemIdentifier>
						<gco:Integer><xsl:value-of select="app:defined_region_id"/></gco:Integer>
					</grg:itemIdentifier>
					<grg:name>
						<gco:CharacterString>
							<xsl:choose>
								<xsl:when test="app:anzlic_jurisdiction and app:anzlic_category and app:anzlic_name">
									<xsl:value-of select="concat(app:anzlic_jurisdiction,' > ',app:anzlic_category,' > ',app:anzlic_name)"/>
								</xsl:when>
								<xsl:when test="app:defined_region_name">
									<xsl:value-of select="app:defined_region_name"/>
								</xsl:when>
							</xsl:choose>
						</gco:CharacterString>
					</grg:name>
					<grg:status>
						<grg:RE_ItemStatus>valid</grg:RE_ItemStatus>
					</grg:status>
					<grg:dateAccepted>
						<gco:Date>2011-07-06</gco:Date>
					</grg:dateAccepted>
					<grg:definition>
						<gco:CharacterString><xsl:value-of select="app:location_description"/></gco:CharacterString>
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
					<xsl:variable name="anzlicName" select="app:anzlic_name"/>
					<xsl:if test="normalize-space($anzlicName)!=''">
						<xsl:variable name="anzlicLookup" select="$anzlicGEN//grg:RE_RegisterItem[grg:name=$anzlicName]"/>
						<xsl:if test="count($anzlicLookup)>0">
							<grg:specificationLineage uuidref="$anzlicGENThesaurus">
								<grg:RE_Reference>
									<grg:itemIdentifierAtSource>
										<gco:CharacterString><xsl:value-of select="$anzlicLookup/grg:itemIdentifer/*"/></gco:CharacterString>
									</grg:itemIdentifierAtSource>
									<grg:similarity>
										<grg:RE_SimilarityToSource codeListValue="identical"
							 														 	   codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#RE_SimilarityToSource"/>
									</grg:similarity>
								</grg:RE_Reference>
							</grg:specificationLineage>
						</xsl:if>
					</xsl:if>
					<gnreg:itemIdentifier>
						<gco:CharacterString><xsl:value-of select="$keywordUuid"/></gco:CharacterString>
					</gnreg:itemIdentifier>
					<gnreg:extent>
						<gmd:EX_Extent>
							<gmd:geographicElement>
								<gmd:EX_GeographicBoundingBox>
									<gmd:westBoundLongitude>
										<gco:Decimal><xsl:value-of select="app:west_bounding_coordinate"/></gco:Decimal>
									</gmd:westBoundLongitude>
									<gmd:eastBoundLongitude>
										<gco:Decimal><xsl:value-of select="app:east_bounding_coordinate"/></gco:Decimal>
									</gmd:eastBoundLongitude>
									<gmd:southBoundLatitude>
										<gco:Decimal><xsl:value-of select="app:south_bounding_coordinate"/></gco:Decimal>
									</gmd:southBoundLatitude>
									<gmd:northBoundLatitude>
										<gco:Decimal><xsl:value-of select="app:north_bounding_coordinate"/></gco:Decimal>
									</gmd:northBoundLatitude>
								</gmd:EX_GeographicBoundingBox>
							</gmd:geographicElement>
						</gmd:EX_Extent>	
					</gnreg:extent>
				</grg:RE_RegisterItem>
			</grg:containedItem>
		</fragment>
	</xsl:template>

	<!-- process the featureMember elements in WFS response -->
	<xsl:template match="gml:featureMember">
		<xsl:param name="uuid"/>
		
		<xsl:apply-templates select="app:MarlinKeywords">
			<xsl:with-param name="uuid" select="$uuid"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="app:MarlinDatasetRegions">
			<xsl:with-param name="uuid" select="$uuid"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- process the MarlinKeywords in WFS response -->
	<xsl:template match="app:MarlinKeywords">
			<xsl:param name="uuid"/>

			<xsl:call-template name="addKeywordRegisterItem">
				<xsl:with-param name="keywordUuid" select="concat($uuid,':concept:',app:keyword_id)"/>
			</xsl:call-template>

	</xsl:template>

	<!-- process the MarlinDatasetRegions in WFS response -->
	<xsl:template match="app:MarlinDatasetRegions">
			<xsl:param name="uuid"/>

			<xsl:call-template name="addRegionRegisterItem">
				<xsl:with-param name="keywordUuid" select="concat($uuid,':concept:',app:defined_region_id)"/>
			</xsl:call-template>

	</xsl:template>


</xsl:stylesheet>
