
There are several types of signatures one can put on TBML files
(including its asset card renderings in XSLT).

- Signature signed with a web SSL certificate. TBML signed this way
  has a security rating based on the reputation of the website. That
  is, AlphaWallet, or any TBML compatible Dapp browser would treat it
  secure as long as the web certificate used is current and not
  revoked or blacklisted. On the user interface, the user would see
  "security undertaken by www.my.company.com" where the domain name is
  the one in the SSL certificate.

- Signature by an Ethereum key which is authorised by the smart
  contract's deploying key. TBML signed this way has a security rating
  based on the trust of the smart contract, that is, as long as the
  smart contract itself is not revoked or blacklisted for security
  flaws, the corresponding TBML is considered safe. The user would see
  "security undertaken by the smart contract's author'.

- Signature by AlphaWallet or the Dapp browser's team. Each
  implementation uses a different measurement. As of AlphaWallet, the
  key that is used to sign the apk file to be released is to sign the
  TBML files. There are hidden key management cycle issues with this
  approach which we elect to solve in a later occassion.

Currently, signing in the first way is exemplified by the following
command, assuming the key is stored in
`skstravel.cn/skstravel_cn.pkcs8.pem` and the key is of ECDSA-256
type.

To sign the XML:

$ /opt/xmlsectool-2.0.0/xmlsectool.sh --sign --digest SHA-256 --signatureAlgorithm 'http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256' --inFile contracts/TicketingContract.xml --outFile /tmp/signed.xml --key skstravel.cn/skstravel_cn.pkcs8.pem --certificate skstravel.cn/skstravel_cn.crt 

