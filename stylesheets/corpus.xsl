<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:param name="distribute-vocabulary" select="true()"/>
    
    <xsl:template match="tan:item/tan:desc" mode="reduce-tan-voc-files">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:variable name="corpus-collection-adjusted" as="document-node()*">
        <xsl:apply-templates select="$corpus-collection-resolved" mode="expand-work-element"/>
    </xsl:variable>
    <xsl:template match="tan:work" mode="expand-work-element">
        <xsl:variable name="this-vocabulary" select="tan:element-vocabulary(.)" as="element()*"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <xsl:copy-of select="$this-vocabulary/tan:item/*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:param name="works-to-exclude-regex-on-IRI">fra-Guillaumont</xsl:param>
    <xsl:variable name="language-priority-list" as="xs:string+" select="('grc', 'lat', 'eng')"/>
    <xsl:template match="table[@id = 'corpus-table']" mode="template-to-corpus">
        <xsl:variable name="work-vocab-items" select="tan:vocabulary('work', (), $corpus-claims-expanded/tan:TAN-A/tan:head)"/>
        <div class="links-to-other-formats">Other formats: <a
            href="{($corpus-claims-expanded/tan:TAN-A/tan:head/tan:master-location/@href)[1]}">TAN-A</a>
            (master)</div>
        <input class="search" type="search" data-column="all"/>
        <table class="tablesorter show-last-col-only" id="corpus-table">
            <thead>
                <tr>
                    <td rowspan="2">Title and description</td>
                    <td rowspan="2">Author</td>
                    <td colspan="2">Original</td>
                    <td rowspan="2">CPG</td>
                    <!-- we add a filler because in our css, we are going to hide the first four columns in the tbody, and we need to balance them with an equal number of columns in the thead -->
                    <td colspan="4" rowspan="2" class="filler"/>
                </tr>
                <tr>
                    <td>lang</td>
                    <td>extant (%)</td>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each
                    select="$work-vocab-items/(tan:item[tan:affects-element = 'work'], tan:work)[tan:IRI[not(matches(., $works-to-exclude-regex-on-IRI))]]">
                    <!-- Sort the table rows by CPG number, putting the 'nocpg' numbers at the end -->
                    <xsl:sort select="(tan:IRI[matches(., 'cpg')])[1]"/>
                    <xsl:apply-templates select="." mode="#current"/>
                </xsl:for-each>
                
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="tan:*" mode="template-to-corpus">
        <!-- This template shallow skips tan elements, but shallow copies html elements -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="tan:item | tan:work | tan:version" mode="template-to-corpus">
        <xsl:variable name="this-work-item" select="."/>
        <!--<xsl:variable name="this-work-id" select="(tan:id, @xml:id)[1]"/>-->
        <xsl:variable name="this-work-id" select="(tan:name[matches(., 'cpg')])[1]"/>
        <xsl:variable name="this-is-a-version" select="(name(.) = 'version') or (tan:affects-element = 'version')"/>
        <xsl:variable name="these-work-names-sorted" as="element()*">
            <xsl:for-each select="$this-work-item/tan:name[not(@norm)]">
                <xsl:sort
                    select="
                        if (exists(@xml:lang)) then
                            index-of($language-priority-list, @xml:lang)
                        else
                            999"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="these-work-iris" select="tan:IRI"/>
        <xsl:variable name="corresponding-transcription-vocabulary-item"
            select="$corpus-collection-resolved/*/tan:head//(tan:work, tan:version, tan:item[tan:affects-element = ('work', 'version')])[tan:IRI = $these-work-iris]"
        />
        <xsl:variable name="this-work-tan-transcriptions"
            select="$corresponding-transcription-vocabulary-item/root()"/>
        <!--<xsl:variable name="this-work-tan-transcriptions-without-bibliography" select="$corresponding-transcription-vocabulary-item[not(tan:IRI = $bibliography-prepped/*/*/dc:description)]"/>-->
        
        <xsl:variable name="claims-about-this-work"
            select="
                $corpus-claims-expanded/tan:TAN-A/tan:body/tan:claim[*[*/tan:IRI = $these-work-iris]]"/>
        <xsl:variable name="work-claims-re-incipit"
            select="$claims-about-this-work[tan:verb[*/tan:name = 'has incipit']]"/>
        <xsl:variable name="work-claims-re-original-language"
            select="$claims-about-this-work[tan:verb[*/tan:name = 'originally written']]"/>
        <xsl:variable name="this-orig-lang-code"
            select="$work-claims-re-original-language/tan:in-lang"/>
        <xsl:variable name="this-orig-lang"
            select="
                for $i in $work-claims-re-original-language
                return
                    concat(tan:lang-name($i/tan:in-lang)[1], if (exists($i/tan:adverb)) then
                        concat(' (', $i/tan:adverb/text(), ')')
                    else
                        ())"/>
        <xsl:variable name="work-claims-re-ancient-translations"
            select="$claims-about-this-work[tan:verb[*/tan:name = 'translates']]"/>
        <!--<xsl:variable name="ancient-translation-idrefs"
            select="$work-claims-re-ancient-translations/tan:subject"/>-->
        <!--<xsl:variable name="ancient-translation-vocabulary-items" select="tan:vocabulary('version', false(), $ancient-translation-idrefs, $corpus-claims-expanded/tan:TAN-A/tan:head)"/>-->
        <xsl:variable name="ancient-translation-vocabulary-items" select="$work-claims-re-ancient-translations/tan:subject//*[tan:IRI]"/>
        <xsl:variable name="work-claims-re-authorship"
            select="$claims-about-this-work[tan:verb[*/tan:name = 'is author of']]"/>
        <xsl:variable name="work-claims-re-portion-extant"
            select="$claims-about-this-work[tan:verb[*/tan:IRI = 'tag:kalvesmaki.com,2014:verb:work-survives-in-original-language']]"/>
        <xsl:variable name="work-claims-re-modern-editions" select="$claims-about-this-work[tan:subject[.//tan:affects-element = 'scriptum']]"/>
        <xsl:variable name="modern-edition-iris" select="$work-claims-re-modern-editions/tan:subject//tan:IRI"/>
        <!--<xsl:variable name="this-id-to-be-searched-in-bibliography"
            select="concat(replace($this-work-id, '^cpg', ''), ' (translation|edition)')"/>-->
        <!--<xsl:variable name="this-id-regex-for-bibliography">
            <xsl:choose>
                <xsl:when test="$this-is-a-version">
                    <!-\- Version ids have the form (no)?cpg0000a?-LNG -\->
                    <xsl:variable name="id-parts" select="tokenize($this-work-id, '-')"/>
                    <xsl:value-of select="concat(replace($id-parts[1], '^(no)?cpg', ''), ' edition ', tan:lang-name($id-parts[2]))"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-\- Work ids have the form (no)?cpg0000a? -\->
                    <xsl:value-of select="concat(replace($this-work-id, '^(no)?cpg', ''), ' (translation|edition)')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>-->
        <!--<xsl:variable name="bibliography-refs-to-this-work" as="element()*"
            select="$bibliography-prepped/*/*[*:subject[matches(., $this-id-regex-for-bibliography)]]"/>-->
        <xsl:variable name="bibliography-refs-to-this-work" as="element()*"
            select="$bibliography-prepped/*/*[dc:description = $modern-edition-iris]"/>
        <xsl:variable name="this-collated-edition-url" select="concat($this-work-id, '.html')"/>
        <xsl:variable name="collated-edition-available"
            select="doc-available(concat('../', $this-collated-edition-url))"/>
        <xsl:variable name="this-cpg-norm"
            select="normalize-space(replace($this-work-id, 'cpg', ' CPG '))"/>
        
        <xsl:variable name="diagnostics-on" select="true()"/>
        <xsl:if test="$diagnostics-on">
            <xsl:message select="'Diagnostics on, template mode template-to-corpus'"/>
            <xsl:message select="'This work item: ', $this-work-item"/>
            <xsl:message select="'CPG norm: ', $this-cpg-norm"/>
            <!--<xsl:message select="'This work id:', $this-work-id"/>-->
            <xsl:message select="'This is a version: ', $this-is-a-version"/>
            <xsl:message select="'Work TAN transcriptions: ', count($this-work-tan-transcriptions), tan:shallow-copy($this-work-tan-transcriptions/*)"/>
            <xsl:message select="'Claims about this work: ', $claims-about-this-work"/>
            <!--<xsl:message select="'ID regex for bibliography: ', $this-id-regex-for-bibliography"/>-->
            <xsl:message select="'Bibliography refs to this work: ', $bibliography-refs-to-this-work"/>
        </xsl:if>

        <!--<test15a this=""><xsl:copy-of select="$this-work-item"/></test15a>-->
        <!--<test15c><xsl:copy-of select="$corresponding-transcription-vocabulary-item"/></test15c>-->
        <!--<test15b transcriptions=""><xsl:copy-of select="tan:shallow-copy($this-work-tan-transcriptions, 2)"/></test15b>-->
        <!--<test15c claims-about-this=""><xsl:copy-of select="$claims-about-this-work"/></test15c>-->
        <!--<test15f mod-edn-iris=""><xsl:copy-of select="$modern-edition-iris"/></test15f>-->
        <tr id="{$this-work-id}">
            <td>
                <xsl:apply-templates select="$these-work-names-sorted"
                    mode="template-to-corpus-td-content"/>
            </td>
            <td>
                <div>
                    <xsl:value-of
                        select="$work-claims-re-authorship/ancestor-or-self::*[tan:subject][1]/tan:subject/text()"/>
                    <xsl:value-of
                        select="$work-claims-re-authorship/ancestor-or-self::*[tan:adverb][1]/tan:adverb/text()"
                    />
                </div>
            </td>
            <td>
                <xsl:apply-templates select="$work-claims-re-original-language/tan:object"
                    mode="template-to-corpus-td-content"/>
            </td>
            <td>
                <xsl:apply-templates select="$work-claims-re-portion-extant/tan:object"
                    mode="template-to-corpus-td-content"/>
            </td>
            <td colspan="{if ($this-is-a-version) then 3 else 5}">
                <!-- The main column of the table -->
                <div class="id-label">
                    <div class="cpg-no">
                        <xsl:value-of select="$this-cpg-norm"/>
                    </div>
                    <xsl:apply-templates select="tan:IRI" mode="template-to-corpus-td-content"/>
                </div>
                <div class="names">
                    <xsl:for-each select="$these-work-names-sorted">
                        <div>
                            <xsl:choose>
                                <xsl:when test="$collated-edition-available and position() = 1">
                                    <a href="{$this-collated-edition-url}">
                                        <xsl:value-of select="."/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </xsl:for-each>
                </div>
                <xsl:if test="not($this-orig-lang-code = 'grc') and not($this-is-a-version)">
                    <div class="orig-lang">Written originally in <xsl:value-of
                            select="$this-orig-lang"/>. </div>
                </xsl:if>
                <xsl:apply-templates select="$work-claims-re-portion-extant/tan:object"
                    mode="template-to-corpus-portion-extant"/>
                <xsl:apply-templates select="$work-claims-re-authorship"
                    mode="template-to-corpus-authorship-claim"/>
                <xsl:apply-templates select="tan:desc" mode="template-to-corpus-td-content"/>
                <xsl:apply-templates select="$work-claims-re-incipit/tan:object"
                    mode="template-to-corpus-incipit"/>
                <!--<xsl:if
                    test="exists($ancient-translation-vocabulary-items) and not($this-is-a-version)">
                    <xsl:variable name="ancient-translations-grouped" as="element()*"
                        select="tan:group-elements-by-IRI($ancient-translation-vocabulary-items/(tan:item, tan:version))"
                    />
                    <div class="ancient-translations">
                        <div>Ancient translations</div>
                        <table class="tablesorter show-last-col-only">
                            <thead>
                                <tr>
                                    <td rowspan="2">Title and description</td>
                                    <td colspan="2">Original</td>
                                    <!-\- we add a filler because in our css, we are going to hide the first four columns in the tbody, and we need to balance them with an equal number of columns in the thead -\->
                                    <td colspan="4" rowspan="2" class="filler"/>
                                </tr>
                                <tr>
                                    <td>lang</td>
                                    <td>extant (%)</td>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:apply-templates select="$ancient-translations-grouped/*[1]"
                                    mode="#current"/>
                            </tbody>
                        </table>
                    </div>
                </xsl:if>-->
                <!--<div class="ed-and-tr">
                    <xsl:choose>
                        <xsl:when test="count($bibliography-refs-to-this-work) gt 0">
                            <xsl:text>Published editions and translations (</xsl:text>
                            <xsl:value-of
                                select="count(distinct-values($bibliography-refs-to-this-work/@*:about))"/>
                            <xsl:text>): </xsl:text>
                            <xsl:for-each-group select="$bibliography-refs-to-this-work"
                                group-by="@*:about">
                                <xsl:sort select="current-group()[1]/*:date" order="descending"/>
                                <xsl:variable name="this-item-tan-id" as="xs:string*"
                                    select="current-group()[1]/*:description"/>
                                <xsl:variable name="this-item-transcriptions"
                                    select="$this-work-tan-transcriptions[*/tan:head/tan:source/tan:IRI = $this-item-tan-id]"/>
                                <xsl:variable name="these-refs" as="element()*">
                                    <xsl:for-each select="current-group()">
                                        <div>
                                            <xsl:copy-of select="tan:analyze-subject-tag(.)"/>
                                        </div>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:variable name="pub-prefix" as="xs:string*">
                                    <xsl:for-each-group select="$these-refs" group-by="*[2]">
                                        <xsl:value-of
                                            select="concat(tan:item-sequence(current-group()/*[3]), current-grouping-key())"
                                        />
                                    </xsl:for-each-group>
                                </xsl:variable>
                                <xsl:if test="$diagnostics-on">
                                    <xsl:message select="'This item TAN id: ', $this-item-tan-id"/>
                                    <xsl:message select="'Item transcriptions: ', count($this-item-transcriptions), tan:shallow-copy($this-item-transcriptions/*)"/>
                                    <xsl:message select="'Pub prefix: ', $pub-prefix"/>
                                </xsl:if>
                                <div class="pub">
                                    <div class="pub-prefix">
                                        <xsl:value-of
                                            select="concat(normalize-space(tan:item-sequence($pub-prefix)), ': ')"
                                        />
                                    </div>
                                    <xsl:copy-of
                                        select="tan:rdf-bib-to-chicago-humanities-bibliography-html(current-group()[1]/.., $bibliography-prepped)"/>
                                    <xsl:copy-of
                                        select="tan:transcription-hyperlink($this-item-transcriptions)"
                                    />
                                </div>
                            </xsl:for-each-group>
                        </xsl:when>
                        <xsl:when
                            test="exists($work-claims-re-portion-extant/tan:object[number(.) le 0])"
                        /><!-\- Ignore works that no longer survive -\->
                        <xsl:otherwise>
                            <xsl:text>No published editions or translations are known</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>

                </div>-->
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*" mode="template-to-corpus-td-content template-to-corpus-portion-extant template-to-corpus-authorship-claim">
        <!-- These subtemplates are shallow skips. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="tan:in-lang" mode="template-to-corpus-td-content">
        <div class="in-lang">
            <xsl:value-of select="tan:lang-name(text())"/>
        </div>
    </xsl:template>
    <xsl:template match="tan:name | tan:in-lang | tan:object | tan:IRI | tan:desc" mode="template-to-corpus-td-content">
        <xsl:variable name="is-language-code" select="self::tan:in-lang"/>
        <div class="{name(.)}">
            <xsl:value-of select="text()"/>
        </div>
    </xsl:template>
    <xsl:template match="tan:object" mode="template-to-corpus-portion-extant">
        <xsl:variable name="amount-extant-double" select="number(text())" as="xs:double?"/>
        <xsl:variable name="amount-extant-percent"
            select="format-number($amount-extant-double, '#%')"/>
        <xsl:if test="$amount-extant-double lt 1">
            <div class="orig-extant">
                <xsl:choose>
                    <xsl:when test="$amount-extant-double le 0">
                        <xsl:text>None of the original survives.</xsl:text>
                    </xsl:when>
                    <xsl:when test="$amount-extant-double le .7">
                        <xsl:value-of
                            select="concat('Only ', $amount-extant-percent, ' of the original is extant.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="concat($amount-extant-percent, ' of the original is extant.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tan:claim[not(tan:adverb/text() = 'not')]" mode="template-to-corpus-authorship-claim">
        <xsl:variable name="this-subject" select="ancestor-or-self::*[tan:subject][1]/tan:subject"/>
        <xsl:variable name="this-adverb" select="ancestor-or-self::*[tan:adverb][1]/tan:adverb"/>
        <xsl:variable name="this-claim-is-trivial"
            select="not(exists($this-adverb)) and $this-subject//tan:name = 'evagrius ponticus'"/>
        <xsl:if test="not($this-claim-is-trivial)">
            <div class="claim">
                <xsl:apply-templates select="$this-subject" mode="#current"/>
                <xsl:apply-templates select="$this-adverb" mode="#current"/>
                <xsl:text> wrote this work.</xsl:text>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tan:subject" mode="template-to-corpus-authorship-claim">
        <!--<xsl:variable name="this-idref" select="text()"/>-->
        <!--<xsl:variable name="this-vocab-item" as="element()*" select="tan:vocabulary('person', false(), $this-idref, root(.)/tan:TAN-A/tan:head)"/>-->
        <xsl:variable name="this-vocab-item" select="*"/>
        <xsl:variable name="this-first-name" select="($this-vocab-item//tan:name)[1]"/>
        <xsl:value-of select="tan:title-case($this-first-name)"/>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="tan:adverb" mode="template-to-corpus-authorship-claim">
        <xsl:value-of select="text()"/>
    </xsl:template>
    <xsl:template match="tan:object" mode="template-to-corpus-incipit">
        <div class="incipit">
            <xsl:text>Incipit: </xsl:text>
            <xsl:value-of select="."/>
        </div>
    </xsl:template>
    
    <xsl:template match="div[@class = 'body']|table[@id = 'corpus-table']" mode="template-to-corpus-prev">
        <xsl:variable name="work-vocab-items" select="tan:vocabulary('work', (), $corpus-claims-expanded/tan:TAN-A/tan:head)"/>
        <xsl:variable name="diagnostics-on" select="true()"/>
        <xsl:if test="$diagnostics-on">
            <xsl:message select="'diagnostics on for template mode template-to-corpus'"/>
        </xsl:if>
        <div class="links-to-other-formats">Other formats: <a
                href="{($corpus-claims-expanded/tan:TAN-A/tan:head/tan:master-location/@href)[1]}">TAN-A</a>
            (master)</div>
        <input class="search" type="search" data-column="all"/>
        <table class="tablesorter show-last-col-only" id="corpus-table">
            <thead>
                <tr>
                    <td rowspan="2">Title and description</td>
                    <td rowspan="2">Author</td>
                    <td colspan="2">Original</td>
                    <td rowspan="2">CPG</td>
                    <!-- we add a filler because in our css, we are going to hide the first four columns in the tbody, and we need to balance them with an equal number of columns in the thead -->
                    <td colspan="4" rowspan="2" class="filler"/>
                </tr>
                <tr>
                    <td>lang</td>
                    <td>extant (%)</td>
                </tr>
            </thead>
            <tbody>
                <!-- $corpus-expanded/tan:TAN-A/tan:head/tan:definitions/tan:work[tan:IRI[not(matches(., $works-to-exclude-regex-on-IRI))]] -->
                <xsl:for-each
                    select="$work-vocab-items/tan:item[tan:IRI[not(matches(., $works-to-exclude-regex-on-IRI))]]">
                    <xsl:sort select="(tan:id, @xml:id)[1]"/>
                    <xsl:variable name="this-work" select="."/>
                    <xsl:variable name="this-work-id" select="(tan:id, @xml:id)[1]"/>
                    <xsl:variable name="this-work-iris" select="tan:IRI"/>
                    <!--<xsl:variable name="this-work-tan-transcriptions"
                        select="$corpus-collection-resolved[*/tan:head/tan:work/tan:IRI = $this-work-iris]"/>-->
                    <xsl:variable name="this-work-tan-transcriptions"
                        select="$corpus-collection-resolved[tan:vocabulary('work', (), */tan:head)/tan:item/tan:IRI = $this-work-iris]"
                    />
                    <xsl:variable name="these-claims"
                        select="
                            $corpus-claims-expanded/tan:TAN-A/tan:body/tan:claim[(tan:object, tan:subject) = $this-work-id]"/>
                    <xsl:variable name="incipit-claims"
                        select="$these-claims[tan:verb = 'has-incipit']"/>
                    <xsl:variable name="orig-language-claims"
                        select="$these-claims[tan:verb = 'written-in']"/>
                    <xsl:variable name="ancient-translation-claims"
                        select="$these-claims[tan:verb = 'is-translation-of']"/>
                    <xsl:variable name="this-id-to-be-searched-in-bibliography"
                        select="concat(replace(@xml:id, '^cpg', ''), ' (translation|edition)')"/>
                    <xsl:variable name="bibliography-refs-to-this-work" as="element()*"
                        select="$bibliography-prepped/*/*/*:subject[matches(., $this-id-to-be-searched-in-bibliography)]"/>
                    <xsl:variable name="this-collated-edition-url"
                        select="concat($this-work-id, '.html')"/>
                    <xsl:variable name="collated-edition-available"
                        select="doc-available(concat('../', $this-collated-edition-url))"/>
                    <xsl:variable name="this-cpg-norm"
                        select="normalize-space(replace($this-work-id, 'cpg', ' CPG '))"/>
                    <xsl:variable name="this-authorship-claim"
                        select="$these-claims[tan:verb = 'wrote']"/>
                    <xsl:variable name="these-adverbs-and-authors" as="xs:string*">
                        <xsl:for-each select="$this-authorship-claim[not(tan:adverb = 'not')]">
                            <xsl:variable name="this-claim" select="."/>
                            <xsl:for-each select="tan:subject">
                                <xsl:variable name="this-person" select="."/>
                                <xsl:variable name="this-person-name"
                                    select="
                                        if (. = 'evagrius') then
                                            'Evagrius'
                                        else
                                            $corpus-claims-expanded/*/tan:head/tan:definitions/tan:person[@xml:id = $this-person]/tan:name[1]"/>
                                <xsl:value-of
                                    select="string-join((../tan:adverb, $this-person-name), ' ')"/>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="these-adverbs-and-nonauthors" as="xs:string*">
                        <xsl:for-each select="$this-authorship-claim[tan:adverb = 'not']">
                            <xsl:variable name="this-claim" select="."/>
                            <xsl:for-each select="tan:subject">
                                <xsl:variable name="this-person" select="."/>
                                <xsl:variable name="this-person-name"
                                    select="
                                        if (. = 'evagrius') then
                                            'Evagrius'
                                        else
                                            $corpus-claims-expanded/*/tan:head/tan:definitions/tan:person[@xml:id = $this-person]/tan:name[1]"/>
                                <xsl:value-of
                                    select="string-join((../tan:adverb, $this-person-name), ' ')"/>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="this-author-formatted-pass-1" as="xs:string*">
                        <xsl:value-of select="tan:item-sequence($these-adverbs-and-nonauthors)"/>
                        <xsl:if
                            test="exists($these-adverbs-and-nonauthors) and exists($these-adverbs-and-authors)">
                            <xsl:text>, but rather </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="tan:item-sequence($these-adverbs-and-authors)"/>
                    </xsl:variable>
                    <xsl:variable name="this-author-formatted"
                        select="replace(string-join($this-author-formatted-pass-1, ''), 'improbably', 'probably not')"/>
                    <xsl:variable name="this-orig-lang-code" select="$orig-language-claims/tan:object"/>
                    <xsl:variable name="this-orig-lang"
                        select="
                            for $i in $orig-language-claims
                            return
                                concat(tan:lang-name($i/tan:object)[1], if (exists($i/tan:adverb)) then
                                    concat(' (', $i/tan:adverb, ')')
                                else
                                    ())"/>
                    <xsl:variable name="this-orig-survival-qty" as="xs:double?"
                        select="$these-claims[tan:verb = 'survives-in-original-language']/tan:object/text()"/>
                    <xsl:variable name="this-orig-survival"
                        select="format-number($this-orig-survival-qty, '#%')"/>
                    <xsl:if test="$diagnostics-on">
                        <xsl:message select="'this work id:', $this-work-id"/>
                        <xsl:message select="'transcription count: ', count($this-work-tan-transcriptions)"/>
                        <xsl:message select="'these claims: ', $these-claims"/>
                    </xsl:if>
                    <xsl:text>&#xa;</xsl:text>
                    <tr id="{$this-work-id}">
                        <td>
                            <xsl:for-each select="tan:name">
                                <div>
                                    <xsl:value-of select="."/>
                                </div>
                            </xsl:for-each>
                        </td>
                        <td>
                            <div>
                                <xsl:value-of select="$this-authorship-claim/ancestor-or-self::*[tan:subject][1]/tan:subject"/>
                                <xsl:value-of select="$this-authorship-claim/ancestor-or-self::*[tan:adverb][1]/tan:adverb"/>
                            </div>
                        </td>
                        <td>
                            <div>
                                <xsl:value-of select="$this-orig-lang-code"/>
                            </div>
                        </td>
                        <td>
                            <div>
                                <xsl:value-of select="$this-orig-survival-qty"/>
                            </div>
                        </td>
                        <td colspan="5">
                            <!-- The main lens of the table -->
                            <div class="id-label">
                                <div class="cpg-no">
                                    <xsl:value-of select="$this-cpg-norm"/>
                                </div>
                                <xsl:for-each select="tan:IRI">
                                    <div class="IRI">
                                        <xsl:value-of select="."/>
                                    </div>
                                </xsl:for-each>
                            </div>
                            <div class="names">
                                <xsl:for-each
                                    select="distinct-values((@which, tan:name[not(@common)]))">
                                    <div>
                                        <xsl:choose>
                                            <xsl:when
                                                test="$collated-edition-available and position() = 1">
                                                <a href="{$this-collated-edition-url}">
                                                  <xsl:value-of select="."/>
                                                </a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="."/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                </xsl:for-each>
                            </div>
                            <xsl:if test="not($this-orig-lang-code = 'grc')">
                                <div class="orig-lang">Written originally in <xsl:value-of
                                        select="$this-orig-lang"/>. </div>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$this-orig-survival-qty = 0">
                                    <div class="orig-extant">None of the original composition
                                        survives. </div>
                                </xsl:when>
                                <xsl:when
                                    test="$this-orig-survival-qty gt 0 and $this-orig-survival-qty le .7">
                                    <div class="orig-extant">Only <xsl:value-of
                                            select="$this-orig-survival"/> of the original is
                                        extant. </div>
                                </xsl:when>
                                <xsl:when
                                    test="$this-orig-survival-qty gt .7 and $this-orig-survival-qty lt 1">
                                    <div class="orig-extant"><xsl:value-of
                                            select="$this-orig-survival"/> of the original is
                                        extant. </div>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:if
                                test="
                                    not(every $i in $these-adverbs-and-authors
                                        satisfies $i = 'Evagrius')">
                                <div class="authorship">The author was <xsl:value-of
                                        select="$this-author-formatted"/>. </div>
                            </xsl:if>
                            <div class="desc">
                                <xsl:value-of select="tan:desc"/>
                            </div>
                            <xsl:if test="exists($incipit-claims)">
                                <div class="incipit">Incipit: <xsl:value-of
                                        select="$incipit-claims/tan:object"/></div>
                            </xsl:if>
                            <xsl:if test="exists($ancient-translation-claims)">
                                <div class="ancient-translations">Ancient translations:
                                        <xsl:for-each select="$ancient-translation-claims">
                                        <xsl:variable name="this-transl-id" select="tan:subject"/>
                                        <xsl:variable name="these-translation-claims"
                                            select="$corpus-claims-expanded/*/tan:body/tan:claim[(tan:object, tan:subject) = $this-transl-id]"/>
                                        <xsl:variable name="these-lang-codes"
                                            select="distinct-values($these-translation-claims[tan:verb = 'written-in']/tan:object)"/>
                                        <xsl:value-of
                                            select="
                                                tan:item-sequence(for $i in $these-lang-codes
                                                return
                                                    tan:lang-name($i)[1])"
                                        />
                                    </xsl:for-each>
                                </div>
                            </xsl:if>
                            <div class="ed-and-tr">Editions and translations (<xsl:value-of
                                    select="count(distinct-values($bibliography-refs-to-this-work/../@*:about))"
                                />): <xsl:for-each-group select="$bibliography-refs-to-this-work"
                                    group-by="../@*:about">
                                    <xsl:sort select="current-group()[1]/../*:date"
                                        order="descending"/>
                                    <xsl:variable name="this-item-tan-id" as="xs:string*">
                                        <xsl:for-each select="current-group()[1]/../*:description">
                                            <xsl:analyze-string select="."
                                                regex="tag:evagriusponticus.net,2012:scriptum:\S+">
                                                <xsl:matching-substring>
                                                  <xsl:value-of select="."/>
                                                </xsl:matching-substring>
                                            </xsl:analyze-string>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:variable name="this-item-transcriptions"
                                        select="$this-work-tan-transcriptions[*/tan:head/tan:source/tan:IRI = $this-item-tan-id]"/>
                                    <xsl:variable name="these-refs" as="element()*">
                                        <xsl:for-each select="current-group()">
                                            <div>
                                                <xsl:copy-of select="tan:analyze-subject-tag(.)"/>
                                            </div>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:variable name="pub-prefix" as="xs:string*">
                                        <xsl:for-each-group select="$these-refs" group-by="*[2]">
                                            <xsl:value-of
                                                select="concat(tan:item-sequence(current-group()/*[3]), current-grouping-key())"
                                            />
                                        </xsl:for-each-group>
                                    </xsl:variable>
                                    <div class="pub">
                                        <div class="pub-prefix">
                                            <xsl:value-of
                                                select="concat(normalize-space(tan:item-sequence($pub-prefix)), ': ')"
                                            />
                                        </div>
                                        <xsl:copy-of
                                            select="tan:rdf-bib-to-chicago-humanities-bibliography-html(current-group()[1]/.., $bibliography-prepped)"/>
                                        <xsl:copy-of
                                            select="tan:transcription-hyperlink($this-item-transcriptions)"
                                        />
                                    </div>
                                </xsl:for-each-group></div>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
</xsl:stylesheet>
