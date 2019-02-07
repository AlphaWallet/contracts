var xx = [1];
console.log("xx:");
console.log(xx);
//hhh why can't we pass in tokens without quotes?
var tokenList = React.createElement(TokenList, { tokens1: xx });
ReactDOM.render(tokenList, document.querySelector("#tokens"));