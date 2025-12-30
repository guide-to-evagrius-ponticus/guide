<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
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
    
    <!-- When you run this stylesheet, it will produce diagnostics that are very important.
        Words for which lemmas are not defined will be searched through local or online 
        databases for a lemma. These need to be manually inspected. Sometimes a stopword 
        needs to be introduced. Sometimes there's a typo in the source text that needs to 
        be fixed. Sometimes the lemmas-*.xsl file needs to be updated. That's normally the
        case, and it's set up so that you can simply correct/update output xsl:map-entry 
        elements, then paste them into the relevant lemmas-*.xsl file. There is a helper
        stylesheet, re-sort-files.xsl, which takes a long lemmas file and re-alphabetizes
        the lemma entries. So you can paste new entries at the end of the lemmas, file,
        then re-sort as needed.
        When you do a run, edit the lemmas, then re-run, you'll still get items back, mainly
        to make sure the lemmas themselves have lemmas.
    -->
    
    <!-- To check:
        
        To do: 
        Why isn't nocpg11 showing up in the results?
        
        Proofread Greek from Frankenberg's edition of the Letters and Antirrhetikos, then make an 
        attempt to include Frankenberg in the index.
    -->
    
    <xsl:include href="../../TAN/TAN-2022/functions/TAN-function-library.xsl"/>
    <xsl:include href="index-resources/lemmas.xsl"/>
    
    <!-- What is the minimum length of a letter entry? -->
    <xsl:param name="greek-letter-entry-length-min" as="xs:integer" select="2"/>
    
    <!-- What is the maximum size of a letter group? -->
    <xsl:param name="letter-entry-size-max" as="xs:integer" select="80"/>
    
    <!-- What percentage of commonality should determine whether to group texts in the same reading? -->
    <xsl:param name="text-cluster-commonality-minimum" as="xs:decimal" select="0.7"/>
    
    <xsl:variable name="stopwords" as="document-node()" select="doc('index-resources/stopwords.xml')"/>
    
    <xsl:variable name="gep-template" as="document-node()" select="doc('../templates/template.html')"/>
    <xsl:variable name="gep-work-vocabulary" as="document-node()" select="doc('../tan/TAN-voc/evagrius-works-TAN-voc.xml')"/>
    
    <xsl:variable name="TAN-library-uris" as="xs:anyURI*" select="uri-collection('../TAN?recurse=yes')"/>
    
    
    <!-- 'cpg24\d[0-9]\.eng'  \.grc| -->
    <!-- \.(eng|grc) -->
    <xsl:param name="TAN-uris-must-match" as="xs:string?" select="'\.(eng|grc)'"/>
    
    <!-- We ignore specific versions, e.g., Joest (identical with Gressmann, who does not use the 
        standard reference system), Frankenberg (something in the future), Vat. Gr. 754 (imperfect
        transcription of imperfect manuscript, superseded by critical edition), logical form of the
        PG (preferring another version with the modern reference system).
        Ignore the letter from Loukios.
        The 2025 edition of the letters supersedes the 20th c. studies, but Mai's 1837 fragment was
        not included.
    -->
    <xsl:param name="TAN-uris-must-not-match" as="xs:string?" 
        select="'TAN-A|franken|scriptum|vat_gr_754|1858\.pg\.ref-logical|243[56].+joest|nocpg01|
        cpg2437.*grc\.19\d\d|do_not_release|%20Copy'"/>
    
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
            <!-- Put the more recent versions first -->
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
    
    
    
    <xsl:function name="gep:lang-name" as="xs:string">
        <!-- Input: the input for tan:lang-name -->
        <!-- Output: the output from tan:lang-name, but adjusted according to GEP specs -->
        <xsl:param name="lang-code" as="xs:string"/>
        <xsl:sequence select="tan:lang-name($lang-code) => replace('\([^\)]+\)', '') => normalize-space()"/>
    </xsl:function>
    
    <xsl:function name="gep:string-base" as="xs:string">
        <!-- Input: input for tan:base-string -->
        <!-- Output: output from tan:base-string, slightly adjusted -->
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:sequence select="tan:string-base($arg) => replace('ς', 'σ')"/>
    </xsl:function>
    
    
    <xsl:function name="gep:string-clusters" as="xs:integer*">
        <!-- Input: a sequence of strings, a decimal from 0 through 1 -->
        <!-- Output: a sequence of integers, one for each string, identifying the cluster it belongs to, based on
            string differencing, and a percentage in common that meets or exceeds the second parameter. -->
        <!-- Results are greedy. A string is put in the first group with the string that best matches, and is above
            the minimum threshold. -->
        <xsl:param name="string-sequence" as="xs:string*"/>
        <xsl:param name="commonality-minimum" as="xs:decimal"/>
        
        <xsl:variable name="diagnostics-on" as="xs:boolean" select="contains($string-sequence[1], 'replacemewithsometext')"/>
        
        <xsl:variable name="first-group" as="element()">
            <group n="1">
                <text n="1">{$string-sequence[1]}</text>
            </group>
        </xsl:variable>
        <xsl:variable name="pass-1" as="element()">
            <pass-1>
                <xsl:iterate select="tail($string-sequence)">
                    <xsl:param name="results-so-far" as="element()+" select="$first-group"/>
                    <xsl:param name="current-pos" as="xs:integer" select="2"/>
                    
                    <xsl:on-completion select="$results-so-far"/>
                    
                    <xsl:variable name="string-to-place" as="xs:string" select="."/>
                    <xsl:variable name="string-to-place-length" as="xs:integer" select="string-length(.)"/>
                    
                    <xsl:variable name="best-curr-group-number" as="xs:integer?">
                        <xsl:for-each-group select="$results-so-far/text" group-by="
                                let $d := tan:diff(., $string-to-place, true()),
                                    $len := avg((string-length(.), $string-to-place-length))
                                return
                                    (string-length(string-join($d/tan:common)) div $len)">
                            <xsl:sort select="current-grouping-key()" order="descending"/>
                            <xsl:if test="$diagnostics-on">
                                <xsl:message>string {$current-pos}, diff% {current-grouping-key()}</xsl:message>
                            </xsl:if>
                            <xsl:if
                                test="position() eq 1 and current-grouping-key() ge $commonality-minimum">
                                <xsl:sequence
                                    select="current-group()[1]/parent::group/@n => xs:integer()"/>
                            </xsl:if>
                        </xsl:for-each-group>
                    </xsl:variable>
                    <xsl:variable name="best-group-number" as="xs:integer"
                        select="($best-curr-group-number, count($results-so-far) + 1)[1]"/>
                    
                    <xsl:variable name="new-groups" as="element()+">
                        <xsl:sequence select="$results-so-far[position() lt $best-group-number]"/>
                        <group n="{$best-group-number}">
                            <xsl:copy-of select="$results-so-far[position() eq $best-group-number]/*"/>
                            <text n="{$current-pos}">{$string-to-place}</text>
                        </group>
                        <xsl:sequence select="$results-so-far[position() gt $best-group-number]"/>
                    </xsl:variable>
                    
                    <xsl:if test="$diagnostics-on">
                        <xsl:message select="'results so far: ' || serialize($results-so-far)"/>
                        <xsl:message select="'new groups: ' || serialize($new-groups)"/>
                    </xsl:if>
                    
                    <xsl:next-iteration>
                        <xsl:with-param name="results-so-far" select="$new-groups"/>
                        <xsl:with-param name="current-pos" select="$current-pos + 1"/>
                    </xsl:next-iteration>
                    
                </xsl:iterate>
            </pass-1>
        </xsl:variable>
        
        <xsl:if test="$diagnostics-on">
            <xsl:message>pass 1: {serialize($pass-1)}</xsl:message>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="count($string-sequence) eq 1">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:when test="count($string-sequence) gt 1">
                <xsl:for-each select="1 to count($string-sequence)">
                    <xsl:variable name="this-pos" as="xs:string" select="string(.)"/>
                    <xsl:if test="$diagnostics-on">
                        <xsl:message>function results pos {$this-pos}: {$pass-1/group[text/@n = $this-pos]/@n}</xsl:message>
                    </xsl:if>
                    <xsl:sequence select="$pass-1/group[text/@n = $this-pos]/@n => xs:integer()"/>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
        
    </xsl:function>
    
    
    <xsl:mode name="simple-normalize-and-tokenize" on-no-match="shallow-copy"/>
    
    <xsl:template match="@xml:lang[. eq 'en']" mode="simple-normalize-and-tokenize">
        <xsl:attribute name="xml:lang" select="'eng'"/>
    </xsl:template>
    
    <xsl:template match="@n[. eq 'pr']" mode="simple-normalize-and-tokenize">
        <xsl:attribute name="n" select="'pref'"/>
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
        <replace pattern="(δυσ|δυσκί|ἐκ|ἐνα|λαν|λογι|πράγ|σύμβο|συνέστη|χρώ|χω)-\s*" replacement="$1"/>
        <replace pattern="(ἀπαγγ|κρί|ἐστε)\[" replacement="$1"/>
        <replace pattern="[··]" replacement="&#x200a;·"/>
    </xsl:variable>
    
    <!-- ignore lemmas from the Bible -->
    <xsl:template match="*:div[@type = 'psalm']/*:div[@type = 'verse'] | *:div[@n = ('prov', 'eccl')]/*:div[@type = 'chapter']"
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
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:analyze-string select="$simple-text-norm" regex="\[[a-zA-Z]\]">
                <!-- Ignore letter labels in square brackets -->
                <xsl:matching-substring>
                    <x>{.}</x>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="." regex="{$lang-regex}">
                        <xsl:matching-substring>
                            <xsl:variable name="tok-adjusted" as="xs:string" select="tan:batch-replace(., $token-batch-replacements)"/>
                            <xsl:variable name="is-stopword" as="xs:boolean"
                                select="lower-case(normalize-unicode($tok-adjusted)) = $stopwords/stopwords/group[@xml:lang = $language-norm]/w"
                            />
                            <xsl:variable name="first-char" as="xs:string" select="gep:string-base(lower-case(substring($tok-adjusted, 1, 1)))"/>
                            <xsl:variable name="ad-hoc-check-is-ok" as="xs:boolean" select="true()"/>
                            <xsl:variable name="string-checked" as="xs:string?" select="
                                    if ($is-stopword or not($ad-hoc-check-is-ok)) then
                                        ()
                                    else
                                        gep:lemmas($tok-adjusted, $this-div, $language)"
                            />
                            <tok>
                                <xsl:if test="string-length($string-checked) gt 0">
                                    <xsl:attribute name="lemma" select="$string-checked"/>
                                </xsl:if>
                                <xsl:value-of select="$tok-adjusted"/>
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
    
    <xsl:variable name="token-batch-replacements" as="element()*">
        <replace pattern="[᾽᾿]" replacement="'"/>
    </xsl:variable>
    
    <xsl:function name="gep:build-letter-groups" as="element()*" visibility="private">
        <!-- Input: tok elements, with @lemma for the identified lemma -->
        <!-- Output: <letter> specifying a sequence of letters and a number of toks in that group -->
        <xsl:param name="tok-elements" as="element(tok)*"/>
        <xsl:param name="curr-string-length" as="xs:integer"/>
        
        <xsl:for-each-group select="$tok-elements[@lemma]" group-by="gep:string-base(lower-case(substring(@lemma, 1, $curr-string-length)))">
            <xsl:sort select="current-grouping-key()"/>
            
            <xsl:variable name="distinct-entries" as="xs:string+" select="distinct-values(current-group()/@lemma)"/>
            <xsl:choose>
                <xsl:when test="count($distinct-entries) lt $letter-entry-size-max">
                    <letter key="{current-grouping-key()}" entry-count="{count($distinct-entries)}" tok-count="{count(current-group())}"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence
                        select="gep:build-letter-groups(current-group(), $curr-string-length + 1)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group> 
    </xsl:function>
    
    <xsl:variable name="letter-groups" as="element()">
        <letter-groups>
            <xsl:for-each-group select="$files-of-interest-tokenized//tok[@lemma]" group-by="ancestor::*[@xml:lang][1]/@xml:lang">
                <lang key="{current-grouping-key()}" count="{count(current-group())}">
                    <xsl:copy-of select="gep:build-letter-groups(current-group(), 1)"/>
                </lang>
            </xsl:for-each-group> 
        </letter-groups>
    </xsl:variable>
    
    <xsl:variable name="ref-map" as="map(*)">
        <xsl:map>
            <xsl:map-entry key="'pr'" select="-1"/>
            <xsl:map-entry key="'pref'" select="-1"/>
            <xsl:map-entry key="'ti'" select="0"/>
            <xsl:map-entry key="'title'" select="0"/>
            <xsl:map-entry key="'pref_title'" select="0"/>
            <xsl:map-entry key="'sch'" select="0"/>
            <xsl:map-entry key="'head_1'" select="5.5"/>
            <xsl:map-entry key="'head_2'" select="14.5"/>
            <xsl:map-entry key="'head_3'" select="33.5"/>
            <xsl:map-entry key="'head_4'" select="39.5"/>
            <xsl:map-entry key="'head_5'" select="53.5"/>
            <xsl:map-entry key="'head_6'" select="56.5"/>
            <xsl:map-entry key="'head_7'" select="62.5"/>
            <xsl:map-entry key="'head_8'" select="70.5"/>
            <xsl:map-entry key="'head_9'" select="90.5"/>
            <xsl:map-entry key="'head_10'" select="999"/>
            <xsl:map-entry key="'app_1'" select="999"/>
            <xsl:map-entry key="'app_2'" select="999"/>
            <xsl:map-entry key="'app_3'" select="999"/>
            <xsl:map-entry key="'supp_1'" select="999"/>
            <xsl:map-entry key="'supp_2'" select="999"/>
            <xsl:map-entry key="'125_suppl_f3'" select="999"/>
            <xsl:map-entry key="'conclusion'" select="999"/>
            <xsl:map-entry key="'ep'" select="999"/>
            <xsl:map-entry key="'epilogue'" select="999"/>
            <xsl:map-entry key="'ep1'" select="1000"/>
            <xsl:map-entry key="'ep2'" select="1001"/>
        </xsl:map>
    </xsl:variable>
    
    <xsl:function name="gep:ref-sort-order" visibility="private" as="xs:decimal">
        <!-- Input: a string -->
        <!-- Output: the sort order for the string, interpreted as a canonical ref to 
            one of Evagrius's work -->
        <xsl:param name="ref" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="not(exists($ref))">
                <xsl:sequence select="9999999"/>
            </xsl:when>
            <xsl:when test="$ref castable as xs:decimal">
                <xsl:sequence select="xs:decimal($ref)"/>
            </xsl:when>
            <xsl:when test="map:contains($ref-map, $ref)">
                <xsl:sequence select="$ref-map($ref)"/>
            </xsl:when>
            <xsl:when test="matches($ref, '\d#\d')">
                <xsl:analyze-string select="$ref" regex="\d+#\d+">
                    <xsl:matching-substring>
                        <xsl:sequence select="xs:decimal(replace(., '#', '.'))"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($ref, 'sch(\+?)\d')">
                <xsl:analyze-string select="$ref" regex="sch(\+?)(\d+)([a-z]*)">
                    <xsl:matching-substring>
                        <xsl:variable name="last-int" as="xs:integer?" select="tan:letter-to-number(regex-group(3))"/>
                        <xsl:sequence select="xs:decimal(regex-group(2)) + ($last-int div 100)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($ref, '\d')">
                <xsl:variable name="first-digit" as="xs:string" select="replace($ref, '^\D*(\d+).*$', '$1')"/>
                <xsl:message>Taking first digit from {$ref} as sort order.</xsl:message>
                <xsl:sequence select="xs:decimal($first-digit)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Order for {$ref} undefined</xsl:message>
                <xsl:sequence select="9999999"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:variable name="raw-index" as="document-node()">
        <xsl:document>
            <raw-index>
                <!-- Group by language -->
                <xsl:for-each-group select="$files-of-interest-tokenized//div[not(*:div)]" group-by="ancestor-or-self::*[@xml:lang][1]/@xml:lang">
                    <xsl:variable name="this-lang" as="xs:string" select="current-grouping-key()"/>

                    <index xml:lang="{$this-lang}" count="{count(current-group())}">
                        <!-- Group by first "letter" -->
                        <xsl:for-each-group select="current-group()/tok[@lemma]" group-by="
                                let $this := gep:string-base(lower-case(@lemma))
                                return
                                    $letter-groups/lang[@key = $this-lang]/letter[starts-with($this, @key)][last()]/@key">
                            <xsl:sort select="current-grouping-key()"/>

                            <letter key="{current-grouping-key()}" count="{count(current-group())}">
                                <!-- Then sort by lemma (dictionary entry word) -->
                                <xsl:for-each-group select="current-group()" group-by="@lemma">
                                    <xsl:sort
                                        select="gep:string-base(lower-case(current-grouping-key()))"/>

                                    <entry key="{current-grouping-key()}"
                                        count="{count(current-group())}">
                                        
                                        <!-- Then group by work -->
                                        <xsl:for-each-group select="current-group()"
                                            group-by="tokenize(base-uri(), '/')[position() = (last() - 1)]">
                                            <work key="{current-grouping-key()}"
                                                count="{count(current-group())}">
                                                
                                                <!-- Then group by canonical reference -->
                                                <xsl:for-each-group select="current-group()" composite="yes"
                                                  group-by="ancestor::*[not(@type = 'variant')]/@n">
                                                    <!-- Sort references, dealing with anomalies -->
                                                    <xsl:sort select="gep:ref-sort-order(current-grouping-key()[1])"
                                                  />
                                                    <xsl:sort select="gep:ref-sort-order(current-grouping-key()[2])"
                                                  />
                                                  
                                                  <xsl:variable name="this-ref" as="xs:string"
                                                  select="string-join(current-grouping-key(), '.')"/>
                                                    
                                                  <xsl:variable name="strings-to-compare" as="xs:string+">
                                                      <xsl:for-each select="current-group()">
                                                  <xsl:sequence select="
                                                                    string-join((
                                                                    preceding-sibling::tok[3],
                                                                    preceding-sibling::tok[2],
                                                                    preceding-sibling::tok[1],
                                                                    .,
                                                                    following-sibling::tok[1],
                                                                    following-sibling::tok[2],
                                                                    following-sibling::tok[3]
                                                                    ), ' ')
                                                                    => gep:string-base() => lower-case()"
                                                  />
                                                      </xsl:for-each>
                                                  </xsl:variable>
                                                    
                                                  <xsl:variable name="cluster-group-numbers"
                                                  as="xs:integer+"
                                                  select="gep:string-clusters($strings-to-compare, $text-cluster-commonality-minimum)"
                                                  />
                                                    
                                                    <!-- Then group by commonality cluster -->
                                                  <xsl:for-each-group select="current-group()" group-by="let $p := position() return
                                                      $cluster-group-numbers[$p]">
                                                      
                                                      <!-- Then group by identity -->
                                                  <xsl:for-each-group select="current-group()"
                                                  group-by="
                                                                let $st := preceding-sibling::tok[$KWIC-length + 1],
                                                                    $en := following-sibling::tok[$KWIC-length + 1]
                                                                return
                                                                    string-join((
                                                                    preceding-sibling::tok[@lemma][not(exists($st)) or (. >> $st)],
                                                                    .,
                                                                    following-sibling::tok[@lemma][not(exists($st)) or ($en >> .)]
                                                                    ), ' ')
                                                                    => gep:string-base() => lower-case()">

                                                  <xsl:apply-templates select="current-group()[1]"
                                                  mode="build-KWIC">
                                                  <xsl:with-param name="ref" tunnel="yes"
                                                  select="$this-ref"/>
                                                  <xsl:with-param name="other-versions" tunnel="yes"
                                                  select="current-group()[position() gt 1]"/>
                                                  <xsl:with-param name="lang" tunnel="yes"
                                                  select="$this-lang"/>
                                                  <xsl:with-param name="version-priority"
                                                  tunnel="yes" select="position()"/>

                                                  </xsl:apply-templates>
                                                  </xsl:for-each-group>
                                                      
                                                      
                                                      
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
        <xsl:param name="other-versions" tunnel="yes" as="element()*"/>
        <xsl:param name="version-priority" tunnel="yes" as="xs:integer"/>
        <xsl:param name="ref" tunnel="yes" as="xs:string" select="string-join(ancestor::*/@n, '.')"/>
        
        <xsl:variable name="curr-pos" as="xs:integer" select="count(preceding-sibling::tok) + 1"/>
        <xsl:variable name="KWIC-start" as="element()?" select="../tok[position() eq ($curr-pos - $KWIC-length)]/preceding-sibling::*[1]"/>
        <xsl:variable name="KWIC-end" as="element()?" select="../tok[position() eq ($curr-pos + $KWIC-length)]/following-sibling::*[1]"/>
        <xsl:variable name="is-variant" as="xs:boolean?" select="$version-priority gt 1"/>
        
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
        <xsl:param name="lang" tunnel="yes" as="xs:string" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
        <xsl:variable name="this-lem-norm" as="xs:string" select="gep:string-base(lower-case(@lemma))"/>
        <span>
            <xsl:attribute name="class">xref</xsl:attribute>
            <a href="{$letter-groups/lang[@key = $lang]/letter[starts-with($this-lem-norm, @key)][last()]/@key}.html#{@lemma}">
                <xsl:value-of select="."/>
            </a>
        </span>
    </xsl:template>
    
    
    
    
    
    <!-- OUTPUT -->
    
    <xsl:variable name="all-nav-banners" as="element()+">
        <xsl:apply-templates select="$letter-groups" mode="nav-banner"/>
    </xsl:variable>
    
    <xsl:mode name="nav-banner" on-no-match="shallow-skip"/>
    
    <xsl:template match="lang" mode="nav-banner">
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">nav-banner</xsl:attribute>
            <xsl:attribute name="lang" select="@key"/>
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="href" select="'index.html'"/>
                    <xsl:text>🛈</xsl:text>
                </xsl:element>
            </xsl:element>
            <xsl:for-each-group select="letter" group-by="substring(@key, 1, 2)">
                <xsl:choose>
                    <xsl:when test="count(current-group()) eq 1">
                        <xsl:apply-templates select="current-group()" mode="#current"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:attribute name="class">stub closed</xsl:attribute>
                                <xsl:text>{current-grouping-key()}</xsl:text>
                            </xsl:element>
                            <xsl:apply-templates select="current-group()" mode="#current"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group> 
        </xsl:element>
    </xsl:template>
    <xsl:template match="letter/@key" mode="nav-banner">
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">letter</xsl:attribute>
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="href">{.}.html</xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    
    
    
    
    <xsl:mode name="catalyze-html-index-files" on-no-match="shallow-skip"/>
    <xsl:mode name="create-html-index-index" on-no-match="shallow-copy"/>
    <xsl:mode name="create-html-index-index-content" on-no-match="shallow-skip"/>
    <xsl:mode name="create-html-index-files" on-no-match="shallow-copy"/>
    <xsl:mode name="create-html-stopword-index" on-no-match="shallow-copy"/>
    
    <xsl:template match="raw-index" mode="catalyze-html-index-files">
        <xsl:variable name="this-url" as="xs:string" select="'../index/index.html'"/>
        
        <xsl:result-document href="{$this-url}" method="html">
            <xsl:apply-templates select="$gep-template" mode="create-html-index-index"/>
        </xsl:result-document>
        
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    
    <xsl:template match="html:div[@id = 'content']" mode="create-html-index-index">
        <xsl:element name="h1" namespace="http://www.w3.org/1999/xhtml">Word Indexes</xsl:element>
        <xsl:apply-templates select="$raw-index" mode="create-html-index-index-content"/>
    </xsl:template>
    
    <xsl:template match="index/@xml:lang" mode="create-html-index-index-content">
        <xsl:variable name="lang-name" as="xs:string" select="gep:lang-name(.)"/>
        <xsl:element name="h2" namespace="http://www.w3.org/1999/xhtml">
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="href">word/{.}/index.html</xsl:attribute>
                <xsl:text>{$lang-name} Word Index</xsl:text>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="stopwords/group" mode="catalyze-html-index-files">
        <xsl:variable name="this-lang" as="xs:string" select="@xml:lang"/>
        <xsl:variable name="this-lang-name" as="xs:string" select="gep:lang-name($this-lang)"/>
        <xsl:variable name="this-url" as="xs:string" select="'../index/word/' || $this-lang || '/stopwords.html'"/>
        
        <xsl:result-document href="{$this-url}" method="html">
            <xsl:apply-templates select="$gep-template" mode="create-html-stopword-index">
                <xsl:with-param name="stopwords" tunnel="yes" select="."/>
            </xsl:apply-templates>
        </xsl:result-document>
        
    </xsl:template>
    
    
    
    
    <xsl:template match="raw-index/index" mode="catalyze-html-index-files">
        <xsl:variable name="this-lang" as="xs:string" select="@xml:lang"/>
        <xsl:variable name="this-url" as="xs:string" select="'../index/word/' || $this-lang || '/index.html'"/>
        
        <xsl:result-document href="{$this-url}" method="html">
            <xsl:apply-templates select="$gep-template" mode="create-html-index-files">
                <xsl:with-param name="nav-banner" tunnel="yes" select="$all-nav-banners[@lang = $this-lang]"/>
            </xsl:apply-templates>
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
                <xsl:with-param name="nav-banner" tunnel="yes" select="$all-nav-banners[@lang = $this-lang]"/>
            </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="html:div[@class eq 'nav-banner']//@href" 
        mode="create-html-index-files create-html-stopword-index" priority="1">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="@src | @href" mode="create-html-index-files create-html-stopword-index">
        <xsl:attribute name="{name(.)}" select="'../../' || ."/>
    </xsl:template>
    
    <xsl:template match="html:head/html:link[@rel = 'stylesheet'][last()]" mode="create-html-index-files create-html-stopword-index">
        <xsl:next-match/>
        <xsl:element name="link" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="rel">stylesheet</xsl:attribute>
            <xsl:attribute name="type">text/css</xsl:attribute>
            <xsl:attribute name="href">../../../css/indexes.css</xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    <xsl:variable name="snippets" as="document-node()" select="doc('index-resources/word-index-snippets.xhtml')"/>
    <xsl:template match="html:div[@id = 'content']" mode="create-html-index-files">
        <xsl:param name="nav-banner" tunnel="yes" as="element()"/>
        <xsl:param name="letter-data" tunnel="yes" as="element()?"/>
        
        <xsl:variable name="language-name" as="xs:string" select="gep:lang-name($nav-banner/@lang)"/>
        <xsl:if test="not(exists($letter-data))">
            
            <xsl:apply-templates select="$snippets/html:html/html:body/*" mode="word-index-snippets">
                <xsl:with-param name="language-code" tunnel="yes" select="$nav-banner/@lang"/>
            </xsl:apply-templates>
        </xsl:if>
        
        <xsl:apply-templates select="$nav-banner" mode="#current">
            <xsl:with-param name="curr-letter" tunnel="yes" select="$letter-data/@key"/>
            <xsl:with-param name="prev-letter" tunnel="yes" select="$letter-data/preceding-sibling::*[1]/@key"/>
            <xsl:with-param name="next-letter" tunnel="yes" select="$letter-data/following-sibling::*[1]/@key"/>
        </xsl:apply-templates>
        
        <xsl:if test="exists($letter-data)">
            <xsl:element name="h2" namespace="http://www.w3.org/1999/xhtml">{$letter-data/@key}</xsl:element>
            
            <!-- Create a quick list of lemmas, for easy navigation -->
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class" select="'lemma-list'"/>
                <xsl:for-each select="$letter-data/entry">
                    <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                        <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="href" select="'#' || @key"/>
                            <xsl:value-of select="@key"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
            
            <!-- Here comes the good stuff. -->
            <xsl:apply-templates select="$letter-data/*" mode="#current"/>
            
            <xsl:apply-templates select="$nav-banner" mode="#current">
                <xsl:with-param name="curr-letter" tunnel="yes" select="$letter-data/@key"/>
                <xsl:with-param name="prev-letter" tunnel="yes" select="$letter-data/preceding-sibling::*[1]/@key"/>
                <xsl:with-param name="next-letter" tunnel="yes" select="$letter-data/following-sibling::*[1]/@key"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    
    <xsl:mode name="word-index-snippets" on-no-match="shallow-copy"/>
    
    <xsl:template match="*" priority="2" mode="word-index-snippets">
        <xsl:param name="language-code" tunnel="yes" as="xs:string+"/>
        <xsl:if test="not(exists(@class)) or contains-token(@class, $language-code)">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="text()[contains(., '{')]" mode="word-index-snippets">
        <xsl:param name="language-code" tunnel="yes" as="xs:string+"/>
        <xsl:variable name="language-name" as="xs:string" select="gep:lang-name($language-code)"/>
        
        <xsl:analyze-string select="." regex="\{{\$language-name\}}">
            <xsl:matching-substring>
                <xsl:value-of select="$language-name"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    

    <xsl:template match="html:div[@class eq 'nav-banner']" mode="create-html-index-files">
        <xsl:param name="prev-letter" tunnel="yes" as="xs:string?"/>
        <xsl:param name="next-letter" tunnel="yes" as="xs:string?"/>
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">nav-prev</xsl:attribute>
                <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="href">{$prev-letter}.html</xsl:attribute>
                    <xsl:text>{$prev-letter}</xsl:text>
                </xsl:element>
            </xsl:element>
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">nav-next</xsl:attribute>
                <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="href">{$next-letter}.html</xsl:attribute>
                    <xsl:text>{$next-letter}</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="@class[. eq 'stub closed']" mode="create-html-index-files">
        <xsl:param name="curr-letter" tunnel="yes" as="xs:string?"/>
        <xsl:variable name="this-stub" as="element()" select="parent::*"/>
        <xsl:choose>
            <xsl:when test="starts-with($curr-letter, $this-stub)">
                <xsl:attribute name="class" select="'stub open'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="html:div/@class[. = 'letter']" mode="create-html-index-files">
        <xsl:param name="curr-letter" tunnel="yes" as="xs:string?"/>
        <xsl:variable name="this-letter" as="element()" select="parent::*"/>
        <xsl:choose>
            <xsl:when test="$this-letter eq $curr-letter">
                <xsl:attribute name="class">letter current</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="index[@xml:lang = 'eng']/letter/entry" mode="create-html-index-files">
        <!--<xsl:variable name="best-keyword" as="xs:string">
            <!-\- In English, we take the best keyword as the most common one. -\->
            <xsl:for-each-group select="descendant::span[@class = 'kw']" group-by=".">
                <!-\- Prefer lowercase to uppercase -\->
                <xsl:sort select="current-grouping-key()" order="descending"/>
                <!-\- Take the most common form of the keyword -\->
                <xsl:sort select="count(current-group())" order="descending"/>
                <xsl:if test="position() eq 1">
                    <xsl:value-of select="current-group()[1]"/>
                </xsl:if>
            </xsl:for-each-group> 
        </xsl:variable>-->
        <xsl:variable name="best-keyword" as="xs:string" select="@key"/>
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
        <xsl:variable name="best-name" as="xs:string?" 
            select="$gep-work-vocabulary//tan:item[tan:name = $this-cpg-no]/tan:name[1]"/>
        <xsl:if test="not(exists($best-name))">
            <xsl:message>No. {$this-cpg-no} has no best name in the GEP work vocabulary</xsl:message>
        </xsl:if>
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">work {$this-cpg-no}</xsl:attribute>
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
                    <xsl:when test="matches(., '243[56].+joest', 'i')">Joest</xsl:when>
                    <xsl:when test="matches(., '243[56].+gressmann', 'i')">Gress</xsl:when>
                    <!-- 2439 -->
                    <xsl:when test="matches(., '2439.+gribomont', 'i')">Grib</xsl:when>
                    <xsl:when test="matches(., '2439.+garnier', 'i')">Garn</xsl:when>
                    <xsl:when test="matches(., '2439.+erasmus', 'i')">Eras</xsl:when>
                    <xsl:when test="matches(., '2448.+a1', 'i')">A1</xsl:when>
                    <xsl:when test="matches(., '2448.+a2', 'i')">A2</xsl:when>
                    <xsl:when test="matches(., '(barb|paris)-gr', 'i')">{replace(., '^.+(barb|paris)-gr-(\d+).+$', '$1 gr $2')}</xsl:when>
                    <!-- 2452 -->
                    <xsl:when test="matches(., '2452.+1863', 'i')">PG</xsl:when>
                    <xsl:when test="matches(., '\d\.pg', 'i')">PG</xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="''"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="html-folder" as="xs:string" select="'../../../' || ../@key"/>
        <xsl:variable name="single-edition-uri" as="xs:string" select="$html-folder || '/' || @filename || '.html#' || @ref"/>
        <xsl:variable name="collated-edition-uri" as="xs:string" select="$html-folder || '/' || ../@key || '-full-for-reading.html#' || @ref"/>
        <xsl:variable name="local-collated-edition-uri" as="xs:string"
            select="('../' || ../@key || '/' || ../@key || '-full-for-reading.html') => resolve-uri()"/>
        
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
                <xsl:choose>
                    <xsl:when test="unparsed-text-available($local-collated-edition-uri)">
                        <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="href">{$collated-edition-uri}</xsl:attribute>
                            <xsl:value-of select="'🗐'"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
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
    
    <xsl:template match="html:div[@id = 'content']" mode="create-html-stopword-index">
        <xsl:param name="stopwords" tunnel="yes" as="element()"/>
        
        <xsl:element name="h2" namespace="http://www.w3.org/1999/xhtml">Stopwords</xsl:element>
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">The following words have been omitted
            in the results of the {gep:lang-name($stopwords/@xml:lang)} word index: </xsl:element>
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="$stopwords/*" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="group/w" mode="create-html-stopword-index">
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
        <xsl:text>&#xa;</xsl:text>
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
            <xsl:copy-of select="$letter-groups"/>
            <nav-banners>
                <xsl:copy-of select="$all-nav-banners"/>
            </nav-banners>
            <xsl:copy-of select="tan:trim-long-tree($raw-index, 20, 40)"/>
            <unique-vocabulary>
                <!-- Find words that are attested in only one of his works, and no others, useful for
                    authorship questions, esp. 6583. -->
                <xsl:for-each-group select="
                        $raw-index/index[@xml:lang='grc']//entry[not(work[2])
                        or (every $i in work
                            satisfies ($i/@key = ('cpg6583a', 'cpg6583b')))]"
                    group-by="work[1]/@key">
                    <xsl:sort select="current-grouping-key()"/>
                    <work key="{current-grouping-key()}" count="{count(current-group())}">
                        <xsl:copy-of select="current-group()"/>
                    </work>
                </xsl:for-each-group> 
                
                <xsl:copy-of select="$raw-index//entry[not(work[2])]"/>
            </unique-vocabulary>
            <!--<most-common-entries>
                <!-\- I want to know which lemmata have the greatest quantity in each language, to make sure I haven't
                captured overly common words. -\->
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
            </most-common-entries>-->
            <get-some-lemmas xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:apply-templates select="$raw-index" mode="get-some-lemmas"/>
            </get-some-lemmas>
        </diagnostics>
        
        
        <xsl:apply-templates select="$raw-index" mode="catalyze-html-index-files"/>
        <xsl:apply-templates select="$stopwords" mode="catalyze-html-index-files"/>
    </xsl:template>
    

    
</xsl:stylesheet>