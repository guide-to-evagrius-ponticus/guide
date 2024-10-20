<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tan="tag:textalign.net,2015:ns"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:gep="https://evagriusponticus.net"
    exclude-result-prefixes="#all"
    expand-text="yes"
    version="3.0">
    
    <!-- Primary (catalyzing) input: any XML file, including this one -->
    <!-- Secondary (main) input: TAN-TEI files -->
    <!-- Primary output: perhaps diagnostics -->
    <!-- Secondary output: one index file per letter per language, with KWIC and links -->
    
    <!-- To do: lemma xrefs, e.g., 
        χείριστος to κακός 
        ἐρῶ ῥέομαι to λέγω
        
        Type Greek for CPG 2458.2, 2458.5, 2469
    -->
    
    <xsl:include href="../../TAN/TAN-2022/functions/TAN-function-library.xsl"/>
    <xsl:include href="index-resources/lemmas.xsl"/>
    
    <xsl:param name="greek-letter-entry-length" as="xs:integer" select="2"/>
    
    <xsl:variable name="stopwords" as="document-node()" select="doc('index-resources/stopwords.xml')"/>
    
    <xsl:variable name="gep-template" as="document-node()" select="doc('../templates/template.html')"/>
    <xsl:variable name="gep-work-vocabulary" as="document-node()" select="doc('../tan/TAN-voc/evagrius-works-TAN-voc.xml')"/>
    
    <xsl:variable name="TAN-library-uris" as="xs:anyURI*" select="uri-collection('../TAN?recurse=yes')"/>
    
    
    <!-- 'cpg24\d[0-9]\.eng' -->
    <xsl:param name="TAN-uris-must-match" as="xs:string?" select="'cpg24(42|57)\.grc'"/>
    <xsl:param name="TAN-uris-must-not-match" as="xs:string?" select="'TAN-A|franken|scriptum|vat_gr_754'"/>
    
    <xsl:param name="KWIC-length" as="xs:integer" select="4"/>
    
    <xsl:variable name="uris-of-interest" as="xs:anyURI*" select="
            $TAN-library-uris[if (matches($TAN-uris-must-match, '\S')) then
                matches(., $TAN-uris-must-match, 'i')
            else
                true()][if (matches($TAN-uris-must-not-match, '\S')) then
                not(matches(., $TAN-uris-must-not-match, 'i'))
            else
                true()]"/>
    
    <xsl:variable name="uris-of-interest-sorted" as="xs:anyURI*">
        <xsl:for-each select="$uris-of-interest">
            <xsl:sort select="reverse(tokenize(., '/'))[2]"/>
            <xsl:sort select="analyze-string(., '\.(\d\d\d\d)')/*:match/*:group => xs:integer()" order="descending"/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="files-of-interest" as="document-node()*" select="tan:open-file($uris-of-interest-sorted)"/>
    <xsl:variable name="files-of-interest-resolved" as="document-node()*" select="$files-of-interest ! tan:resolve-doc(.)"/>
    <xsl:variable name="files-of-interest-tokenized" as="document-node()*">
        <!--<xsl:apply-templates select="$files-of-interest" mode="simple-normalize-and-tokenize"/>-->
        <!-- Up to 30 seconds extra to resolve the Trilogy in Greek -->
        <xsl:apply-templates select="$files-of-interest-resolved" mode="simple-normalize-and-tokenize"/>
    </xsl:variable>
    
    <xsl:mode name="simple-normalize-and-tokenize" on-no-match="shallow-copy"/>
    
    <xsl:template match="@xml:lang[. eq 'en']" mode="simple-normalize-and-tokenize">
        <xsl:attribute name="xml:lang" select="'eng'"/>
    </xsl:template>
    
    <xsl:variable name="batch-replacements.eng" as="element()*">
        <replace pattern="(fully-|properly-|richly-)(\S)" replacement="$1&#x200B;$2"/>
        <replace pattern="(eye-)(disease|salve)" replacement="$1&#x200B;$2"/>
        <replace pattern="(fallen-)(away)" replacement="$1&#x200B;$2"/>
        <replace pattern="(ing-)(thought)" replacement="$1&#x200B;$2"/>
        <replace pattern="(knowledge-)(seeking)" replacement="$1&#x200B;$2"/>
        <replace pattern="(non) - (knower)" replacement="$1$2"/>
        <replace pattern="(re) (clothe)" replacement="$1-$2"/>
    </xsl:variable>
    <xsl:variable name="batch-replacements.grc" as="element()*">
        <!-- Drop numerals -->
        <replace pattern="[α-ωϙϛϟϡ]+΄" replacement=""/>
        <replace pattern="(.)&#xad;\s*(.)" replacement="$1$2"/>
        <replace pattern="(ἀγαλλιά|δικαιο|δυσπρόσι|σωφρο|ἄγγε|ἀντιλαμβα|ἀπανθρω|ἀσθέ|γυναι|δαιμο)-\s*" replacement="$1"/>
        <replace pattern="(δυσ|δυσκί|ἐνα|λαν|λογι|πράγ|σύμβο|συνέστη|χρώ|χω)-\s*" replacement="$1"/>
        <replace pattern="(ἀπαγγ|κρί|ἐστε)\[" replacement="$1"/>
        <replace pattern="[··]" replacement="&#x200a;·"/>
    </xsl:variable>
    
    <!-- ignore lemmas from the Bible -->
    <xsl:template match="*:div[@type = 'psalm']/*:div[@type = 'verse'] | *:div[@n = 'prov']/*:div[@type = 'chapter']"
        mode="simple-normalize-and-tokenize" priority="1"/>
    
    <xsl:template match="*:div[not(*:div)]" mode="simple-normalize-and-tokenize">
        <xsl:variable name="language" as="xs:string" select="ancestor::*[@xml:lang][1]/@xml:lang"/>
        <xsl:variable name="language-norm" as="xs:string">
            <xsl:choose>
                <xsl:when test="$language eq 'en'">eng</xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$language"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="lang-regex" as="xs:string">
            <xsl:choose>
                <xsl:when test="$language-norm eq 'eng'">[a-zA-Z\p{{IsLatin-1Supplement}}\p{{IsLatinExtended-A}}]+(-[a-zA-Z\p{{IsLatin-1Supplement}}\p{{IsLatinExtended-A}}]+)*</xsl:when>
                <xsl:when test="$language-norm eq 'grc'">[\p{{IsGreek}}\p{{IsGreekExtended}}]+</xsl:when>
                <xsl:otherwise>[\p{{L}}]+(-[\p{{L}}]+)*</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="simple-text" as="xs:string" select="normalize-space(.)"/>
        <xsl:variable name="simple-text-norm" as="xs:string">
            <xsl:choose>
                <xsl:when test="$language-norm eq 'eng'">
                    <xsl:sequence select="tan:batch-replace($simple-text, $batch-replacements.eng)"
                    />
                </xsl:when>
                <xsl:when test="$language-norm eq 'grc'">
                    <xsl:sequence select="tan:batch-replace($simple-text, $batch-replacements.grc)"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$simple-text"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="this-div" as="element()" select="."/>

        <div>
            <xsl:copy-of select="@*"/>
            <xsl:analyze-string select="$simple-text-norm" regex="\[[a-zA-Z]\]">
                <xsl:matching-substring>
                    <x>{.}</x>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="." regex="{$lang-regex}">
                        <xsl:matching-substring>
                            <xsl:variable name="is-stopword" as="xs:boolean"
                                select="lower-case(normalize-unicode(.)) = $stopwords/stopwords/group[@xml:lang = $language-norm]/w"
                            />
                            <xsl:variable name="first-char" as="xs:string" select="tan:string-base(lower-case(substring(., 1, 1)))"/>
                            <xsl:variable name="ad-hoc-check-is-ok" as="xs:boolean" select="true()"/>
                            <xsl:variable name="string-checked" as="xs:string?" select="
                                    if ($is-stopword or not($ad-hoc-check-is-ok)) then
                                        ()
                                    else
                                        gep:lemmas(., $this-div, $language)"
                            />
                            <tok>
                                <xsl:if test="string-length($string-checked) gt 0">
                                    <xsl:attribute name="lemma" select="$string-checked"/>
                                </xsl:if>
                                <xsl:value-of select="."/>
                            </tok>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <x>{.}</x>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </div>
    </xsl:template>
    
    
    <xsl:variable name="raw-index" as="document-node()">
        <xsl:document>
            <raw-index>
                <xsl:for-each-group select="$files-of-interest-tokenized//div[not(*:div)]" group-by="ancestor-or-self::*[@xml:lang][1]/@xml:lang">

                    <index xml:lang="{current-grouping-key()}" count="{count(current-group())}">
                        <!-- Group by first letter -->
                        <xsl:for-each-group select="current-group()/tok[@lemma]" group-by="tan:string-base(lower-case(substring(@lemma, 1, $greek-letter-entry-length)))">
                            <xsl:sort select="current-grouping-key()"/>

                            <letter key="{current-grouping-key()}" count="{count(current-group())}">
                                <!-- Then sort by word -->
                                <xsl:for-each-group select="current-group()" group-by="@lemma">
                                    <xsl:sort select="tan:string-base(lower-case(current-grouping-key()))"/>

                                    <entry key="{current-grouping-key()}"
                                        count="{count(current-group())}">
                                        <xsl:for-each-group select="current-group()" group-by="tokenize(base-uri(), '/')[position() = (last() - 1)]">
                                            <work key="{current-grouping-key()}"
                                                count="{count(current-group())}">
                                                
                                                <xsl:for-each-group select="current-group()" group-by="string-join(ancestor::*/@n, '.')">
                                                <!-- Then sort by canonical reference -->
                                                  <xsl:sort select="
                                                            replace(current-grouping-key(), '^p', ' p')
                                                            => replace('^(\d)(\.|$)', '0$1$2')"
                                                  />
                                                    <xsl:variable name="this-ref" as="xs:string" select="current-grouping-key()"/>
                                                    <xsl:for-each-group select="current-group()" 
                                                        group-by="string-join((
                                                        preceding-sibling::tok[2], 
                                                        preceding-sibling::tok[1], 
                                                        ., 
                                                        following-sibling::tok[1],
                                                        following-sibling::tok[2]
                                                        ), ' ')
                                                        => tan:string-base() => lower-case()">
                                                        
                                                  <xsl:apply-templates select="current-group()[1]"
                                                  mode="build-KWIC">
                                                      <xsl:with-param name="ref" tunnel="yes" select="$this-ref"/>
                                                      <xsl:with-param name="other-versions" tunnel="yes" select="current-group()[position() gt 1]"/>
                                                  </xsl:apply-templates>
                                                  <!--<xsl:apply-templates select="current-group()[position() gt 1]"
                                                  mode="build-KWIC">
                                                      <xsl:with-param name="ref" tunnel="yes" select="$this-ref"/>
                                                      <xsl:with-param name="is-variant" tunnel="yes" select="true()"/>
                                                  </xsl:apply-templates>-->
                                                    </xsl:for-each-group> 
                                                </xsl:for-each-group> 
                                                
                                            </work>
                                        </xsl:for-each-group> 
                                    </entry>
                                </xsl:for-each-group> 
                            </letter>
                        </xsl:for-each-group> 
                    </index>
                </xsl:for-each-group> 
            </raw-index>
        </xsl:document>
    </xsl:variable>
    
    <xsl:mode name="build-KWIC" on-no-match="shallow-copy"/>
    <xsl:mode name="build-KWIC-xrefs" on-no-match="shallow-copy"/>
    
    <!-- First catch, on the tokens of interest -->
    <xsl:template match="tok" mode="build-KWIC">
        <xsl:param name="is-variant" tunnel="yes" as="xs:boolean?" select="false()"/>
        <xsl:param name="other-versions" tunnel="yes" as="element()*"/>
        <xsl:param name="ref" tunnel="yes" as="xs:string" select="string-join(ancestor::*/@n, '.')"/>
        
        <xsl:variable name="curr-pos" as="xs:integer" select="count(preceding-sibling::tok) + 1"/>
        <xsl:variable name="KWIC-start" as="element()?" select="../tok[position() eq ($curr-pos - $KWIC-length)]/preceding-sibling::*[1]"/>
        <xsl:variable name="KWIC-end" as="element()?" select="../tok[position() eq ($curr-pos + $KWIC-length)]/following-sibling::*[1]"/>
        
        <div>
            <xsl:attribute name="filename" select="tan:cfn(base-uri(.))"/>
            <xsl:if test="exists($other-versions)">
                <xsl:attribute name="other-versions"
                    select="($other-versions ! tan:cfn(base-uri(.))) => string-join(' ')"/>
            </xsl:if>
            <xsl:attribute name="ref" select="$ref"/>
            <xsl:if test="$is-variant">
                <xsl:attribute name="class">var</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="preceding-sibling::*[(. >> $KWIC-start) or not(exists($KWIC-start))]" mode="build-KWIC-xrefs"/>
            <span>
                <xsl:attribute name="class">kw</xsl:attribute>
                <xsl:value-of select="."/>
            </span>
            <xsl:apply-templates select="following-sibling::*[($KWIC-end >> .) or not(exists($KWIC-end))]" mode="build-KWIC-xrefs"/>
        </div>
    </xsl:template>
    
    <xsl:template match="x | tok[not(@lemma)]" mode="build-KWIC-xrefs">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!-- second catch, on the xref tokens -->
    <xsl:template match="tok[@lemma]" mode="build-KWIC-xrefs">
        <span>
            <xsl:attribute name="class">xref</xsl:attribute>
            <a href="{tan:string-base(lower-case(substring(@lemma, 1, $greek-letter-entry-length)))}.html#{@lemma}">
                <xsl:value-of select="."/>
            </a>
        </span>
    </xsl:template>
    
    
    
    
    
    <!-- OUTPUT -->
    
    
    <xsl:mode name="catalyze-html-index-files" on-no-match="shallow-skip"/>
    <xsl:mode name="create-html-index-files" on-no-match="shallow-copy"/>
    <xsl:mode name="nav-banner" on-no-match="shallow-skip"/>
    
    <xsl:template match="raw-index/index" mode="catalyze-html-index-files">
        <xsl:variable name="this-lang" as="xs:string" select="@xml:lang"/>
        <xsl:variable name="this-url" as="xs:string" select="'../index/word/' || $this-lang || '/index.html'"/>
        
        <xsl:result-document href="{$this-url}" method="html">
            <xsl:apply-templates select="$gep-template" mode="create-html-index-files"/>
        </xsl:result-document>
        
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="index/letter" mode="catalyze-html-index-files">
        <xsl:variable name="this-lang" as="xs:string" select="../@xml:lang"/>
        <xsl:variable name="this-url" as="xs:string" select="'../index/word/' || $this-lang || '/' || @key || '.html'"/>
        
        <xsl:message>Saving file at {resolve-uri($this-url)}</xsl:message>
        <xsl:result-document href="{$this-url}" method="html">
            <xsl:apply-templates select="$gep-template" mode="create-html-index-files">
                <xsl:with-param name="letter-data" tunnel="yes" select="."/>
            </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="@src | @href" mode="create-html-index-files">
        <xsl:attribute name="{name(.)}" select="'../../' || ."/>
    </xsl:template>
    <xsl:template match="html:head/html:link[@rel = 'stylesheet'][last()]" mode="create-html-index-files">
        <xsl:next-match/>
        <xsl:element name="link" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="rel">stylesheet</xsl:attribute>
            <xsl:attribute name="type">text/css</xsl:attribute>
            <xsl:attribute name="href">../../../css/indexes.css</xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="html:div[@id = 'content']" mode="create-html-index-files">
        <xsl:param name="letter-data" tunnel="yes" as="element()?"/>
        
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">nav-banner</xsl:attribute>
            <xsl:apply-templates select="$letter-data/.." mode="nav-banner"/>
        </xsl:element>
        <xsl:if test="exists($letter-data)">
            <xsl:element name="h2" namespace="http://www.w3.org/1999/xhtml">{$letter-data/@key}</xsl:element>
            <xsl:apply-templates select="$letter-data/*" mode="#current"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="letter/@key" mode="nav-banner">
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">letter</xsl:attribute>
            <xsl:element name="a">
                <xsl:attribute name="href">{.}.html</xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="index[@xml:lang = 'eng']/letter/entry" mode="create-html-index-files">
        <xsl:variable name="best-keyword" as="xs:string">
            <!-- In English, we take the best keyword as the most common one. -->
            <xsl:for-each-group select="descendant::span[@class = 'kw']" group-by=".">
                <!-- Prefer lowercase to uppercase -->
                <xsl:sort select="current-grouping-key()" order="descending"/>
                <!-- Take the most common form of the keyword -->
                <xsl:sort select="count(current-group())" order="descending"/>
                <xsl:if test="position() eq 1">
                    <xsl:value-of select="current-group()[1]"/>
                </xsl:if>
            </xsl:for-each-group> 
        </xsl:variable>
        <xsl:element name="h3" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="id" select="@key"/>
            <xsl:value-of select="$best-keyword"/>
        </xsl:element>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="index[@xml:lang = 'grc']/letter/entry" mode="create-html-index-files">
        <xsl:variable name="best-keyword" as="xs:string" select="@key"/>
        <xsl:element name="h3" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="id" select="@key"/>
            <xsl:value-of select="$best-keyword"/>
        </xsl:element>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="entry/work" mode="create-html-index-files">
        <xsl:variable name="this-cpg-no" as="xs:string" select="@key"/>
        <xsl:variable name="best-name" as="xs:string" select="$gep-work-vocabulary//tan:item[tan:name = $this-cpg-no]/tan:name[1]"/>
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">work</xsl:attribute>
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">title</xsl:attribute>
                <xsl:value-of select="$best-name"/>
            </xsl:element>
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:apply-templates mode="#current"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="work/div" mode="create-html-index-files">
        <xsl:variable name="version-identifier" as="xs:string*">
            <xsl:for-each select="@filename, tokenize(@other-versions)">
                <xsl:choose>
                    <xsl:when test="matches(., '-s1', 'i')">S1</xsl:when>
                    <xsl:when test="matches(., '-s2', 'i')">S2</xsl:when>
                    <xsl:when test="matches(., 'frankenberg', 'i')">Frkbg</xsl:when>
                    <xsl:when test="matches(., 'sinkewicz', 'i')">Sink</xsl:when>
                    <!-- 2436, 2437 -->
                    <xsl:when test="matches(., '2436.+joest', 'i')">Joest</xsl:when>
                    <xsl:when test="matches(., '2436.+gressmann', 'i')">Gress</xsl:when>
                    <!-- 2439 -->
                    <xsl:when test="matches(., '2439.+gribomont', 'i')">Grib</xsl:when>
                    <xsl:when test="matches(., '2439.+garnier', 'i')">Garn</xsl:when>
                    <xsl:when test="matches(., '2439.+erasmus', 'i')">Eras</xsl:when>
                    <xsl:when test="matches(., '2448.+a1', 'i')">A1</xsl:when>
                    <xsl:when test="matches(., '2448.+a2', 'i')">A2</xsl:when>
                    <xsl:when test="matches(., '(barb|paris)-gr', 'i')">{replace(., '^.+(barb|paris)-gr-(\d+).+$', '$1 gr $2')}</xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="''"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="html-folder" as="xs:string" select="'../../../' || ../@key"/>
        <xsl:variable name="single-edition-uri" as="xs:string" select="$html-folder || '/' || @filename || '.html#' || @ref"/>
        <xsl:variable name="collated-edition-uri" as="xs:string" select="$html-folder || '/' || ../@key || '-full-for-reading.html#' || @ref"/>
        
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">{string-join((@class, 'entry'), ' ')}</xsl:attribute>
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">ref</xsl:attribute>
                
                <xsl:value-of select="@ref || ' '"/>
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class">ver</xsl:attribute>
                    <xsl:value-of select="$version-identifier[1] || ' '"/>
                    <xsl:choose>
                        <xsl:when test="count($version-identifier) gt 1 and string-length($version-identifier[1]) eq 0">
                            <xsl:value-of select="'(' || (count($version-identifier)) || ' vers.)'"/>
                        </xsl:when>
                        <xsl:when test="count($version-identifier) gt 1">
                            <xsl:value-of select="'(+' || (count($version-identifier) - 1) || ')'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:apply-templates mode="#current"/>
            </xsl:element>
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">display</xsl:attribute>
                <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="href">{$single-edition-uri}</xsl:attribute>
                    <xsl:value-of select="'🗏'"/>
                </xsl:element>
                <xsl:if test="true() or unparsed-text-available(replace($collated-edition-uri, '^\.\./\.\./', ''))">
                    <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="href">{$collated-edition-uri}</xsl:attribute>
                        <xsl:value-of select="'🗐'"/>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:element>
        
    </xsl:template>
    <xsl:template match="work/div/text()" mode="create-html-index-files">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="span | a" mode="create-html-index-files">
        <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
        
    </xsl:template>
    
    
    <!-- GET GREEK LEMMAS -->
    
    <xsl:mode name="get-some-lemmas" on-no-match="shallow-skip"/>
    
    <xsl:template match="index[@xml:lang = 'grc']" mode="get-some-lemmas">
        <xsl:element name="xsl:map">
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
        
    </xsl:template>
    <xsl:template match="index[@xml:lang = 'grc']/letter[position() lt 270000]/entry[@key][not(@key = $lemma-keys.grc)]"
        mode="get-some-lemmas">
        <xsl:variable name="local-answer" as="element()*" select="tan:lm-data(@key, 'grc', true())"/>
        <xsl:variable name="morpheus-answer" as="document-node()?" select="tan:search-morpheus(@key)"/>
        
        <xsl:variable name="diagnostics-on" as="xs:boolean" select="@key eq 'ἑαυτοῦ'"/>
        
        <xsl:if test="$diagnostics-on">
            <xsl:message select="serialize(.)"/>
        </xsl:if>
        
        <xsl:element name="xsl:map-entry">
            <xsl:attribute name="key">'{@key}'</xsl:attribute>
            <xsl:attribute name="select">'{$morpheus-answer//dict/hdwd}'</xsl:attribute>
        </xsl:element>

    </xsl:template>
    
    
    
    
    <!-- CONTROLLING THE PROCESS -->
    
    <!-- TO DO Fr ankenberg, CPG 2440 and above. -->
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <diagnostics>
            <uris-of-interest-sorted count="{count($uris-of-interest-sorted)}">
                <xsl:for-each select="$uris-of-interest-sorted">
                    <uri>{.}</uri>
                </xsl:for-each>
            </uris-of-interest-sorted>
            <!--<files-of-interest-resolved><xsl:copy-of select="$files-of-interest-resolved[1]"/></files-of-interest-resolved>-->
            <!--<files-of-interest-tokenized><xsl:copy-of select="$files-of-interest-tokenized[1]"/></files-of-interest-tokenized>-->
            <xsl:copy-of select="tan:trim-long-tree($raw-index, 5, 10)"/>
            <most-common-entries>
                <!-- I want to know which lemmata have the greatest quantity in each language, to make sure I haven't
                captured overly common words. -->
                <xsl:for-each select="$raw-index/raw-index/index">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                    </xsl:copy>
                    <xsl:for-each select="letter/entry">
                        <xsl:sort select="xs:integer(@count)" order="descending"/>
                        <xsl:if test="position() lt 11">
                            <xsl:copy>
                                <xsl:copy-of select="@*"/>
                            </xsl:copy>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each> 
            </most-common-entries>
            <get-some-lemmas xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:apply-templates select="$raw-index" mode="get-some-lemmas"/>
            </get-some-lemmas>
        </diagnostics>
        
        
        <!--<xsl:apply-templates select="$raw-index" mode="catalyze-html-index-files"/>-->
    </xsl:template>
    

    
</xsl:stylesheet>