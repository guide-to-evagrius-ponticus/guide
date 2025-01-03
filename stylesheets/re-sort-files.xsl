<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tan="tag:textalign.net,2015:ns"
    exclude-result-prefixes="#all" version="3.0">

    <!-- Primary input: various Guide to Evagrius Ponticus files -->
    <!-- Secondary input: none -->
    <!-- Primary output: the file, sorted -->
    <!-- Secondary output: none -->
    <!-- Used for the following files: lemmas-grc.xsl, stopwords.xml -->
    
    
    <xsl:include href="../../TAN/TAN-2022/functions/TAN-function-library.xsl"/>
    <xsl:mode default-mode="#unnamed" on-no-match="shallow-copy"/>

    <xsl:output indent="yes"/>
    
    <xsl:template match="xsl:map">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current">
                <xsl:sort select="tan:string-base(@key) => lower-case()"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="group">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current">
                <xsl:sort select="tan:string-base(.) => lower-case()"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
