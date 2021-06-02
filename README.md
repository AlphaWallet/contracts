# Delivery and Payment contracts

This repository stored Spawnable token contracts and various payment contracts created by James Sangalli in 2019.

Spawnable tokens refer to the tokens that didn't exist on the blockchain until used for the first time. An attestation (a signed message) attests to the existence of such a token with a specific owner. However, unless a buyer of the token is trying to purchase it from that owner, it can remain off-chain and TokenScript would treat it the same as if it were on-chain, since it can "spawn" on-chain if needed.

Such a design is the basis of TokenScript's 2018/2019 FIFA/UEFA ticket experiments, where tickets "spawn" on-chain if needed.

At the moment - 2021 - Weiwu is expanding the functionality to allow NFT artwork to spawn only when someone is willing to pay for it. See more in [DvP architect](dvp_arch.md)

In financial institutions, this is termed "deliver-versus-payment", hence the name of this repo. It was initially called Spawnable by our team members enamoured by first-person P2P shooters, where a player "spawn" into existence.
