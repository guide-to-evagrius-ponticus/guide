<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tan="tag:textalign.net,2015:ns"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="distribute-vocabulary" select="true()"/>
    
    <!-- When citing scripta, what actions should have priority? -->
    <xsl:param name="scripta-claim-priority-sequence" as="xs:string+" select="('edits', 'transcribes', 'translates', 'quotes')"/>
    <xsl:param name="scripta-claim-priority-sequence-labels" as="xs:string+" select="('editions', 'transcriptions', 'translations', 'extracts')"/>
    
    <xsl:template match="tan:item/tan:desc" mode="reduce-tan-voc-files">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!--<xsl:variable name="corpus-collection-adjusted" as="document-node()*">
        <xsl:apply-templates select="$corpus-collection-resolved" mode="expand-work-element"/>
    </xsl:variable>-->
    <!--<xsl:template match="tan:work" mode="expand-work-element">
        <xsl:variable name="this-vocabulary" select="tan:element-vocabulary(.)" as="element()*"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <xsl:copy-of select="$this-vocabulary/tan:item/*"/>
        </xsl:copy>
    </xsl:template>-->
    
    <xsl:param name="works-to-exclude-regex-on-IRI">fra-Guillaumont</xsl:param>
    <xsl:variable name="language-priority-list" as="xs:string+" select="('grc', 'lat', 'eng')"/>
    
    <xsl:template match="table[@id = 'corpus-table']" mode="template-to-corpus">
        <xsl:variable name="work-vocab-items" select="tan:vocabulary('work', (), $corpus-claims-expanded/tan:TAN-A/tan:head)"/>
        
        <div class="links-to-other-formats">Other formats: <a
            href="{($corpus-claims-expanded/tan:TAN-A/tan:head/tan:master-location/@href)[1]}">TAN-A</a>
            (master)</div>
        <div class="search">
            <div>Search</div>
            <input class="search" type="search" data-column="all"/>
        </div>
        <table class="tablesorter search show-last-col-only" id="corpus-table">
            <thead>
                <tr>
                    <td>Title and description</td>
                    <td>Author</td>
                    <td>Language</td>
                    <td>Portion extant</td>
                    <td>CPG</td>
                    <!-- we add a filler because in our css we are going to hide the first five columns in the tbody, and we need to balance them with an equal number of columns in the thead -->
                    <td colspan="5" class="filler"/>
                </tr>
                <!--<tr>
                    <td rowspan="2">Title and description</td>
                    <td rowspan="2">Author</td>
                    <td colspan="2">Original</td>
                    <td rowspan="2">CPG</td>
                    <td colspan="5" rowspan="2" class="filler"/>
                </tr>
                <tr>
                    <td>lang</td>
                    <td>extant (%)</td>
                </tr>-->
            </thead>
            <tbody>
                <xsl:for-each
                    select="$work-vocab-items/(tan:item[tan:affects-element = 'work'], tan:work)[tan:IRI[not(matches(., $works-to-exclude-regex-on-IRI))]]">
                    <!-- Sort the table rows by CPG number, putting the 'nocpg' numbers at the end -->
                    <xsl:sort select="(tan:IRI[matches(., 'cpg')])[1]"/>
                    <xsl:apply-templates select="." mode="#current">
                        <xsl:with-param name="number-of-visible-sort-columns" select="5" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:for-each>
                
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="tan:*" mode="template-to-corpus">
        <!-- This template shallow skips tan elements, but shallow copies html elements -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:variable name="base-evagrius-folder" select="resolve-uri('../..', static-base-uri())"/>
    <xsl:template match="tan:item | tan:work | tan:version" mode="template-to-corpus">
        <!-- This very long template builds a <td> row corresponding to a single work or work-version.
            Because this deals with versions, it is recursive/nestable. Each row's <td> cells are data about the work-version. -->
        <xsl:param name="number-of-visible-sort-columns" as="xs:integer" select="4" tunnel="yes"/>
        <!-- In the variables below we use "work" to refer not merely to works but to work-versions. This template applies first to Evagrius's work 
            such-and-such, and then to each translation of work such-and-such. -->
        <xsl:variable name="this-work-item" select="."/>
        <!--<xsl:variable name="this-work-id" select="(tan:id, @xml:id)[1]"/>-->
        <xsl:variable name="this-work-id" select="(tan:name[matches(., 'cpg')])[1]"/>
        <xsl:variable name="this-cpg-id" as="xs:string?"
            select="analyze-string($this-work-id, '(no)?cpg[\d.]+[ab]?')/*:match"/>
        <!-- The primary subfolder should be in the form (no)?cpg\d+ -->
        <xsl:variable name="this-base-html-folder-uri-resolved"
            select="resolve-uri('../../' || $this-cpg-id, static-base-uri())"/>
        <xsl:variable name="these-html-uris-resolved" as="xs:anyURI*">
            <xsl:try select="uri-collection($this-base-html-folder-uri-resolved)">
                <xsl:catch>
                    <xsl:message select="'No HTML files at ' || $this-base-html-folder-uri-resolved"
                    />
                </xsl:catch>
            </xsl:try>
        </xsl:variable>
        <xsl:variable name="this-html-transcription-collection" as="document-node()*">
            <xsl:for-each select="$these-html-uris-resolved">
                <xsl:choose>
                    <xsl:when test="doc-available(.)">
                        <xsl:sequence select="doc(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="'Doc not available at ' || ."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="this-is-a-version" select="(name(.) = 'version') or (tan:affects-element = 'version')"/>
        <xsl:variable name="these-work-names-sorted" as="element()*">
            <xsl:for-each select="$this-work-item/tan:name[not(@norm)][not(matches(., 'cpg'))]">
                <!-- Sort the names by language priority -->
                <xsl:sort select="
                        if (exists(@xml:lang)) then
                            index-of($language-priority-list, @xml:lang)
                        else
                            999"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="these-work-iris" select="tan:IRI"/>
        <!-- Find transcriptions for the work at hand -->
        <xsl:variable name="corresponding-transcription-vocabulary-item" as="element()*"
            select="$corpus-collection-resolved/*/tan:head//(tan:work, tan:version, tan:item[tan:affects-element = ('work', 'version')])[tan:IRI = $these-work-iris]"
        />
        <xsl:variable name="this-work-tan-transcriptions"
            select="$corresponding-transcription-vocabulary-item/root()"/>
        <!--<xsl:variable name="this-work-tan-transcriptions-without-bibliography" select="$corresponding-transcription-vocabulary-item[not(tan:IRI = $bibliography-prepped/*/*/dc:description)]"/>-->
        
        <!-- Find all assertions about the work at hand -->
        <xsl:variable name="claims-with-this-work-as-subject"
            select="
                $corpus-claims-expanded/tan:TAN-A/tan:body/tan:claim[tan:subject/(self::tan:subject, tan:which)[*/tan:IRI = $these-work-iris]]"
        />
        <xsl:variable name="claims-with-this-work-as-object"
            select="
                $corpus-claims-expanded/tan:TAN-A/tan:body/tan:claim[tan:object/(self::tan:object, tan:which)[*/tan:IRI = $these-work-iris]]"
        />
        <!-- If the work is merely an object filter, then the claim is really about two or more other things, e.g., scriptum A transcribes scriptum B's version
        of work such-and-such. -->
        <xsl:variable name="claims-with-this-work-as-object-filter"
            select="
                $corpus-claims-expanded/tan:TAN-A/tan:body/tan:claim[tan:object[tan:which]/(tan:work, tan:version)[*/tan:IRI = $these-work-iris]]"
        />

        <!-- How does the work-version begin? -->
        <xsl:variable name="work-claims-re-incipit"
            select="$claims-with-this-work-as-subject[tan:verb[*/tan:name = 'has incipit']]"/>
        <!-- In what language was the work originally written? (Some spurious works were really written not in Greek but in Syriac.) -->
        <xsl:variable name="work-claims-re-original-language"
            select="$claims-with-this-work-as-subject[tan:verb[*/tan:name = 'originally written']]"/>
        <xsl:variable name="this-orig-lang-code"
            select="$work-claims-re-original-language/tan:in-lang"/>
        <xsl:variable name="this-orig-lang-statement"
            select="
                for $i in $work-claims-re-original-language
                return
                    concat(tan:lang-name($i/tan:in-lang)[1], if (exists($i/tan:adverb)) then
                        concat(' (', $i/tan:adverb/text(), ')')
                    else
                        ())"/>
        
        <!-- Look for claims about what scripta edit, translate, transcribe, etc. the work at hand. -->
        <xsl:variable name="work-claims-involving-scripta"
            select="$claims-with-this-work-as-object[tan:subject[(self::*, tan:which)/(tan:scriptum, tan:item[tan:affects-element = 'scriptum'])]]"
        />
        
        
        <xsl:variable name="work-claims-re-translations"
            select="$claims-with-this-work-as-object[tan:verb[*/tan:name = 'translates']]"/>
        <!--<xsl:variable name="ancient-translation-idrefs"
            select="$work-claims-re-ancient-translations/tan:subject"/>-->
        <!--<xsl:variable name="ancient-translation-vocabulary-items" select="tan:vocabulary('version', false(), $ancient-translation-idrefs, $corpus-claims-expanded/tan:TAN-A/tan:head)"/>-->
        
        <!-- The following scripta are claimed to translate the work at hand -->
        <xsl:variable name="scripta-translation-items"
            select="$work-claims-re-translations/tan:subject/(self::*, tan:which)/(tan:scriptum, tan:item[tan:affects-element = 'scriptum'][not(tan:IRI = $these-work-iris)])"
        />
        <!-- The following translations are not scripta but abstract entities, i.e., work-versions in their own right, all of them ancient translations. -->
        <xsl:variable name="version-translation-items"
            select="$work-claims-re-translations/tan:subject/(self::*, tan:which)/(tan:version, tan:item[not(tan:affects-element = 'scriptum')][not(tan:IRI = $these-work-iris)])"
        />
        <!--<xsl:variable name="ancient-translation-vocabulary-items" select="$work-claims-re-translations/tan:subject//*[tan:IRI]"/>-->
        
        <!-- Who or what has edited the work-version at hand? -->
        <xsl:variable name="work-claims-re-editions"
            select="$claims-with-this-work-as-object[tan:verb[*/tan:name = 'edits']]"/>
        <!-- What scripta provide editions of the work-version at hand? -->
        <xsl:variable name="scripta-edition-items"
            select="$work-claims-re-editions/tan:subject/(self::*, tan:which)/(tan:scriptum, tan:item[tan:affects-element = 'scriptum'][not(tan:IRI = $these-work-iris)])"
        />
        
        <!-- Who is claimed to be the author/creator? Not all works attributed to Evagrius are reliably attributed to him. -->
        <xsl:variable name="work-claims-re-authorship"
            select="$claims-with-this-work-as-object[tan:verb[*/tan:name = 'is author of']]"/>
        <!-- How much of the work-version at hand survives? -->
        <xsl:variable name="work-claims-re-portion-extant"
            select="$claims-with-this-work-as-subject[tan:verb[*/tan:IRI = 'tag:kalvesmaki.com,2014:verb:work-survives-in-original-language']]"/>
        <!-- Is the work extant? -->
        <xsl:variable name="work-is-extant" select="not(matches(normalize-space($work-claims-re-portion-extant/tan:object/text()), '^0?\.?0$'))"/>
        <!--<xsl:variable name="work-claims-re-modern-editions" select="$claims-with-this-work-as-object[tan:subject[.//tan:affects-element = 'scriptum']]"/>-->
        <!--<xsl:variable name="modern-edition-iris" select="$work-claims-re-modern-editions/tan:subject//tan:IRI"/>-->
        <!--<xsl:variable name="this-id-to-be-searched-in-bibliography"
            select="concat(replace($this-work-id, '^cpg', ''), ' (translation|edition)')"/>-->
        <!--<xsl:variable name="this-id-regex-for-bibliography">
            <xsl:choose>
                <xsl:when test="$this-is-a-version">
                    <!-\- Version ids have the form (no)?cpg0000a?-LNG -\->
                    <xsl:variable name="id-parts" select="tokenize($this-work-id, '-')"/>
                    <xsl:value-of select="concat(replace($id-parts[1], '^(no)?cpg', ''), ' edition ', tan:lang-name($id-parts[2]))"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-\- Work ids have the form (no)?cpg0000a? -\->
                    <xsl:value-of select="concat(replace($this-work-id, '^(no)?cpg', ''), ' (translation|edition)')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>-->
        <!--<xsl:variable name="bibliography-refs-to-this-work" as="element()*"
            select="$bibliography-prepped/*/*[*:subject[matches(., $this-id-regex-for-bibliography)]]"/>-->
        
        <!-- Find all bibliographical entries that are said to be editions or translations of the work -->
        <xsl:variable name="bibliography-refs-to-this-work" as="element()*"
            select="$bibliography-rdf-file/*/*[dc:description = ($scripta-translation-items/tan:IRI, $scripta-edition-items/tan:IRI)]"/>
        
        <!-- Look for a collated parallel HTML edition. -->
        <!--<xsl:variable name="this-collated-edition-url" select="concat($this-work-id, '.html')"/>-->
        <!--<xsl:variable name="collated-edition-available"
            select="doc-available(concat('../', $this-collated-edition-url))"/>-->
        <xsl:variable name="this-cpg-norm"
            select="normalize-space(replace($this-work-id, 'cpg', ' CPG '))"/>
        <!-- contains($this-cpg-id, '2430') and exists($work-claims-involving-scripta) and $this-is-a-version -->
        <xsl:variable name="diagnostics-on" select="false()"/>
        <xsl:if test="$diagnostics-on">
            <xsl:message select="'Diagnostics on, template mode template-to-corpus'"/>
            <xsl:message select="'Work item: ', $this-work-item"/>
            <xsl:message select="'Work id: ' || $this-work-id"/>
            <xsl:message select="'CPG id: ' || $this-cpg-id"/>
            <xsl:message select="'Base HTML folder uri: ' || $this-base-html-folder-uri-resolved"/>
            <xsl:message select="'HTML URIs: ' || string-join($these-html-uris-resolved, ' ')"/>
            <xsl:message select="'This is a version: ', $this-is-a-version"/>
            <xsl:message select="'Work names sorted: ' || string-join($these-work-names-sorted, '; ')"/>
            <xsl:message select="'Work IRIs: ' || string-join($these-work-iris, '; ')"/>
            <xsl:message select="'Transcription vocab item: ', $corresponding-transcription-vocabulary-item"/>
            <xsl:message select="'TAN transcriptions for this work (' || string(count($this-work-tan-transcriptions)) || ')'"/>
            <xsl:message select="'Claims with this work as subject: ', $claims-with-this-work-as-subject"/>
            <xsl:message select="'Claims with this work as object: ', $claims-with-this-work-as-object"/>
            <xsl:message select="'Claims with this work as object filter: ', $claims-with-this-work-as-object-filter"/>
            <xsl:message select="'Work claims re incipit:', $work-claims-re-incipit"/>
            <xsl:message select="'Work claims re original language:', $work-claims-re-original-language"/>
            <xsl:message select="'This orig. lang code: ' || string-join($this-orig-lang-code, ', ')"/>
            <xsl:message select="'This orig. lang statement: ' || $this-orig-lang-statement"/>
            <xsl:message select="'Work claims involving scripta: ', $work-claims-involving-scripta"/>
            <xsl:message select="'Work claims re translations:', $work-claims-re-translations"/>
            <xsl:message select="'Scripta translation items: ', $scripta-translation-items"/>
            <xsl:message select="'Version translation items: ', $version-translation-items"/>
            <xsl:message select="'Work claims re editions:', $work-claims-re-editions"/>
            <xsl:message select="'Scripta edition items: ', $scripta-edition-items"/>
            <xsl:message select="'Work claims re authorship:', $work-claims-re-authorship"/>
            <xsl:message select="'Work claims re portion extant:', $work-claims-re-portion-extant"/>
            <xsl:message select="'Work is extant?', $work-is-extant"/>
            <xsl:message select="'Bibliography refs to this work: ', $bibliography-refs-to-this-work"/>
            <xsl:message select="'CPG norm: ', $this-cpg-norm"/>
        </xsl:if>

        <tr id="{$this-work-id}">
            <!-- Next several <td>s are invisible, corresponding to sort columns in <thead> -->
            <td>
                <xsl:apply-templates select="$these-work-names-sorted"
                    mode="template-to-corpus-td-content"/>
            </td>
            <td>
                <div>
                    <xsl:value-of
                        select="string-join(($work-claims-re-authorship/ancestor-or-self::*[tan:subject][1]/tan:subject/text(), $work-claims-re-authorship/ancestor-or-self::*[tan:adverb][1]/tan:adverb/text()), ' ')"/>
                </div>
            </td>
            <td>
                <xsl:apply-templates select="$work-claims-re-original-language/tan:in-lang"
                    mode="template-to-corpus-td-content"/>
            </td>
            <td>
                <xsl:apply-templates select="$work-claims-re-portion-extant/tan:object"
                    mode="template-to-corpus-td-content"/>
            </td>
            <xsl:if test="$number-of-visible-sort-columns = 5">
                <td>
                    <xsl:value-of select="$this-cpg-norm"/>
                </td>
            </xsl:if>
            <!-- The only column of the table that's visible -->
            <!-- The trick here is that @colspan should be identical to the number of visible sort columns in the thead -->
            <td colspan="{$number-of-visible-sort-columns}">
                <div class="id-label">
                    <div class="cpg-no">
                        <xsl:value-of select="$this-cpg-norm"/>
                    </div>
                    <xsl:apply-templates select="tan:IRI" mode="template-to-corpus-td-content"/>
                </div>
                <div class="names">
                    <div><xsl:value-of select="$these-work-names-sorted[1]"/></div>
                    <div class="aliases">
                        <xsl:if test="count($these-work-names-sorted) gt 1">
                            <xsl:value-of select="'Other names: '"/> 
                        </xsl:if>
                        <xsl:for-each-group select="$these-work-names-sorted[position() gt 1]"
                            group-by="replace(lower-case(.), '[\W]+', '')">
                            <xsl:if test="position() gt 1">
                                <xsl:value-of select="', '"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:for-each-group> 
                    </div>
                    
                </div>
                <xsl:if test="not($this-orig-lang-code = 'grc') and not($this-is-a-version)">
                    <div class="orig-lang">Written originally in <xsl:value-of
                            select="$this-orig-lang-statement"/>. </div>
                </xsl:if>
                <xsl:apply-templates select="$work-claims-re-portion-extant/tan:object"
                    mode="template-to-corpus-portion-extant"/>
                <xsl:apply-templates select="$work-claims-re-authorship"
                    mode="template-to-corpus-authorship-claim"/>
                <xsl:apply-templates select="tan:desc" mode="template-to-corpus-td-content"/>
                <xsl:apply-templates select="$work-claims-re-incipit/tan:object"
                    mode="template-to-corpus-incipit"/>
                
                <xsl:if test="exists($these-html-uris-resolved) and not($this-is-a-version)">
                    <div class="html-editions">
                        <select onchange="location = this.options[this.selectedIndex].value;">
                            <option>Read transcriptions</option>
                            <xsl:for-each select="$these-html-uris-resolved">
                                <xsl:sort
                                    select="
                                        if (contains(., '-full-')) then
                                            1
                                        else
                                            2"
                                />
                                <xsl:sort select="."/>
                                <xsl:variable name="this-doc" select="doc(.)"/>
                                <xsl:variable name="these-titles" 
                                    select="$this-doc/html:html/html:body/html:div/(html:h1 | html:div[contains-token(@class, 'e-head')]//html:div[contains-token(@class, 'e-name')])"/>
                                <xsl:variable name="this-clarification" as="xs:string?">
                                    <xsl:choose>
                                        <xsl:when test="contains(., 'full-for-reading')">
                                            <xsl:value-of select="' (reading optimized)'"/>
                                        </xsl:when>
                                        <xsl:when test="contains(., 'full-for-search')">
                                            <xsl:value-of select="' (search optimized)'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:variable>
                                <option value="{tan:uri-relative-to(., $base-evagrius-folder)}">
                                    <xsl:value-of select="$these-titles[1] || $this-clarification"/>
                                </option>
                                
                            </xsl:for-each> 
                        </select>​
                    </div>
                </xsl:if>
                
                <xsl:if test="exists($version-translation-items)">
                    <xsl:variable name="ancient-translations-grouped" as="element()*"
                        select="tan:group-elements-by-IRI($version-translation-items)"/>
                    <div class="ancient-translations collapse">
                        <div class="label">Ancient translations</div>
                        
                        <table class="tablesorter show-last-col-only">
                            <thead>
                                <tr>
                                    <td>Title and description</td>
                                    <td>Creator</td>
                                    <td>Language</td>
                                    <td>Portion extant</td>
                                    <td colspan="4" class="filler"/>
                                </tr>
                                <!--<tr>
                                    <td rowspan="2">Title and description</td>
                                    <td rowspan="2">Authorship</td>
                                    <td colspan="2">Original</td>
                                    <!-\- the last <td>'s @colspan is equal to the number of preceding columns; it is invisible, 
                                        counterbalancing the initial hidden columns in the table's body -\->
                                    <td colspan="4" rowspan="2" class="filler"/>
                                </tr>
                                <tr>
                                    <td>lang</td>
                                    <td>extant (%)</td>
                                </tr>-->
                            </thead>
                            <tbody>
                                <xsl:for-each select="$ancient-translations-grouped/*[1]">
                                    <xsl:sort select="(.//tan:name[matches(., 'cpg')])[1]"/>
                                    <xsl:apply-templates select="." mode="#current">
                                        <xsl:with-param name="number-of-visible-sort-columns"
                                            tunnel="yes" select="4"/>
                                    </xsl:apply-templates>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </div>
                </xsl:if>
                
                <div class="ed-and-tr">
                    <!-- Group scripta according to type. -->
                    <xsl:for-each-group select="$work-claims-involving-scripta"
                        group-by="tan:verb//tan:name[. = $scripta-claim-priority-sequence]">
                        <xsl:sort
                            select="index-of($scripta-claim-priority-sequence, current-grouping-key())"/>
                        <xsl:variable name="this-type-index"
                            select="index-of($scripta-claim-priority-sequence, current-grouping-key())"/>
                        <xsl:variable name="this-type"
                            select="$scripta-claim-priority-sequence-labels[$this-type-index]"/>
                        <div class="{current-grouping-key()} collapse">
                            <div class="label">
                                <xsl:value-of select="$this-type"/>
                            </div>
                            <table class="tablesorter scripta">
                                <thead>
                                    <tr>
                                        <xsl:if test="$this-type = 'translations'">
                                            <td class="scriptum-lang">Language</td>
                                        </xsl:if>
                                        <td class="scriptum-date">Date</td>
                                        <td class="scriptum-data">Source</td>
                                    </tr>
                                </thead>
                                <tbody>
                                    
                                    <xsl:for-each select="current-group()/tan:subject">
                                        <!-- The date needs to be finagled a bit, because some dc:date values are ranges of years. -->
                                        <xsl:sort order="descending"
                                            select="number(replace(($bibliography-rdf-file/*/*[dc:description = current()/(self::*, tan:which)/(tan:scriptum, tan:item[tan:affects-element = 'scriptum'])/tan:IRI]/dc:date)[1],'^\D*(\d+)\D.*$','$1'))"/>
                                        <xsl:variable name="these-scriptum-iris"
                                            select="(self::*, tan:which)/(tan:scriptum, tan:item[tan:affects-element = 'scriptum'])/tan:IRI"/>
                                        <xsl:variable name="these-bib-records"
                                            select="$bibliography-rdf-file/*/*[dc:description = $these-scriptum-iris]"/>
                                        <xsl:variable name="this-date"
                                            select="(($these-bib-records/dc:date), '?')[1]"/>
                                        <!-- We adjust the language name to avoid parenthetical dates -->
                                        <xsl:variable name="these-lang-codes" select="../tan:in-lang"/>
                                        <xsl:variable name="this-lang"
                                            select="
                                                for $i in $these-lang-codes
                                                return
                                                    replace(tan:lang-name($i)[1], ' \(\d+-\)|\(to \d+\)', '')"/>
                                        <xsl:variable name="this-work-object"
                                            select="../tan:object[.//tan:IRI = $these-work-iris]"/>
                                        <xsl:variable name="these-author-names"
                                            select="$these-bib-records//foaf:surname"/>
                                        <xsl:variable name="this-short-identifier"
                                            select="
                                                string-join(if (exists($these-author-names)) then
                                                    $these-author-names
                                                else
                                                    $these-bib-records/dc:title, ', ')"/>
                                        <xsl:variable name="this-where" as="item()*">
                                            <xsl:copy-of
                                                select="tan:rdf-bib-to-chicago-humanities-bibliography-html($these-bib-records)"
                                            />
                                        </xsl:variable>
                                        <xsl:variable
                                            name="these-relevant-supplementary-claims-with-this-scriptum-as-subject"
                                            select="$claims-with-this-work-as-object-filter[tan:subject[descendant::tan:IRI = $these-scriptum-iris]]"/>
                                        <xsl:variable
                                            name="these-relevant-supplementary-claims-with-this-scriptum-as-object"
                                            select="$claims-with-this-work-as-object-filter[tan:object[descendant::tan:IRI = $these-scriptum-iris]]"/>
                                        <!-- grab all html pages that have a head entry for that particular scriptum and work combo; the XPath is unfortunately too long to read easily -->
                                        <!--<xsl:variable name="these-html-editions-first-check"
                                            select="$html-transcription-collection[html:html/html:body//html:div[tokenize(@class, ' ') = 'head'][.//html:div[@class = 'source' and .//html:div[@class = 'IRI'] = $these-scriptum-iris]][.//html:div[@class = ('work', 'version') and .//html:div[@class = 'IRI'] = $these-work-iris]]]"/>-->
                                        <xsl:variable name="these-html-editions-first-check"
                                            select="$this-html-transcription-collection[html:html/html:body//html:div[contains-token(@class, 'e-head')][.//html:div[contains-token(@class, 'e-source') and .//html:div[contains-token(@class, 'e-IRI')] = $these-scriptum-iris]][.//html:div[tokenize(@class, ' ') = ('e-work', 'e-version') and .//html:div[contains-token(@class, 'e-IRI')] = $these-work-iris]]]"/>
                                       <!-- We refine further, to avoid cases where we're listing translations, and other version of that work have leaked in. This is not an accurate
                                       fix, but it has to do for now, so as not to delay the 2020 edition any further. --> 
                                        <xsl:variable name="these-html-editions"
                                            select="
                                                if (exists($these-lang-codes)) then
                                                    $these-html-editions-first-check[html:html/html:body//html:div[contains-token(@class, 'e-body')][.//@lang = $these-lang-codes]]
                                                else
                                                    $these-html-editions-first-check"
                                        />
                                        <xsl:variable name="these-comments" as="item()*">
                                            <xsl:if test="exists(../@adverb)">
                                                <div class="adverb">
                                                    <!-- We expect that if there are multiple values of @adverb, the order and terminology is already best expressed in the original attribute. -->
                                                    <xsl:value-of select="tan:initial-upper-case(../@adverb || ' ' || ../@verb || '. ')"/>
                                                </div>
                                            </xsl:if>
                                            <xsl:apply-templates select="." mode="explain-div-filter">
                                                <xsl:with-param name="initial-text" select="'See '"/>
                                                <xsl:with-param name="final-text" select="'. '"/>
                                            </xsl:apply-templates>
                                            <xsl:apply-templates select="$this-work-object" mode="explain-div-filter">
                                                <xsl:with-param name="initial-text" select="'Restricted to '"/>
                                                <xsl:with-param name="final-text" select="'. '"/>
                                            </xsl:apply-templates>
                                            
                                            <!-- We now add comments about how one scriptum relates with another, e.g., Dysinger transcribes Guillaumont's edition of work such-and-such -->
                                            <!--<xsl:message select="'xrefs: ', $these-relevant-supplementary-claims-with-this-scriptum-as-subject, $these-relevant-supplementary-claims-with-this-scriptum-as-object"/>-->
                                            <xsl:if test="exists($these-relevant-supplementary-claims-with-this-scriptum-as-subject) or exists($these-relevant-supplementary-claims-with-this-scriptum-as-object)">
                                                <div class="xrefs collapse">
                                                    <div class="label">cross-references</div>
                                                    <xsl:apply-templates
                                                        select="$these-relevant-supplementary-claims-with-this-scriptum-as-subject"
                                                        mode="claim-to-comments-subject-understood">
                                                        <xsl:with-param name="subject-iris" select="$these-scriptum-iris" tunnel="yes"/>
                                                        <xsl:with-param name="work-version-iris" select="$these-work-iris" tunnel="yes"/>
                                                    </xsl:apply-templates>
                                                    <xsl:apply-templates
                                                        select="$these-relevant-supplementary-claims-with-this-scriptum-as-object"
                                                        mode="claim-to-comments-object-understood">
                                                        <xsl:with-param name="object-iris" select="$these-scriptum-iris" tunnel="yes"/>
                                                        <xsl:with-param name="work-version-iris" select="$these-work-iris" tunnel="yes"/>
                                                    </xsl:apply-templates>
                                                </div>
                                            </xsl:if>
                                        </xsl:variable>
                                        
                                        
        
                                        <tr>
                                            <xsl:if test="$this-type = 'translations'">
                                                <td class="scriptum-lang">
                                                  <xsl:value-of select="$this-lang"/>
                                                </td>
                                            </xsl:if>
                                            <td class="scriptum-date">
                                                <xsl:value-of select="$this-date"/>
                                            </td>
                                            <td class="scriptum-data">
                                                <div class="scriptum-bibl">
                                                    <xsl:copy-of select="$this-where"/>
                                                </div>
                                                <div class="comment">
                                                    <xsl:copy-of select="$these-comments"/>
                                                </div>
                                                <div class="html-editions">
                                                    <xsl:for-each select="$these-html-editions">
                                                        <xsl:sort
                                                          select="exists(html:html/html:body/html:div[matches(@class, 'merge')])"/>
                                                        <div>
                                                          <a href="{tan:cfne(.)}">
                                                          <xsl:choose>
                                                          <xsl:when
                                                          test="exists(html:html/html:body/html:div[matches(@class, 'merge')]) and contains(base-uri(.), 'for-reading')">
                                                          <xsl:text>collated parallel edition (reading optimized)</xsl:text>
                                                          </xsl:when>
                                                          <xsl:when
                                                          test="exists(html:html/html:body/html:div[matches(@class, 'merge')])">
                                                          <xsl:text>collated parallel edition (search optimized)</xsl:text>
                                                          </xsl:when>
                                                          <xsl:otherwise>
                                                          <xsl:text>transcription</xsl:text>
                                                          </xsl:otherwise>
                                                          </xsl:choose>
                                                          </a>
                                                        </div>
                                                    </xsl:for-each>
                                                </div>
                                            </td>
                                            
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                    </xsl:for-each-group>
                    <xsl:if test="not(exists($work-claims-involving-scripta)) and $work-is-extant">
                        <div class="pending">List of sources pending.</div>
                    </xsl:if>
                </div>
                
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*"
        mode="template-to-corpus-td-content template-to-corpus-portion-extant template-to-corpus-authorship-claim 
        claim-to-comments-subject-understood claim-to-comments-object-understood explain-div-filter">
        <!-- These subtemplates are shallow skips. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <!-- These subtemplates should not include text unless explicitly told to do so -->
    <xsl:template match="text()" mode="template-to-corpus-authorship-claim explain-div-filter claim-to-comments-subject-understood claim-to-comments-object-understood"/>
    <xsl:template match="tan:in-lang" mode="template-to-corpus-td-content">
        <div class="in-lang">
            <xsl:value-of select="tan:lang-name(text())"/>
        </div>
    </xsl:template>
    <xsl:template match="tan:name | tan:object | tan:IRI | tan:desc" mode="template-to-corpus-td-content">
        <div class="{name(.)}">
            <xsl:value-of select="text()"/>
        </div>
    </xsl:template>
    <xsl:template match="tan:object" mode="template-to-corpus-portion-extant">
        <xsl:variable name="amount-extant-double" select="number(text())" as="xs:double?"/>
        <xsl:variable name="amount-extant-percent"
            select="format-number($amount-extant-double, '#%')"/>
        <xsl:if test="$amount-extant-double lt 1">
            <div class="orig-extant">
                <xsl:choose>
                    <xsl:when test="$amount-extant-double le 0">
                        <xsl:text>None of the original survives.</xsl:text>
                    </xsl:when>
                    <xsl:when test="$amount-extant-double le .7">
                        <xsl:value-of
                            select="concat('Only ', $amount-extant-percent, ' of the original is extant.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="concat($amount-extant-percent, ' of the original is extant.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tan:claim[not(tan:adverb/text() = 'not')]" mode="template-to-corpus-authorship-claim">
        <xsl:variable name="this-subject" select="ancestor-or-self::*[tan:subject][1]/tan:subject"/>
        <xsl:variable name="this-adverb" select="ancestor-or-self::*[tan:adverb][1]/tan:adverb"/>
        <xsl:variable name="this-claim-is-trivial"
            select="not(exists($this-adverb)) and $this-subject//tan:name = 'evagrius ponticus'"/>
        <xsl:if test="not($this-claim-is-trivial)">
            <div class="claim">
                <xsl:apply-templates select="$this-subject" mode="#current"/>
                <xsl:apply-templates select="$this-adverb" mode="#current"/>
                <xsl:choose>
                    <xsl:when test="$this-adverb/text() = 'improbably'">
                        <xsl:text> write this work.</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> wrote this work.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tan:subject" mode="template-to-corpus-authorship-claim">
        <xsl:variable name="this-vocab-item" select="*"/>
        <xsl:variable name="this-first-name" select="($this-vocab-item//tan:name)[1]"/>
        <xsl:value-of select="tan:title-case($this-first-name)"/>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="tan:adverb" mode="template-to-corpus-authorship-claim">
        <xsl:choose>
            <xsl:when test="text() = 'improbably'">
                <xsl:text>probably did not</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tan:object" mode="template-to-corpus-incipit">
        <div class="incipit">
            <xsl:text>Incipit: </xsl:text>
            <xsl:value-of select="."/>
        </div>
    </xsl:template>
    
    <xsl:template match="tan:subject[tan:div] | tan:object[tan:div] | tan:work[tan:div]" mode="explain-div-filter">
        <xsl:param name="initial-text" as="xs:string?"/>
        <xsl:param name="final-text" as="xs:string?"/>
        <xsl:variable name="div-count" select="count(tan:div)"/>
        <div class="{name(.)}-div">
            <xsl:value-of select="$initial-text"/>
            <xsl:apply-templates select="tan:div" mode="explain-div-filter"/>
            <!--<xsl:for-each-group select="tan:div" group-by="@type">
                <xsl:variable name="is-plural"
                    select="
                        count(current-group()/@n) gt 1 or (some $i in current-group()/@n
                            satisfies matches($i, '[,-]'))"/>
                <xsl:variable name="type-suffix"
                    select="
                        if ($is-plural) then
                            's'
                        else
                            ()"/>
                <xsl:value-of
                    select="current-grouping-key() || $type-suffix || ' ' || string-join(current-group()/@n, ', ')"
                />
                <xsl:if test="position() lt $div-count">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each-group>-->
            <xsl:value-of select="$final-text"/>
        </div>
    </xsl:template>
    <xsl:template match="tan:div" mode="explain-div-filter">
        <xsl:variable name="is-plural" select="matches(@n, '[,-]')"/>
        <xsl:variable name="type-suffix"
            select="
                if ($is-plural) then
                    's '
                else
                    ' '"/>
        <xsl:value-of
            select="@type || $type-suffix || ' ' || @n"/>
        <xsl:if test="exists(tan:div)">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="tan:div" mode="#current"/>
        <xsl:if test="exists(following-sibling::tan:div)">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tan:claim" mode="claim-to-comments-subject-understood">
        <xsl:param name="subject-iris" tunnel="yes"/>
        <xsl:param name="work-version-iris" tunnel="yes"/>
        <!-- We make the shaky assumption that an embedded work-version filter is always in the
            object, not the subject. -->
        <xsl:variable name="relevant-objects" select="tan:object[.//tan:IRI = $work-version-iris]"/>
        <div class="claim">
            <xsl:apply-templates select="tan:subject[.//tan:IRI = $subject-iris]"
                mode="explain-div-filter">
                <xsl:with-param name="initial-text" select="'→ At '"/>
            </xsl:apply-templates>
            <xsl:if test="exists(@adverb)">
                <div class="adverb">
                    <!-- We expect that if there are multiple values of @adverb, the order and terminology is already best expressed in the original attribute. -->
                    <xsl:value-of select="@adverb"/>
                </div>
            </xsl:if>
            <div class="verb">
                <xsl:text> </xsl:text>
                <xsl:value-of select="tan:commas-and-ands(tan:verb//tan:name[1])"/>
            </div>
            <xsl:for-each select="$relevant-objects">
                <xsl:variable name="this-scriptum-iris" select="(self::*, tan:which)/(tan:scriptum, tan:item[tan:affects-element = 'scriptum'])/tan:IRI"/>
                <xsl:variable name="this-bib-item" select="$bibliography-rdf-file/*/*[dc:description = $this-scriptum-iris]"/>
                <xsl:copy-of
                    select="tan:rdf-bib-to-chicago-humanities-bibliography-html($this-bib-item)"
                />
                <xsl:apply-templates select="." mode="explain-div-filter"/>
            </xsl:for-each>
        </div>
    </xsl:template>
    <xsl:template match="tan:claim" mode="claim-to-comments-object-understood">
        <xsl:param name="object-iris" tunnel="yes"/>
        <xsl:param name="work-version-iris" tunnel="yes"/>
        <!-- We make the shaky assumption that an embedded work-version filter is always in the
            object, not the subject. -->
        <xsl:variable name="relevant-subjects" select="tan:subject"/>
        <div class="claim">
            <xsl:text>→ </xsl:text>
            <xsl:for-each select="$relevant-subjects">
                <xsl:variable name="this-scriptum-iris" select="(self::*, tan:which)/(tan:scriptum, tan:item[tan:affects-element = 'scriptum'])/tan:IRI"/>
                <xsl:variable name="this-bib-item" select="$bibliography-rdf-file/*/*[dc:description = $this-scriptum-iris]"/>
                <xsl:copy-of
                    select="tan:rdf-bib-to-chicago-humanities-bibliography-html($this-bib-item)"
                />
                <xsl:apply-templates select="." mode="explain-div-filter"/>
            </xsl:for-each>
            <xsl:if test="exists(@adverb)">
                <div class="adverb">
                    <!-- We expect that if there are multiple values of @adverb, the order and terminology is already best expressed in the original attribute. -->
                    <xsl:value-of select="@adverb"/>
                </div>
            </xsl:if>
            <div class="verb">
                <xsl:text> </xsl:text>
                <xsl:value-of select="tan:commas-and-ands(tan:verb//tan:name[1])"/>
            </div>
            <xsl:apply-templates select="tan:object[.//tan:IRI = $object-iris]"
                mode="explain-div-filter">
                <xsl:with-param name="initial-text" select="' at '"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>
    <!--<xsl:template match="tan:subject" mode="claim-to-comments-subject-understood">
        <xsl:apply-templates select="." mode="explain-div-filter">
        </xsl:apply-templates>
    </xsl:template>-->
    <!--<xsl:template match="tan:object" mode="claim-to-comments-object-understood">
        <xsl:apply-templates select="." mode="explain-div-filter">
            <xsl:with-param name="initial-text" select="'At '"/>
        </xsl:apply-templates>
    </xsl:template>-->
    
</xsl:stylesheet>
