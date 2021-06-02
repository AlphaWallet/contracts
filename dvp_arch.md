# DvP Architect

A DvP scenario (Delivery-versus-Payment) typically involves two tokens.

One is called a Delivery token, which represents the commodity people buys and sells. It is typically ERC721 or ERC1155.

The other is called a Payment token, which represents money. It is typically either Ether or ERC20 token.

An example of a DvP scenario would be buying a specific CryptoKitty (NFT) with 100 USDT.

# Smart contract architect for DvP

Every delivery token has a sister DvP contract on top of the token contract. This contract is responsible for receiving DvP transactions. The contract has to be ERC20-approved by the Payment contract (ERC20) to function.

The address of the DvP contract is stored in the delivery contract. The delivery contract delicates calls to its `dvp(bytes deal)` function to this contract, so the smart contract team must consider this contract within its security perimeter.
