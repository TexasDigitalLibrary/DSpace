<?xml version="1.0" encoding="UTF-8" ?>
<!-- Revisions  are provided by Texas Digital Libraries ETD Metadata Working Group, ca 2015.
	These revisions are made avalible to all without restrictions 
	provided any reuse follows the license and notice provided below. -->
<!-- 
    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>

 -->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" encoding="UTF-8" />
	
	<!-- namespace location -->
	<xsl:template match="/">
	<thesis xmlns="http://www.ndltd.org/standards/metadata/etdms/1-1"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.ndltd.org/standards/metadata/etdms/1-1/etdms11.xsd">

	<!-- ******* Title: <dc:title> ******* -->
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
		<title><xsl:value-of select="." /></title>
		</xsl:for-each>
	<!-- ******* Author: <dc.creator> ******* -->
		<!-- dc.contributor.author is deprecated-->
		<!--<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
		<creator><xsl:value-of select="." /></creator>
		</xsl:for-each>-->
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
			<creator><xsl:value-of select="." /></creator>
		</xsl:for-each>
	<!-- ******* Advisor(s): <dc.contributor.advisor > ******* -->
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='advisor']/doc:element/doc:field[@name='value']">
			<contributor><xsl:value-of select="." /></contributor>
		</xsl:for-each>
	<!-- ******* Subject Keywords: <dc:subject> ******* -->
	<!-- dc.subject -->
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
			<subject><xsl:value-of select="." /></subject>
		</xsl:for-each>
	<!-- dc.subject.qualifiers -->
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:element/doc:field[@name='value']">
			<subject><xsl:value-of select="." /></subject>
		</xsl:for-each>
	<!-- ******* Abstract/Descriptions ******* -->
	<!-- dc.description.abstract -->	
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
			<description.abstract><xsl:value-of select="." /></description.abstract>
		</xsl:for-each>
	<!-- dc.description and dc.description.qualifiers -->
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
			<description.note><xsl:value-of select="." /></description.note>
		</xsl:for-each>
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='sponsorship']/doc:element/doc:field[@name='value']">
			<description.note><xsl:value-of select="." /></description.note>
		</xsl:for-each>		
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='tableOfContents']/doc:element/doc:field[@name='value']">
			<description.note><xsl:value-of select="." /></description.note>
		</xsl:for-each>
	<!-- ******* Graduation Date: <dc.date.issued> ******* -->
		<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
			<date><xsl:value-of select="substring(.,0,11)" /></date>
		</xsl:for-each>
	<!-- ******* Institutional Repository URL: <dc.identifier.uri> ******* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
				<identifier><xsl:value-of select="." /></identifier>
			</xsl:for-each>
	<!-- ******* Author idenifier: <dc.identifier.orcid> ******* -->		
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='orcid']/doc:element/doc:field[@name='value']">
				<identifier.orcid><xsl:value-of select="." /></identifier.orcid>
			</xsl:for-each>
	<!-- ******* Type: <dc:type> ******* -->
	<!--  unqualified and qualified -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
				<type><xsl:value-of select="." /></type>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:element/doc:field[@name='value']">
				<type><xsl:value-of select="." /></type>
			</xsl:for-each>
	<!-- ******* Format: <dc:format> ******* -->
	<!--  unqualified and qualified -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:field[@name='value']">
				<format><xsl:value-of select="." /></format>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:element/doc:field[@name='value']">
				<format><xsl:value-of select="." /></format>
			</xsl:for-each>
	<!-- ******* Language: <dc:language> ******* -->
	<!--  unqualified and qualified -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
				<language><xsl:value-of select="." /></language>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
				<language><xsl:value-of select="." /></language>
			</xsl:for-each>
	<!-- ******* Rights Statements ******* -->
	<!--  unqualified and qualified -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
				<rights><xsl:value-of select="." /></rights>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value']">
				<rights><xsl:value-of select="." /></rights>
			</xsl:for-each>	
	<!-- ******* Degree Information ******* -->
			<xsl:if test="doc:metadata/doc:element[@name='thesis']">
			<degree>
	<!-- Awarding or granting insitution: <thesis.degree.grantor> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='thesis']/doc:element[@name='degree']/doc:element[@name='grantor']/doc:element/doc:field[@name='value']">
				<grantor><xsl:value-of select="." /></grantor>
			</xsl:for-each>
	<!--Degree name: <thesis.degree.name> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='thesis']/doc:element[@name='degree']/doc:element[@name='name']/doc:element/doc:field[@name='value']">
				<name><xsl:value-of select="." /></name>
			</xsl:for-each>
	<!--Degree level: <thesis.degree.level> -->	
			<xsl:for-each select="doc:metadata/doc:element[@name='thesis']/doc:element[@name='degree']/doc:element[@name='level']/doc:element/doc:field[@name='value']">
				<level><xsl:value-of select="." /></level>
			</xsl:for-each>
	<!--Area of study/Discipline: <thesis.degree.discipline> -->				
			<xsl:for-each select="doc:metadata/doc:element[@name='thesis']/doc:element[@name='degree']/doc:element[@name='discipline']/doc:element/doc:field[@name='value']">
				<discipline><xsl:value-of select="." /></discipline>
			</xsl:for-each>
			</degree>
			</xsl:if>
		</thesis>
	</xsl:template>
</xsl:stylesheet>
