<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:variable name="keywordThe">
		<xsl:value-of select="'urn:marine.csiro.au:keywords'"/>
	</xsl:variable>

	<xsl:variable name="regionThe">
		<xsl:value-of select="concat($keywordThe,':region')"/>
	</xsl:variable>

	<xsl:variable name="equipThe">
		<xsl:value-of select="concat($keywordThe,':equipment')"/>
	</xsl:variable>

	<xsl:variable name="subjectThe">
		<xsl:value-of select="concat($keywordThe,':subject')"/>
	</xsl:variable>

	<xsl:variable name="gcmdThe">
		<xsl:value-of select="concat($keywordThe,':gcmd')"/>
	</xsl:variable>

	<xsl:variable name="dataSourceThe">
		<xsl:value-of select="concat($keywordThe,':dataSource')"/>
	</xsl:variable>

	<xsl:variable name="cmarAOIThe">
		<xsl:value-of select="concat($keywordThe,':cmarAOI')"/>
	</xsl:variable>

	<xsl:variable name="taxonomicGroupThe">
		<xsl:value-of select="concat($keywordThe,':taxonomicGroup')"/>
	</xsl:variable>

	<xsl:variable name="habitatThe">
		<xsl:value-of select="concat($keywordThe,':habitat')"/>
	</xsl:variable>

	<xsl:variable name="standardDataTypeThe">
		<xsl:value-of select="concat($keywordThe,':standardDataType')"/>
	</xsl:variable>

	<xsl:variable name="anzlicThe">
		<xsl:value-of select="concat($keywordThe,':anzlicSearch')"/>
	</xsl:variable>

	<xsl:variable name="projectThe">
		<xsl:value-of select="'urn:marine.csiro.au:projectregister'"/>
	</xsl:variable>

	<xsl:variable name="projectTheTitle">
		<xsl:value-of select="'MarLIN Project Register'"/>
	</xsl:variable>

	<xsl:variable name="sourceThe">
		<xsl:value-of select="'urn:marine.csiro.au:sourceregister'"/>
	</xsl:variable>

	<xsl:variable name="sourceTheTitle">
		<xsl:value-of select="'MarLIN Source Register'"/>
	</xsl:variable>

	<xsl:variable name="globalProjectThe">
		<xsl:value-of select="'urn:marine.csiro.au:globalprojectregister'"/>
	</xsl:variable>

	<xsl:variable name="globalProjectTheTitle">
		<xsl:value-of select="'MarLIN Global Project Register'"/>
	</xsl:variable>

	<xsl:variable name="surveyThe">
		<xsl:value-of select="'urn:marine.csiro.au:surveyregister'"/>
	</xsl:variable>

	<xsl:variable name="surveyTheTitle">
		<xsl:value-of select="'MarLIN Survey Register'"/>
	</xsl:variable>

</xsl:stylesheet>
