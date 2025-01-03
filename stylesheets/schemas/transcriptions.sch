<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
   xmlns:gep="tag:evagriusponticus.net,2012:ns" queryBinding="xslt3"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
   <xsl:include href="xsl-check.xsl"/>
   <sch:ns uri="http://www.w3.org/1999/XSL/Transform" prefix="xsl"/>
   <sch:ns uri="tag:evagriusponticus.net,2012:ns" prefix="gep"/>
   <sch:let name="context-base-uri" value="base-uri(/)"/>
   <sch:let name="current-default-namespace" value="namespace-uri-for-prefix('', /*)"/>
   <sch:let name="current-namespaces" value="/*/namespace::*"/>
   <sch:pattern>
      <sch:rule context="xsl:stylesheet/xsl:param[not(@static)]">
         <sch:let name="this-name" value="@name"/>
         <sch:let name="matching-param"
            value="$all-included-stylesheets/*/xsl:param[@name = $this-name]"/>
         <sch:assert test="exists($matching-param)">In this stylesheet, each param should be found
            in an imported/included stylesheet.</sch:assert>
      </sch:rule>
      <sch:rule context="xsl:map-entry[contains(@key, 'params')]">
         <sch:let name="this-default-ns" value="namespace-uri-for-prefix('', .)"/>
         <sch:let name="target-uri"
            value="replace(../xsl:map-entry[contains(@key, 'stylesheet-location')]/@select, $apos, '')"/>
         <sch:let name="target-stylesheet" value="doc(resolve-uri($target-uri, $context-base-uri))"/>
         <sch:let name="target-default-namespace" value="namespace-uri-for-prefix('', $target-stylesheet/*)"/>
         <sch:let name="target-xpath-default-namespace"
            value="($target-stylesheet/*/@xpath-default-namespace, '')[1]"/>
         <sch:let name="target-xpath-default-namespace-name"
            value="
               if ($target-xpath-default-namespace eq '') then
                  '[NO NAMESPACE]'
               else
                  $target-xpath-default-namespace"
         />
         <sch:report role="warning" test="$this-default-ns ne $target-xpath-default-namespace and
            not($target-xpath-default-namespace = $current-namespaces)"
            >Current default namespace <sch:value-of select="$current-default-namespace"/> does not
            match the target xpath default namespace <sch:value-of select="$target-xpath-default-namespace-name"/>.
            If you try to bind a value to a parameter in the target stylesheet via QName() without a prefix,
            nothing will happen, because the QName will be assigned the namespace <sch:value-of
               select="$current-default-namespace"/> rather than <sch:value-of
               select="$target-xpath-default-namespace-name"/>. You can fix this by adding
            xmlns="<sch:value-of select="$target-xpath-default-namespace"/>" to
            this element.</sch:report>
         <!-- schematron quick fixes do not support insertion of namespace nodes, so no SQF is supplied -->
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="transform-map">
      <sch:rule context="xsl:map-entry[contains(@key, 'static-params')][not(*)]">
         <sch:let name="target-uri"
            value="replace(../xsl:map-entry[contains(@key, 'stylesheet-location')]/@select, $apos, '')"/>
         <sch:let name="target-stylesheet" value="doc(resolve-uri($target-uri, $context-base-uri))"/>
         <sch:let name="first-tier-params" value="$target-stylesheet/*/xsl:param[@static]"/>
         <sch:report test="exists($first-tier-params)" sqf:fix="add-param-map-entries"
            >First-tier static params are missing from this map.</sch:report>
         
      </sch:rule>
      <sch:rule context="xsl:map-entry[contains(@key, 'stylesheet-params')][not(*)]">
         <sch:let name="target-uri"
            value="replace(../xsl:map-entry[contains(@key, 'stylesheet-location')]/@select, $apos, '')"/>
         <sch:let name="target-stylesheet" value="doc(resolve-uri($target-uri, $context-base-uri))"/>
         <sch:let name="first-tier-params" value="$target-stylesheet/*/xsl:param[not(@static)]"/>
         
         
         <sch:report test="exists($first-tier-params)" sqf:fix="add-param-map-entries"
            >First-tier params are missing from this map.</sch:report>
         


      </sch:rule>
      <sch:rule context="xsl:map-entry[@key = 'stylesheet-params']/xsl:map/xsl:map-entry[matches(@key, 'xs:QName')]">
         <sch:let name="this-xsQName-value" value="replace(@key, '^.*xs:QName\(.|.\)\s*$', '')"/>
         <sch:let name="these-components" value="tokenize($this-xsQName-value, ':')"/>
         <sch:let name="this-prefix"
            value="
               if (count($these-components) gt 1) then
                  $these-components[1]
               else
                  ()"
         />
         <sch:let name="this-local-name" value="$these-components[last()]"/>
         <!--<sch:let name="this-qname-prefix" value="prefix-from-QName(@key)"/>-->
         <!--<sch:report test="true()">Prefix <sch:value-of select="$this-qname-prefix"/></sch:report>-->
      </sch:rule>
   </sch:pattern>
   <sqf:fixes>
      <sqf:fix id="add-param-map-entries">
         <sqf:description>
            <sqf:title>Add first-tier params to map</sqf:title>
         </sqf:description>
         <sqf:add match="." position="last-child">
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="xsl:map" namespace="http://www.w3.org/1999/XSL/Transform">
               <xsl:text>&#xa;</xsl:text>
               <xsl:for-each select="$first-tier-params">
                  <xsl:copy-of select="gep:param-to-map-entry(.)"/>
                  <xsl:text>&#xa;</xsl:text>
               </xsl:for-each>
            </xsl:element>
            <xsl:text>&#xa;</xsl:text>
         </sqf:add>
      </sqf:fix>
   </sqf:fixes>
</sch:schema>
