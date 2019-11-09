<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">
    <!--<xsl:import href="transcriptions-core.xsl"/>-->
    <xsl:import href="../../TAN/TAN-2020/applications/display/display%20merged%20sources%20as%20HTML.xsl"/>
    <!--<xsl:import href="../../TAN/TAN-2020/functions/TAN-T-functions.xsl"/>-->
    <!--<xsl:import href="../../TAN/TAN-2020/functions/TAN-extra-functions.xsl"/>-->
    <!--<xsl:import href="../../TAN/TAN-2020/applications/get%20inclusions/convert-TAN-to-HTML.xsl"/>-->
    
    <xsl:param name="diagnostics-on" select="true()" static="yes"/>
    
    <!-- Input: A TAN-A file from the sibling directory tan -->
    <!-- Output: the html page for the TAN file -->
    
    <xsl:output indent="yes" use-when="$diagnostics-on"/>
    
    <xsl:param name="validation-phase" select="'terse'"/>
    <xsl:param name="distribute-vocabulary" select="true()"/>
    <xsl:param name="add-bibliography" select="false()"/>
    <xsl:param name="tables-via-css" select="true()"/>
    <xsl:param name="table-layout-fixed" select="false()"/>
    <xsl:param name="td-widths-proportionate-to-string-length" select="true()"/>
    <xsl:param name="fill-defective-merges" select="false()"/>
    <xsl:param name="sort-and-group-by-what-alias" as="xs:string*" select="('Greek', 'Syriac', 'English')"/>
    <xsl:param name="attributes-to-convert-to-elements" as="xs:string*"
        select="('href', 'accessed-when', 'when', 'resp', 'wit')"/>
    <xsl:param name="add-controller-label" as="xs:boolean" select="false()"/>
    <xsl:param name="add-controller-options" as="xs:boolean" select="false()"/>
    <xsl:param name="calculate-width-at-td-or-leaf-div-level" select="true()"/>
    <xsl:variable name="rgb-color-1" as="xs:integer+" select="(228, 209, 209)"/>
    <xsl:variable name="rgb-color-2" as="xs:integer+" select="(185, 176, 176)"/>
    <xsl:variable name="rgb-color-3" as="xs:integer+" select="(217, 236, 208)"/>
    <xsl:variable name="rgb-color-4" as="xs:integer+" select="(119, 168, 168)"/>
    <xsl:variable name="rgb-color-5" as="xs:integer+" select="(126, 74, 53)"/>
    <xsl:variable name="rgb-color-6" as="xs:integer+" select="(202, 181, 119)"/>
    <xsl:variable name="rgb-color-7" as="xs:integer+" select="(219, 206, 176)"/>
    <xsl:variable name="rgb-color-8" as="xs:integer+" select="(131, 128, 96)"/>
    <xsl:param name="primary-color-array" as="array(xs:integer+)"
        select="[$rgb-color-1, $rgb-color-2, $rgb-color-3, $rgb-color-4, $rgb-color-5, $rgb-color-6, $rgb-color-7, $rgb-color-8]"/>
    
    <xsl:param name="output-directory-relative-to-catalyzing-input" select="'../..'"/>
    <xsl:param name="template-url-resolved"
        select="resolve-uri('../template.html', static-base-uri())"/>
    
    <xsl:variable name="this-cpg" as="xs:string">
        <xsl:analyze-string select="tan:cfn(/)" regex="(no)?cpg\d+(a|\.\d)?">
            <xsl:matching-substring>
                <xsl:value-of select="."/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    <xsl:param name="output-url-relative-to-template" as="xs:string?"
        select="'../' || $this-cpg || '.html'"/>
    
    <!-- Input pass 1 -->
    <!-- We turn on TEI formatting, and suppress the plain-text surrogate -->
    <xsl:param name="tei-should-be-plain-text" select="false()"/>
    
    <xsl:template
        match="tan:name[@norm] | tan:vocabulary-key | tan:vocabulary | tan:tan-vocabulary 
        | tan:annotation | tan:to-do | tan:expanded | tan:resolved | tan:stamped"
        mode="input-pass-1"/>
    <!--<xsl:template match="*[@when]" mode="input-pass-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <when xmlns="">
                <xsl:choose>
                    <xsl:when test="@when castable as xs:dateTime">
                        <xsl:value-of select="format-dateTime(@when, '[FNn], [MNn] [D], [Y], [H01]:[m01]:[s01] [z,6-6]', 'en', (), ())"/>
                    </xsl:when>
                    <xsl:when test="@when castable as xs:date">
                        <xsl:value-of select="format-date(@when, '[FNn], [MNn] [D], [Y]', 'en', (), ())"/>
                    </xsl:when>
                </xsl:choose>
            </when>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>-->
    
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
    <!--<xsl:template match="html:head" mode="revise-infused-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <!-\-<link rel="stylesheet" type="text/css" href="css/tan2018.css" />-\->
            <link rel="stylesheet" type="text/css" href="css/tan2019.css" />
        </xsl:copy>
    </xsl:template>-->
    <xsl:template match="html:body" mode="revise-infused-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <!--<script type="text/javascript" src="scripts/tan2018.js"/>-->
            <script type="text/javascript" src="scripts/tan2019.js"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="html:head/html:script[last()]" mode="revise-infused-template">
        <xsl:copy-of select="."/>
        <script type="application/javascript" src="scripts/jquery-ui-1.12.1/jquery-ui.js"/>
    </xsl:template>
    <xsl:template match="html:div[tokenize(@class, ' ') = 'TAN-T-merge']/html:h1"
        mode="revise-infused-template">
        <h2>
            <xsl:value-of select="."/>
        </h2>
    </xsl:template>
    <xsl:template match="html:div[@class = 'control-wrapper']" mode="revise-infused-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <div class="control-instructions">
                <div class="label info">⍰</div>
                <div>Drag any panel below to reorder the sources; click the checkbox to turn texts
                    on and off; click a label to learn more about the source.</div>
            </div>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="html:div[html:div[@class = 'IRI']][not(preceding-sibling::html:div[@class = 'label'])]"
        mode="revise-infused-template">
        <!-- Insert an info icon label for anything that's a vocab item not preceded by a sibling label -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <div class="label info">🛈</div>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
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
    
    <xsl:variable name="items-to-collate" as="element()">
        <sort-key-prep>
            <a src="S1-Guill">
                <ref>1</ref>
                <ref>2</ref>
                <ref>3</ref>
                <ref>4</ref>
                <ref>5</ref>
                <ref>6</ref>
                <ref>ep1</ref>
                <ref>ep2</ref>
            </a>
            <a src="S1-Dy">
                <ref>1</ref>
                <ref>2</ref>
                <ref>3</ref>
                <ref>4</ref>
                <ref>5</ref>
                <ref>6</ref>
            </a>
            <a src="S1-Fr">
                <ref>1</ref>
                <ref>2</ref>
                <ref>3</ref>
                <ref>4</ref>
                <ref>5</ref>
                <ref>6</ref>
                <ref>ep1</ref>
            </a>
            <a src="S2-Guill">
                <ref>1</ref>
                <ref>2</ref>
                <ref>3</ref>
                <ref>4</ref>
                <ref>5</ref>
                <ref>6</ref>
                <ref>ep1</ref>
                <ref>ep2</ref>
            </a>
            <a src="S2-Dy">
                <ref>1</ref>
                <ref>2</ref>
                <ref>3</ref>
                <ref>4</ref>
                <ref>5</ref>
                <ref>6</ref>
                <ref>ep1</ref>
                <ref>ep2</ref>
            </a>
            <a src="grc-PG4">
                <ref>2</ref>
                <ref>5</ref>
            </a>
            <a src="grc-PG12">
                <ref>3</ref>
                <ref>1</ref>
                <ref>6</ref>
                <ref>4</ref>
                <ref>5</ref>
            </a>
            <a src="grc-PG86a">
                <ref>4</ref>
            </a>
            <a src="grc-PG39">
                <ref>4</ref>
            </a>
            <a src="grc-Bars">
                <ref>2</ref>
            </a>
            <a src="grc-Dor">
                <ref>4</ref>
            </a>
            <a src="grc-Oct">
                <ref>6</ref>
            </a>
            <a src="grc-DP">
                <ref>4</ref>
                <ref>6</ref>
            </a>
            <a src="grc-EpF">
                <ref>4</ref>
            </a>
            <a src="grc-Géh1987">
                <ref>5</ref>
                <ref>1</ref>
            </a>
            <a src="grc-Géh1996">
                <ref>4</ref>
                <ref>5</ref>
                <ref>6</ref>
            </a>
            <a src="grc-Géh1998">
                <ref>3</ref>
                <ref>1</ref>
                <ref>4</ref>
            </a>
            <a src="grc-Hau">
                <ref>1</ref>
                <ref>2</ref>
                <ref>3</ref>
                <ref>4</ref>
                <ref>5</ref>
                <ref>6</ref>
            </a>
            <a src="grc-Mu1931">
                <ref>1</ref>
                <ref>2</ref>
                <ref>3</ref>
                <ref>4</ref>
            </a>
            <a src="grc-Mu1932">
                <ref>1</ref>
                <ref>3</ref>
            </a>
            <a src="grc-Pitra">
                <ref>4</ref>
                <ref>5</ref>
                <ref>1</ref>
                <ref>6</ref>
            </a>
            <a src="grc-Wolf">
                <ref>4</ref>
            </a>
        </sort-key-prep>
        
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:choose>
            <!--<xsl:when test="true()">
                <xsl:variable name="color-tan" as="xs:double+" select="(210, 180, 140)"/>
                <xsl:variable name="color-lightblue" as="xs:double+" select="(173, 216, 230)"/>
                <xsl:variable name="blend-1" as="xs:double+" select="tan:blend-colors($color-tan, $color-lightblue, .5)"/>
                <xsl:variable name="blend-2" select="tan:blend-colors($rgb-red, $rgb-green, 0.2)"/>
                <xsl:variable name="blend-3" select="tan:blend-colors(array:get($color-array, 1), array:get($color-array, 2), 0.5)"/>
                <html>
                    <head/>
                    <body>
                        <div
                            style="background-color: rgba({string-join((for $i in $blend-1 return string($i)), ', ')})"
                            >blend 1: <xsl:value-of select="$blend-1"/></div>
                        <div
                            style="background-color: rgba({string-join((for $i in $blend-2 return string($i)), ', ')})"
                            >blend 2: <xsl:value-of select="$blend-2"/></div>
                        <div
                            style="background-color: rgba({string-join((for $i in $blend-3 return string($i)), ', ')})"
                            >blend 3: <xsl:value-of select="$blend-3"/></div>
                        <div>Color array size: <xsl:value-of select="array:size($color-array)"/></div>
                    </body>
                </html>
            </xsl:when>-->
            <xsl:when test="$diagnostics-on">
                <!-- diagnostics -->
                <diagnostics>
                    <!--<sequence-to-collate><xsl:copy-of select="$items-to-collate"/></sequence-to-collate>-->
                    <!--<collation><xsl:copy-of select="tan:collate-sequences($items-to-collate/*)"/></collation>-->
                    <!--<alias-based-group-and-sort-pattern><xsl:copy-of select="$alias-based-group-and-sort-pattern"/></alias-based-group-and-sort-pattern>-->
                    <!--<source-group-and-sort-pattern><xsl:copy-of select="$source-group-and-sort-pattern"/></source-group-and-sort-pattern>-->
                    <!--<sources-expanded><xsl:copy-of select="$self-expanded[position() gt 1]"/></sources-expanded>-->
                    <!--<self-resolved><xsl:copy-of select="$self-resolved"/></self-resolved>-->
                    <!--<self-expanded><xsl:copy-of select="$self-expanded"/></self-expanded>-->
                    <!--<in1><xsl:copy-of select="$input-pass-1"/></in1>-->
                    <!--<in1b><xsl:copy-of select="$input-pass-1b"/></in1b>-->
                    <in2-new><xsl:copy-of select="$input-pass-2"/></in2-new>
                    <in2-comparison><xsl:copy-of select="tan:merge-expanded-docs-old($input-pass-1b)"/></in2-comparison>
                    <!--<in3><xsl:copy-of select="$input-pass-3"/></in3>-->
                    <!--<source-bib><xsl:copy-of select="$source-bibliography"/></source-bib>-->
                    <!--<in4><xsl:copy-of select="$input-pass-4"/></in4>-->
                    <!--<template-url><xsl:copy-of select="$template-url-resolved"/></template-url>-->
                    <!--<template><xsl:copy-of select="$template-doc"/></template>-->
                    <!--<template-infused><xsl:copy-of select="$template-infused-with-revised-input"/></template-infused>-->
                    <!--<output-url><xsl:copy-of select="$output-url-resolved"/></output-url>-->
                    <!--<infusion-revised><xsl:copy-of select="$infused-template-revised"/></infusion-revised>-->
                </diagnostics>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$infused-template-revised"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
