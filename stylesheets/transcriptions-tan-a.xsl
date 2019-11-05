<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
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
    <!-- For the time being, we turn off TEI formatting -->
    <xsl:template match="tan:div[tei:*]/text()" mode="input-pass-1"/>
    
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
    
    
    
    <!--<!-\- STEP 1: MERGE SOURCES -\->
    <xsl:variable name="sources-merged" select="tan:merge-expanded-docs($self-expanded[tan:TAN-T])"/>
    

    <!-\- STEP 2: ADJUST INPUT (SELF EXPANDED) -\->
    <xsl:variable name="input-adjusted-for-gep" as="document-node()?">
        <xsl:apply-templates select="$sources-merged" mode="adjust-tan-t-for-gep"/>
    </xsl:variable>
    <!-\- elements to suppress -\->
    <xsl:template
        match="tan:name[@norm] | tan:vocabulary-key | tan:vocabulary | tan:tan-vocabulary 
        | tan:annotation | tan:to-do | tan:expanded | tan:resolved | tan:stamped"
        mode="adjust-tan-t-for-gep"/>
    
    
    <!-\- STEP 3: CONVERT INPUT TO HTML -\->
    <xsl:variable name="tan-file-as-html" select="tan:tan-to-html($input-adjusted-for-gep)"/>
    <xsl:param name="children-element-values-to-add-to-class-attribute" as="xs:string*"
        select="()"/>
    <!-\- skip tei elements, errors, warnings -\->
    <xsl:template match="tei:teiHeader | tan:div[tei:*]/text() | tan:error | tan:warning | tan:help" mode="tan-to-html-pass-2"/>
    
    
    <!-\- STEP 4: GET TEMPLATE AND INFUSE IT WITH INPUT CONTENT -\->
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
        <!-\- Insert an info icon label for anything that's a vocab item not preceded by a sibling label -\->
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
    <!-\- text changes -\->
    <xsl:template match="html:div[@class = ('n', 'ref')]/text()" mode="infuse-gep-template">
        <xsl:value-of select="replace(., '_', ' ')"/>
    </xsl:template>
    <xsl:template match="html:div[@class = 'IRI']/text()[matches(., '^http')]" mode="infuse-gep-template">
        <a href="{.}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
    
    
    
    <!-\- I LEFT OFF HERE -\->-->
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
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$diagnostics-on">
                <!-- diagnostics -->
                <diagnostics>
                    <!--<self-resolved><xsl:copy-of select="$self-resolved"/></self-resolved>-->
                    <self-expanded><xsl:copy-of select="$self-expanded"/></self-expanded>
                    <!--<in1><xsl:copy-of select="$input-pass-1"/></in1>-->
                    <!--<in1b><xsl:copy-of select="$input-pass-1b"/></in1b>-->
                    <!--<in2><xsl:copy-of select="$input-pass-2"/></in2>-->
                    <!--<in3><xsl:copy-of select="$input-pass-3"/></in3>-->
                    <!--<source-bib><xsl:copy-of select="$source-bibliography"/></source-bib>-->
                    <!--<in4><xsl:copy-of select="$input-pass-4"/></in4>-->
                    <template-url><xsl:copy-of select="$template-url-resolved"/></template-url>
                    <template><xsl:copy-of select="$template-doc"/></template>
                    <template-infused><xsl:copy-of select="$template-infused-with-revised-input"/></template-infused>
                    <output-url><xsl:copy-of select="$output-url-resolved"/></output-url>
                    <infusion-revised><xsl:copy-of select="$infused-template-revised"/></infusion-revised>
                    <!--<sources-merged><xsl:copy-of select="$sources-merged"/></sources-merged>
                    <input-adjusted><xsl:copy-of select="$input-adjusted-for-gep"/></input-adjusted>
                    <tan-as-html><xsl:copy-of select="$tan-file-as-html"/></tan-as-html>
                    <gep-template><xsl:copy-of select="$gep-template"/></gep-template>
                    <output-1><xsl:copy-of select="$output-pass-1"/></output-1>-->
                </diagnostics>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$infused-template-revised"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
