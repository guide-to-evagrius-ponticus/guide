<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">

    <!-- This is the master stylesheet for generating the Guide to Evagrius Ponticus -->
    <!-- Input: any XML document whatsoever -->
    <!-- Output: the static html pages that constitute the Guide -->
    <!-- This stylesheet can be run on any XML document because the core -->
    <xsl:include href="corpus.xsl"/>
    <xsl:include href="bibliography.xsl"/>
    <xsl:include href="core.xsl"/>
    <xsl:include href="global-variables.xsl"/>

    <xsl:template match="/">
        <xsl:for-each select="$content">
            <xsl:variable name="this-doc" select="."/>
            <xsl:variable name="new-uri"
                select="replace(base-uri($this-doc), 'content-', '')"/>
            <xsl:variable name="pass1">
                <xsl:apply-templates select="$gep-template" mode="content-into-template">
                    <xsl:with-param name="content-doc" select="$this-doc" tunnel="yes"/>
                    <xsl:with-param name="target-url"
                        select="replace($new-uri, '.+/([^/]+)$', '$1')" tunnel="yes"/>
                    <xsl:with-param name="edition" select="$this-edition" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:variable name="pass2">
                <xsl:choose>
                    <xsl:when test="exists($pass1//table[@id = 'corpus-table'])">
                        <xsl:variable name="pass1b">
                            <xsl:apply-templates select="$pass1" mode="insert-tablesorter"/>
                        </xsl:variable>
                        <xsl:apply-templates select="$pass1b" mode="template-to-corpus"/>
                    </xsl:when>
                    <xsl:when test="exists($pass1//table[@id = 'bibliography-table'])">
                        <xsl:variable name="pass1b">
                            <xsl:apply-templates select="$pass1" mode="insert-tablesorter"/>
                        </xsl:variable>
                        <xsl:apply-templates select="$pass1b" mode="template-to-bibliography"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$pass1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:result-document href="{$new-uri}">
                <xsl:apply-templates select="$pass2" mode="content-post-prepped">
                    <xsl:with-param name="edition" select="$this-edition" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*" mode="content-into-template content-post-prepped">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="comment() | processing-instruction()"
        mode="content-into-template content-post-prepped">
        <xsl:copy-of select="."/>
    </xsl:template>

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

    <xsl:template match="*[@class = 'this-edition']" mode="content-post-prepped">
        <xsl:param name="edition" as="xs:string" tunnel="yes"/>
        <xsl:value-of select="$edition"/>
    </xsl:template>
    <xsl:template match="*[@class = 'this-year']" mode="content-post-prepped">
        <xsl:param name="edition" as="xs:string" tunnel="yes"/>
        <xsl:value-of select="replace($edition, '\D+', '')"/>
    </xsl:template>
</xsl:stylesheet>
