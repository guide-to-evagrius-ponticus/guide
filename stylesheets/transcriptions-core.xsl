<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">
    <xsl:import href="../../TAN/TAN-2018/do%20things/display/display%20merged%20sources%20as%20HTML.xsl"/>
    
    <xsl:param name="template-url-resolved"
        select="resolve-uri('../template.html', static-base-uri())"/>
    <!--<xsl:param name="replace-template-element-with-text-content" as="xs:string"
        select="'page content goes here'"/>-->
    <xsl:param name="levels-to-convert-to-aaa" as="xs:integer*" select="()"/>

    <!-- Input pass 1 -->
    <!-- For the time being, we turn off TEI formatting -->
    <xsl:template match="tan:div/tei:*" mode="input-pass-1"/>
    
    <!-- Infuse template -->
    <!-- Override the default behavior -->
    <xsl:template match="html:body" mode="infuse-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <!-- Find the element that's marked to be exchanged -->
    <xsl:template match="html:div[@class = 'body']" mode="infuse-template">
        <xsl:param name="new-content" tunnel="yes"/>
        <xsl:copy-of select="$new-content"/>
    </xsl:template>

    <!-- Revising infused template -->
    <xsl:template match="html:head" mode="revise-infused-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <link rel="stylesheet" type="text/css" href="css/tan2018.css" />
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:body" mode="revise-infused-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <script type="text/javascript" src="scripts/tan2018.js"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
