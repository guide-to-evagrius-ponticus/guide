<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:z="http://www.zotero.org/namespaces/export#" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/"
    xmlns:bib="http://purl.org/net/biblio#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:vcard="http://nwalsh.com/rdf/vCard#" xmlns:link="http://purl.org/rss/1.0/modules/link/"
    xmlns:f="http://kalvesmaki.com/" exclude-result-prefixes="xs" version="2.0">

    <!-- XSLT written March 2013 by Joel Kalvesmaki to turn Zotero RDF into Exhibit-ready JSON. 
    Last update: 2013-04-02. To do:
    * accommodate multiple URLs -->

    <xsl:output method="text"/>

    <xsl:template match="/">
        <xsl:text>{&#xA;	"items" :      [&#xA;</xsl:text>
        <!-- First the biblio items -->
        <xsl:apply-templates/>
        <!-- Now author data -->
        <xsl:variable name="i2" as="item()+">
            <xsl:for-each select="//foaf:Person">
                <xsl:value-of select="string-join((foaf:surname,foaf:givenname),'|')"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="j2" select="distinct-values($i2)"/>
        <xsl:for-each select="$j2">
            <xsl:variable name="k2">
                <xsl:choose>
                    <xsl:when test="contains(.,'|')">
                        <xsl:value-of select="substring-before(.,'|')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:text>        {
            "label" :         "</xsl:text>
            <xsl:value-of select="replace(.,'\|',', ')"/>
            <xsl:text>",
			"type" :          "Author",
			"original-name" : "</xsl:text>
            <xsl:value-of select="replace(.,'\|',', ')"/>
            <xsl:text>",
			"last-name" :     "</xsl:text>
            <xsl:value-of select="$k2"/>
            <xsl:text>"
        }</xsl:text>
            <xsl:if test="not(.=$j2[last()])">
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>&#xA;</xsl:text>
        </xsl:for-each>
        <xsl:text>
	],
	"types" :      {
		"Author" :      {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#Author"
		},
		"Publication" : {
			"label" :       "Publication",
			"uri" :         "http:\/\/simile.mit.edu\/2006\/11\/bibtex#Publication",
			"pluralLabel" : "Publications"
		}
	},
	"properties" : {
		"issn" :          {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#issn"
		},
		"number" :        {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#number"
		},
		"copyright" :     {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#copyright"
		},
		"note" :          {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#note"
		},
		"author" :        {
			"reverseLabel" :         "authors of",
			"label" :                "author",
			"groupingLabel" :        "their authors",
			"uri" :                  "http:\/\/simile.mit.edu\/2006\/11\/bibtex#author",
			"reverseGroupingLabel" : "what they author",
			"reversePluralLabel" :   "authors of",
			"valueType" :            "item",
			"pluralLabel" :          "authors"
		},
		"address" :       {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#address"
		},
		"editor" :        {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#editor"
		},
		"lccn" :          {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#lccn"
		},
		"howpublished" :  {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#howpublished"
		},
		"url" :           {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#url"
		},
		"isbn" :          {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#isbn"
		},
		"edition" :       {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#edition"
		},
		"keywords" :      {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#keywords"
		},
		"shorttitle" :    {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#shorttitle"
		},
		"series" :        {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#series"
		},
		"pages" :         {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#pages"
		},
		"year" :          {
			"valueType" : "number",
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#year"
		},
		"journal" :       {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#journal"
		},
		"booktitle" :     {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#booktitle"
		},
		"school" :        {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#school"
		},
		"publisher" :     {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#publisher"
		},
		"abstract" :      {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#abstract"
		},
		"language" :      {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#language"
		},
		"original-name" : {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#original-name"
		},
		"volume" :        {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#volume"
		},
		"annote" :        {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#annote"
		},
		"translator" :    {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#translator"
		},
		"doi" :           {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#doi"
		},
		"date" :          {
			"uri" : "http:\/\/purl.org\/dc\/elements\/1.1\/date"
		},
		"month" :         {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#month"
		},
		"urldate" :       {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#urldate"
		},
		"last-name" :     {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#last-name"
		},
		"key" :           {
			"uri" : "http:\/\/simile.mit.edu\/2006\/11\/bibtex#key"
		}
	}
}</xsl:text>
    </xsl:template>

    <!-- Children of the document element -->
    <xsl:template match="@*|node()">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Publication types -->
    <xsl:template
        match="rdf:RDF/bib:Article|rdf:RDF/bib:Book|rdf:RDF/bib:BookSection|rdf:RDF/bib:Thesis|rdf:RDF/rdf:Description|rdf:RDF/bib:Document|rdf:RDF/bib:ConferenceProceedings">
        <xsl:variable name="pub" select="."/>
        <xsl:variable name="obj"
            select="('bib:Article', 'bib:Book', 'bib:BookSection', 'bib:ConferenceProceedings', 'bib:Document', 'bib:Journal', 'bib:Memo', 'bib:Thesis', 'rdf:Description', 'z:Attachment')"/>
        <xsl:variable name="exh"
            select="('article',     'book',     'book chapter',    'conference paper',            'misc',       'journal',     'misc',   'thesis',        'multiple',       'link')"/>
        <xsl:variable name="i" select="fn:index-of($obj,fn:name(.))"/>
        <xsl:text>		{&#xA;			"pub-type" : </xsl:text>
        <xsl:choose>
            <xsl:when test="matches(name(.),'rdf:Description')">
                <xsl:value-of
                    select="concat('[&quot;misc&quot;, &quot;',lower-case(replace(./z:itemType,'([A-Z])',' $1')),'&quot;]')"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="$exh[$i]"/>
                <xsl:text>"</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>,&#xA;</xsl:text>
        <xsl:text>			"type" :     "Publication",&#xA;</xsl:text>
        <xsl:choose>
            <xsl:when test="fn:count(dc:subject) = 1">
                <xsl:text>			"keywords" : "</xsl:text>
                <xsl:value-of select="f:esc(dc:subject)"/>
                <xsl:text>",&#xA;</xsl:text>
            </xsl:when>
            <xsl:when test="fn:count(dc:subject) > 1">
                <xsl:text>			"keywords" :  [&#xA;</xsl:text>
                <xsl:for-each select="dc:subject[position() &lt; last()]">
                    <xsl:value-of select="concat('				&quot;',f:esc(.),'&quot;,&#xA;')"/>
                </xsl:for-each>
                <xsl:value-of select="concat('				&quot;',f:esc(dc:subject[last()]),'&quot;&#xA;')"/>
                <xsl:text>],&#xA;</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:apply-templates/>
        <xsl:variable name="links"
            select="distinct-values(.//dcterms:URI/rdf:value|.[starts-with(@rdf:about,'http')]/@rdf:about|//z:Attachment[@rdf:about=$pub/link:link/@rdf:resource]//rdf:value)"/>
        <xsl:choose>
            <xsl:when test="count($links)=1">
                <xsl:text>            "url" :      "&lt;a href=\"</xsl:text>
                <xsl:value-of select="f:esc($links)"/>
                <xsl:text>\"&gt;link&lt;\/a&gt;",&#xA;</xsl:text>
            </xsl:when>
            <xsl:when test="count($links) &gt; 1">
                <xsl:text>            "url" :      [&#xA;</xsl:text>
                <xsl:for-each select="$links[position() &lt; last()]">
                    <xsl:value-of
                        select="concat('				&quot;&lt;a href=\&quot;',f:esc(.),'\&quot;&gt;link&lt;\/a&gt;&quot;,&#xA;')"
                    />
                </xsl:for-each>
                <xsl:value-of
                    select="concat('				&quot;&lt;a href=\&quot;',f:esc($links[last()]),'\&quot;&gt;link&lt;\/a&gt;&quot;&#xA;')"/>
                <xsl:text>],&#xA;</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>			"id" :       "</xsl:text>
        <xsl:value-of select="f:esc(generate-id(.))"/>
        <xsl:text>"&#xA;		},&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="z:Attachment|rdf:RDF/bib:Journal"/>

    <!-- Descendents of the root element -->
    <xsl:template match="bib:Journal/dc:title">
        <xsl:text>			"journal" :  "</xsl:text>
        <xsl:value-of select="f:esc(.)"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="bib:pages">
        <xsl:text>			"pages" :    "</xsl:text>
        <xsl:value-of select="replace(.,'-','&amp;ndash;')"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="bib:Series/dc:title">
        <xsl:text>			"series" :   "</xsl:text>
        <xsl:value-of select="f:esc(.)"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="bib:Series/dc:identifier">
        <xsl:text>			"number" :   "</xsl:text>
        <xsl:value-of select="replace(.,'-','&amp;ndash;')"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="dc:date">
        <xsl:text>			"date" :     "</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>",&#xA;</xsl:text>
        <xsl:text>			"year" :     "</xsl:text>
        <xsl:value-of select="f:yr(.)"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="bib:authors|bib:editors|z:translators">
        <xsl:text>			"</xsl:text>
        <xsl:value-of select="fn:replace(fn:local-name(.),'ors','or')"/>
        <xsl:text>" :   </xsl:text>
        <!-- Differentiate between single and multiple authors -->
        <xsl:choose>
            <xsl:when test="fn:count(.//foaf:Person) = 1">
                <xsl:value-of
                    select="concat('&quot;',.//foaf:surname,', ',.//foaf:givenname,'&quot;,&#xA;')"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>["</xsl:text>
                <xsl:variable name="i" as="item()+">
                    <xsl:for-each select=".//foaf:Person">
                        <xsl:value-of select="fn:string-join(*,', ')"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="fn:string-join($i,'&quot;, &quot;')"/>
                <xsl:text>"],&#xA;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="dc:publisher//foaf:name">
        <xsl:text>			"publisher" :"</xsl:text>
        <xsl:value-of select="f:esc(.)"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="dc:publisher//vcard:locality">
        <xsl:text>			"address"   :"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="bib:Journal/prism:volume">
        <xsl:text>			"volume" :   "</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template
        match="rdf:RDF/bib:Book/dc:title|bib:Article/dc:title|bib:BookSection/dc:title|bib:Thesis/dc:title|bib:Document/dc:title|rdf:RDF/rdf:Description/dc:title[1]">
        <xsl:text>			"label" :    "</xsl:text>
        <xsl:value-of select="f:esc(.)"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="dcterms:isPartOf/bib:Book/dc:title|rdf:Description/dc:title[2]">
        <xsl:text>			"booktitle" :"</xsl:text>
        <xsl:value-of select="f:esc(.)"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="z:itemType[text()='webpage']">
        <xsl:text>			"howpublished" :"</xsl:text>
        <xsl:value-of select="f:esc(..//rdf:value)"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>
    <xsl:template match="dcterms:isReferencedBy|dcterms:abstract">
        <xsl:text>			"annote" :   "</xsl:text>
        <xsl:variable name="i" select="@rdf:resource"/>
        <xsl:variable name="j"
            select="f:esc(fn:string-join((//bib:Memo[@rdf:about=$i]/rdf:value,./text()),'&lt;br/&gt;'))"/>
        <xsl:variable name="k"
            select="replace($j,' -([a-zA-Z]+)',' &lt;span class=\\&quot;bibsig\\&quot;&gt;-$1&lt;\\/span&gt;')"/>
        <xsl:value-of select="$k"/>
        <xsl:text>",&#xA;</xsl:text>
    </xsl:template>

    <xsl:function name="f:esc" as="xs:string">
        <!-- 2013-03-31, Kalvesmaki; escapes JSON chars -->
        <xsl:param name="str"/>
        <xsl:variable name="vQuo">"</xsl:variable>
        <xsl:variable name="i" select="replace($str,'/','\\/')"/>
        <xsl:variable name="j" select="replace($i,'\n','')"/>
        <xsl:variable name="k" select="replace($j,$vQuo,fn:concat('\\',$vQuo))"/>
        <xsl:value-of select="$k"/>
    </xsl:function>
    <xsl:function name="f:yr">
        <!-- 2013-04-02, Kalvesmaki; extracts first 4-digit year from string, returns as integer -->
        <xsl:param name="str" as="xs:string"/>
        <xsl:variable name="x" select="replace($str,'.*([0-9]{4}).*','$1')"/>
        <xsl:choose>
            <xsl:when test="matches($x,'[0-9]{4}')">
                <xsl:value-of select="$x"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>0</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
