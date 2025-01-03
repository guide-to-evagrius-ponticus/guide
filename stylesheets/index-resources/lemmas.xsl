<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:gep="https://evagriusponticus.net" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:tan="tag:textalign.net,2015:ns" exclude-result-prefixes="#all" expand-text="true"
    version="3.0">

    <!-- This stylesheet is exclusively for the function lemmas, to convert
        word tokens in the Guide to Evagrius Ponticus to a lemma. -->
    <!-- Primary (catalyzing) input: any XML file, including this one -->
    <!-- Secondary input: none -->
    <!-- Primary output: none -->
    <!-- Secondary output: none -->

    <xsl:include href="lemmas-grc.xsl"/>
    <xsl:include href="lemmas-eng.xsl"/>


    <xsl:function name="gep:lemmas" as="xs:string">
        <!-- Input: a string representing a word token, the <div> in which the token appears, and a language code -->
        <!-- Output: the lemma for that word, if known (otherwise the input is returned lowercase) -->
        <xsl:param name="word-token" as="xs:string"/>
        <xsl:param name="div-context" as="element()"/>
        <xsl:param name="language" as="xs:string"/>

        <xsl:variable name="word-token-norm" as="xs:string" select="normalize-unicode($word-token)"/>

        <xsl:variable name="diagnostics-on" select="false()"/>
        
        <xsl:variable name="keyword" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$language = ('eng', 'en') and ($word-token-norm = $lemma-keys.eng)">
                    <xsl:sequence select="$word-token-norm"/>
                </xsl:when>
                <xsl:when test="$language = ('eng', 'en') and (lower-case($word-token-norm) = $lemma-keys.eng)">
                    <xsl:sequence select="lower-case($word-token-norm)"/>
                </xsl:when>
                <xsl:when test="$language = ('eng', 'en') and matches($word-token-norm, '(s|ed|er|ing|eth|est)$')">
                    <xsl:variable name="keyword-no-suffix-1" as="xs:string" select="
                            replace(lower-case($word-token-norm), '(s|d|r|ing|eth|est)$', '')"/>
                    <xsl:variable name="keyword-no-suffix-2" as="xs:string" select="
                            replace($keyword-no-suffix-1, 'e$', '')"/>
                    <xsl:variable name="keyword-no-suffix-3" as="xs:string" select="
                            replace($word-token-norm, 'ing$', 'e')"/>
                    <xsl:variable name="keyword-no-suffix-4" as="xs:string" select="
                            replace($word-token-norm, 'ie(s|d)$', 'y')"/>
                    <xsl:variable name="keyword-no-suffix-5" as="xs:string" select="
                            replace($word-token-norm, '([a-z])\1(ing|ed)$', '$1')"/>
                    <xsl:variable name="first-keyword" as="xs:string?"
                        select="($keyword-no-suffix-1, $keyword-no-suffix-2, $keyword-no-suffix-3, 
                        $keyword-no-suffix-4, $keyword-no-suffix-5)[. = $lemma-keys.eng][1]"
                    />
                    
                    <xsl:sequence select="$first-keyword"/>
                    <!--<xsl:choose>
                        <xsl:when test="$keyword-no-suffix-1 = $lemma-keys.eng">
                            <xsl:sequence select="$keyword-no-suffix-1"/>
                        </xsl:when>
                        <xsl:when test="$keyword-no-suffix-2 = $lemma-keys.eng">
                            <xsl:sequence select="$keyword-no-suffix-2"/>
                        </xsl:when>
                    </xsl:choose>-->
                </xsl:when>
                <xsl:when test="$language = ('en', 'eng')">
                    <xsl:message>'{$word-token-norm}',</xsl:message>
                </xsl:when>
                <xsl:when test="$language eq 'grc' and ($word-token-norm = $lemma-keys.grc)">
                    <xsl:sequence select="$word-token-norm"/>
                </xsl:when>
                <xsl:when test="$language eq 'grc'">
                    <xsl:variable name="string-base-index" as="xs:integer*" select="index-of($lemma-keys-string-base.grc, $word-token-norm)"/>
                    <xsl:sequence select="$lemma-keys.grc[$string-base-index[1]]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$language = ('eng', 'en') and exists($keyword)">
                <xsl:variable name="resolution" as="item()*" select="$lemmas.eng($keyword)"/>
                <xsl:if test="$diagnostics-on">
                    <xsl:message>processing {$word-token-norm} in div context
                        {normalize-space($div-context)} on {count($resolution)} lemma resolution
                        items.</xsl:message>
                </xsl:if>

                <xsl:iterate select="$resolution">
                    <xsl:on-completion>
                        <xsl:sequence select="lower-case($word-token-norm)"/>
                    </xsl:on-completion>
                    <xsl:if test="$diagnostics-on">
                        <xsl:message>Assessing {.}</xsl:message>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when
                            test="((. instance of xs:string) or (. instance of text())) and matches(., '\S')">
                            <xsl:if test="$diagnostics-on">
                                <xsl:message>{$word-token-norm} becomes {.}</xsl:message>
                            </xsl:if>
                            <xsl:sequence select="."/>
                            <xsl:break/>
                        </xsl:when>
                        <xsl:when
                            test="(name(.) eq 'matches') and matches(normalize-space($div-context), @pattern)">
                            <xsl:sequence select="string(.)"/>
                            <xsl:break/>
                        </xsl:when>
                        <xsl:when test="name(.) eq 'otherwise'">
                            <xsl:sequence select="string(.)"/>
                            <xsl:break/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:next-iteration/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:iterate>
            </xsl:when>

            <xsl:when test="$language eq 'grc' and exists($keyword)">
                <xsl:variable name="resolution" as="item()+" select="$lemmas.grc($keyword)"/>
                <xsl:if test="$diagnostics-on">
                    <xsl:message>processing {$word-token-norm} in div context
                        {normalize-space($div-context)} on {count($resolution)} lemma resolution
                        items.</xsl:message>
                </xsl:if>

                <xsl:iterate select="$resolution">
                    <xsl:on-completion>
                        <xsl:sequence select="lower-case($word-token-norm)"/>
                    </xsl:on-completion>
                    <xsl:if test="$diagnostics-on">
                        <xsl:message>Assessing {.}</xsl:message>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when
                            test="((. instance of xs:string) or (. instance of text())) and matches(., '\S')">
                            <xsl:if test="$diagnostics-on">
                                <xsl:message>{$word-token-norm} becomes {.}</xsl:message>
                            </xsl:if>
                            <xsl:sequence select="."/>
                            <xsl:break/>
                        </xsl:when>
                        <xsl:when test="not(. instance of element())">
                            <xsl:message>keyword {$keyword} generates unexpected content: {serialize(.)}</xsl:message>
                        </xsl:when>
                        <xsl:when
                            test="(name(.) eq 'matches') and matches(normalize-space($div-context), @pattern)">
                            <xsl:sequence select="string(.)"/>
                            <xsl:break/>
                        </xsl:when>
                        <xsl:when test="name(.) eq 'otherwise'">
                            <xsl:sequence select="string(.)"/>
                            <xsl:break/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:next-iteration/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:iterate>
            </xsl:when>
            <xsl:when test="$language eq 'grc'">

                <xsl:sequence select="$word-token-norm"/>
                <!--<xsl:sequence select="lower-case(tan:string-base($word-token))"/>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="lower-case($word-token-norm)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    

    

</xsl:stylesheet>
