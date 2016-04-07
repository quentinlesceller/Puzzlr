package com.example.aniss.inse6140;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.StrictMode;
import android.view.View;
import android.widget.Button;



public class MainActivity extends Activity implements View.OnClickListener{

    private static Button login, register;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(android.R.style.ThemeOverlay_Material_Dark);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if(Build.VERSION.SDK_INT > 9){
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);

        }

        login = (Button) findViewById(R.id.etLogin);
        register = (Button) findViewById(R.id.etRegister);



        login.setOnClickListener(this);
        register.setOnClickListener(this);




    }






    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.etLogin:



                startActivity(new Intent(this, Login.class));


                break;

            case R.id.etRegister:



                startActivity(new Intent(this, Register.class));



                break;
        }
    }
}
