<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">

    <!-- This is the master stylesheet for generating the everything in the Guide to Evagrius Ponticus except the transcriptions (see transcriptions.xsl) -->
    <!-- Input: any XML document whatsoever -->
    <!-- Output: the static html pages that constitute the Guide -->
    <!-- This stylesheet can be run on any XML document because the core input documents are defined by parameters -->
    <xsl:include href="corpus.xsl"/>
    <xsl:include href="bibliography.xsl"/>
    <xsl:include href="core.xsl"/>
    <xsl:include href="global-variables.xsl"/>
    <xsl:output method="xhtml" indent="yes"/>

    <xsl:param name="diagnostics" as="xs:boolean" select="true()"/>
    <xsl:param name="validation-phase" select="'normal'"/>

    <xsl:template match="/" priority="5">
        <xsl:for-each select="$content">
            <xsl:variable name="this-doc" select="."/>
            <xsl:variable name="new-uri" select="replace(base-uri($this-doc), 'content-', '')"/>
            <xsl:variable name="is-corpus" select="matches(base-uri(.), 'content-corpus.htm')" as="xs:boolean"/>
            <xsl:variable name="is-bibliography" select="matches(base-uri(.), 'content-bibliography.htm')" as="xs:boolean"/>
            <xsl:variable name="pass1">
                <xsl:apply-templates select="$gep-template" mode="content-into-template">
                    <xsl:with-param name="content-doc" select="$this-doc" tunnel="yes"/>
                    <xsl:with-param name="target-url"
                        select="replace($new-uri, '.+/([^/]+)$', '$1')" tunnel="yes"/>
                    <xsl:with-param name="edition" select="$this-edition" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:variable name="pass2">
                <xsl:if test="$is-bibliography or $is-corpus">
                    <xsl:apply-templates select="$pass1" mode="insert-tablesorter"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="pass3">
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
            <xsl:choose>
                <xsl:when test="$diagnostics">
                    <xsl:message>Diagnostics on</xsl:message>
                    <xsl:if test="$is-corpus">
                        <!--<xsl:copy-of select="$corpus-resolved"/>-->
                        <xsl:copy-of select="$corpus-expanded"/>
                        <!--<xsl:copy-of select="$pass3"/>-->
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message select="'File saved at', $new-uri"/>
                    <xsl:result-document href="{$new-uri}">
                        <xsl:apply-templates select="$pass3" mode="content-post-prepped">
                            <xsl:with-param name="edition" select="$this-edition" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

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
