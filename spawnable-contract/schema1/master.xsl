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
        <script src="https://unpkg.com/react@16/umd/react.development.js"></script>
        <script src="https://unpkg.com/react-dom@16/umd/react-dom.development.js"></script>
        <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
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
          h1 {
          text-align: center;
          }
          html {
          background-color: #54c1e2;
          }
          body {
          border-radius: 10pt 10pt 10pt 10pt;
          background-color: white;
          }
        </style>
      </head>
      <body>
        <xsl:call-template name="token"/>

        <script type="text/babel">
          ReactDOM.render(
          <Token/>
          ,
          document.querySelector("#tokens")
          );
        </script>

        <div id="banner">
          <h1>You have purchased 2 tickets.</h1>
        </div>
        <div id="tokens"/>
        <div id="other-tokens">

        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
