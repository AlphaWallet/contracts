<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" id="card" xml:id="card"
                xmlns:tb="http://attestation.id/ns/tbml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:include href="asset-card.xsl"/>
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
                    h1 {
                    border-radius-
                    #asset-card {
                    background-color: white;
                    border-radius-top: 1em;
                    border-radius-bottom: 1em;
                    padding: 1ex;
                    }
                </style>
            </head>
            <body>
                <div class="banner">

                </div>
                <div class="assets under-action">
                <div class="asset card">
                    <xsl:apply-templates select="tb:token"/>
                </div>
                </div>
                <div class="asset icon">

                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
