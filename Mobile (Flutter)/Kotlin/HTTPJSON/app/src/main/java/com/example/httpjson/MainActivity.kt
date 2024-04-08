package com.example.httpjson

import android.os.Build
import android.os.Bundle
import android.os.StrictMode
import android.os.StrictMode.ThreadPolicy
import android.widget.ListView
import androidx.appcompat.app.AppCompatActivity
import org.json.JSONArray
import java.net.HttpURLConnection
import java.net.URL


class MainActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        //val t = Toast.makeText(applicationContext, "Начали парсинг", Toast.LENGTH_LONG)
        //t.show()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // разрешить внешние соединения
        if (Build.VERSION.SDK_INT > 9) {
            val policy = ThreadPolicy.Builder().permitAll().build()
            StrictMode.setThreadPolicy(policy)
        }

        val url = "https://mysafeinfo.com/api/data?list=cyberattacktypes&format=json"
        val connection = URL(url).openConnection() as HttpURLConnection
        val responseCode = connection.responseCode

        try {
            val data = connection.inputStream.bufferedReader().use { it.readText() }
            // ... do something with "data"
            //val toast = Toast.makeText(applicationContext, data, Toast.LENGTH_LONG)
            //toast.show()
            hanldeJson(data)

        } finally {
            connection.disconnect()
        }

    }




    private fun hanldeJson(jsonString: String?) {

        val jsonArray = JSONArray(jsonString)

        val list = ArrayList<Attack>()
        var x = 0
        while (x < jsonArray.length()) {

            val jsonObject = jsonArray.getJSONObject(x)

            list.add(
                Attack(
                    jsonObject.getInt("ID"),
                    jsonObject.getString("AttackName") ,
                    jsonObject.getString("Description") ,
            ))

            x++
        }

        val adapter = ListAdapte(this, list)
        val list2: ListView = findViewById(R.id.president_list);
        list2.setAdapter(adapter);

        //val toast = Toast.makeText(applicationContext, x.toString(), Toast.LENGTH_LONG)
        //toast.show()


    }
}


