<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" id="card" xml:id="card"
                xmlns:tbml="http://attestation.id/ns/tbml"
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
        <!-- wonder the use of xsl:comment? see https://github.com/facebook/react/issues/14712 -->
        <script src="https://unpkg.com/react@16/umd/react.development.js"><xsl:comment/></script>
        <script src="https://unpkg.com/react-dom@16/umd/react-dom.development.js"><xsl:comment/></script>
        <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"><xsl:comment/></script>
        <style type="text/css">
          table {
          width: 48%;
          min-width: 16em;
          margin: 1%;
          border: thin ridge;
          padding: 1ex;
          background-color: whitesmoke;
          border: thin solid silver;
          box-shadow: 5pt 5pt silver;
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
          //hhh test if <App /> works
          var app = React.createElement(App);
          ReactDOM.render(app, document.getElementById('root'));

          <!--const tokenList = <TokenList tokens={tokens} />;-->
          <!--var tokenList = React.createElement(TokenList, { tokens: tokens });-->
          <!--ReactDOM.render(-->
            <!--tokenList,-->
            <!--document.querySelector("#tokens")-->
          <!--);-->
        </script>

        <!--<div id="banner">-->
          <!--<h1>You have purchased 2 <xsl:value-of select="/tbml:token/tbml:name"/></h1>-->
        <!--</div>-->
        <!--<div id="tokens"/>-->
        <!--<div id="other-tokens"/>-->
        <!--<div id="actions">-->
        <!--</div>-->
        <div id="root"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
