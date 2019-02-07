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
            <td>
              {this.props.countryName}
            </td>
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
            <td>
              {this.props.category}
            </td>
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

      class TokenList extends React.Component {
        render() {
          let rows = this.createRows()
          return <div>{rows}</div>
        }

        createRows() {
          <!--let rows = this.props.tokens.map(each =>-->
            <!--<Token key={each.symbol} countryName={each.countryName} category={each.category} />-->
          <!--)-->
          //hhh The symbols are not unique! Need a better key
          var rows = this.props.tokens.map(function (each) {
            return React.createElement(Token, { key: each.symbol, countryName: each.countryName, category: each.category });
          });
          return rows;
        }
      }

      //hhh move?
      //hhh the classes in this file, are they loaded more than once when doing XSLT transforms? In efficient?
      class App extends React.Component {
        constructor(props) {
        super(props)

        //hhh rename tokens1 to say that it's hardcoded for testing. But normally it should fail
        const tokens1 = [
          {
            name: "Reserve Token",
            symbol: "RSRV",
            balance: 10,
            countryName: "SG",
            category: 1,
          },
          {
            name: "CanYaCoin",
            symbol: "CAN",
            balance: 20,
            countryName: "US",
            category: -1,
          },
        ]
        <!--
        const tokens1 = [
          {
            name: "Reserve Token",
            symbol: "RSRV",
            balance: 10,
            //hhh test when fields are not available yet. Maybe not as easy if nested?
            //countryName: "SG"
            category: 1,
          },
          {
            name: "CanYaCoin",
            symbol: "CAN",
            balance: 20,
            countryName: "US",
            category: -1,
          },
        ]
        -->
        let tokens
        if (typeof web3 == "undefined") {
          console.log("Using hardcoded tokens data for testing")
          tokens = tokens1

          //hhh remove
          console.log("Running timer to simulate changes to hardcoded tokens data")
          setInterval(() => {
            this.setState((prevState, props) => {
              return {
                  tokens: [
                    {
                      name: "Reserve Token",
                      symbol: "RSRV",
                      balance: 10,
                      countryName: "SG",
                      category: prevState.tokens[0].category + 1,
                    },
                    {
                      name: "CanYaCoin",
                      symbol: "CAN",
                      balance: 20,
                      countryName: "US",
                      category: prevState.tokens[1].category - 1,
                    },
                  ]
                }
             })
          }, 3000)
        } else {
          console.log("Accessing web3.tokens")
          tokens = web3.tokens

          web3.tokensDataChanged = (oldTokens, updatedTokens) => {
            //If we aren't using React, we can get a diff ourselves
            //hhh remove
            console.log("fired")
            console.log(`old: ${oldTokens[0].category}`)
            console.log(`new: ${oldTokens[0].category}`)
            this.setState(() => {
              return { tokens: updatedTokens }
            })
          }

          //hhh remove
          //web3.tokensDataChanged = (oldTokens, updatedTokens) => {
          //  console.log("tokens: ")
          //  console.log(updatedTokens)
          //}
        }

        this.state = {
          <!--tokens: tokens1-->
          tokens: tokens
        }
      }

      render() {
        <!--
        //hhh template access doesn't work here. Have to fix it, maybe include into tbml JS object?
        return (<div>
          <div id="banner">
            <h1>You have purchased 2 Vouchers</h1>
          </div>
          <TokenList tokens={tokens} />
          <div id="other-tokens"/>
          <div id="actions"/>
        </div>)
        -->

        <!--console.log("tokens:")-->
        <!--console.log(this.state.tokens)-->

        //hhh template access doesn't work here. Have to fix it, maybe include into tbml JS object?
        return React.createElement(
          "div",
          null,
          React.createElement(
            "div",
            { id: "banner" },
            React.createElement(
              "h1",
              null,
              "You have purchased 2 Vouchers"
            )
          ),
          React.createElement(TokenList, { tokens: this.state.tokens }),
          React.createElement("div", { id: "other-tokens" }),
          React.createElement("div", { id: "actions" })
        );
      }
    }
    </script>

  </xsl:template>
</xsl:stylesheet>
