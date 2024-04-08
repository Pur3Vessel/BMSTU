package com.example.kotlin_auth5_klicker_fb

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.Toast
import android.widget.*
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.auth.AuthResult
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase

class MainActivity : AppCompatActivity() {

    private lateinit var auth: FirebaseAuth

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        auth = FirebaseAuth.getInstance()

        setContentView(R.layout.activity_login)

        // get reference to all views
        var et_user_name = findViewById(R.id.editTextUsername) as EditText
        var et_password = findViewById(R.id.editTextPassword) as EditText
        var btn_submit = findViewById(R.id.buttonLogin) as Button


        // set on-click listener
        btn_submit.setOnClickListener {
            val user_name = et_user_name.text;
            val password = et_password.text;
            auth.signInWithEmailAndPassword(user_name.toString(), password.toString()).addOnCompleteListener(this) { task ->
                if (task.isSuccessful) {
                    setContentView(R.layout.activity_main)
                    val btnLogin = findViewById<Button>(R.id.btnLogin)
                    var counter = 0
                    btnLogin.setOnClickListener { view ->
                        val myRef =
                            FirebaseDatabase.getInstance("https://kotlin-auth5-klicker-fb-default-rtdb.asia-southeast1.firebasedatabase.app/").reference
                        myRef.child("counter").setValue(counter)
                        counter++

                        val myToast = Toast.makeText(this, "!!!", Toast.LENGTH_SHORT)
                        myToast.show()

                    }
                } else {
                    val myToast = Toast.makeText(this, "failed :-(", Toast.LENGTH_SHORT)
                    myToast.show()
                }
            }
            // your code to validate the user_name and password combination
            // and verify the same

        }
    }

}