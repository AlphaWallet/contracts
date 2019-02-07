function x() {
          let rows = this.props.tokens.map(each =>
            <Token key={each.symbol} countryName={each.countryName} category={each.category} />
          )

          //hhh template access doesn't work here. Have to fix it, maybe include into tbml JS object?
    return (<div>
        <div id="banner">
          <h1>You have purchased 2 Vouchers</h1>
        </div>
        <TokenList tokens={tokens} />
        <div id="other-tokens"/>
        <div id="actions"/>
      </div>)
}
