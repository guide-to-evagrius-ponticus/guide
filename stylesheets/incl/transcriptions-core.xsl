<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">
    <!-- Core components shared by the transcriptions applications -->
    <xsl:variable name="gep-template-uri-resolved" as="xs:anyURI" select="resolve-uri('../../templates/template.html', static-base-uri())"/>
    <xsl:variable name="gep-template" as="document-node()" select="doc($gep-template-uri-resolved)"/>
    
</xsl:stylesheet>
