<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:z="http://www.zotero.org/namespaces/export#" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:bib="http://purl.org/net/biblio#"
    xmlns:vcard="http://nwalsh.com/rdf/vCard#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/"
    xmlns:link="http://purl.org/rss/1.0/modules/link/"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">
    <xsl:output method="xhtml" indent="no"/>
    <xsl:include href="../../TAN/TAN-1-dev/functions/TAN-c-functions.xsl"/>
    <xsl:include href="../../TAN/stylesheets/prepare/TAN-to-HTML-core.xsl"/>
    <xsl:include href="../../TAN/tools/iso-639-3/lang/lang-ext-tan-functions.xsl"/>
    <xsl:variable name="gep-template" select="doc('../template.html')"/>
    <xsl:variable name="template-with-tablesorter" as="document-node()">
        <xsl:document>
            <xsl:apply-templates select="$gep-template" mode="insert-tablesorter"/>
        </xsl:document>
    </xsl:variable>
    <xsl:variable name="bibliography" select="doc('../bibliography.rdf')"/>
    <xsl:variable name="bibliography-prepped" as="document-node()">
        <xsl:document>
            <xsl:apply-templates select="$bibliography" mode="prep-rdf"/>
        </xsl:document>
    </xsl:variable>
    <xsl:variable name="corpus" select="doc('../tan/TAN-c/evagrius-corpus-TAN-c.xml')"/>
    <xsl:variable name="corpus-resolved" select="tan:resolve-doc($corpus)"/>

    <xsl:template match="comment()" mode="html-cleanup insert-tablesorter prep-rdf">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="text()" mode="insert-tablesorter prep-rdf">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="*" mode="html-cleanup insert-tablesorter prep-rdf">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="head" mode="insert-tablesorter">
        <xsl:copy>
            <xsl:copy-of select="node()"/>
            <link rel="stylesheet" type="text/css" href="tablesorter/css/theme.default.css">
                <xsl:comment/>
            </link>
            <script type="text/javascript" src="tablesorter/js/jquery.tablesorter.combined.js"/>
            <script>
                $(function(){
                $('table').tablesorter({
                widgets: ["filter"],
                widgetOptions : {
                filter_external : '.search',
                filter_defaultFilter: { 1 : '~{query}' },
                filter_columnFilters: true,
                filter_placeholder: { search : 'Search...' },
                filter_saveFilters : true,
                filter_reset: '.reset'
                }
                });
                $('button[data-column]').on('click', function(){
                var $this = $(this),
                totalColumns = $table[0].config.columns,
                col = $this.data('column'), // zero-based index or "all"
                filter = [];
                filter[ col === 'all' ? totalColumns : col ] = $this.text();
                $table.trigger('search', [ filter ]);
                return false;
                });
                });
            </script>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dc:date" mode="prep-rdf">
        <xsl:variable name="year" as="xs:string*">
            <xsl:analyze-string select="." regex="\d\d\d\d([–-]\d*)?">
                <xsl:matching-substring>
                    <xsl:value-of select="."/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="($year[1], '0')[1]"/>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="tan:rdf-bib-to-chicago-humanities-bibliography-html" as="element()*">
        <xsl:param name="bib-elements" as="element()*"/>
        <xsl:param name="rdf-context" as="document-node()*"/>
        <xsl:variable name="primary-creators"
            select="($bib-elements/(bib:authors, bib:editors, z:presenters))[1]"/>
        <xsl:for-each select="$bib-elements">
            <xsl:variable name="this-pub" select="."/>
            <xsl:variable name="this-title"
                select="
                    if (exists(dc:title)) then
                        dc:title
                    else
                        (.//dc:title)[1]"/>
            <xsl:variable name="citation-raw" as="element()">
                <div>
                    <xsl:value-of select="tan:name-sequence($primary-creators, true())"/>
                    <xsl:text>. </xsl:text>
                    <xsl:copy-of select="tan:dc-title-to-chicago-html($this-title, '.')"/>
                    <xsl:text> </xsl:text>
                    <xsl:choose>
                        <xsl:when test="self::bib:BookSection">
                            <!-- For chapters in a book (one of the more complicated types of entries) -->
                            <xsl:variable name="volume-title"
                                select="dcterms:isPartOf/bib:Book/dc:title"/>
                            <xsl:variable name="volume-editors"
                                select="
                                    if (exists(bib:editors)) then
                                        bib:editors
                                    else
                                        /*/bib:Book[dc:title = $volume-title]/bib:editors"/>
                            <xsl:text> In </xsl:text>
                            <xsl:copy-of select="tan:dc-title-to-chicago-html($volume-title, ())"/>
                            <xsl:if test="exists($volume-editors)">
                                <xsl:text>. Edited by </xsl:text>
                                <xsl:value-of select="tan:name-sequence($volume-editors, false())"/>
                            </xsl:if>
                            <xsl:if test="exists(bib:pages)">
                                <xsl:text>, pp. </xsl:text>
                                <xsl:value-of select="bib:pages"/>
                            </xsl:if>
                            <xsl:text>. </xsl:text>
                            <xsl:if
                                test="exists(dcterms:isPartOf/bib:Book/dcterms:isPartOf/bib:Series)">
                                <xsl:value-of
                                    select="concat(string-join(dcterms:isPartOf/bib:Book/dcterms:isPartOf/bib:Series//text()[matches(., '\S')], ' '), '. ')"
                                />
                            </xsl:if>
                            <xsl:value-of select="tan:publisher-info($this-pub)"/>
                            <xsl:text>. </xsl:text>
                        </xsl:when>
                        <xsl:when test="self::bib:Article">
                            <!-- Cases where the item is a journal article -->
                            <xsl:copy-of
                                select="tan:dc-title-to-chicago-html(dcterms:isPartOf/bib:Journal/dc:title, ())"/>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="dcterms:isPartOf/bib:Journal/prism:volume"/>
                            <xsl:if test="exists(dcterms:isPartOf/bib:Journal/prism:number)">
                                <xsl:text>, no. </xsl:text>
                                <xsl:value-of select="dcterms:isPartOf/bib:Journal/prism:number"/>
                            </xsl:if>
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="dc:date"/>
                            <xsl:text>): </xsl:text>
                            <xsl:value-of select="bib:pages"/>
                            <xsl:text>.</xsl:text>
                        </xsl:when>
                        <xsl:when test="self::bib:Book">
                            <!-- cases where the item is a book -->
                            <xsl:if test="exists(z:translators)">
                                <xsl:text>Translated by </xsl:text>
                                <xsl:value-of select="tan:name-sequence(z:translators, false())"/>
                                <xsl:text>. </xsl:text>
                            </xsl:if>
                            <xsl:if test="exists(dcterms:isPartOf/bib:Series)">
                                <xsl:value-of
                                    select="concat(string-join(dcterms:isPartOf/bib:Series//text()[matches(., '\S')], ' '), '. ')"
                                />
                            </xsl:if>
                            <xsl:value-of select="tan:publisher-info($this-pub)"/>
                            <xsl:text>. </xsl:text>
                        </xsl:when>
                        <xsl:when test="self::bib:Thesis">
                            <!-- cases where the item is a thesis -->
                            <xsl:value-of select="(z:type, z:itemType)[1]"/>
                            <xsl:text>. </xsl:text>
                            <xsl:value-of select="(dc:publisher//foaf:name, '[n.p.]')[1]"/>
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="dc:date"/>
                            <xsl:text>. </xsl:text>
                        </xsl:when>
                        <xsl:when test="self::bib:ConferenceProceedings">
                            <!-- cases where the item is a lecture or oral paper -->
                            <xsl:value-of select="(z:type, z:itemType)[1]"/>
                            <xsl:if test="exists(z:meetingName)">
                                <xsl:value-of select="concat(', ', z:meetingName)"/>
                            </xsl:if>
                            <xsl:if test="exists(.//vcard:locality)">
                                <xsl:value-of select="concat(', ', .//vcard:locality)"/>
                            </xsl:if>
                            <xsl:value-of select="concat(', ', dc:date)"/>
                        </xsl:when>
                        <xsl:when test="self::bib:Document">
                            <!-- cases where the item is a web page -->
                            <xsl:if test="exists(dcterms:isPartOf) and exists(dc:title)">
                                <xsl:for-each select="dcterms:isPartOf//dc:title">
                                    <xsl:value-of select="concat(., ' (', local-name(..), '). ')"/>
                                </xsl:for-each>
                            </xsl:if>
                            <xsl:value-of select="tan:publisher-info($this-pub)"/>
                            <xsl:text>. </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="warning">Content Pending</div>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </xsl:variable>
            <xsl:apply-templates select="$citation-raw" mode="html-cleanup"/>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="tan:dc-title-to-chicago-html" as="item()*">
        <xsl:param name="dc-title-element" as="element()?"/>
        <xsl:param name="terminal-punctuation" as="xs:string?"/>
        <xsl:choose>
            <xsl:when
                test="$dc-title-element/(parent::bib:Book, parent::bib:Journal, parent::z:Website)">
                <div class="book-title">
                    <xsl:value-of select="$dc-title-element"/>
                </div>
                <xsl:value-of select="$terminal-punctuation"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>“</xsl:text>
                <xsl:value-of select="concat($dc-title-element, $terminal-punctuation)"/>
                <xsl:text>”</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="tan:name-sequence" as="xs:string?">
        <xsl:param name="person-elements" as="element()*"/>
        <xsl:param name="surname-first" as="xs:boolean"/>
        <xsl:variable name="persons" select="$person-elements/descendant-or-self::foaf:Person"/>
        <xsl:variable name="person-count" select="count($persons)"/>
        <xsl:variable name="results" as="xs:string*">
            <xsl:for-each select="$persons">
                <xsl:variable name="this-name" as="xs:string*">
                    <xsl:choose>
                        <xsl:when test="$surname-first = true()">
                            <xsl:value-of select="foaf:surname"/>
                            <xsl:if test="exists(foaf:givenname) and exists(foaf:surname)">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:value-of select="foaf:givenname"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="foaf:givenname"/>
                            <xsl:if test="exists(foaf:givenname) and exists(foaf:surname)">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:value-of select="foaf:surname"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="string-join($this-name, '')"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="tan:item-sequence($results)"/>
    </xsl:function>

    <xsl:function name="tan:item-sequence" as="xs:string?">
        <xsl:param name="string-sequence" as="xs:string*"/>
        <xsl:value-of select="tan:item-sequence($string-sequence, 'and')"/>
    </xsl:function>
    <xsl:function name="tan:item-sequence" as="xs:string?">
        <!-- Input: any sequence of strings that should be rendered in a sequence; some copula word (e.g., 'and', 'or', 'but rather') -->
        <!-- Output: the strings, joined by commas and the copula -->
        <xsl:param name="string-sequence" as="xs:string*"/>
        <xsl:param name="copula" as="xs:string?"/>
        <xsl:variable name="copula-prepped" select="concat(' ', $copula, ' ')"/>
        <xsl:variable name="n" select="count($string-sequence)"/>
        <xsl:choose>
            <xsl:when test="$n = 1">
                <xsl:value-of select="$string-sequence"/>
            </xsl:when>
            <xsl:when test="$n = 2">
                <xsl:value-of select="string-join($string-sequence, $copula-prepped)"/>
            </xsl:when>
            <xsl:when test="$n gt 2">
                <xsl:value-of
                    select="concat(string-join($string-sequence[position() lt $n], ', '), ',', $copula-prepped, $string-sequence[last()])"
                />
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="tan:analyze-subject-tag" as="element()*">
        <!-- Input: a subject tag used in the Evagrius bibliography -->
        <!-- Output: a series of elements parsing the edition and translation information -->
        <xsl:param name="tag-string" as="xs:string?"/>
        <xsl:analyze-string select="$tag-string" regex=" (edition|translation) ">
            <xsl:matching-substring>
                <div class="relation">
                    <xsl:value-of select="."/>
                </div>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <div class="object">
                    <xsl:value-of select="."/>
                </div>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="tan:publisher-info" as="xs:string?">
        <xsl:param name="bib-item" as="element()"/>
        <xsl:variable name="special-bib-item-data"
            select="tan:convert-text-to-elements($bib-item/dc:description)"/>
        <xsl:variable name="publisher-locale" select="$bib-item/dc:publisher//vcard:locality"/>
        <xsl:variable name="publisher-name" select="$bib-item/dc:publisher//foaf:name"/>
        <xsl:variable name="published-date" select="$bib-item/dc:date"/>
        <xsl:variable name="locale-norm"
            select="
                if (exists($publisher-locale)) then
                    tan:item-sequence($publisher-locale)
                else
                    ($special-bib-item-data/*:place, '[n.p.]')[1]"/>
        <xsl:variable name="name-norm"
            select="($publisher-name, $special-bib-item-data/*:publisher, '[n.p.]')[1]"/>
        <xsl:variable name="date-norm" select="replace($published-date, '^0$', '[n.d.]')"/>
        <xsl:value-of select="concat($locale-norm, ': ', $name-norm, ', ', $date-norm)"/>
    </xsl:function>

    <xsl:function name="tan:convert-text-to-elements" as="element()*">
        <!-- Input: any elements -->
        <!-- Output: each element, but with its text analyzed for element names and content -->
        <!-- This assumes syntax such as <dc:description>Place: Washington, D.C.</dc:description>, with a new line for each element-->
        <xsl:param name="dc-description-element" as="element()*"/>
        <xsl:for-each select="$dc-description-element">
            <xsl:copy>
                <xsl:analyze-string select="." regex="^\s*(\w+)\s*: (.+)$" flags="m">
                    <xsl:matching-substring>
                        <xsl:element name="{lower-case(regex-group(1))}">
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:element>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:copy>
        </xsl:for-each>
    </xsl:function>

    <xsl:template match="text()" mode="html-cleanup">
        <!-- Here's where we clean up the niggly things, like replacing hyphens with en dashes -->
        <xsl:variable name="pass1" select="replace(., '\.\.', '.')"/>
        <xsl:variable name="pass2" select="replace($pass1, '[,\.] \(', ' (')"/>
        <xsl:variable name="pass3" select="replace($pass2, '(\d)-', '$1–')"/>
        <xsl:variable name="pass4" select="replace($pass3, '\.,', ',')"/>
        <xsl:copy-of select="tan:text-tags-to-html($pass4)"/>
    </xsl:template>
    <xsl:variable name="element-regex" as="xs:string" select="'&lt;([a-zA-Z0-9]+)([^&gt;]*)&gt;(.+?)&lt;/\1&gt;'"/>
    <xsl:function name="tan:text-tags-to-html" as="item()*">
        <xsl:param name="raw-text" as="xs:string?"/>
        
        <xsl:analyze-string select="$raw-text" regex="{$element-regex}"
            flags="ms">
            <xsl:matching-substring>
                <xsl:variable name="this-element-name" select="regex-group(1)"/>
                <xsl:variable name="this-element-attributes" as="element()">
                    <attr>
                        <!--<xsl:attribute name="test" select="regex-group(2)"></xsl:attribute>-->
                        <xsl:analyze-string select="regex-group(2)" regex="(\w+)\s*=\s*[&quot;&apos;&#34;](.+?)[&quot;&apos;&#34;]">
                            <xsl:matching-substring>
                                <xsl:attribute name="{regex-group(1)}" select="regex-group(2)"></xsl:attribute>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </attr>
                </xsl:variable>
                <xsl:variable name="this-element-content" select="regex-group(3)"/>
                <xsl:element name="{$this-element-name}">
                    <xsl:copy-of select="$this-element-attributes/@*"/>
                    <xsl:choose>
                        <xsl:when test="not(matches($this-element-content, $element-regex, 'ms'))">
                            <xsl:value-of select="$this-element-content"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="tan:text-tags-to-html($this-element-content)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="tan:transcription-hyperlink" as="element()?">
        <!-- Input: a transcription file (member of $corpus-collection) -->
        <!-- Output: <div> with hyperlink to transcription -->
        <xsl:param name="transcriptions" as="item()*"/>
        <xsl:if test="exists($transcriptions)">
            <div class="transcriptions">
                Transcriptions: 
                <xsl:for-each select="$transcriptions">
                    <div>
                        <a href="{tan:uri-relative-to(tan:base-uri(.), $site-base-uri)}">
                            <xsl:value-of select=".//*:body/@xml:lang"/>
                        </a>
                    </div>
                </xsl:for-each>
            </div></xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
