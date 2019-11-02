<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">
    <xsl:import href="../../TAN/TAN-2020/functions/TAN-T-functions.xsl"/>
    <xsl:import href="../../TAN/TAN-2020/functions/TAN-extra-functions.xsl"/>
    <xsl:import href="../../TAN/TAN-2020/applications/get%20inclusions/convert-TAN-to-HTML.xsl"/>
    
    <xsl:param name="diagnostics-on" select="true()" static="yes"/>
    
    <!-- Input: A TAN file from the sibling directory tan -->
    <!-- Output: the html page for the TAN file -->
    
    <xsl:output indent="yes" use-when="$diagnostics-on"/>
    
    <xsl:param name="validation-phase" select="'terse'"/>
    <xsl:param name="distribute-vocabulary" select="true()"/>
    
    <xsl:variable name="input-adjusted-for-gep" as="document-node()?">
        <xsl:apply-templates select="$self-expanded" mode="adjust-tan-t-for-gep"/>
    </xsl:variable>
    <!-- elements to suppress -->
    <xsl:template
        match="tan:name[@norm] | tan:vocabulary-key | tan:vocabulary | tan:tan-vocabulary | tan:annotation | tan:to-do"
        mode="adjust-tan-t-for-gep"/>
    
    <xsl:variable name="tan-file-as-html" select="tan:tan-to-html($input-adjusted-for-gep)"/>
    
    <!-- skip tei elements, errors, warnings -->
    <xsl:template match="tei:teiHeader | tan:div/tei:* | tan:error | tan:warning | tan:help" mode="tan-to-html-pass-2"/>
    
    <xsl:variable name="gep-template" select="doc('../template.html')"/>
    
    <xsl:variable name="output-pass-1" as="document-node()?">
        <xsl:apply-templates select="$gep-template" mode="infuse-gep-template"/>
    </xsl:variable>
    <xsl:template match="html:head" mode="infuse-gep-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <link rel="stylesheet" type="text/css" href="css/tan2018.css" />
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:body" mode="infuse-gep-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <script type="text/javascript" src="scripts/tan2018.js"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:div[@id = 'content']" mode="infuse-gep-template">
        <xsl:apply-templates select="$tan-file-as-html/*" mode="#current"/>
    </xsl:template>
    
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$diagnostics-on">
                <!-- diagnostics -->
                <diagnostics>
                    <self-resolved><xsl:copy-of select="$self-resolved"/></self-resolved>
                    <input-adjusted><xsl:copy-of select="$input-adjusted-for-gep"/></input-adjusted>
                    <tan-as-html><xsl:copy-of select="$tan-file-as-html"/></tan-as-html>
                    <gep-template><xsl:copy-of select="$gep-template"/></gep-template>
                    <output-1><xsl:copy-of select="$output-pass-1"/></output-1>
                </diagnostics>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$output-pass-1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
