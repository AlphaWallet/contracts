function x() {
  var rows = this.props.tokens.map(function (each) {
    return React.createElement(Token, { key: each.symbol, countryName: each.countryName, category: each.category });
  });

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
    React.createElement(TokenList, { tokens: tokens }),
    React.createElement("div", { id: "other-tokens" }),
    React.createElement("div", { id: "actions" })
  );
}