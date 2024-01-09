<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">

    <xsl:variable name="this-year" select="year-from-date(current-date())"/>
    <xsl:variable name="this-month" select="month-from-date(current-date())"/>
    <xsl:variable name="this-quarter" select="ceiling($this-month div 3)"/>
    <xsl:variable name="seasons" select="('spring', 'summer', 'autumn', 'winter')" as="xs:string+"/>
    <!--<xsl:variable name="this-season" as="xs:string?" select="$seasons[$this-quarter]"/>-->
    <xsl:variable name="this-season" as="xs:string">
        <xsl:choose>
            <xsl:when test="$this-month = (3, 4, 5)">spring</xsl:when>
            <xsl:when test="$this-month = (6, 7, 8)">summer</xsl:when>
            <xsl:when test="$this-month = (9, 10, 11)">autumn</xsl:when>
            <xsl:otherwise>winter</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!--<xsl:variable name="this-edition" select="string-join(($this-season, string($this-year)), ' ')"/>-->
    <xsl:param name="this-edition" select="'2024'" as="xs:string"/>
</xsl:stylesheet>
