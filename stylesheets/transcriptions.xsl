<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="schemas/transcriptions.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">
    
    <!-- Catalyzing (main) input: a class-1 file -->
    <!-- Secondary input: none -->
    <!-- Primary output: the html page for the TAN file -->
    <!-- Secondary output: none -->
    <!-- Relative URLs are resolved under the presumtion that output will be put into a child folder of the root. -->
    
    <!-- Items below point to development version of TAN -->
    <!--<xsl:import href="../../TAN/TAN-2022/functions/TAN-T-functions.xsl"/>
    <xsl:import href="../../TAN/TAN-2022/functions/TAN-extra-functions.xsl"/>
    <xsl:import href="../../TAN/TAN-2022/applications/get%20inclusions/convert-TAN-to-HTML.xsl"/>-->
    <xsl:include href="../../TAN/TAN-2021/functions/TAN-function-library.xsl"/>
    <xsl:include href="incl/transcriptions-core.xsl"/>
    
    <xsl:param name="output-diagnostics-on" select="false()" static="yes"/>
    <!--<xsl:param name="tan:html-out.remove-what-attributes-regex" as="xs:string" select="'TAN-version'"/>
    <xsl:param name="tan:html-out.remove-what-elements-regex" as="xs:string" select="'teiHeader'"/>-->
    
    
    <xsl:output indent="yes" use-when="$output-diagnostics-on"/>
    <xsl:output indent="no" method="html" use-when="not($output-diagnostics-on)"/>
    
    <xsl:param name="tan:default-validation-phase" select="'terse'"/>
    <xsl:param name="tan:distribute-vocabulary" select="true()"/>
    

    <!-- STEP 1: ADJUST INPUT (SELF EXPANDED) -->
    <xsl:variable name="input-adjusted-for-gep" as="document-node()?">
        <xsl:apply-templates select="$tan:self-expanded" mode="adjust-tan-t-for-gep"/>
    </xsl:variable>
    
    <xsl:mode name="adjust-tan-t-for-gep" on-no-match="shallow-copy"/>
    <!-- nodes to suppress -->
    <xsl:template
        match="tan:name[@norm] | tan:vocabulary-key | tan:vocabulary | tan:tan-vocabulary 
        | tan:annotation | tan:expanded | tan:resolved | tan:stamped | tan:item/tan:id
        | tan:div[@type = 'title']/tan:ref | tan:div[@type = 'title']/tan:title 
        | tan:div[@type = 'title']/tan:n | tan:affects-element | tan:affects-attribute
        | tan:affects-element | tan:affects-attribute | *:teiHeader | tan:ref/tan:n
        | tan:body/*[1]/self::tei:* | tan:div[not(tan:div)][tei:*]/text() | tan:div/tan:n
        | tan:div[@type = 'verse'][tan:div]/tan:ref | tan:div/tan:type | tan:body/tan:div[1]/tan:div[1]/tei:pb[@n = '230']
        | @q | @attr | @resp | @TAN-version | @roles | @who | @which | @licensor | @include | @xml:base
        | @ref-alias | @alias-copy | *[@rend]/@* | @defective | @instant | @status | @break | @anchored | @precision
        | tei:cit/@type | tei:alt | tei:w/@xml:id | tei:milestone[@rend]/@unit
        | tei:certainty/@target | tei:certainty/@locus" 
        mode="adjust-tan-t-for-gep"/>
    <xsl:template match="@rend" priority="1" mode="adjust-tan-t-for-gep">
        <xsl:copy-of select="."/>
    </xsl:template>
    <!-- For human readers, names are more significant than IRIs -->
    <xsl:template match="*[tan:IRI][tan:name]" priority="-1" mode="adjust-tan-t-for-gep">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="tan:name" mode="#current"/>
            <xsl:apply-templates select="tan:IRI" mode="#current"/>
            <xsl:apply-templates select="node() except (tan:name | tan:IRI)" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:pb" mode="adjust-tan-t-for-gep">
        <xsl:element name="milestone" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="unit" select="'page'"/>
            <xsl:apply-templates select="@*" mode="#current"/>
        </xsl:element>
    </xsl:template>
    <!-- elements to expand -->
    <!--<xsl:template match="tei:ref" mode="adjust-tan-t-for-gep">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:if test="not(@rend)">
                <xsl:apply-templates select="@cRef" mode="attr-to-element"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>-->
    <!-- text to wrap -->
    <xsl:template match="tan:comment/text() | tan:change/text()" mode="adjust-tan-t-for-gep">
        <div class="text">
            <xsl:value-of select="."/>
        </div>
    </xsl:template>
    <xsl:template match="*[@href][not(*)]" mode="adjust-tan-t-for-gep">
        <xsl:copy>
            <xsl:apply-templates select="@* except @href" mode="#current"/>
            <a>
                <xsl:copy-of select="@href"/>
                <xsl:value-of select="name(.)"/>
            </a>
        </xsl:copy>
    </xsl:template>
    
    <!-- Insert a dropcap class marker -->
    <xsl:template match="tan:body/tan:div[1][not(tan:div)][not(tei:*)]/@n | tan:body/tan:div[1]/tan:div[1][not(tan:div)][not(tei:*)]/@n 
        | tan:body/tan:div[1]/tan:div[1]/tan:div[1][not(tan:div)][not(tei:*)]/@n" mode="adjust-tan-t-for-gep">
        <xsl:copy/>
        <xsl:attribute name="class" select="'dcap'"/>
    </xsl:template>
    <!-- For TEI dropcaps, hit the first inner leaf element that has a node, to avoid anchors, and push any nested
        anchors out of the dropcap zone. -->
    <xsl:template match="tan:body/tan:div[1]/tei:*[node()][1] | tan:body/tan:div[1]/tan:div[1]/tei:*[node()][1]
        | tan:body/tan:div[1]/tan:div[1]/tan:div[1]/tei:*[node()][1]" mode="adjust-tan-t-for-gep">
        <xsl:variable name="anchors" as="element()*" select="node()[matches(., '\S')][1]/preceding-sibling::tei:*[not(node())]"/>
        <xsl:apply-templates select="$anchors" mode="#current"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="class" select="'dcap'"/>
            <xsl:apply-templates select="node() except $anchors" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tan:div[@type = 'scholion']/tan:ref/text()" mode="adjust-tan-t-for-gep">
        <xsl:value-of select="replace(., '.+sch', 'Sch. ')"/>
    </xsl:template>
    <xsl:template match="tan:div[@type = ('psalm')]/tan:ref/text()" mode="adjust-tan-t-for-gep">
        <xsl:value-of select="'Psalm ' || ."/>
    </xsl:template>
    <xsl:template priority="2" match="tan:div[@n = 'prov']/tan:ref | tan:div[@n = 'prov']/tan:div[tan:div]/tan:ref 
        | tan:div[@n = 'prov']/tan:div/tan:div[tan:div]/tan:ref" mode="adjust-tan-t-for-gep"/>
    
    
    <!-- These are bugs in the TAN application. Need to be fixed. -->
    <xsl:template match="html:a" priority="2" mode="tan:prepare-to-convert-to-html-pass-1">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="@xml:*" mode="tan:prepare-to-convert-to-html-pass-3">
        <xsl:attribute name="{name(.)}" select="." namespace=""/>
    </xsl:template>
    
    
    <!-- STEP 2: CONVERT INPUT TO HTML -->
    <xsl:variable name="tan-file-as-html"
        select="tan:prepare-to-convert-to-html($input-adjusted-for-gep) => tan:convert-to-html(true())"/>
    <!--<xsl:param name="children-element-values-to-add-to-class-attribute" as="xs:string*"
        select="()"/>-->
    <!-- skip tei header, errors, warnings; prefer TEI over plain text -->
    <xsl:template match="tei:teiHeader | tan:div[tei:*]/text() | tan:error | tan:warning | tan:help" mode="tan-to-html-pass-2"/>
    
    
    <!-- STEP 3: GET TEMPLATE AND INFUSE IT WITH INPUT CONTENT -->
    <!--<xsl:param name="elements-to-be-labeled" as="xs:string*" select="()"/>-->
    <xsl:variable name="output-pass-1" as="document-node()?">
        <xsl:apply-templates select="$gep-template" mode="infuse-gep-template"/>
    </xsl:variable>
    
    <xsl:mode name="infuse-gep-template" on-no-match="shallow-copy"/>
    <!--<xsl:template match="html:head" mode="infuse-gep-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <link rel="stylesheet" type="text/css" href="css/tan2018.css" />
        </xsl:copy>
    </xsl:template>-->
    <!--<xsl:template match="html:body" mode="infuse-gep-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <script type="text/javascript" src="scripts/tan2018.js"/>
        </xsl:copy>
    </xsl:template>-->
    <!-- html:div[@id = 'content'] -->
    <xsl:template match="html:div[contains-token(@id, 'content')]" mode="infuse-gep-template">
        <xsl:apply-templates select="$tan-file-as-html/*" mode="#current"/>
    </xsl:template>
    <!-- html:div[@class = 'head'] -->
    <xsl:template match="html:div[contains-token(@class, 'e-head')]" mode="infuse-gep-template">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <div class="label">about this transcription</div>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <!-- html:div[html:div[@class = 'IRI']][not(preceding-sibling::html:div[@class = 'label'])] -->
    <xsl:template
        match="html:div[html:div[contains-token(@class, 'e-IRI')]][not(preceding-sibling::html:div[contains-token(@class, 'label')])]"
        mode="infuse-gep-template">
        <!-- Insert an info icon label for anything that's a vocab item not preceded by a sibling label -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <div class="label info">🛈</div>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <!-- html:div[tokenize(@class, ' ') = 'TAN-T']/html:div[tokenize(@class, ' ') = 'body'] -->
    <xsl:template
        match="html:div[tokenize(@class, ' ') = ('e-TAN-T', 'e-TEI')]/html:div[contains-token(@class, 'e-body')]"
        mode="infuse-gep-template">
        <h2>
            <xsl:value-of select="$input-adjusted-for-gep/*/tan:head/tan:name[1]"/>
        </h2>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <!-- text changes -->
    <!-- html:div[@class = ('n', 'ref')]/text() -->
    <xsl:template match="html:div[tokenize(@class, ' ') = ('a-n', 'a-ref')]/text()" mode="infuse-gep-template">
        <xsl:value-of select="replace(., '_', ' ')"/>
    </xsl:template>
    <!-- html:div[@class = 'IRI']/text()[matches(., '^http')] -->
    <xsl:template match="html:div[contains-token(@class, 'e-IRI')]/text()[matches(., '^http')]" mode="infuse-gep-template">
        <a href="{.}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
    
    <xsl:template match="/" priority="1" use-when="$output-diagnostics-on">
        <xsl:message select="'Diagnostics on for application ' || static-base-uri()"/>
        <diagnostics>
            <self-expanded><xsl:copy-of select="$tan:self-expanded"/></self-expanded>
            <input-adjusted><xsl:copy-of select="$input-adjusted-for-gep"/></input-adjusted>
            <tan-as-html><xsl:copy-of select="$tan-file-as-html"/></tan-as-html>
            <gep-template><xsl:copy-of select="$gep-template"/></gep-template>
            <output-1><xsl:copy-of select="$output-pass-1"/></output-1>
        </diagnostics>
    </xsl:template>
    <xsl:template match="/">
        <xsl:copy-of select="$output-pass-1"/>
    </xsl:template>
    
</xsl:stylesheet>
