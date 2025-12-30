<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:include href="global-variables-for-schematron-validation.xsl"/>
    
    <xsl:param name="run-corpus-only" as="xs:boolean" select="false()"/>
    
    <xsl:variable name="content" as="document-node()*"
        select="
            if ($run-corpus-only) then
                doc('../../templates/corpus.htm')
            else
                collection('../../templates/?select=*.htm')"
    />
    
    <xsl:variable name="tan-collection-base-uri" select="resolve-uri('../../tan/', static-base-uri())"/>
    
    <xsl:variable name="main-tan-voc-uri-resolved" select="resolve-uri('../../tan/TAN-voc/evagrius.TAN-voc.xml', static-base-uri())"/>
    <xsl:variable name="tan-folder-uris-resolved" select="uri-collection($tan-collection-base-uri)"/>
    <xsl:variable name="corpus-collection" select="collection('../../tan/?select=cpg*.xml')"/>
    <!--<xsl:variable name="corpus-collection" select="collection('../../tan/?select=cpg6583*.xml')"/>-->
    <xsl:variable name="corpus-collection-resolved" as="document-node()*"
        select="
            for $i in $corpus-collection
            return
                tan:resolve-doc($i)"
    />
    <xsl:variable name="html-transcription-collection" select="collection('../?select=cpg*.html')"/>
    <xsl:variable name="site-base-uri" select="resolve-uri('..', static-base-uri())"/>
</xsl:stylesheet>
