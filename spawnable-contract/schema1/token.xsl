<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" id="card" xml:id="card"
                xmlns:tb="http://attestation.id/ns/tbml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:key name="l10n" match="tb:attribute-type" use="@id"/>
  <xsl:template name="token">
    <script type="text/babel">
      class Token extends React.Component {
      render() {
      return <table>
          <caption id="caption"/>
          <tbody>
          <tr>
            <th>
              <xsl:value-of select="key('l10n', 'country')/tb:name"/>
            </th>
            <td/>
          </tr>
          <tr>
            <th>
              <xsl:value-of select="key('l10n', 'locality')/tb:name"/>
            </th>
            <td/>
          </tr>
          <tr>
            <th>
              <xsl:value-of select="key('l10n', 'time')/tb:name"/>
            </th>
            <td/>
          </tr>
          <tr>
            <th>
              <xsl:value-of select="key('l10n', 'numero')/tb:name"/>
            </th>
            <td/>
          </tr>
          <tr>
            <th>
              <xsl:value-of select="key('l10n', 'category')/tb:name"/>
            </th>
            <td/>
          </tr>
          <tr>
            <th>
              <xsl:value-of select="key('l10n', 'section')/tb:name"/>
            </th>
            <td/>
          </tr>
        </tbody>
      </table>

      }
      }
    </script>

  </xsl:template>
</xsl:stylesheet>
