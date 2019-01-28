<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" id="card" xml:id="card"
                xmlns:tb="http://attestation.id/ns/tbml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:include href="token.xsl"/>
  <xsl:template match="/">
    <html>
      <head>
        <!-- script to populate fields with values from the blockchain -->
        <script type="text/javascript">
          //<![CDATA[
                        window.addEventListener('load', async () => {
                        })
                    //]]>
        </script>
        <style type="text/css">
          tr {
          display: inline-block;
          width: 50%;
          }
          tr:nth-child(odd) {
          text-align: left;
          }

          tr:nth-child(even) {
          text-align: right;
          }

          th, td {
          display: block;
          }

          table {
          width: 100%;
          }
          body {
          background-color: #54c1e2;
          }
          #banner {
          border-radius: 10pt 10pt 0pt 0pt;
          background-color: white;
          }
          .tokens {
          background-color: white;
          min-height: 10pt;
          }
          .other.tokens {
          border-radius: 0pt 0pt 10pt 10pt;
          }
        </style>
      </head>
      <body>
        <div id="banner">
          <h1>You have purchased 2 tickets.</h1>
        </div>
        <div class="tokens under-action">
          <div class="asset card">
            <xsl:apply-templates select="tb:token"/>
          </div>
        </div>
        <div class="other tokens">

        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
