//
//  CryptoMessage.swift
//  Puzzlr
//
//  Contains all the necessary Crypto to send and receive an image.
//
//  Created by Quentin Le Sceller on 23/03/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import Foundation
import CryptoSwift

// The Data Blockchain
let dataBlockchain = DataBlockchain(ip: Server.sharedInstance.getIP(), port: 3000)

class CryptoMessage {
    
    // MARK: Public functions.
    
    /**
     Send an image.
     
     - parameter username: the recipient username
     - parameter image:    the image to send
     
     - returns: true if successfully sent
     */
    func sendImage(username : String, image : UIImage) -> Bool {
        var success = Bool(true)
        
        // MARK: IV Generation
        let IV = generateRandomString(16)
        let IVArray: [UInt8] = Array(IV.utf8)
        
        // MARK: AES key generation
        let AESKey = generateRandomString(16)
        
        // MARK: MAC key generation
        let MACKey = generateRandomString(16)
        let MACKeyArray: [UInt8] = Array(MACKey.utf8)
        
        do {
            // MARK: Preparation for AES Encryption
            // Converting image to base64 array
            let base64Image = convertImageToBase64(image)
            let data = NSData(base64EncodedString: base64Image, options: NSDataBase64DecodingOptions(rawValue: 0))
            let dataArray = data?.arrayOfBytes()
            
            // MARK: AES Image encryption
            let encryptedImageArray: [UInt8] = try AES(key: AESKey, iv: IV, blockMode: .CBC).encrypt(dataArray!, padding: PKCS7())
            // Converting to base 64 string
            let encryptedImageData = NSData(bytes: encryptedImageArray, length: encryptedImageArray.count)
            let encryptedImage = encryptedImageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            
            // MARK: MAC
            let macArray: [UInt8] = try! Authenticator.HMAC(key: MACKeyArray, variant: HMAC.Variant.sha512).authenticate(IVArray + encryptedImageArray)
            // Converting MAC into hexadecimal string
            let mac = NSData(bytes: macArray, length: macArray.count).toHexString()
            
            // MARK: RSA Encryption of sender username, AES and MAC keys.
            // Retrieving RSA Public Key from Keychain
            let publicKey = RSAUtils.getRSAKeyFromKeychain(username)
            
            // Getting my username
            let defaults = NSUserDefaults.standardUserDefaults()
            let usernameSender =  defaults.valueForKey("username") as? String
            
            // Username is at the end because its length is variable
            let textToEncrypt = AESKey + MACKey + usernameSender!
            let dataToEncrypt = textToEncrypt.dataUsingEncoding(NSUTF8StringEncoding)
            
            let RSACiphertextData =  RSAUtils.encryptWithRSAKey(dataToEncrypt!, rsaKeyRef: publicKey!, padding: SecPadding.PKCS1)
            
            let RSACiphertextDataHex = (RSACiphertextData?.toHexString())!
            
            // "RSA" tags to find the RSA ciphertext afterward
            let RSACiphertext = "RSA" + RSACiphertextDataHex + "RSA"
            
            // Final Ciphertext
            let ciphertext = RSACiphertext + IV + mac + encryptedImage
            
            // MARK: Sending to Blockchain
            dataBlockchain.sendMessage(username, data: ciphertext, sync: true)
            
        } catch _ {
            success = Bool(false)
            print("Fail AES")
        }
        
        return success
    }
    
    /**
     Retrieve an UIImage from a ciphertext.
     
     - parameter ciphertext: the ciphertext
     
     - returns: an UIImage
     */
    func retrieveImage(ciphertext : String) -> Message? {
        
        // The not read icon.
        let icon = UIImage(named: "notread")!
        
        //MARK: RSA Preprocessing
        
        // Removing first "RSA" tag
        let firstRSACiphertext = ciphertext.substringFromIndex(ciphertext.startIndex.advancedBy(3))
        
        // Removing second "RSA" tag
        let range: Range<String.Index> = firstRSACiphertext.rangeOfString("RSA")!
        let rsaCipherText =  firstRSACiphertext.substringToIndex(range.startIndex)
        
        let cipherTextWORSA = firstRSACiphertext.substringFromIndex(range.endIndex)
        
        // MARK: RSA Decryption
        let rsaCipherTextData = rsaCipherText.dataFromHexadecimalString()
        
        let decodedRSAString = decryptWithRSA(rsaCipherTextData!)
        
        // Getting AES Key
        let AESKey = decodedRSAString.substringToIndex(32)
        
        let decodedRSAStringWOAES = decodedRSAString.substringFromIndex(32)
        
        // Getting MAC Key
        let MACKey = decodedRSAStringWOAES.substringToIndex((decodedRSAStringWOAES.startIndex.advancedBy(32)))
        let MACKeyArray: [UInt8] = Array(MACKey.utf8)
        
        // Getting sender username
        let username = decodedRSAStringWOAES.substringFromIndex((decodedRSAStringWOAES.startIndex.advancedBy(32)))
        
        // MARK: Getting IV
        let IV = cipherTextWORSA.substringToIndex(cipherTextWORSA.startIndex.advancedBy(32))
        let IVArray: [UInt8] = Array(IV.utf8)
        
        let cipherTextWORSAIV = cipherTextWORSA.substringFromIndex(cipherTextWORSA.startIndex.advancedBy(32))
        
        // MARK: Getting MAC value
        let macArrayHexRetrieved = cipherTextWORSAIV.substringToIndex(cipherTextWORSAIV.startIndex.advancedBy(128))
        
        // MARK: AES Decryption preprocessing
        let aesCiphertextBase64 = cipherTextWORSAIV.substringFromIndex(cipherTextWORSAIV.startIndex.advancedBy(128))
        let aesCiphertextData = NSData(base64EncodedString: aesCiphertextBase64, options: NSDataBase64DecodingOptions(rawValue: 0) )
        let aesCiphertextArray = aesCiphertextData?.arrayOfBytes()
        
        // MARK: Testing MAC
        let macArray: [UInt8] = try! Authenticator.HMAC(key: MACKeyArray, variant: HMAC.Variant.sha512).authenticate(IVArray + aesCiphertextArray!)
        let macArrayHex = macArray.toHexString()
        if macArrayHex == macArrayHexRetrieved {
            do {
                //MARK : AES Decryption
                let decryptedImage = try AES(key: AESKey, iv: IV, blockMode: .CBC).decrypt(aesCiphertextArray!, padding: PKCS7())
                let decryptedImageData = NSData(bytes: decryptedImage)
                let decryptedImageBase64 = decryptedImageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                let image = convertBase64ToImage(decryptedImageBase64)
                let message = Message(icon: icon, name: username, type: 3, photo: image)
                return message!
            } catch _ {
                print("failed AES decryption")
            }
        } else {
            print("MAC does not match.")
        }
        return nil
    }
    // MARK: Private functions.
    
    /**
     Generate random string
     
     - parameter numberOfBytes: number of random bytes to generate
     
     - returns: the random string
     */
    private func generateRandomString(numberOfBytes : Int) -> String{
        let bytesCount = numberOfBytes // number of bytes
        var randomValue = "" // hexadecimal version of randomBytes
        var randomBytes = [UInt8](count: bytesCount, repeatedValue: 0) // array to hold randoms bytes
        
        // Gen random bytes
        SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
        
        // Turn randomBytes into array of hexadecimal strings
        // Join array of strings into single string
        randomValue = randomBytes.map({String(format: "%02hhx", $0)}).joinWithSeparator("")
        
        return randomValue
    }
    
    /**
     Convert UImage to Base64
     
     - parameter image: the UIImage
     
     - returns: return base64 string image
     */
    private func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.lowQualityJPEGNSData
        return imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))    }
    
    /**
     Convert Base64 to UImage.
     
     - parameter base64String: the base 64 string image
     
     - returns: the UIImage
     */
    private func convertBase64ToImage(base64String: String) -> UIImage {
        
        let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions(rawValue: 0) )
        
        let decodedimage = UIImage(data: decodedData!)
        
        return decodedimage!
        
    }
    
    /**
     Convert Image to Byte Array
     
     - parameter image: the UIImage
     
     - returns: the byte array containing the image
     */
    private func convertImageToByteArray(image : UIImage) -> [UInt8] {
        let imageData = image.lowQualityJPEGNSData
        return imageData.arrayOfBytes()
    }
    
    /**
     Convert byte array to UIImage
     
     - parameter byteArray: the byte array containing the image
     
     - returns: the UIImage
     */
    private func convertByteArrayToImage(byteArray : [UInt8]) -> UIImage {
        let imageData = NSData(bytes: byteArray)
        return UIImage(data: imageData)!
    }
    
    /**
     Convert byte array to hex string
     
     - parameter bytes: the byte array
     
     - returns: the hex string
     */
    private func bytesToHexString(bytes: [UInt8]) -> String {
        return bytes.map{String(format: "%02X", $0)}.joinWithSeparator("")
    }
    
    /**
     Decrypt RSA Data with the private key
     
     - parameter rsaCiphertextData: the RSA ciphertext
     
     - returns: the plain text.
     */
    private func decryptWithRSA(rsaCiphertextData : NSData) -> NSString {
        let privateKey = AsymmetricCryptoManager.sharedInstance.getPrivateKeyReference()
        let decodedRSAData = RSAUtils.decryptWithRSAKey(rsaCiphertextData, rsaKeyRef: privateKey!, padding: SecPadding.None)
        return  NSString(data: decodedRSAData!, encoding: NSUTF8StringEncoding)!
    }
}

// MARK: - Extension for UIImage quality
extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}

// MARK: - Extension for String
extension String {
    
    /**
     Create NSData from hexadecimal string representation
     
     - returns: the NSData
     */
    func dataFromHexadecimalString() -> NSData? {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
        
        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)
        
        let found = regex.firstMatchInString(trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count))
        if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
            return nil
        }
        
        // everything ok, so now let's build NSData
        let data = NSMutableData(capacity: trimmedString.characters.count / 2)
        
        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [UInt8], length: 1)
        }
        
        return data
    }
}
