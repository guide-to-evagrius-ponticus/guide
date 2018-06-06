<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">
    <xsl:import href="transcriptions-core.xsl"/>
    
    <!-- Input: A TAN-A-div file from the sibling directory tan -->
    <!-- Output: the html page for the TAN file -->
    
    <xsl:variable name="this-cpg" as="xs:string">
        <xsl:analyze-string select="tan:cfn(/)" regex="(no)?cpg\d+(a|\.\d)?">
            <xsl:matching-substring>
                <xsl:value-of select="."/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    <xsl:param name="output-url-relative-to-template" as="xs:string?"
        select="concat($this-cpg, '.html')"/>
    
    <xsl:template match="html:head/html:script[last()]" mode="revise-infused-template">
        <xsl:copy-of select="."/>
        <script type="application/javascript" src="scripts/jquery-ui-1.12.1/jquery-ui.js"/>
    </xsl:template>
    <xsl:template match="html:div[matches(@class, 'TAN-T-merge')]/html:div[following-sibling::html:hr]" mode="revise-infused-template">
        <h2><xsl:value-of select="."/></h2>
    </xsl:template>
    <xsl:template match="text()" mode="revise-infused-template">
        <xsl:value-of select="replace(., '_', ' ')"/>
    </xsl:template>
    <!--<xsl:template match="html:div[tokenize(@class,' ') = 'version'][1]" mode="revise-infused-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="../html:div[@class = 'ref']"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>-->
    
    <!--<xsl:template match="/" priority="5">
        <!-\- diagnostics -\->
        <diagnostics>
            <!-\-<xsl:copy-of select="tan:collate-sequences($test1)"/>-\->
            <!-\-<xsl:copy-of select="tan:merge-expanded-docs($self-expanded[position() gt 1])"/>-\->
            <!-\-<xsl:copy-of select="$input-pass-1"/>-\->
            <!-\-<xsl:copy-of select="$input-pass-2"/>-\->
            <!-\-<xsl:copy-of select="$input-pass-3"/>-\->
            <!-\-<xsl:copy-of select="$input-pass-4"/>-\->
            <!-\-<test05><xsl:copy-of select="$template-url-resolved"/></test05>-\->
            <!-\-<xsl:copy-of select="$template-doc"/>-\->
            <xsl:copy-of select="$template-infused-with-revised-input"/>
        </diagnostics>
    </xsl:template>-->
    
</xsl:stylesheet>
