package com.example.aniss.inse6140;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.StrictMode;
import android.provider.MediaStore;
import android.provider.MediaStore.MediaColumns;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.RSAPrivateKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;

import javax.crypto.spec.SecretKeySpec;

import BlockChain.DataBlockchain;
import security.Asymmetric;
import security.Symmetric;
import tools.Encoding;


public class Home extends Activity implements AdapterView.OnItemSelectedListener {

    int REQUEST_CAMERA = 0, SELECT_FILE = 1;
    Button btnSelect;
    Button btnConfirm;
    ImageView ivImage;
    Bitmap image;
    BitmapDrawable drawable;
    Bundle bundle;
    String publicKeyofUser;
    String username;
    String myusername;
    Spinner spinnerTech;
    final String[] options = {"Menu","Messages","Logout"};





    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(android.R.style.ThemeOverlay_Material_Dark);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        if(Build.VERSION.SDK_INT > 9){
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);

        }
        btnSelect = (Button) findViewById(R.id.btnSelectPhoto);
        btnSelect.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                selectImage();
            }
        });
        btnConfirm = (Button) findViewById(R.id.btnConfirm);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, options);
        spinnerTech = (Spinner) findViewById(R.id.spinnerTech);
        spinnerTech.setAdapter(adapter);
        spinnerTech.setOnItemSelectedListener(this);


        final Encoding encoding = new Encoding();

        bundle = getIntent().getExtras();

        publicKeyofUser = bundle.getString("Public key of user");
        username = bundle.getString("Username");
        myusername = bundle.getString("My username");


        btnConfirm.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

                try {


                    if (ivImage == null) {


                        Toast.makeText(getApplicationContext(), "No picture selected, please select one.", Toast.LENGTH_LONG).show();


                    } else {

                        try{



                            image = ((BitmapDrawable)ivImage.getDrawable()).getBitmap();
                            if(image == null){
                                Toast.makeText(getApplicationContext(), "Null", Toast.LENGTH_LONG).show();
                            }

                            Symmetric symmetric = new Symmetric();

                            SecretKeySpec aesKey = symmetric.generateAESKey();

                            byte[] iv = symmetric.generateIV();


                            String ivHex = encoding.encodeImage(iv);





                            int width = image.getWidth();
                            int height = image.getHeight();
                            System.out.println("Image width to send is : " + width);
                            System.out.println("Image height to send is : " + height);

                            String configName = image.getConfig().name();
                            System.out.println("Config name to send is : " + configName);
                            byte[] imageByteArray = encoding.bitmapToByteArray(image);







                            byte[] encryptedByteArrayImage = symmetric.encrypt(aesKey, iv, imageByteArray);




                            String encryptedImageHex = encoding.encodeImage(encryptedByteArrayImage);


                            byte[] publicKeyofUserByteArray = encoding.decodeImage(publicKeyofUser);

                            PublicKey publicKeyOfUser = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(publicKeyofUserByteArray));


                            Asymmetric asymmetric = new Asymmetric();




                            SecretKeySpec macKey = symmetric.generateMacKey();






                            byte[] tag = symmetric.computeMac(encryptedByteArrayImage, macKey, iv);

                            String tagHex = encoding.encodeImage(tag);





                            byte[] usernameByteArray = myusername.getBytes();



                            ByteArrayOutputStream byteArrayOutputStream2 = new ByteArrayOutputStream(aesKey.getEncoded().length + macKey.getEncoded().length + usernameByteArray.length);


                            byteArrayOutputStream2.write(aesKey.getEncoded());
                            byteArrayOutputStream2.write(macKey.getEncoded());
                            byteArrayOutputStream2.write(usernameByteArray);

                            byte[] rsaPlaintext = byteArrayOutputStream2.toByteArray();

                            byte[] rsaCipherText = asymmetric.rsaEncryptKey(rsaPlaintext, publicKeyOfUser);


                            String message = "RSA Ciphertext:" + encoding.encodeImage(rsaCipherText) +"RSA Ciphertext," + "IV:" + ivHex + "IV," + "AES Ciphertext:" + encryptedImageHex + "AES Ciphertext," + "Tag:" + tagHex +"Tag," + "Image width:" + String.valueOf(width) + "Image width," + "Image height:" + String.valueOf(height) + "Image height," + "Config name:" + configName + "Config name,";

                            DataBlockchain dataBlockchain = new DataBlockchain("172.30.8.254", 3000);

                            dataBlockchain.sendMessage(username, message);








                        }catch(Exception ex){


                            ex.printStackTrace();

                        }







                    }


                } catch (Exception e1) {
                    e1.printStackTrace();
                }


            }
        });
        ivImage = (ImageView) findViewById(R.id.ivImage);

        //drawable = (BitmapDrawable)ivImage.getDrawable();



    }








    private void selectImage() {
        final CharSequence[] items = { "Take Photo", "Choose from Library",
                "Cancel" };

        AlertDialog.Builder builder = new AlertDialog.Builder(Home.this);
        builder.setTitle("Add Photo!");
        builder.setItems(items, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int item) {
                if (items[item].equals("Take Photo")) {
                    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                    startActivityForResult(intent, REQUEST_CAMERA);
                } else if (items[item].equals("Choose from Library")) {
                    Intent intent = new Intent(
                            Intent.ACTION_PICK,
                            android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                    intent.setType("image/*");
                    startActivityForResult(
                            Intent.createChooser(intent, "Select File"),
                            SELECT_FILE);
                } else if (items[item].equals("Cancel")) {
                    dialog.dismiss();
                }
            }
        });

        builder.show();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == SELECT_FILE)
                onSelectFromGalleryResult(data);
            else if (requestCode == REQUEST_CAMERA)
                onCaptureImageResult(data);
        }
    }

    private void onCaptureImageResult(Intent data) {
        Bitmap thumbnail = (Bitmap) data.getExtras().get("data");
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        thumbnail.compress(Bitmap.CompressFormat.JPEG, 90, bytes);

        File destination = new File(Environment.getExternalStorageDirectory(),
                System.currentTimeMillis() + ".jpg");

        FileOutputStream fo;
        try {
            destination.createNewFile();
            fo = new FileOutputStream(destination);
            fo.write(bytes.toByteArray());
            fo.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        ivImage.setImageBitmap(thumbnail);


    }

    @SuppressWarnings("deprecation")
    private void onSelectFromGalleryResult(Intent data) {
        Uri selectedImageUri = data.getData();
        String[] projection = { MediaColumns.DATA };
        Cursor cursor = managedQuery(selectedImageUri, projection, null, null,
                null);
        int column_index = cursor.getColumnIndexOrThrow(MediaColumns.DATA);
        cursor.moveToFirst();

        String selectedImagePath = cursor.getString(column_index);

        Bitmap bm;
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(selectedImagePath, options);
        final int REQUIRED_SIZE = 600;
        int scale = 1;
        while (options.outWidth / scale / 2 >= REQUIRED_SIZE
                && options.outHeight / scale / 2 >= REQUIRED_SIZE)
            scale *= 2;
        options.inSampleSize = scale;
        options.inJustDecodeBounds = false;
        bm = BitmapFactory.decodeFile(selectedImagePath, options);

        ivImage.setImageBitmap(bm);

    }



    /*private byte[] bitmapToByteArray(Bitmap image, int width, int height){


        int size = image.getRowBytes() * image.getHeight();
        ByteBuffer byteBuffer = ByteBuffer.allocate(size);
        image.copyPixelsToBuffer(byteBuffer);
        return byteBuffer.array();
    }


    private void byteArrayToBitmap(byte[] byteArrayImage, Bitmap.Config configBmp, int width, int height){
        Bitmap image = Bitmap.createBitmap(width, height, configBmp);
        ByteBuffer buffer = ByteBuffer.wrap(byteArrayImage);
        image.copyPixelsFromBuffer(buffer);



    }*/




    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {

        if(position == 1){
            Asymmetric asymmetric = new Asymmetric();
            Symmetric symmetric = new Symmetric();
            try {
            DataBlockchain dataBlockchain = new DataBlockchain("172.30.8.254", 3000);
            LinkedHashMap<String, String> receivedMessages = dataBlockchain.getAllMessages(myusername);
            if(!receivedMessages.isEmpty()){

                    PrivateKey myPrivateKey = this.readPrivateKeyFromFile(myusername);

                    Collection<String> messages = receivedMessages.values();
                    Object[] messagesArrayObject = messages.toArray();
                    for(int i = 0; i < messagesArrayObject.length; i++){
                        String message = messagesArrayObject[i].toString();




                        System.out.println("---------------------------------------------------------" );
                        String rsaCipherText = message.substring(message.lastIndexOf("RSA Ciphertext:") + 15, message.indexOf("RSA Ciphertext,"));
                        String iv = message.substring(message.lastIndexOf("IV:") + 3, message.indexOf("IV,"));


                        String configName = message.substring(message.lastIndexOf("Config name:") + 12, message.indexOf("Config name,"));
                        String widthString = message.substring(message.lastIndexOf("Image width:") + 12, message.indexOf("Image width,"));
                        int imageWidth = Integer.valueOf(widthString);
                        String heightString = message.substring(message.lastIndexOf("Image height:") + 13, message.indexOf("Image height,"));
                        int imageHeight = Integer.valueOf(heightString);

                        System.out.println("Received image width is : " + imageWidth );
                        System.out.println("Received image height is : " + imageWidth );
                        System.out.println("Received config name is : " + configName);


                        Encoding myEncoding = new Encoding();
                        byte[] ivBytesArray = myEncoding.decodeImage(iv);
                        byte[] rsaCipherTextByteArray = myEncoding.decodeImage(rsaCipherText);
                        byte[] rsaPlainTextByteArray = asymmetric.rsaDecryptKey(rsaCipherTextByteArray, myPrivateKey);

                        byte[] aesKeyByteArray = new byte[32];
                        for(int j = 0; j < 32; j++){

                            aesKeyByteArray[j] = rsaPlainTextByteArray[j];

                        }

                        byte[] macKeyByteArray = new byte[32];
                        int k = 0;

                        for(int j = 32; j < 64; j++){

                            macKeyByteArray[k] = rsaPlainTextByteArray[j];
                            k++;

                        }

                        byte[] usernameByteArray = new byte[rsaPlainTextByteArray.length - 64];
                        int h = 0;

                        for(int j = 64; j < rsaPlainTextByteArray.length; j++){

                            usernameByteArray[h] = rsaPlainTextByteArray[j];
                            h++;


                        }


                        SecretKeySpec macKey = new SecretKeySpec(macKeyByteArray, "HmacSHA512");
                        SecretKeySpec aesKey = new SecretKeySpec(aesKeyByteArray, "AES");



                        String username = new String(usernameByteArray);


                        String aesCipherText = message.substring(message.lastIndexOf("AES Ciphertext:") + 15, message.indexOf("AES Ciphertext,"));
                        byte[] aesCipherTextByteArray = myEncoding.decodeImage(aesCipherText);

                        byte[] aesPlainTextByteArray = symmetric.decrypt(aesCipherTextByteArray, aesKey, ivBytesArray);







                       System.out.println("---------------------------------------------------------");
                       /* Bitmap.Config configBmp = Bitmap.Config.valueOf(configName);
                        Bitmap image1 = myEncoding.byteArrayToBitmap(aesCipherTextByteArray, imageWidth, imageHeight, configBmp);
                        Bitmap image2 = myEncoding.byteArrayToBitmap(aesPlainTextByteArray, imageWidth, imageHeight, configBmp);*/



                        FileOutputStream fileOutputStream1 = openFileOutput("Encrypted.txt", MODE_PRIVATE);
                        FileOutputStream fileOutputStream2 = openFileOutput("Decrypted.txt", MODE_PRIVATE);

                        writeBimapToFile(fileOutputStream1, aesCipherTextByteArray, imageWidth, imageHeight, configName);
                        writeBimapToFile(fileOutputStream2, aesPlainTextByteArray, imageWidth, imageHeight, configName);

                        Bundle bundle = new Bundle();
                        bundle.putString("Encrypted image file name", "Encrypted.txt");
                        bundle.putString("Decrypted image file name", "Decrypted.txt");
                        Intent intent = new Intent(Home.this, Show_received_image.class);
                        intent.putExtras(bundle);
                        startActivity(intent);



                    }


            }else{
                Toast.makeText(getApplicationContext(), "None", Toast.LENGTH_LONG).show();
            }

            } catch (Exception e1) {
                e1.printStackTrace();
            }
        }else if(position == 2){
            System.exit(0);
        }


    }

    private void writeBimapToFile(FileOutputStream fileOutputStream1, byte[] imageData, int imageWidth, int imageHeight, String configName) throws IOException {

        ObjectOutputStream objectOutputStream = new ObjectOutputStream(new BufferedOutputStream(fileOutputStream1));
        try{
            objectOutputStream.writeObject(imageData);
            objectOutputStream.writeObject(imageWidth);
            objectOutputStream.writeObject(imageHeight);
            objectOutputStream.writeObject(configName);

        }catch (Exception ex1){
            Toast.makeText(getApplicationContext(), ex1.getMessage(), Toast.LENGTH_LONG).show();
        }finally {
            objectOutputStream.close();
        }


    }


    @Override
    public void onNothingSelected(AdapterView<?> parent) {

    }


    public PrivateKey readPrivateKeyFromFile(String username) throws IOException, ClassNotFoundException, NoSuchAlgorithmException, InvalidKeySpecException{

        FileInputStream fileInputStream = openFileInput(username + "PrivateKey.key");
        ObjectInputStream objectInputStream = new ObjectInputStream(new BufferedInputStream(fileInputStream));
        BigInteger m = (BigInteger) objectInputStream.readObject();
        BigInteger e = (BigInteger) objectInputStream.readObject();
        RSAPrivateKeySpec keySpec = new RSAPrivateKeySpec(m, e);
        KeyFactory factory = KeyFactory.getInstance("RSA");
        PrivateKey privateKey = factory.generatePrivate(keySpec);

        return privateKey;


    }



}