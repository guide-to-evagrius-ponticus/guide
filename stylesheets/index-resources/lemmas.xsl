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
                <xsl:when test="$language eq 'eng' and ($word-token-norm = $lemma-keys.eng)">
                    <xsl:sequence select="$word-token-norm"/>
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
            <xsl:when test="$language eq 'eng' and exists($keyword)">
                <xsl:variable name="resolution" as="item()+" select="$lemmas.eng($keyword)"/>
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

    

    <xsl:variable name="lemma-keys.eng" select="map:keys($lemmas.eng)"/>
    <xsl:variable name="lemmas.eng" as="map(*)">
        <xsl:map>
            <xsl:map-entry key="'Acts'">
                <matches pattern="Acts \d"/>
                <otherwise>acts</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'co-essential'">coessential</xsl:map-entry>
            <xsl:map-entry key="'colour'">color</xsl:map-entry>
            <xsl:map-entry key="'colours'">colors</xsl:map-entry>
            <xsl:map-entry key="'con-substantial'">consubstantial</xsl:map-entry>
            <xsl:map-entry key="'corporal'">corporeal</xsl:map-entry>
            <xsl:map-entry key="'dæmon'">demon</xsl:map-entry>
            <xsl:map-entry key="'dæmons'">demons</xsl:map-entry>
            <xsl:map-entry key="'épithumia'">epithumia</xsl:map-entry>
            <xsl:map-entry key="'favour'">favor</xsl:map-entry>
            <xsl:map-entry key="'flavour'">flavor</xsl:map-entry>
            <xsl:map-entry key="'flavours'">flavors</xsl:map-entry>
            <xsl:map-entry key="'first-born'">firstborn</xsl:map-entry>
            <xsl:map-entry key="'forwards'">forward</xsl:map-entry>
            <xsl:map-entry key="'Frank'">
                <matches pattern="Mel\. Frank"/>
                <otherwise>frank</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'ful'">
                <matches pattern="ful\[ly\]">fully</matches>
                <otherwise/>
            </xsl:map-entry>
            <xsl:map-entry key="'fulfil'">fulfill</xsl:map-entry>
            <xsl:map-entry key="'genitor'">
                <matches pattern="pro\]genitor"/>
                <otherwise>genitor</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'habit'">
                <matches pattern="habit\[ual">habitual</matches>
                <otherwise>habit</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'ual'">
                <matches pattern="habit\[ual"/>
                <otherwise>ual</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'pro'">
                <matches pattern="pro\]genitor">progenitor</matches>
                <otherwise>pro</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'honour'">honor</xsl:map-entry>
            <xsl:map-entry key="'honours'">honors</xsl:map-entry>
            <xsl:map-entry key="'in-dwelling'">indwelling</xsl:map-entry>
            <xsl:map-entry key="'œconomy'">economy</xsl:map-entry>
            <xsl:map-entry key="'ions'">
                <matches pattern="\]ions"/>
                <otherwise>ions</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'Juda'">judah</xsl:map-entry>
            <xsl:map-entry key="'judgement'">judgment</xsl:map-entry>
            <xsl:map-entry key="'judgements'">judgments</xsl:map-entry>
            <xsl:map-entry key="'labour'">labor</xsl:map-entry>
            <xsl:map-entry key="'labours'">labors</xsl:map-entry>
            <xsl:map-entry key="'levelled'">leveled</xsl:map-entry>
            <xsl:map-entry key="'levelling'">leveling</xsl:map-entry>
            <xsl:map-entry key="'Macarios'">macarius</xsl:map-entry>
            <xsl:map-entry key="'Maxims'">
                <matches pattern="Maxims \d"/>
                <otherwise>maxims</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'Mel'">
                <matches pattern="Mel\. Frank"/>
                <otherwise>mel</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'nother'">
                <matches pattern=" a\]nother">another</matches>
                <otherwise>nother</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'para'">
                <matches pattern="para physin"/>
                <otherwise>para</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'physiké'">physike</xsl:map-entry>
            <xsl:map-entry key="'practise'">practice</xsl:map-entry>
            <xsl:map-entry key="'praktikē'">praktike</xsl:map-entry>
            <xsl:map-entry key="'praktiké'">praktike</xsl:map-entry>
            <xsl:map-entry key="'prob'">
                <matches pattern="\[prob\."/>
                <otherwise>prob</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'recognise'">recognize</xsl:map-entry>
            <xsl:map-entry key="'Saviour'">savior</xsl:map-entry>
            <xsl:map-entry key="'saviour'">savior</xsl:map-entry>
            <xsl:map-entry key="'Saviours'">saviors</xsl:map-entry>
            <xsl:map-entry key="'saviours'">saviors</xsl:map-entry>
            <xsl:map-entry key="'savours'">savors</xsl:map-entry>
            <xsl:map-entry key="'Shéol'">sheol</xsl:map-entry>
            <xsl:map-entry key="'St'">
                <matches pattern=" St\. ">saint</matches>
                <otherwise>st</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'theologiké'">theologike</xsl:map-entry>
            <xsl:map-entry key="'Tim'">
                <matches pattern="\dTim"/>
                <otherwise>tim</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'towards'">toward</xsl:map-entry>
            <xsl:map-entry key="'travelled'">traveled</xsl:map-entry>
            <xsl:map-entry key="'travelling'">traveling</xsl:map-entry>
            <xsl:map-entry key="'triang'">
                <matches pattern="triang\[ular">triangular</matches>
                <otherwise>triang</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'ular'">
                <matches pattern="triang\[ular"/>
                <otherwise>ular</otherwise>
            </xsl:map-entry>
            <xsl:map-entry key="'wilt'">will</xsl:map-entry>
            <xsl:map-entry key="'worshiped'">worshipped</xsl:map-entry>
            <xsl:map-entry key="'worshiping'">worshipping</xsl:map-entry>
        </xsl:map>
    </xsl:variable>

</xsl:stylesheet>
