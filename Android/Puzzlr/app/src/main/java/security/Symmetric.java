package security;

import android.util.Base64;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.Mac;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * Created by aniss on 04/03/16.
 */
public class Symmetric {

    private static String salt;
    private static final int pswdIterations = 100000;
    private static final int keySize = 256;
    private static final int ivSize = 128;


    public SecretKeySpec generateAESKey() throws UnsupportedEncodingException, NoSuchAlgorithmException, InvalidKeySpecException {

        salt = generateSalt();

        String password = generateRandomPassword(32);

        byte[] saltBytes = salt.getBytes("UTF-8");


        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");

        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), saltBytes, pswdIterations, keySize);

        SecretKey secretKey = factory.generateSecret(spec);



        SecretKeySpec secret = new SecretKeySpec(secretKey.getEncoded(), "AES");




        return secret;

    }


    public byte[] generateIV() throws UnsupportedEncodingException, NoSuchAlgorithmException{

        SecureRandom random = new SecureRandom();

        byte[] iv = random.generateSeed(16);



        return iv;
    }



    public byte[] encrypt(SecretKeySpec secret, byte[] iv, byte[] imageByteArray) throws NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, IllegalBlockSizeException, BadPaddingException, IOException {



        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");

        IvParameterSpec ivParameterSpec = new IvParameterSpec(iv);





        cipher.init(Cipher.ENCRYPT_MODE, secret, ivParameterSpec);






        byte[] encryptedImageByte = cipher.doFinal(imageByteArray);




        return encryptedImageByte;









    }




    public byte[] decrypt(byte [] encryptedImageByte, SecretKeySpec secret, byte[] iv) throws NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, IllegalBlockSizeException, BadPaddingException, IOException{




        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");

        IvParameterSpec ivParameterSpec = new IvParameterSpec(iv);





        cipher.init(Cipher.DECRYPT_MODE, secret, ivParameterSpec);

        return cipher.doFinal(encryptedImageByte);

    }








    private String generateRandomPassword(int length) {
        // TODO Auto-generated method stub

        SecureRandom random = new SecureRandom();
        byte bytes[] = new byte[length];
        random.nextBytes(bytes);
        String s = new String(bytes);
        return s;
    }


    private String generateSalt() {
        // TODO Auto-generated method stub

        SecureRandom random = new SecureRandom();
        byte bytes[] = new byte[16];
        random.nextBytes(bytes);
        String s = new String(bytes);

        return s;
    }



    public SecretKeySpec generateMacKey(){
        byte[] macKey = new byte[32];

        SecureRandom random = new SecureRandom();
        random.nextBytes(macKey);

        SecretKeySpec secretKeySpec = new SecretKeySpec(macKey, "HmacSHA512");


        return secretKeySpec;
    }


    public byte[] computeMac(byte[] ciphertext, SecretKeySpec macKey, byte[] iv) throws NoSuchAlgorithmException, InvalidKeyException{
        Mac mac = Mac.getInstance("HmacSHA512");
        mac.init(macKey);
        mac.update(iv);
        byte[] macBytes = mac.doFinal(ciphertext);
        return macBytes;
    }










}