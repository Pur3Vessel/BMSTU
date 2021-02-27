"use strict"
const fs = require("fs"); //для работы с файлами
var vocabulary = fs.readFileSync(process.argv[2]).toString().split(/ |\n/); // разбиение словаря на отдельные слова относительно пробелов и переводов строки
vocabulary.push(' '); //игнор пробеловs
//console.log(vocabulary);
var example = fs.readFileSync(process.argv[3]).toString().split('\n'); //  разбиение текста на отдельные строчки (для подсчета строк)
//console.log(example);

function scaner (text) {
    let tokens = []; // массив со словами и их координатами
    for (let i = 0; i < text.length; i++) {
        let words = text[i].split(' '); // разбиение строки на отдельные слова относительно пробелов (для подсчета столбцов)
        //console.log(words);
        for (let j = 0; j < words.length; j++) {
            tokens.push([words[j], i + 1, text[i].indexOf(words[j])+ 1]); // занесение "тройки": слово, столбец, строка
        }
    }
    return tokens;
}

var tokens = scaner(example);
//console.log(tokens);

for (let i = 0; i < tokens.length;i++) {
    if (vocabulary.indexOf(tokens[i][0]) == -1) console.log(`${tokens[i][1]}, ${tokens[i][2]} ${tokens[i][0]}`)
}
