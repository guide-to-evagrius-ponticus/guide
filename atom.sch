<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2005/Atom">
    <xsl:include href="stylesheets/global-variables.xsl"/>
    <!--<xsl:output indent="yes"/>-->
    <sch:ns uri="http://www.w3.org/2005/Atom" prefix="atom"/>
    <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <sch:pattern>

        <sch:rule context="atom:feed">
            <sch:let name="last-update" value="xs:dateTime(atom:updated)"/>
            <sch:let name="now" value="current-dateTime()"/>
            <sch:let name="duration-since-last-update" value="$now - $last-update"/>
            <sch:let name="days-since-last-update"
                value="days-from-duration($duration-since-last-update)"/>
            <sch:report test="$days-since-last-update gt 10" sqf:fix="add-entry">Last updated
                    <sch:value-of select="$days-since-last-update"/> days ago.</sch:report>
            <sqf:fix id="add-entry">
                <sqf:description>
                    <sqf:title>Add a new Atom entry, update metadata</sqf:title>
                </sqf:description>
                <sqf:replace match="atom:updated" node-type="element" target="updated"
                    select="current-dateTime()"/>
                <sqf:add match="atom:entry[1]" position="before"><entry>
                        <title>
                            <xsl:text>Guide to Evagrius Ponticus, </xsl:text>
                            <xsl:value-of select="$this-edition"/>
                            <xsl:text> edition</xsl:text>
                        </title>
                        <link href="http://evagriusponticus.net/index.htm"/>
                        <id>
                            <xsl:value-of
                                select="concat('tag:evagriusponticus.net,2015:ed:2016-', $this-month)"
                            />
                        </id>
                        <updated>
                            <xsl:value-of select="current-dateTime()"/>
                        </updated>
                        <published>
                            <xsl:value-of select="current-dateTime()"/>
                        </published>
                        <author>
                            <name>Staff</name>
                        </author>
                        <content type="xhtml">
                            <div xmlns="http://www.w3.org/1999/xhtml">
                                <p>
                                    <xsl:text>The </xsl:text>
                                    <xsl:value-of select="$this-edition"/>
                                    <xsl:text> edition of the </xsl:text>
                                    <em>Guide to Evagrius Ponticus</em>
                                    <xsl:text> is now available. Revisions include the following:</xsl:text>
                                </p>
                                <ul>
                                    <li>
                                        <em>Bibliography</em>
                                        <xsl:text>: 00000 items added, 00000 additional items updated.</xsl:text>
                                    </li>
                                </ul>
                            </div>
                        </content>
                    </entry>
                    <xsl:text>&#xa;</xsl:text>
                </sqf:add>
            </sqf:fix>
        </sch:rule>

    </sch:pattern>
</sch:schema>
