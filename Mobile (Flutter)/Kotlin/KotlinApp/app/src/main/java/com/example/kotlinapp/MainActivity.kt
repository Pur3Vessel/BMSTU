package com.example.kotlinapp

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val et_field = findViewById<EditText>(R.id.text_field)
        val btn_submit = findViewById<Button>(R.id.btn_submit)
        btn_submit.setOnClickListener {
            val data = et_field.text
            Toast.makeText(this@MainActivity, data, Toast.LENGTH_LONG).show()
        }
    }
}