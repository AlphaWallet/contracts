# Client specification #

When the user accesses a contract, the client downloads or updates the XML files.

“access” happens when:
- the app discovers that the user has (or had) tokens under a Contract;
- the user actively seek to use a Contract (scan its QR code or copying its address from the Internet);
- the user gets sent Universal Link which refers to a Contract or its assets

The XML file is downloaded or updated by accessing a link like this:
https://repo.awallet.io/0xA66A3F08068174e8F005112A8b2c7A507a822335

The link will change to https://app.awallet.io if I found that it is impractical to use hostname-based virtual-host in HTTPS in Spring/Thymeleaf.

## For downloading the first time ##

The XML file is downloaded to the mobile phone, validated for signature (in the future, also validated against schemas). If invalid - delete it immediately, otherwise move to the mobile's file storage, under the directory which represents the network.

mainnet/0xA66A3F08068174e8F005112A8b2c7A507a822335.xml

The file's modification date should be set to the same as returned by HTTP GET. Be careful with timezone!

## For checking updates ##

First, request through HTTP HEAD and get the header, examine if `Last-Modified` returned by the HTTP header signifies an update by comparing it against the time of the locally cached file. Be careful with timezone!

If an update is needed, download the new file from the URI, validate for signature (in the future, validate against schemas). If invalid, keep the old file and log the event (or prompt the user). If valid, replace the local file with it and set the modified timestamp again:

mainnet/0xA66A3F08068174e8F005112A8b2c7A507a822335.xml

In the future, the server might return HTTP 300 and 204, for situations that I will document later. Such case will happen once the XML files / Schemas are versioned.

Note that it is intended that an XML document's author tests his work by directly replacing the file in the mobile phone's file storage (this is easily done in Android - unsure about iOS) because we can't give them a facility to test upload their XML to our repository and then pass it to the mobile. Therefore, it is expected that sometimes XML document's last modification date is later than the server's `Last-Modified` header. When this happens, just treat it as "no updates from server". This is also why file extension ".xml" is added when the XML resource is saved, when such extension does not appear in the URI.

Note that when the mobile app requests the XML file from the link, it does not specify network ID (mainnet, Ropsten etc). However, when it stores the XML file locally, it saves the file in the corresponding directory named after network ID. The logic behind this is that: for the server, there is no need to mention network ID, because contracts of the same address on different networks must be deployed by the same person anyway. However, when the client stores the file, it must have already done its content-negotiation (choosing between schema version, crypto-kitty skin vs crypto-pony skin, signature trust level etc.). Therefore it saves the version of XML resulted from the negotiation. For now, the repo server doesn't give HTTP 300 or HTTP 204 so this is out of the question, but when we do add content-negotiation in the future we want to introduce as little change as possible.

This design also means at the current stage, 

mainnet/0xA66A3F08068174e8F005112A8b2c7A507a822335.xml
ropsten/0xd8e5f58de3933e1e35f9c65eb72cb188674624f3.xml

These are two identical files stored *twice* on the mobile's file storage, and that is intended.

# Repo specification #

All XML files in the repository are named like this:

    FIFA WC2018/www.sktravel.com-signed-schema1.xml

Where the directory name "FIFA WC2018" is the Contract's name as returned by the Contract, followed by signer's certificate name (CN, CommonName), followed by schema version. For contracts that share the same contract-name, there are multiple XML files for each contract.

It's possible to have multiple versions:

    FIFA WC2018/schema1/www.sktravel.com-signed.xml
    FIFA WC2018/schema2/www.sktravel.com-signed.xml
    FIFA WC2018/schema1/www.awallet.io-signed.xml
    FIFA WC2018/schema1/signed.xml

The last format is a special one - there is no certificate CN, since the contract's deployment key signs it, which needs no certification.

The XML signature's time stamp is used to determine which file is the latest, thus it is very important to make it correct. This data is however unreliable as we don't have a blockchain timestamp implementation yet, but it will be done in the future.

## Repo Server specication ##

When the server starts, it scans for all XML files in all directories and indexes the validate (by schema and by signature) in a table in memory:

| contract | contract name | schema version | signature date | signer | path |
| 0xA66A3F08068174e8F005112A8b2c7A507a822335 | FIFA WC2018 | 1 | 2019-10-10 | www.sktravel.com | FIFA WC2018/schema1/www.sktravel.com-signed.xml |
| 0xd8e5f58de3933e1e35f9c65eb72cb188674624f3 | FIFA WC2018 | 1 | 2019-10-10 | www.sktravel.com | FIFA WC2018/schema1/www.sktravel.com-signed.xml |

Notice that the server completely doesn't care the network ID (mainnet / testnet).

When the client connects to URI like this:
https://repo.awallet.io/0xA66A3F08068174e8F005112A8b2c7A507a822335
the server either returns the file which claims to define the behaviour of the contract in the URI, with the `Last-Modified` field being the XML signature signing date. In other words, the repo server provides a facade as if all files are modified by the signing, which should be true often. This is because the repo manager might want to swap in and swap out different versions of XML to experiment and that should not fool the application; also because version management (git etc) not always keep modification date aligned with content modification.

In the case that there are multiple files which claim to define the behaviour of the contract in the URI, one of the two things happens.

1. The server, knowing which version of the mobile app supports what kind of XML file, pre-select the compatible file to return.

2. If there are still more than one compatible file, e.g. one signed by contract issuers and another signed by awallet.io while the awallet.io is newer, and that we intend the user to choose, then the server returns 300 with a list of choices.
