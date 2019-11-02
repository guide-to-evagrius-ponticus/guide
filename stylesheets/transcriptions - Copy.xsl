<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">
    <xsl:import href="transcriptions-core.xsl"/>
    
    <xsl:param name="diagnostics-on" select="true()" static="yes"/>
    
    <!-- Input: A TAN file from the sibling directory tan -->
    <!-- Output: the html page for the TAN file -->
    
    <xsl:param name="validation-phase" select="'terse'"/>
    <xsl:param name="input-items" select="$self-expanded"/>
    <xsl:param name="elements-to-be-labeled" as="xs:string*" select="'head'"/>
    <xsl:param name="output-url-relative-to-template" as="xs:string?"
        select="concat(tan:cfn(/), '.html')"/>
    
    <xsl:output indent="yes" use-when="$diagnostics-on"/>
    
    <!-- override merged sources html input pass 1 document node template -->
    <!-- Oct. 2019: The TAN application is a hot mess, and not well concieved. Trying to make do with what is present. -->
    <xsl:template match="/" mode="input-pass-1">
        <xsl:document>
            <xsl:apply-templates mode="#current"/>
        </xsl:document>
    </xsl:template>
    
    <!-- ignore TEI header, tei elements -->
    <xsl:template match="tei:teiHeader | tan:div/tei:*" mode="tan-to-html-pass-2"/>
    
    <xsl:template match="html:div[@class='head']/html:div[@class='label']" mode="revise-infused-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>about this transcription</xsl:text>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:div[@class='body']" mode="revise-infused-template">
        <h2>
            <xsl:value-of select="$input-items/*/tan:head/tan:name[1]"/>
        </h2>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/" priority="5">
        <xsl:choose>
            <xsl:when test="$diagnostics-on">
                <!-- diagnostics -->
                <diagnostics>
                    <!--<i><xsl:copy-of select="$input-items"/></i>-->
                    <!--<i1><xsl:copy-of select="$input-pass-1"/></i1>-->
                    <!--<i2><xsl:copy-of select="$input-pass-2"/></i2>-->
                    <!--<i3><xsl:copy-of select="$input-pass-3"/></i3>-->
                    <i4><xsl:copy-of select="$input-pass-4"/></i4>
                    <!--<xsl:copy-of select="$template-doc"/>-->
                    <html1><xsl:copy-of select="$template-infused-with-revised-input"/></html1>
                    <html2><xsl:copy-of select="$infused-template-revised"/></html2>
                </diagnostics>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$infused-template-revised"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
