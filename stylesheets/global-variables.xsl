<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">

    <xsl:variable name="content" select="collection('../?select=content-*.htm')"/>
    <xsl:variable name="this-year" select="year-from-date(current-date())"/>
    <xsl:variable name="this-month" select="month-from-date(current-date())"/>
    <xsl:variable name="this-season" as="xs:string?">
        <xsl:choose>
            <xsl:when test="$this-month = (1, 2, 3)">spring</xsl:when>
            <xsl:when test="$this-month = (4, 5, 6)">summer</xsl:when>
            <xsl:when test="$this-month = (7, 8, 9)">autumn</xsl:when>
            <xsl:when test="$this-month = (10, 11, 12)">winter</xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="this-edition" select="string-join(($this-season, string($this-year)), ' ')"/>
</xsl:stylesheet>