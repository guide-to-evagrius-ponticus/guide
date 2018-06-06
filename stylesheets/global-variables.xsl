<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">
    <xsl:include href="global-variables-for-schematron-validation.xsl"/>
    <xsl:variable name="content" select="collection('../?select=content-*.htm')"/>
    <xsl:variable name="corpus-collection" select="collection('../tan/?select=cpg*.xml')"/>
    <xsl:variable name="corpus-collection-resolved"
        select="tan:resolve-doc($corpus-collection, false(), (), (), (), ())"/>
    <xsl:variable name="site-base-uri" select="resolve-uri('..', static-base-uri())"/>
</xsl:stylesheet>
