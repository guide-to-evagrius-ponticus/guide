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
    
    <xsl:param name="diagnostics-on" select="false()" static="yes"/>
    
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
    <xsl:param name="sort-and-group-by-what-alias" as="xs:string*" select="('Greek', 'Syriac', 'Latin', 'English')"/>
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
    
    <!-- preliminary changes -->
    <xsl:template match="processing-instruction()" mode="first-stamp-shallow-copy"/>
    
    <!-- ad hoc changes for the Scholia -->
    <xsl:template match="tan:body/tan:div[lower-case(@n) = 'prov']" mode="first-stamp-shallow-copy">
        <!-- We need to adjust the scholia and avoid situations where the Bible verses get merged together -->
        <xsl:variable name="first-div-with-multiple-children"
            select="descendant-or-self::tan:div[count(tan:div) gt 1]"/>
        <xsl:variable name="new-n-first-part" select="@n || '_' || tan:div[1]/@n || '_' || tan:div[1]/tan:div[1]/@n"/>
        <xsl:variable name="new-n-second-part"
            select="
                string-join((for $i in $first-div-with-multiple-children//tan:div[not(@n = 'pt')][last()]
                return
                    $i/@n), '_')"
        />
        <!-- Note: in the following @select that's not a hyphen, it's an en dash, –, to avoid messing up the reset of the hierarchy -->
        <xsl:variable name="new-n"
            select="string-join(($new-n-first-part, $new-n-second-part[string-length(.) gt 0]), '–')"
        />
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="q" select="generate-id(.)"/>
            <xsl:attribute name="type" select="'bible-ref'"/>
            <!-- Just in case, we replace hyphens with en dashes again -->
            <xsl:attribute name="n" select="replace($new-n, '-', '–')"/>
            <!--<xsl:apply-templates select="tan:div/tan:div" mode="scholia-special"/>-->
            <xsl:value-of select="tan:text-join(.)"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tan:div" mode="scholia-special">
        <!-- this is at the verse level of a Biblical verse cited, where we choose to ignore the subverse numbers -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="q" select="generate-id(.)"/>
            <xsl:value-of select="tan:text-join(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Input pass 1 -->
    <!-- We turn on TEI formatting, and suppress the plain-text surrogate -->
    <xsl:param name="tei-should-be-plain-text" select="false()"/>
    
    <xsl:template
        match="tan:name[@norm] | tan:vocabulary-key | tan:vocabulary | tan:tan-vocabulary 
        | tan:annotation | tan:to-do | tan:expanded | tan:resolved | tan:stamped"
        mode="input-pass-1"/>
    
    
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
                <div class="label info">Sources</div>
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
                    <!--<test><xsl:copy-of select="tan:int-to-aaa(999999)"/></test>-->
                    <!--<in2><xsl:copy-of select="$input-pass-2"/></in2>-->
                    <!--<in2-comparison><xsl:copy-of select="tan:merge-expanded-docs-old($input-pass-1b)"/></in2-comparison>-->
                    <!--<in3><xsl:copy-of select="$input-pass-3"/></in3>-->
                    <!--<source-bib><xsl:copy-of select="$source-bibliography"/></source-bib>-->
                    <in4><xsl:copy-of select="$input-pass-4"/></in4>
                    <!--<template-url><xsl:copy-of select="$template-url-resolved"/></template-url>-->
                    <!--<template><xsl:copy-of select="$template-doc"/></template>-->
                    <!--<template-infused><xsl:copy-of select="$template-infused-with-revised-input"/></template-infused>-->
                    <!--<output-url><xsl:copy-of select="$output-url-resolved"/></output-url>-->
                    <infusion-revised><xsl:copy-of select="$infused-template-revised"/></infusion-revised>
                </diagnostics>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$infused-template-revised"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
