<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tan="tag:textalign.net,2015:ns"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns="http://www.w3.org/2005/Atom"
    exclude-result-prefixes="#all" xpath-default-namespace="http://www.w3.org/2005/Atom"
    version="2.0">
    <!--<xsl:output indent="yes"/>-->
    <!--<xsl:include href="stylesheets/core.xsl"/>-->
    <xsl:variable name="main-update" select="/feed/updated" as="xs:dateTime"/>
    <!--<xsl:variable name="now" select="current-dateTime()"/>-->
    <xsl:variable name="text-test" as="element()">
        <value>&lt;p&gt;Comments on  AU offers five conclusions:&lt;/p&gt;
            &lt;ol&gt;
            &lt;li&gt;There is no critical edition of the Arabic translations;&lt;/li&gt;
            &lt;li&gt;Each treatise should be studied independently, to determine whether a translation of the Greek or the Syriac;&lt;/li&gt;
            &lt;li&gt;The vocabulary needs to be studied, to identify common translators;&lt;/li&gt;
            &lt;li&gt;It is acutely important to determine the authenticity of Arabic fragments that correspond to neither Greek nor Syriac;&lt;/li&gt;
            &lt;li&gt;Research in Arabic Evagrius needs to be enlarged.&lt;/li&gt;
            &lt;/ol&gt;
            &lt;p&gt;-jk&lt;/p&gt;</value>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:text>&#xa;</xsl:text>
        <result>
            <!--<xsl:value-of select="current-dateTime()"/>-->
            <!--<xsl:value-of select="$main-update"/>-->
            <test>
                <!--<xsl:value-of select="saxon:dateTime-greater-than($now, $main-update)"/>-->
                <!--<xsl:value-of select="$main-update lt $now"/>-->
                <xsl:copy-of select="tan:text-tags-to-html($text-test/text())"/>
            </test>
        </result>
    </xsl:template>
    
    <xsl:function name="tan:text-tags-to-html" as="item()*">
        <xsl:param name="raw-text" as="xs:string?"/>
        <xsl:analyze-string select="$raw-text" regex="&lt;([a-zA-Z]+)&gt;(.+?)&lt;/\1&gt;" flags="ms">
            <xsl:matching-substring>
                <xsl:variable name="this-element-name" select="regex-group(1)"/>
                <xsl:variable name="this-element-content" select="regex-group(2)"/>
                <xsl:element name="{$this-element-name}">
                    <xsl:choose>
                        <xsl:when
                            test="not(matches($this-element-content, '&lt;([a-zA-Z]+)&gt;(.+?)&lt;/\1&gt;','ms'))">
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
</xsl:stylesheet>
