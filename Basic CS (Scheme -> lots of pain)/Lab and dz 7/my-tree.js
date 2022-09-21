"use strict"
const fs = require('fs'); //для работы с файлами
const path = require('path'); //для работы с путями к файлам
function d_lastdir (tier ,dir_array) {                    //функция, которая определяет последнюю папку в директории. Нужна для красивого рисования с -d
    let ans;
    for (let i = 0; i < dir_array.length; i++) {
        let d_h = fs.lstatSync(path.join(tier, dir_array[i])).isDirectory();
        if (d_h) ans = i;
    }
    return ans;
}
function tree_build (tier, deep , o_mode, d_mode) {             //tier - текущая директория (для рекурсии), deep - строка с "палочками" (для глубины вложенности)
    let dir_array;     
    try {
        dir_array = fs.readdirSync(tier);   // массив с файлами директории
    }    
    catch {                                 // если не удалось прочесть папку (доступ запрещен)
        return;
    }         
    let last_dir;
    if (d_mode) last_dir = d_lastdir(tier ,dir_array);
    for (let i = 0; i < dir_array.length; i++) {
        let pat = path.join(tier, dir_array[i]);         // создается путь до текущего файла
        let stat = fs.lstatSync(pat).isDirectory(); 
        if (stat) {
            directories_c++;
            if (o_mode) {
                if (i == dir_array.length - 1) {
                    console.log(`${deep}└── ${dir_array[i]}`);
                    tree_build(pat, `${deep}   `, o_mode, d_mode);
                }
                else {
                    if (d_mode && i == last_dir) console.log(`${deep}└── ${dir_array[i]}`);
                    else console.log(`${deep}├── ${dir_array[i]}`);
                    tree_build(pat, `${deep}│   `, o_mode, d_mode);
                }
            }
            else {
                if (i == dir_array.length - 1) {
                    fs.appendFileSync(out, `\n${deep}└── ${dir_array[i]}`);
                    tree_build(pat, `${deep}   `, o_mode, d_mode);
                }
                else {
                    if (d_mode && i == last_dir) ls.appendFileSync(out, `\n${deep}└── ${dir_array[i]}`);
                    else fs.appendFileSync(out, `\n${deep}├── ${dir_array[i]}`);
                    tree_build(pat, `${deep}│   `, o_mode, d_mode);
                }
            }
            
        }
        else {
            if (d_mode) continue;        // не директории не рассматриваются в случае с -d
            files_c++;
            if (o_mode) {
                if (i == dir_array.length - 1) {
                    console.log(`${deep}└── ${dir_array[i]}`);
                }
                else {
                    console.log(`${deep}├── ${dir_array[i]}`);
                }
            }
            else {
                if (i == dir_array.length - 1) {
                    fs.appendFileSync(out, `\n${deep}└── ${dir_array[i]}`);
                }
                else {
                    fs.appendFileSync(out, `\n${deep}├── ${dir_array[i]}`);
                }
            }
        }
    }
}

var directories_c = 0;
var files_c = 0;
var tier = path.dirname(require.main.filename);   //директория, из которой идет вызов программы
var out;
var o_mode = true;                   //тут у меня возникла небольшая накладка, и было лень менять функцию, поэтому о_mode начинается с true
var d_mode = false;
for (let i = 0; i < process.argv.length; i++){
    if (process.argv[i] == "-d") {
        d_mode = true;
    }
    if (process.argv[i] == "-o") {
        o_mode = false;
        out = process.argv[i + 1];
    }
    if (process.argv[i] != "-o" && process.argv[i] != "-d") {           // в случае чего можно поменять стартовую директорию (как и в оригинальной утилите)
            let n_p = fs.lstatSync(process.argv[i]).isDirectory();
            if (n_p) tier = process.argv[i];
    }
}
if (o_mode) console.log(".");
else appendFileSync(out, ".");
tree_build(tier,'',o_mode,d_mode);
if (d_mode) {
    if (o_mode) console.log(`\n${directories_c} directories`);
    else appendFileSync (out, `\n${directories_c} directories`);
}
else {
    if (o_mode) console.log(`\n${directories_c} directories, ${files_c} files`);
    else appendFileSync(out, `\n${directories_c} directories, ${files_c} files`);
}