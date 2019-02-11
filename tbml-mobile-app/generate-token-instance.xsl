<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" id="card" xml:id="card"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="\(TbmlStore.defaultTokenFilename)"/>
  <xsl:include href="\(contract.lowercased()).xsl"/>
  <xsl:output method="text"/>

  <xsl:template match="/">
    <![CDATA[
    \(standardTokenTbmlCss)
    ]]>
    <xsl:call-template name="library"/>
    <xsl:call-template name="token"/>
    <xsl:call-template name="tokenRendering"/>
  </xsl:template>
</xsl:stylesheet>

