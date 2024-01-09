<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:param name="output-diagnostics-on" as="xs:boolean" static="true" select="false()"/>
    
    <!-- This is the master stylesheet for generating the everything in the Guide to Evagrius Ponticus except the 
        single-source transcriptions (see transcriptions.xsl) and the parallel editions (see transcriptions-tan-a.xsl) -->
    <!-- Input: any XML document whatsoever, including this one -->
    <!-- Output: the static html pages that constitute the Guide -->
    <!-- This stylesheet can be run on any XML document because the core input documents are defined by parameters -->
    <xsl:include href="incl/corpus.xsl"/>
    <xsl:include href="incl/bibliography.xsl"/>
    <xsl:include href="incl/core.xsl"/>
    <xsl:include href="incl/global-variables.xsl"/>
    
    <xsl:output indent="yes" use-when="$output-diagnostics-on"/>
    <xsl:output indent="no" method="xhtml" use-when="not($output-diagnostics-on)"/>

    <xsl:param name="validation-phase" select="'normal'"/>
    
    <xsl:param name="tan:distribute-vocabulary" select="true()"/>

    <xsl:mode name="template-to-bibliography"/>

    <xsl:mode name="content-into-template" on-no-match="shallow-copy"/>
    
    <!--<xsl:template match="*" mode="content-into-template content-post-prepped">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>-->
    <!--<xsl:template match="comment() | processing-instruction()"
        mode="content-into-template content-post-prepped">
        <xsl:copy-of select="."/>
    </xsl:template>-->
    
    <xsl:template match="head" mode="content-into-template">
        <xsl:param name="content-doc" as="document-node()?" tunnel="yes"/>
        <head>
            <xsl:apply-templates mode="content-into-template"/>
            <xsl:copy-of select="$content-doc/html/head/node()"/>
        </head>
    </xsl:template>
    <xsl:template match="title" mode="content-into-template">
        <xsl:param name="content-doc" as="document-node()?" tunnel="yes"/>
        <title>
            <xsl:value-of select="concat(., ': ', ($content-doc//h2)[1])"/>
        </title>
    </xsl:template>
    <!-- The templates point accurately to their relative location, which is perfect for transcriptions and parallel editions,
    but the main pages are up a level, and the relative hrefs need to be adjusted -->
    <xsl:template match="link[@href[starts-with(., '../')]] | img[@src[starts-with(., '../')]] | script[@src[starts-with(., '../')]] | a[@href[starts-with(., '../')]]" mode="content-into-template">
        <xsl:copy>
            <xsl:copy-of select="@* except (@href | @src)"/>
            <xsl:for-each select="@href | @src">
                <xsl:attribute name="{name(.)}" select="replace(., '^\.\./', '')"/>
            </xsl:for-each>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[@class = 'body']" mode="content-into-template">
        <xsl:param name="content-doc" as="document-node()?" tunnel="yes"/>
        <xsl:copy-of select="$content-doc/html/body/node()"/>
    </xsl:template>
    <xsl:template match="a" mode="content-into-template">
        <xsl:param name="target-url" as="xs:string" tunnel="yes"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="@href = $target-url">
                <xsl:attribute name="style">font-weight:bolder</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="content-into-template"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:mode name="content-post-prepped" on-no-match="shallow-copy"/>
    
    <xsl:template match="*[@class = 'this-edition']" mode="content-post-prepped">
        <xsl:param name="edition" as="xs:string" tunnel="yes"/>
        <xsl:value-of select="$edition"/>
    </xsl:template>
    <xsl:template match="*[@class = 'this-year']" mode="content-post-prepped">
        <xsl:param name="edition" as="xs:string" tunnel="yes"/>
        <xsl:value-of select="replace($edition, '\D+', '')"/>
    </xsl:template>

    <xsl:template match="/" priority="5">
        <xsl:if test="$run-corpus-only">
            <xsl:message select="'Running only the corpus page'"/>
        </xsl:if>
        <xsl:for-each select="$content">
            <xsl:variable name="this-doc" select="."/>
            <xsl:variable name="this-doc-base-uri" select="base-uri(.)"/>
            <xsl:variable name="new-uri" select="replace($this-doc-base-uri, 'templates/', '')"/>
            <xsl:variable name="is-corpus" select="$run-corpus-only or matches(base-uri(.), 'corpus\.htm')" as="xs:boolean"/>
            <xsl:variable name="is-bibliography" select="matches(base-uri(.), 'bibliography\.htm')" as="xs:boolean"/>
            <xsl:variable name="pass1" as="document-node()">
                <xsl:apply-templates select="$gep-template" mode="content-into-template">
                    <xsl:with-param name="content-doc" select="$this-doc" tunnel="yes"/>
                    <xsl:with-param name="target-url"
                        select="replace($new-uri, '.+/([^/]+)$', '$1')" tunnel="yes"/>
                    <xsl:with-param name="edition" select="$this-edition" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:variable name="pass2" as="document-node()?">
                <xsl:if test="$is-bibliography or $is-corpus">
                    <xsl:apply-templates select="$pass1" mode="insert-tablesorter"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="pass3" as="document-node()">
                <xsl:choose>
                    <xsl:when test="$is-corpus">
                        <xsl:apply-templates select="$pass2" mode="template-to-corpus"/>
                    </xsl:when>
                    <xsl:when test="$is-bibliography">
                        <xsl:apply-templates select="$pass2" mode="template-to-bibliography"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$pass1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:if test="$output-diagnostics-on">
                <xsl:message select="'diagnostics on for doc base uri:', $this-doc-base-uri"/>
                <xsl:message select="'is corpus?', $is-corpus"/>
                <xsl:message select="'is bibliography?', $is-bibliography"/>
                <xsl:message>Fix corpus collection</xsl:message>
                
            </xsl:if>
            
            <xsl:choose>
                <xsl:when test="$output-diagnostics-on">
                    <xsl:if test="$is-corpus">
                        <diagnostics>
                            <tan-folder-uris-resolved><xsl:value-of select="$tan-folder-uris-resolved"/></tan-folder-uris-resolved>
                            <!--<xsl:copy-of select="$corpus-collection-resolved/*/tan:head"/>-->
                            <!--<corpus-collection>
                                <xsl:for-each select="$corpus-collection-resolved">
                                    <text>
                                        <xsl:copy-of select="*/@*"/>
                                        <xsl:copy-of select="tan:vocabulary('work', false(), (), root()/*/tan:head)"/>
                                    </text>
                                </xsl:for-each>
                            </corpus-collection>-->
                            <!--<html-coll><xsl:copy-of select="tan:shallow-copy($html-transcription-collection, 2)"/></html-coll>-->
                            <!--<corpus-claims-resolved><xsl:copy-of select="$corpus-claims-resolved"/></corpus-claims-resolved>-->
                            <!--<corpus-claims-expanded><xsl:copy-of select="$corpus-claims-expanded"/></corpus-claims-expanded>-->
                            <corpus-claims-expanded><xsl:copy-of select="$corpus-claims-expanded"/></corpus-claims-expanded>
                            <pass1><xsl:copy-of select="$pass1"/></pass1>
                            <!--<pass2><xsl:copy-of select="$pass2"/></pass2>-->
                            <!--<pass3><xsl:copy-of select="$pass3"/></pass3>-->
                        </diagnostics>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise use-when="not($output-diagnostics-on)">
                    <xsl:result-document href="{$new-uri}">
                        <xsl:apply-templates select="$pass3" mode="content-post-prepped">
                            <xsl:with-param name="edition" select="$this-edition" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                    <xsl:message select="'File saved at', $new-uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
