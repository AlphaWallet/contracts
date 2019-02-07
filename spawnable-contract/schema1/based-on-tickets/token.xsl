<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" id="card" xml:id="card"
                xmlns:tb="http://attestation.id/ns/tbml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template name="token">
    <script type="text/babel">
      class Token extends React.Component {
      //hhh move
      formatTime(d) {
        let date = d
        //let date = new Date()
        //let milliseconds = d.getTime() - d.getTimezoneOffset() * 60 * 1000
        //date.setTime(milliseconds)
        return date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})
      }

      render() {
      let time
      if (this.props.time == null) {
        time = ""
      } else {
        time = this.formatTime(this.props.time)
      }
      return <table>
          <caption id="caption"/>
          <tbody>
          <tr>
            <td>
              x{this.props._count} {this.props.category}
            </td>
          </tr>
          <tr>
            <td>
              {this.props.venue}
            </td>
          </tr>
          <tr>
            <td>
              (i) {this.props.time == null ? "": this.props.time.toLocaleDateString()} (i) {this.props.countryA}-{this.props.countryB} (i) M{this.props.match}
            </td>
          </tr>
          <tr>
            <td>
              {time}, {this.props.locality}
            </td>
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
          <!--let rows = this.props.tokenInstances.map(each =>-->
            <!--<Token key={each.symbol} country={each.country} category={each.category} />-->
          <!--)-->
          //hhh The symbols are not unique! Need a better key
          var rows = this.props.tokenInstances.map(function (each) {
            return React.createElement(Token, {
              key: each.symbol,
              _count: each._count,
              category: each.category,
              venue: each.venue,
              countryA: each.countryA,
              countryB: each.countryB,
              match: each.match,
              locality: each.locality,
              time: each.time,
            });
          });
          return rows;
        }
      }

      //hhh move?
      //hhh the classes in this file, are they loaded more than once when doing XSLT transforms? In efficient?
      class App extends React.Component {
        constructor(props) {
        super(props)

        //hhh rename currentToken1 to say that it's hardcoded for testing. But normally it should fail
        const currentToken1 = {
          name: "Reserve Token",
          symbol: "RSRV",
          instances: [
              {
                name: "Reserve Token",
                symbol: "RSRV",
                balance: 10,
                country: "SG",
                category: 1,
              },
              {
                name: "CanYaCoin",
                symbol: "CAN",
                balance: 20,
                country: "US",
                category: -1,
              },
            ]
        }
        let currentToken
        if (typeof web3 == "undefined") {
          console.log("Using hardcoded currentToken data for testing")
          currentToken = currentToken1

          //hhh remove
          console.log("Running timer to simulate changes to hardcoded currentToken data")
          setInterval(() => {
            //hhh remove
            console.log("Timer to simulate changes to hardcoded currentToken data fired")
            this.setState((prevState, props) => {
              return {
                currentToken: {
                  name: "Reserve Token",
                  symbol: "RSRV",
                  instances: [
                      {
                        balance: 10,
                        country: "SG",
                        category: prevState.currentToken.instances[0].category + 1,
                      },
                      {
                        balance: 20,
                        country: "US",
                        category: prevState.currentToken.instances[1].category - 1,
                      },
                    ]
                  }
                }
             })
          }, 3000)
        } else {
          console.log("Accessing web3.tokens")
          currentToken = web3.tokens.current

          web3.tokensDataChanged = (oldTokens, updatedTokens) => {
            //If we aren't using React, we can get a diff ourselves
            //hhh remove
            console.log("fired")
            this.setState(() => {
              return { currentToken: updatedTokens.current }
            })
          }

          //hhh remove
          //web3.tokensDataChanged = (oldTokens, updatedTokens) => {
          //  console.log("currentToken: ")
          //  console.log(updatedTokens.current)
          //}
        }

        this.state = {
          currentToken: currentToken
        }
      }

      render() {
        <!--
        //hhh template access doesn't work here. Have to fix and get "Vouchers", maybe include into tbml JS object?
        return (<div>
          <div id="banner">
            <h1>You have purchased 2 Vouchers</h1>
          </div>
          <TokenList tokenInstances={tokenInstances} />
          <div id="other-tokens"/>
          <div id="actions"/>
        </div>)
        -->

        let count = 0
        this.state.currentToken.instances.forEach(each => {
          count += Number.parseInt(each._count)
        })

        //hhh template access doesn't work here. Have to fix and get "Vouchers", maybe include into tbml JS object?
        return React.createElement(
          "div",
          null,
          React.createElement(
            "div",
            { id: "banner" },
            React.createElement(
              "h1",
              null,
              `${count} ${this.state.currentToken.name} (${this.state.currentToken.symbol})`
            )
          ),
          React.createElement(TokenList, { tokenInstances: this.state.currentToken.instances }),
          React.createElement("div", { id: "other-tokens" }),
          React.createElement("div", { id: "actions" })
        );
      }
    }
    </script>

  </xsl:template>
</xsl:stylesheet>
