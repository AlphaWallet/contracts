2 videos, showing TBML with tickets and spawnable meetup contracts.

There are still a good deal of hardcoding. They are both still using React.
    
In the tickets video, you can see that when the TBML is first displayed, it doesn't have all the data so ugly artifacts like "NaN ()" appears. This should be resolved (A) by the TBML author handling when the data isn't available/complete yet and (B) for demo purposes, the data isn't available yet, but it should because I already have the data in my database. Compare it to the natively rendered version at the bottom half of the screen.

In the spawnable version, it is similar, except that the data for street, locality, state are extracted via smart contract function calls. I have deleted the data before recording the demo, so the TBML display reloads again when the data is available.

Refreshing is a little slower because I have added delays for debugging.

The initial rendering is a bit slow, I'll have to test that again once I clean up other parts.

A) and B) are the core parts of the TBML API and is really quite simple:

A) The shape of the data is:

```
web3.tokens = [
    current: {
        token
    },
    all: [
        token,
        token,
        ...
    ]
]
```

with:

```
token = {
    symbol: "symbol",
    name: "Some Coin"
    instances: [
        instance,
        instance,
        ...
    ]
}

instance = {
    _count: 1,
    numero: 11
    section: "22",
    building: "Some building",
    street: "Some street",
    country: "SG",
}
```

Originally I used the name "instance" because it was to represent a token ID but wanted to make it less ambiguousfor TBML developers, but "bundle" or "group" might be a more correct name. Or we might just drop _count completely and leave the bundling/grouping to the client?

The readable name of the token "Vouchers" and their localized forms isn't available yet. I'm toying with exposing it as "displayableName":

```
token = {
    displayableName: "Vouchers", //localized version based on phone/app settings
    symbol: "symbol",
    name: "Some Coin"

    instances: [
        instance,
        instance,
        ...
    ]
}
```

If you compare based-on-spawnable/tokens.xsl and based-on-tickets/tokens.xsl, you can see what needs to be done for displaying the data.

One consideration I kept in mind is the web3 v1 is asynchronous, whereas the web3 v0.x APIs are synchronous. But I think by making it asynchronous like we have now seems to work with both versions.

B) The original example and the 2 in the video are all React-based, so web3.tokens is really a gigantic JavaScript object and is the bulk of the API we expose. The other part is just a simple call back which the TBML developers have to hook into like this if they use React:

```
web3.tokensDataChanged = (oldTokens, updatedTokens) => {
    //If we aren't using React, we can get a diff ourselves
    this.setState(() => {
        return { currentToken: updatedTokens.current }
    })
}
```

If they don't, they can use this callback and the arguments to figure out what has changed. We might point them to a good JSON-diff library.

So A) and B) are the core parts of the TBML API. In (A), we can also stuff the entire list of tokens in the user's Ethereum wallet in there. I am abit wary about performance, but this simple approach has quite a number of advantages. Perhaps it can be partially mitigated by adding a permission call that TBML developers have to make to make `tokens` accessible, maybe with https://eips.ethereum.org/EIPS/eip-1102 (which we should implement anyway) or a new function call.

The development and debugging experience is a little tedious, I'm working with the simulator, so I can drop updated files and run a web inspector on the simulator's TBML webview to look at the console.log output. But I believe this is something we need to look into a bit more. I found that it's still possible to hardcode web3.tokens.current and run the same HTML/JavaScript standalone though. So that's a good complement.
