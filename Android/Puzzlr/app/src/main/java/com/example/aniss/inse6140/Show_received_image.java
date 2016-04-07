package com.example.aniss.inse6140;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;
import android.os.StrictMode;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.ObjectInputStream;

import tools.Encoding;

public class Show_received_image extends AppCompatActivity implements View.OnClickListener{
    private ImageView imageView1;
    private Bundle bundle;
    private Button etGoBack, etShowEncryptedImage, etShowDecryptedImage;
    private String encryptedImageFileName;
    private String decryptedImageFileName;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(android.R.style.ThemeOverlay_Material_Dark);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_show_received_image);
        if(Build.VERSION.SDK_INT > 9){
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);

        }
        etGoBack = (Button) findViewById(R.id.etGoBack);
        etShowDecryptedImage = (Button) findViewById(R.id.etShowDecryptedImage);
        etShowEncryptedImage = (Button) findViewById(R.id.etShowEncryptedImage);

        imageView1 = (ImageView) findViewById(R.id.ivImage1);


        etGoBack.setOnClickListener(this);
        etShowEncryptedImage.setOnClickListener(this);
        etShowDecryptedImage.setOnClickListener(this);

        bundle = getIntent().getExtras();
        encryptedImageFileName = bundle.getString("Encrypted image file name");
        decryptedImageFileName = bundle.getString("Decrypted image file name");




    }

    private Bitmap readBitmapFromFile(String fileName) throws IOException, ClassNotFoundException {
        FileInputStream fileInputStream = openFileInput(fileName);
        ObjectInputStream objectInputStream = new ObjectInputStream(new BufferedInputStream(fileInputStream));
        byte[] imageData = (byte[]) objectInputStream.readObject();
        int imageWidth = (int) objectInputStream.readObject();
        int imageHeight = (int) objectInputStream.readObject();
        String configName = (String) objectInputStream.readObject();
        Bitmap.Config configBmp = Bitmap.Config.valueOf(configName);
        Encoding myEncoding = new Encoding();
        Bitmap image = myEncoding.byteArrayToBitmap(imageData, imageWidth, imageHeight, configBmp);

        return image;



    }

    @Override
    public void onClick(View v) {
        if(v.getId() == R.id.etGoBack){
            this.finish();
        }else if(v.getId() == R.id.etShowEncryptedImage){
            try {
                Bitmap image1 = readBitmapFromFile(encryptedImageFileName);
                imageView1.setImageBitmap(image1);
            } catch (IOException e) {
                e.printStackTrace();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }else if(v.getId() == R.id.etShowDecryptedImage){
            try {
                Bitmap image2 = readBitmapFromFile(decryptedImageFileName);
                imageView1.setImageBitmap(image2);
            } catch (IOException e) {
                e.printStackTrace();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }
    }
}
