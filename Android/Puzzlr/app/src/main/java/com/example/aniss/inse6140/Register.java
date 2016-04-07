package com.example.aniss.inse6140;

import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.StrictMode;
import android.util.Base64;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.math.BigInteger;
import java.security.Key;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.RSAPrivateKeySpec;
import java.security.spec.RSAPublicKeySpec;

import BlockChain.DataBlockchain;
import BlockChain.PublicKeyBlockchain;
import BlockChain.UserBlockchain;
import security.Asymmetric;
import tools.Encoding;

//import userblockchain.UserBlockchain;


public class Register extends Activity implements View.OnClickListener{


    Button etRegister;
    EditText  etUsername, etPassword, etConfirmPassword;

    TextView mErrorField;
    TextView tv;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(android.R.style.ThemeOverlay_Material_Dark);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        if(Build.VERSION.SDK_INT > 9){
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);

        }




        etUsername = (EditText) findViewById(R.id.etUsername);
        etPassword = (EditText) findViewById(R.id.etPassword);
        etConfirmPassword = (EditText) findViewById(R.id.etConfirmPassword);
        mErrorField =(TextView) findViewById(R.id.error_messages);
        etRegister = (Button) findViewById(R.id.etRegister);

        tv = (TextView) findViewById(R.id.externalState);



        etRegister.setOnClickListener(this);
    }







    @Override
    public void onClick(final View v) {
        switch (v.getId()){



            case R.id.etRegister:



                if(
                        !etUsername.getText().toString().equals("")
                        && !etPassword.getText().toString().equals("")
                        && !etConfirmPassword.getText().toString().equals("")){
                    if(etPassword.getText().toString().equals(etConfirmPassword.getText().toString())){


                        try{

                            UserBlockchain userBlockchain = new UserBlockchain("172.30.8.254", 3000);

                            Asymmetric asymmetric = new Asymmetric();

                            KeyPair keyPair = asymmetric.generateKeyPair();

                            PublicKey publicKey = keyPair.getPublic();

                            byte[] publicKeyByteArray = publicKey.getEncoded();




                            System.out.println("Generated private key is : " + keyPair.getPrivate().toString());

                            String publicKeyString = new Encoding().encodeImage(publicKeyByteArray);


                            String publicKeyFileName = etUsername.getText().toString() + "PublicKey.key";
                            String privateKeyFileName = etUsername.getText().toString() + "PrivateKey.key";

                            this.storeKeyPairToFiles(keyPair, publicKeyFileName, privateKeyFileName);

                            Boolean registered = userBlockchain.registerUser(etUsername.getText().toString(), etPassword.getText().toString());

                            if(registered){
                                Toast.makeText(getApplicationContext(),"You have registered successfully", Toast.LENGTH_LONG).show();

                                PublicKeyBlockchain publicKeyBlockchain = new PublicKeyBlockchain("172.30.8.254", 3000);
                                if(publicKeyBlockchain.registerPublicKey(etUsername.getText().toString(), publicKeyString)){
                                    Toast.makeText(getApplicationContext(), "Public key registred successfully on server.", Toast.LENGTH_LONG).show();
                                    Intent intent = new Intent(Register.this, Login.class);
                                    startActivity(intent);
                                }else{
                                    Toast.makeText(getApplicationContext(), "Failed to register public key on server.", Toast.LENGTH_LONG).show();
                                }

                            }

                        }catch(Exception ex){
                            Toast.makeText(getApplicationContext(), ex.getMessage(), Toast.LENGTH_LONG).show();
                        }


                    }else{
                        Toast.makeText(getApplicationContext(), "The password fields do not match", Toast.LENGTH_LONG).show();
                    }

                }





                break;
        }
    }










    public void storeKeyPairToFiles(KeyPair keyPair, String publicKeyFileName, String privateKeyFileName) throws NoSuchAlgorithmException, InvalidKeySpecException,
            IOException {

        Key publicKey = keyPair.getPublic();
        Key privateKey = keyPair.getPrivate();

        KeyFactory factory = KeyFactory.getInstance("RSA");

        RSAPublicKeySpec rsaPublicKeySpec = factory.getKeySpec(publicKey, RSAPublicKeySpec.class);
        RSAPrivateKeySpec rsaPrivateKeySpec = factory.getKeySpec(privateKey, RSAPrivateKeySpec.class);



        FileOutputStream fileOutputStream = openFileOutput(publicKeyFileName, MODE_PRIVATE);
        FileOutputStream fileOutputStream1 = openFileOutput(privateKeyFileName, MODE_PRIVATE);

        saveToFile(fileOutputStream, rsaPublicKeySpec.getModulus(), rsaPublicKeySpec.getPublicExponent());
        saveToFile(fileOutputStream1, rsaPrivateKeySpec.getModulus(), rsaPrivateKeySpec.getPrivateExponent());

    }

    /**
     * Save to file.
     *
     * @param fos the filename
     * @param modulus the modulus
     * @param publicExponent the public exponent
     * @throws IOException Signals that an I/O exception has occurred.
     */
    private void saveToFile(FileOutputStream fos, BigInteger modulus, BigInteger publicExponent) throws IOException {

        ObjectOutputStream objectOutputStream = new ObjectOutputStream(new BufferedOutputStream(fos));



        try{
            objectOutputStream.writeObject(modulus);
            objectOutputStream.writeObject(publicExponent);


        }catch(Exception e){
            throw new IOException("Unexpected error", e);

        }finally{
            objectOutputStream.close();
        }

    }
}
