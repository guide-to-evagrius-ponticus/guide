<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:include href="../../TAN/stylesheets/prepare/TAN-rdf-prepare-for-reuse.xsl"/>

    <xsl:variable name="corpus-data-prepped-for-reuse" as="document-node()">
        <xsl:document>
            <xsl:apply-templates select="$corpus-resolved/*" mode="prep-tan-rdf-for-reuse"/>
        </xsl:document>
    </xsl:variable>

    <xsl:template match="comment() | text()" mode="template-to-corpus">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="*" mode="template-to-corpus">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="template-to-corpus"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[@class = 'body']|table[@id = 'corpus-table']" mode="template-to-corpus">
        <div class="links-to-other-formats">Other formats: <a
                href="{($corpus-data-prepped-for-reuse//tan:master-location/@href)[1]}">TAN-rdf</a>
            (master)</div>
        <input class="search" type="search" data-column="all"/>
        <table class="tablesorter show-last-col-only" id="corpus-table">
            <thead>
                <tr>
                    <td rowspan="2">CPG</td>
                    <td rowspan="2">Author</td>
                    <td colspan="2">Original</td>
                    <td rowspan="2">Title and description</td>
                    <!-- we add a filler because in our css, we are going to hide the first four columns in the tbody, and we need to balance them with an equal number of columns in the thead -->
                    <td colspan="4" rowspan="2" class="filler"/>
                </tr>
                <tr>
                    <td>lang</td>
                    <td>extant (%)</td>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="$corpus-data-prepped-for-reuse/*/tan:head/tan:declarations/tan:work">
                    <xsl:sort select="@xml:id"/>
                    <xsl:variable name="this-work" select="."/>
                    <xsl:variable name="these-claims"
                        select="
                            $corpus-data-prepped-for-reuse/*/tan:body/tan:claim[(tan:object, tan:subject) = $this-work/@xml:id]"/>
                    <xsl:variable name="this-incipit"
                        select="$these-claims[tan:verb = 'has-incipit']"/>
                    <xsl:variable name="orig-language"
                        select="$these-claims[tan:verb = 'written-in']"/>
                    <xsl:variable name="this-ancient-translations"
                        select="$these-claims[tan:verb = 'is-translation-of']"/>
                    <xsl:variable name="this-id-to-be-searched-in-bibliography"
                        select="concat(replace(@xml:id, '^cpg', ''), ' (translation|edition)')"/>
                    <xsl:variable name="bibliography-refs-to-this-work" as="element()*"
                        select="$bibliography-prepped/*/*/*:subject[matches(., $this-id-to-be-searched-in-bibliography)]"/>
                    <xsl:variable name="this-cpg"
                        select="normalize-space(replace(@xml:id, 'cpg', ' CPG '))"/>
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
                                            $corpus-data-prepped-for-reuse/*/tan:head/tan:declarations/tan:person[@xml:id = $this-person]/tan:name[1]"/>
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
                                            $corpus-data-prepped-for-reuse/*/tan:head/tan:declarations/tan:person[@xml:id = $this-person]/tan:name[1]"/>
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
                    <xsl:variable name="this-orig-lang-code" select="$orig-language/tan:object"/>
                    <xsl:variable name="this-orig-lang"
                        select="
                            for $i in $orig-language
                            return
                                concat(tan:lang-name($i/tan:object)[1], if (exists($i/tan:adverb)) then
                                    concat(' (', $i/tan:adverb, ')')
                                else
                                    ())"/>
                    <xsl:variable name="this-orig-survival-qty" as="xs:double"
                        select="$these-claims[tan:verb = 'survives-in-original-language']/tan:object"/>
                    <xsl:variable name="this-orig-survival"
                        select="format-number($this-orig-survival-qty, '#%')"/>
                    <xsl:text>&#xa;</xsl:text>
                    <tr id="{@xml:id}">
                        <td>
                            <div><xsl:value-of select="@which"/></div>
                        </td>
                        <td>
                            <div><xsl:value-of select="$this-authorship-claim/(tan:subject, tan:adverb)"
                            /></div>
                        </td>
                        <td>
                            <div><xsl:value-of select="$this-orig-lang-code"/></div>
                        </td>
                        <td>
                            <div><xsl:value-of select="$this-orig-survival-qty"/></div>
                        </td>
                        <td colspan="5">
                            <!-- The main lens of the table -->
                            <div class="id-label">
                                <div class="cpg-no">
                                    <xsl:value-of select="$this-cpg"/>
                                </div>
                                <xsl:for-each select="tan:IRI">
                                    <div class="IRI">
                                        <xsl:value-of select="."/>
                                    </div>
                                </xsl:for-each>
                            </div>
                            <div class="names">
                                <xsl:for-each select="distinct-values((@which, tan:name))">
                                    <div>
                                        <xsl:value-of select="."/>
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
                            <xsl:if test="exists($this-incipit)">
                                <div class="incipit">Incipit: <xsl:value-of
                                        select="$this-incipit/tan:object"/></div>
                            </xsl:if>
                            <xsl:if test="exists($this-ancient-translations)">
                                <div class="ancient-translations">Ancient translations:
                                        <xsl:for-each select="$this-ancient-translations">
                                        <xsl:variable name="this-transl-id" select="tan:subject"/>
                                        <xsl:variable name="these-translation-claims"
                                            select="$corpus-data-prepped-for-reuse/*/tan:body/tan:claim[(tan:object, tan:subject) = $this-transl-id]"/>
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
                                            select="tan:rdf-bib-to-chicago-humanities-bibliography-html(current-group()[1]/.., $bibliography-prepped)"
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
