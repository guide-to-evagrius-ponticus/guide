<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">
    <xsl:import href="../../TAN/TAN-1-dev/functions/TAN-T-functions.xsl"/>

    <!-- temporary stylesheet to make changes to Evagrius TEI files -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/">
        <xsl:for-each select="node()">
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>

    <xsl:variable name="id-conversion-key" as="element()">
        <id-conversion-key>
            <xsl:for-each select="//tei:w">
                <key old="{@xml:id}" new="w{position()}"/>
            </xsl:for-each>
            <xsl:for-each select="//tei:phr">
                <key old="{@xml:id}" new="w{position()}"/>
            </xsl:for-each>
        </id-conversion-key>
    </xsl:variable>
    <xsl:template match="@target">
        <xsl:variable name="these-targets" select="tokenize(., '\s+')"/>
    </xsl:template>
    <!--<xsl:template match="tei:milestone">
        <xsl:variable name="prev-milestone-count" select="count(preceding::tei:milestone)"/>
        <xsl:variable name="ms-pass-1" select="$prev-milestone-count + 50 + 1"/>
        <xsl:variable name="fol-no" select="$ms-pass-1 idiv 2"/>
        <xsl:variable name="r-or-v"
            select="
                if (($ms-pass-1 mod 2) gt 0) then
                    'v'
                else
                    'r'"
        />
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="n" select="concat(string($fol-no), $r-or-v)"/>
        </xsl:copy>
    </xsl:template>-->
    <!--<xsl:template match="tei:div[count(tei:p) lt 2]"/>-->
    <!--<xsl:template match="tei:p[1][tei:supplied]">
        <milestone unit="section" rend="{tei:supplied/text()}"/>
    </xsl:template>-->
    <!--<xsl:template match="tei:p[1]">
        <xsl:variable name="syriac-number-regex" select="'^\s*(ܩ\p{IsSyriac}\p{IsSyriac}?)\W*'"
            as="xs:string"/>
        <xsl:variable name="first-text-node" select="node()[1]/self::text()"/>
        <xsl:variable name="string-analysis" as="xs:string*">
            <xsl:if test="exists($first-text-node)">
                <xsl:analyze-string select="$first-text-node" regex="{$syriac-number-regex}">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="count($string-analysis) gt 1">
            <milestone unit="section" n="{tan:letter-to-number($string-analysis[1])}" rend="{$string-analysis[1]}"/>
        </xsl:if>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="$string-analysis[last()]"/>
            <xsl:copy-of select="node()[position() gt 1]"/>
        </xsl:copy>
    </xsl:template>-->
</xsl:stylesheet>
