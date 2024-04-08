package com.example.calculator


//import kotlinx.android.synthetic.main.activity_main.*
import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import net.objecthunter.exp4j.ExpressionBuilder

class MainActivity : AppCompatActivity()
{

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)


        /*Number Buttons*/
        val tvExpression: TextView = findViewById(R.id.tvExpression)

        val tvOpenParenthesis: TextView = findViewById(R.id.tvOpenParent)
        tvOpenParenthesis.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "("
        }

        val tvCloseParenthesis: TextView = findViewById(R.id.tvCloseParent)
        tvCloseParenthesis.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + ")"
        }

        val tvSqrt: TextView = findViewById(R.id.tvSqrt)
        tvSqrt.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "sqrt("
        }

        val tvArccos: TextView = findViewById(R.id.tvArccos)
        tvArccos.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "acos("
        }

        val tvOne: TextView = findViewById(R.id.tvOne)
        tvOne.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "1"
        }

        val tvTwo: TextView = findViewById(R.id.tvTwo)
        tvTwo.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "2"
        }

        val tvThree: TextView = findViewById(R.id.tvThree)
        tvThree.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "3"
        }

        val tvFour: TextView = findViewById(R.id.tvFour)
        tvFour.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "sin"
        }

        val tvFive: TextView = findViewById(R.id.tvFive)
        tvFive.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "5"
        }

        val tvSix: TextView = findViewById(R.id.tvSix)
        tvSix.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "6"
        }

        val tvSeven: TextView = findViewById(R.id.tvSeven)
        tvSeven.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "7"
        }

        val tvEight: TextView = findViewById(R.id.tvEight)
        tvEight.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "8"
        }

        val tvNine: TextView = findViewById(R.id.tvNine)
        tvNine.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "9"
        }

        val tvZero: TextView = findViewById(R.id.tvZero)
        tvZero.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "0"
        }

        /*Operators*/

        val tvPlus: TextView = findViewById(R.id.tvPlus)
        tvPlus.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "+"
        }

        val tvMinus: TextView = findViewById(R.id.tvMinus)
        tvMinus.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "-"
        }

        val tvMul: TextView = findViewById(R.id.tvMul)
        tvMul.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "*"
        }

        val tvDivide: TextView = findViewById(R.id.tvDivide)
        tvDivide.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "/"
        }

        val tvDot: TextView = findViewById(R.id.tvDot)
        tvDot.setOnClickListener {
            tvExpression.text = tvExpression.text.toString() + "."
        }

        val tvClear: TextView = findViewById(R.id.tvClear)

        val tvResult: TextView = findViewById(R.id.tvResult)
        tvClear.setOnClickListener {
            tvExpression.text = ""
            tvResult.text = ""
        }

        val tvEquals: TextView = findViewById(R.id.tvEquals)
        tvEquals.setOnClickListener {
            val text = tvExpression.text.toString()
            val expression = ExpressionBuilder(text).build()

            val result = expression.evaluate()
            val longResult = result.toLong()
            if (result == longResult.toDouble()) {
                tvResult.text = longResult.toString()
            } else {
                tvResult.text = result.toString()
            }
        }
        val tvBack: TextView = findViewById(R.id.tvBack)
        tvBack.setOnClickListener {
            val text = tvExpression.text.toString()
            if(text.isNotEmpty()) {
                tvExpression.text = text.drop(1)
            }

            tvResult.text = ""
        }

    }







}