<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">
    <xsl:import href="../../TAN/TAN-2020/functions/TAN-T-functions.xsl"/>
    <xsl:import href="../../TAN/TAN-2020/functions/TAN-extra-functions.xsl"/>
    <xsl:import href="../../TAN/TAN-2020/applications/get%20inclusions/convert-TAN-to-HTML.xsl"/>
    
    <xsl:param name="diagnostics-on" select="false()" static="yes"/>
    
    <!-- Input: A TAN file from the sibling directory tan -->
    <!-- Output: the html page for the TAN file -->
    
    <xsl:output indent="yes" use-when="$diagnostics-on"/>
    
    <xsl:param name="validation-phase" select="'terse'"/>
    <xsl:param name="distribute-vocabulary" select="true()"/>
    
    <!-- STEP 1: ADJUST INPUT (SELF EXPANDED) -->
    <xsl:variable name="input-adjusted-for-gep" as="document-node()?">
        <xsl:apply-templates select="$self-expanded" mode="adjust-tan-t-for-gep"/>
    </xsl:variable>
    <!-- elements to suppress -->
    <xsl:template
        match="tan:name[@norm] | tan:vocabulary-key | tan:vocabulary | tan:tan-vocabulary 
        | tan:annotation | tan:to-do | tan:expanded | tan:resolved | tan:stamped"
        mode="adjust-tan-t-for-gep"/>
    
    
    <!-- STEP 2: CONVERT INPUT TO HTML -->
    <xsl:variable name="tan-file-as-html" select="tan:tan-to-html($input-adjusted-for-gep)"/>
    <xsl:param name="children-element-values-to-add-to-class-attribute" as="xs:string*"
        select="()"/>
    <!-- skip tei elements, errors, warnings -->
    <xsl:template match="tei:teiHeader | tan:div[tei:*]/text() | tan:error | tan:warning | tan:help" mode="tan-to-html-pass-2"/>
    
    
    
    <!-- STEP 3: GET TEMPLATE AND INFUSE IT WITH INPUT CONTENT -->
    <xsl:variable name="gep-template" select="doc('../template.html')"/>
    <xsl:param name="elements-to-be-labeled" as="xs:string*" select="()"/>
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
    <xsl:template match="html:div[@class = 'head']" mode="infuse-gep-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <div class="label">about this transcription</div>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:div[html:div[@class = 'IRI']][not(preceding-sibling::html:div[@class = 'label'])]"
        mode="infuse-gep-template">
        <!-- Insert an info icon label for anything that's a vocab item not preceded by a sibling label -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <div class="label">🛈</div>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template
        match="html:div[tokenize(@class, ' ') = 'TAN-T']/html:div[tokenize(@class, ' ') = 'body']"
        mode="infuse-gep-template">
        <h2>
            <xsl:value-of select="$input-adjusted-for-gep/*/tan:head/tan:name[1]"/>
        </h2>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:div[@class = 'IRI']/text()[matches(., '^http')]" mode="infuse-gep-template">
        <a href="{.}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
    
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$diagnostics-on">
                <!-- diagnostics -->
                <diagnostics>
                    <!--<self-resolved><xsl:copy-of select="$self-resolved"/></self-resolved>-->
                    <self-expanded><xsl:copy-of select="$self-expanded"/></self-expanded>
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
