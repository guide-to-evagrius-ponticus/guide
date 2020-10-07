<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="tag:textalign.net,2015:ns" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:bib="http://purl.org/net/biblio#" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">
    <!-- Catalyzing input (= main input): a TAN-voc file -->
    <!-- Auxiliary input: a Zotero RDF bibliography -->
    <!-- Output: the TAN-voc file with new vocabulary items appended to the <body> -->
    <xsl:include href="incl/bibliography.xsl"/>
    <xsl:include href="incl/core.xsl"/>
    <xsl:include href="incl/global-variables.xsl"/>
    <xsl:output method="xml"/>
    
    <xsl:variable name="bibliography-to-vocab-items-pass-1" as="element()*">
        <xsl:apply-templates select="$bibliography-rdf-file" mode="bibliography-to-vocab-items"/>
    </xsl:variable>
    <xsl:template match="document-node()" mode="bibliography-to-vocab-items">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="* | comment() | processing-instruction() | text()" mode="bibliography-to-vocab-items">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="* | comment() | processing-instruction()" mode="bib-to-iris">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="/*" mode="bibliography-to-vocab-items">
        <xsl:for-each select="*">
            <xsl:sort select="dc:date" order="descending"/>
            <xsl:apply-templates select="." mode="#current"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="rdf:RDF/bib:*[dc:title]" mode="bibliography-to-vocab-items">
        <item>
            <xsl:apply-templates mode="bib-to-iris"/>
            <name>
                <xsl:value-of select="tan:commas-and-ands(descendant::foaf:surname) || ' ' || dc:date"/>
            </name>
            <xsl:if test="dcterms:isPartOf/bib:Series/dc:title = 'Sources chrétiennes'">
                <name>
                    <xsl:value-of select="'SC ' || dcterms:isPartOf/bib:Series/dc:identifier"/>
                </name>
            </xsl:if>
            <desc>
                <xsl:value-of select="tan:rdf-bib-to-chicago-humanities-bibliography-html(.)"/>
            </desc>
            <!-- Ad hoc adjustment for converting to claims -->
            <xsl:apply-templates select="dc:subject" mode="bib-to-claims"/>
        </item>
    </xsl:template>
    <xsl:template match="text()" mode="bib-to-iris">
        <xsl:analyze-string select="." regex="tag:evagriusponticus.net,2012\S+|http://lccn.loc\S+">
            <xsl:matching-substring>
                <IRI><xsl:value-of select="."/></IRI>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <xsl:template match="/rdf:RDF/*/dc:identifier" mode="bib-to-iris">
        <xsl:variable name="is-isbn" select="starts-with(., 'ISBN')"/>
        <xsl:if test="$is-isbn">
            <xsl:analyze-string select="."
                regex="[0-9X-]{{6,}}">
                <xsl:matching-substring>
                    <IRI>
                        <xsl:value-of select="'urn:isbn:' || ."/>
                    </IRI>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:template>
    
    <!-- one-time effort to move claims from Zotero database to TAN-A file -->
    <xsl:template match="dc:subject" mode="bib-to-claims">
        <xsl:variable name="is-claim" select="matches(., 'edition|translation')"/>
        <xsl:variable name="claim-parts" select="tokenize(normalize-space(.), ' ')"/>
        <xsl:variable name="is-translation" select="$claim-parts[2] = 'translation'"/>
        <xsl:variable name="this-cpg" select="replace($claim-parts[1], '^(\d)', 'cpg$1')"/>
        <xsl:variable name="this-lang-name-norm" as="xs:string">
            <xsl:choose>
                <xsl:when test="$claim-parts[3] = 'Greek' and $is-translation">
                    <xsl:value-of select="'Modern Greek'"/>
                </xsl:when>
                <xsl:when test="$claim-parts[3] = 'Greek'">
                    <xsl:value-of select="'Ancient Greek'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$claim-parts[3]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="this-lang-code" select="tan:lang-code($this-lang-name-norm)"/>
        <xsl:variable name="this-object"
            select="
                if (not($is-translation or $this-lang-code = 'grc')) then
                    ($this-cpg || '-' || $this-lang-code)
                else
                    $this-cpg"
        />
        <xsl:if test="$is-claim">
            <claim verb="{if ($is-translation) then 'translates' else 'edits'}" object="{$this-object}">
                <xsl:if test="$is-translation">
                    <xsl:attribute name="in-lang" select="$this-lang-code"/>
                </xsl:if>
            </claim>
        </xsl:if>
    </xsl:template>
    
    <xsl:variable name="duplicate-names" select="tan:duplicate-values($bibliography-to-vocab-items-pass-1/tan:name)"/>
    
    <xsl:variable name="bibliography-to-vocab-items-pass-2" as="element()*">
        <xsl:apply-templates select="$bibliography-to-vocab-items-pass-1" mode="voc-items-pass-2"/>
    </xsl:variable>
    <xsl:template match="tan:item" mode="voc-items-pass-2">
        <xsl:variable name="gep-uri-suffix"
            select="replace(replace(tan:IRI[starts-with(., 'tag:evagriusponticus.net,2012')], '.+:([^:]+)$', '$1'), '-', ' ')"
        />
        <xsl:variable name="uri-suffix-is-unique" select="not(tan:name[lower-case(.) = $gep-uri-suffix])"/>
        <xsl:copy>
            <xsl:copy-of select="tan:IRI"/>
            <xsl:apply-templates select="tan:name" mode="#current"/>
            <xsl:if test="$uri-suffix-is-unique">
                <name>
                    <xsl:value-of select="$gep-uri-suffix"/>
                </name>
            </xsl:if>
            <xsl:copy-of select="tan:desc"/>
            <xsl:copy-of select="tan:claim"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tan:name" mode="voc-items-pass-2">
        <xsl:if test="not(. = $duplicate-names)">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:variable name="these-claims" as="element()*">
        <xsl:for-each-group select="$bibliography-to-vocab-items-pass-2/tan:claim" group-by="@object">
            <xsl:sort select="current-grouping-key()"/>
            <xsl:variable name="this-cpg" select="current-grouping-key()"/>
            <xsl:for-each-group select="current-group()" group-by="(@in-lang, @verb)[1]">
                <xsl:sort
                    select="
                        if (not(current-group()[1]/@in-lang)) then
                            'aaa'
                        else
                            current-grouping-key()"
                />
                <xsl:variable name="this-lang" select="current-grouping-key()"/>
                <xsl:variable name="this-verb" select="current-group()[1]/@verb"/>
                <xsl:variable name="these-names"
                    select="
                        for $i in current-group()
                        return
                            replace($i/../tan:name[last()], ' ', '_')"
                />
                <!--<group>
                    <xsl:copy-of select="current-group()"/>
                </group>-->
                <claim subject="{string-join($these-names, ' ')}">
                    <xsl:copy-of select="current-group()[1]/(@verb, @in-lang, @object)"/>
                </claim>
            </xsl:for-each-group> 
        </xsl:for-each-group> 
    </xsl:variable>
    
    <xsl:template match="/">
        <testing>
            <!--<xsl:copy-of select="$bibliography-to-vocab-items-pass-2"/>-->
            <!--<lang><xsl:copy-of select="tan:lang-code('Ancient Greek')"/></lang>-->
            <!--<pass1><xsl:copy-of select="$bibliography-to-vocab-items-pass-1"/></pass1>-->
            <pass2><xsl:copy-of select="$bibliography-to-vocab-items-pass-2"/></pass2>
            <claims><xsl:copy-of select="$these-claims"/></claims>
        </testing>
        <!--<xsl:document>
            <xsl:apply-templates/>
        </xsl:document>-->
    </xsl:template>
    <xsl:template match="processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="tan:body">
        <xsl:variable name="this-vocab" select="*"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <xsl:value-of select="preceding-sibling::text()[1]"/>
            <xsl:comment>New vocab added <xsl:value-of select="current-dateTime()"/></xsl:comment>
            <xsl:value-of select="preceding-sibling::text()[1]"/>
            <xsl:copy-of select="$bibliography-to-vocab-items-pass-2[not(tan:IRI = $this-vocab/tan:IRI)]"/>
        </xsl:copy>
        
    </xsl:template>
    
</xsl:stylesheet>
