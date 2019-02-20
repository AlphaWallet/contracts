API
===
The TBML API are:

A. The token data.

B. The callback when the token data changes.

A. Token Data
---
The shape of the data is:

```
web3.tokens = [
    currentInstance: instance,
    current: token,
    all: [
        token,
        token,
        ...
    ],
    definition: {
        "0xD8e5F58DE3933E1E35f9c65eb72cb188674624F3": tokenDefinition,
        "0xf018225735f70a1961B6B8aa07B005e6392072E7": tokenDefinition,
        ...
    },
    dataChanged: function(oldTokens, updatedWeb3Tokens)
]
```

with:

```
token = {
    contractAddress: "0xD8e5F58DE3933E1E35f9c65eb72cb188674624F3",
    instances: [
        instance,
        instance,
        ...
    ]
}

instance = {
    _count: 1,
    contractAddress: "0xD8e5F58DE3933E1E35f9c65eb72cb188674624F3",
    numero: 11
    section: "22",
    building: "Some building",
    street: "Some street",
    country: "SG",
    ...
}

tokenDefinition = {
    attributes: {
        attributeId: attribute,
        name: {
            value: "Tickets test",
        }
        symbol: {
            value: "TEST",
        }
        category: {
            name: "Cat",
        },
        countryA: {
            name: "Team A",
        },
        ...
    },
    grouping: {...},
    ordering: {...},
},

attribute = {
    name: "Cat",
    value: "TEST",
}
```

Note that a token instance is the equivalent of a  ticket token ID or a bundle of token IDs.

`web3.tokens.all` and `web3.tokens.current` are *not* available in this iteration.

The metadata of a token is available in `web3.tokens.definition` with the contract address in [EIP55](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md) as the key. The metadata is basically a 1:1 map from the relevant parts of the asset definition. Only the localized attribute names (and not grouping, ordering) is available for now.

For example, to access the localized attribute name `"countryA"` for the token with contract `"0xD8e5F58DE3933E1E35f9c65eb72cb188674624F3"` use:

```
web3.tokens.definition["0xD8e5F58DE3933E1E35f9c65eb72cb188674624F3"].attributes["countryA"]["name"]
```

An attribute can have a `"value"` instead. Specifically, the `"name"` and `"symbol"` attributes has a value so TBML developers can be access them even if the user does not hold any token instance in their wallet.

If you compare [spawnable-contract/schema1/token-plain-javascript.xsl](../spawnable-contract/schema1/token-plain-javascript.xsl) and [blockchain-tickets/schema1/token-plain-javascript.xsl](../blockchain-tickets/schema1/token-plain-javascript.xsl), you can see what needs to be done for changing the layout (aside from some boilerplate).

One consideration I kept in mind is that the web3 v1 API is asynchronous, whereas the web3 v0.x APIs are synchronous. But I think by making it asynchronous like we have now seems to work with both versions.

B. Callback
---
TBML developers can hook into the callback like this if they use React:

```
web3.tokens.dataChanged = (oldTokens, updatedTokens) => {
    //If we aren't using React, we can get a diff ourselves
    this.setState(() => {
        return { currentInstance: updatedTokens.currentInstance }
    })
}
```

If they don't, they can use this callback and the arguments to figure out what has changed. We might point them to a good JSON-diff library; but since the purpose here is just to render a static layout, they can just re-render the whole DOM as we do in our examples.

Future
---
In (A), we can also stuff the entire list of tokens in the user's Ethereum wallet in there (in a future iteration) under the `all` key. We might have to key them by wallet/networks too. Performance is a concern, but this simple approach has quite a number of advantages. Perhaps it can be partially mitigated by adding a permission call that TBML developers have to make to make `tokens` accessible, maybe as part of the permission granted via https://eips.ethereum.org/EIPS/eip-1102 (which we should implement anyway) or a new function call.

The development and debugging experience is a little tedious. With access to the simulator, we can drop updated files and run a web inspector on the simulator's TBML webview to look at the console.log output. But this is something we need to look into a bit more. It's still possible to hardcode `web3.tokens.currentInstance` and run the same HTML/JavaScript standalone after XSLT. So that's a workaround.

token.xsl
===
3 XSL templates are expected in token.xsl:

* ```<xsl:template name="library">``` - for ```<script>``` tags.
* ```<xsl:template name="token">``` - (class) definition for rendering a token instance
* ```<xsl:template name="tokenRendering">``` - HTML and code to render a token instance

We concatenate the output of all 3 in the app and load it for rendering each token instance, but

1. In future iterations, we might attempt to parse and cache these files to improve performance. We should probably recommend that this not be used (so maybe it's worth thinking if it should be supported, but maybe developers will do it anyway). This template is optional because [default-token.xsl](default-token.xsl) defines an empty template with the same name.
2. When rendering the entire list of token instances using `master.xsl`, we could call and load the `library` and `token` templates once for the entire list and the `tokenRendering` template once for each token instance.

Implementing the TBML API and Rendering in the Mobile Apps
===
There are a few additional files that are used in the app which is in the `tbml-mobile-app` directory:

* [standard-styles.css](standard-styles.css) — CSS style classes that are injected into each token instance webview. TBML developers can use them or override if they want. Most notably this should include the custom fonts we include in the app. (the custom fonts don't work yet although the styles specify them)
* [default-token.xsl](default-token.xsl) — The default token.xsl file which is included with empty templates and TBML-developer friendly messages
* [generate-token-instance.xsl](generate-token-instance.xsl) - The XSL file used to include [default-token.xsl](default-token.xsl) ("TbmlStore.defaultTokenFilename"), the contract's `token.xsl` ("contract.lowercased().xsl") standard-styles.css ("standardTokenTbmlCss") as well as call the templates. The output of applying this XSL file on the asset definition is the HTML (and JavaScript + CSS) that is then rendered in each token instance's web view with each web view having access to the TBML API.
