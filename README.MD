# PUZZLR

Puzzlr is a decentralized and secure image sharing App for Android and iOS. It uses [Fabric](https://github.com/hyperledger/fabric), a blockchain created by the [Hyperledger Project](https://www.hyperledger.org). Puzzlr is made available as a Proof-Of-Concept and should not not be considered as a "safe" product.

## Server Installation

- Copy the chaincode files into your Open Blockchain virtual machine.
- In the VM, run `go get` in chaincode_user folder to get bcrypt.
- Launch obc-peer.
- Deploy the 3 chaincodes.

## Client Installation and Usage



### iOS

Open this project with XCode, Build and install it on your device. Be sure to replace the IP with the IP of your Open Blockchain server.

### Android

**to be written**

## Usage

### iOS Version

Puzzlr is meant to be intuitive and easy to use. Just create an account. If you want to send a picture to someone, you need to add him in the "Contact" menu. Then you can go back to the "Send/Receive" menu and create a new message. Just press send.
On the other device just pull down to refresh and see the message.

### Android Version

**to be written**

## Credits

Thanks to all IBM Open Blockchain developpers.

### iOS Version

Many thanks to the developper of SwiftyRSA, Swift-RSAUtils, AsymmetricCryptoManager, CryptoImportExportManager, SWRevealViewController and CryptoSwift.

## License

This software is made available under the [MIT License](LICENSE).