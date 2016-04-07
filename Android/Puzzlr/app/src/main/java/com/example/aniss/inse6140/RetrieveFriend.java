package com.example.aniss.inse6140;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.StrictMode;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import BlockChain.PublicKeyBlockchain;
import BlockChain.UserBlockchain;

public class RetrieveFriend extends AppCompatActivity implements View.OnClickListener{

    private Button etRetrieve;
    private EditText etUsername;
    private Bundle bundle;
    String myUsername;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(android.R.style.ThemeOverlay_Material_Dark);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_retrieve_friend);
        if(Build.VERSION.SDK_INT > 9){
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);

        }
        etUsername = (EditText) findViewById(R.id.etUsername);
        etRetrieve = (Button) findViewById(R.id.etRetrieve);
        etRetrieve.setOnClickListener(this);
        bundle = getIntent().getExtras();
        myUsername = bundle.getString("My username");

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.etRetrieve:
                if(!etUsername.getText().toString().equals("")){
                    UserBlockchain userBlockchain = new UserBlockchain("172.30.8.254", 3000);

                    if(userBlockchain.getRegistered(etUsername.getText().toString())){
                        PublicKeyBlockchain publicKeyBlockchain = new PublicKeyBlockchain("172.30.8.254", 3000);
                        String publicKeyofUser = publicKeyBlockchain.queryPublicKey(etUsername.getText().toString());
                        Intent intent = new Intent(RetrieveFriend.this, Home.class);
                        Bundle bundle = new Bundle();
                        bundle.putString("Public key of user", publicKeyofUser);
                        bundle.putString("Username", etUsername.getText().toString());
                        bundle.putString("My username", myUsername);
                        intent.putExtras(bundle);
                        startActivity(intent);

                    }else{
                        Toast.makeText(getApplicationContext(), "This username is not registred, please enter another one.", Toast.LENGTH_LONG).show();
                    }
                }
        }
    }
}
