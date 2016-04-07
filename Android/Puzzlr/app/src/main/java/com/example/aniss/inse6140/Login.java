package com.example.aniss.inse6140;
import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.StrictMode;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import BlockChain.JSONException;
import BlockChain.UserBlockchain;


public class Login extends Activity implements View.OnClickListener{

    Button login;
    EditText username, password;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(android.R.style.ThemeOverlay_Material_Dark);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);





        if(Build.VERSION.SDK_INT > 9){
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);

        }

        username = (EditText) findViewById(R.id.etUsername);
        password = (EditText) findViewById(R.id.etPassword);
        login = (Button) findViewById(R.id.etLogin);


        login.setOnClickListener(this);





    }





    @Override
    public void onClick(View v) {
        switch (v.getId()){


            case R.id.etLogin:


                if(!username.getText().toString().equals("") && !password.getText().toString().equals("")){
                    UserBlockchain userBlockchain = new UserBlockchain("172.30.8.254", 3000);
                    try {

                        if(userBlockchain.login(username.getText().toString(), password.getText().toString())){
                            Toast.makeText(getApplicationContext(), "You have logged in successfully", Toast.LENGTH_LONG).show();
                            Intent intent = new Intent(Login.this, RetrieveFriend.class);
                            Bundle bundle = new Bundle();
                            bundle.putString("My username", username.getText().toString());
                            intent.putExtras(bundle);
                            startActivity(intent);
                        }else{
                            Toast.makeText(getApplicationContext(), "You have to register first.", Toast.LENGTH_LONG).show();
                        }
                    } catch (JSONException e) {
                        Toast.makeText(getApplicationContext(), e.getMessage(), Toast.LENGTH_LONG).show();
                    }

                }




                break;
        }
    }
}
