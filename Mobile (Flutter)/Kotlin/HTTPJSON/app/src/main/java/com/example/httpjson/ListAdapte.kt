package com.example.httpjson

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import androidx.appcompat.widget.AppCompatTextView

class ListAdapte (val context: Context, val list: ArrayList<Attack>) : BaseAdapter() {
    override fun getCount(): Int {
        return list.size
    }

    override fun getItem(position: Int): Any {
        return list[position]
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun getView(position: Int, countertView: View?, parent: ViewGroup?): View {

        val view: View = LayoutInflater.from(context).inflate(R.layout.row_layout,parent,false)
        val attackID = view.findViewById(R.id.attack_id) as AppCompatTextView
        val attackName = view.findViewById(R.id.attack_name) as AppCompatTextView
        val attackDescription = view.findViewById(R.id.attack_description) as AppCompatTextView

        attackID.text = list[position].id.toString()
        attackName.text = list[position].name
        attackDescription.text = list[position].description

        return view
    }
}