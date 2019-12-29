<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:z="http://www.zotero.org/namespaces/export#" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:bib="http://purl.org/net/biblio#"
    xmlns:vcard="http://nwalsh.com/rdf/vCard#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/"
    xmlns:link="http://purl.org/rss/1.0/modules/link/"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="2.0">

    <xsl:template match="comment() | text()" mode="template-to-bibliography bib-rdf-to-html">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="*" mode="template-to-bibliography bib-rdf-to-html">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="div[@class = 'body'] | table[@id = 'bibliography-table']"
        mode="template-to-bibliography">
        <div class="links-to-other-formats">Other formats: <a
                href="http://www.zotero.org/groups/evagrius_ponticus">Zotero</a> (master), <a
                href="bibliography.rdf">RDF</a>, <a href="bibliography.zip">BibTeX</a>.</div>
        <input class="search" type="search" data-column="all"/>
        <table class="tablesorter show-last-col-only" id="bibliography-table">
            <thead>
                <tr>
                    <td>Year</td>
                    <td>Author</td>
                    <td>Title</td>
                    <td>Type</td>
                    <td>Citation</td>
                    <!-- we add a filler because in our css, we are going to hide the first four columns in the tbody, and we need to balance them with an equal number of columns in the thead -->
                    <td colspan="4" class="filler"/>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each
                    select="$bibliography-prepped/*/bib:*[not((self::bib:memo, self::bib:Memo, self::bib:Journal))]">
                    <xsl:sort select="dc:date" order="descending"/>
                    <xsl:variable name="this-item" select="."/>
                    <xsl:variable name="this-item-tan-id" as="xs:string*">
                        <xsl:for-each select="dc:description">
                            <xsl:analyze-string select="."
                                regex="tag:evagriusponticus.net,2012:scriptum:\S+">
                                <xsl:matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="this-item-other-ids" as="xs:string*"
                        select="dc:identifier/text()"/>
                    <xsl:variable name="this-item-all-ids" select="$this-item-tan-id, $this-item-other-ids" as="xs:string*"/>
                    <xsl:variable name="this-item-transcriptions" select="$corpus-collection[*/tan:head/tan:source[tan:IRI = $this-item-tan-id]]"/>
                    <xsl:text>&#xa;</xsl:text>
                    <tr id="{@rdf:about}">
                        <td>
                            <xsl:value-of select="dc:date"/>
                        </td>
                        <td>
                            <xsl:value-of
                                select="(bib:authors, bib:editors, z:presenters)//foaf:surname"/>
                        </td>
                        <td>
                            <xsl:value-of select="dc:title"/>
                        </td>
                        <td>
                            <xsl:value-of select="z:itemType"/>
                        </td>
                        <td colspan="5">
                            <xsl:if test="exists($this-item-all-ids)">
                                <div class="id-label">
                                    <xsl:for-each select="$this-item-all-ids">
                                        <div class="id">
                                            <xsl:copy-of
                                                select="tan:hyperlink-text(normalize-space(.), 30)"
                                            />
                                        </div>
                                    </xsl:for-each>
                                </div>
                            </xsl:if>
                            <!--<xsl:copy-of
                                select="tan:rdf-bib-to-chicago-humanities-bibliography-html(., $bibliography-prepped)"/>-->
                            <xsl:copy-of
                                select="tan:rdf-bib-to-chicago-humanities-bibliography-html(.)"/>
                            
                            <xsl:apply-templates select="dcterms:abstract" mode="bib-rdf-to-html"/>
                            <xsl:apply-templates
                                select="root()/*/bib:Memo[@rdf:about = $this-item/dcterms:isReferencedBy/@rdf:resource]"
                                mode="bib-rdf-to-html"/>
                            <xsl:for-each-group
                                select="dc:subject[matches(., ' (edition|translation) ')]"
                                group-by="replace(., '^\S+\s+(.+)$', '$1')">
                                <xsl:variable name="subject-parsed" as="xs:string*"
                                    select="
                                        for $i in current-group()
                                        return
                                            tan:analyze-subject-tag($i)[1]"/>
                                <xsl:variable name="this-group-name"
                                    select="replace(current-grouping-key(), '(\S+)\s+(.+)', '$2 $1')"/>
                                <div class="corpus-xref">
                                    <xsl:value-of select="concat($this-group-name, ' of ')"/>
                                    <xsl:for-each select="$subject-parsed">
                                        <xsl:variable name="corpus-id"
                                            select="replace(., '^(\d)', 'cpg$1')"/>
                                        <a href="corpus.htm#{$corpus-id}">
                                            <xsl:value-of
                                                select="replace($corpus-id, 'cpg', ' CPG ')"/>
                                        </a>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                </div>
                            </xsl:for-each-group>
                            <xsl:copy-of select="tan:transcription-hyperlink($this-item-transcriptions)"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template match="dcterms:abstract | bib:Memo" mode="bib-rdf-to-html">
        <xsl:variable name="this-text" select="string-join(.//text()[matches(., '\S')], '&#xa;')"/>
        <div class="abstract clip-after-line-1">
            <xsl:copy-of select="tan:text-tags-to-html($this-text)"/>
        </div>
    </xsl:template>
    <xsl:template match="dc:subject" mode="bib-rdf-to-html">
        <xsl:if test="matches(., ' (edition|translation) ')">
            <xsl:variable name="subject-parsed" select="tan:analyze-subject-tag(.)"/>
            <xsl:variable name="corpus-id" select="replace($subject-parsed[1], '^(\d)', 'cpg$1')"/>
            <div class="corpus-xref">
                <xsl:value-of select="concat($subject-parsed[3], $subject-parsed[2], 'of ')"/>
                <a href="corpus-build.htm#{$corpus-id}">
                    <xsl:value-of select="replace($corpus-id, 'cpg', ' CPG ')"/>
                </a>
            </div>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
