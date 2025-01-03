<xsl:stylesheet 
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gep="tag:evagriusponticus.net,2012:ns" version="3.0"
   expand-text="true">
   <xsl:variable name="apos" as="xs:string">'</xsl:variable>
   <xsl:variable name="all-included-stylesheets" as="document-node()*">
      <xsl:apply-templates select="/*/*" mode="get-xsl-imports-and-includes"/>
   </xsl:variable>
   <xsl:template match="xsl:import | xsl:include" mode="get-xsl-imports-and-includes">
      <xsl:variable name="this-base-uri" select="base-uri(.)"/>
      <xsl:variable name="this-target-uri-resolved" select="resolve-uri(@href, $this-base-uri)"/>
      <xsl:variable name="this-target-doc" select="doc($this-target-uri-resolved)"/>
      <xsl:sequence select="$this-target-doc"/>
      <xsl:apply-templates select="$this-target-doc/*/*" mode="#current"/>
   </xsl:template>
   <xsl:template match="*" mode="get-xsl-imports-and-includes"/>
   <xsl:function name="gep:param-to-map-entry" as="element()*">
      <!-- Input: param elements -->
      <!-- Output: one map entry per param element -->
      <xsl:param name="param-elements" as="element(xsl:param)*"/>
      <xsl:apply-templates select="$param-elements" mode="param-to-map-entry"/>
   </xsl:function>
   <xsl:function name="gep:change-default-namespace" as="element()*">
      <!-- Input: elements; a string to which the default namespace should be changed -->
      <!-- Output: each element, with the chosen namespace added as the default -->
      <xsl:param name="elements" as="element()*"/>
      <xsl:param name="default-namespace-uri" as="xs:string?"/>
      <xsl:for-each select="$elements">
         <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:namespace name="" select="($default-namespace-uri, '')[1]"/>
            <xsl:copy-of select="node()"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:function>
   <xsl:template match="xsl:param" mode="param-to-map-entry">
      <xsl:element name="xsl:map-entry" namespace="http://www.w3.org/1999/XSL/Transform">
         <xsl:attribute name="key">xs:QName('{@name}')</xsl:attribute>
         <xsl:copy-of select="@select | node()"/>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>