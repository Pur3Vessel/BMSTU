'use strict'      
const fs = require('fs');
const readline = require('readline');        // для стандартного ввода

function searcher (file, str, n_mode, m_mode, digit_for_m) {                 // ищет без ключа -i
    let file_array = file.toString().split('\n');
    let m_counter = 0;
    for (let i = 0; i < file_array.length; i++) {
        if (file_array[i].indexOf(str) != -1) {
            m_counter++;
            if (n_mode) console.log(`${1+i} : ${file_array[i]}`);
            else console.log(file_array[i]);
        }
        if (m_mode && m_counter == digit_for_m) break;
    }
}
function searcher_with_e (file, reg, n_mode, m_mode, digit_for_m) {                 // ищет с ключом -e
    let file_array = file.toString().split('\n');
    let m_counter = 0;
    for (let i = 0; i < file_array.length; i++) {
        if (reg.test(file_array[i])) {
            m_counter++;
            if (n_mode) console.log(`${1+i} : ${file_array[i]}`);
            else console.log(file_array[i]);
        }
        if (m_mode && m_counter == digit_for_m) break;
    }
}
function searcher_with_i (file, str, n_mode, m_mode, digit_for_m) {        // ищет с ключом -i
    let file_array = file.toString().split('\n');
    let m_counter = 0;
    let str_copy = str.toLowerCase();                                      // отличие от searcher в том, что поиск идет относительно копий с маленькими буквами
    let file_array_copy = file.toString().toLowerCase().split('\n');
    for (let i = 0; i < file_array.length; i++) {
        if (file_array_copy[i].indexOf(str_copy) != -1) {
            m_counter++;
            if (n_mode) console.log(`${1+i} : ${file_array[i]}`);
            else console.log(file_array[i]);
        }
        if (m_mode && m_counter == digit_for_m) break;
    }
}

function arguments_maker(args, ob, found) {                   //функция которая анализирует массив аргументов и подготавливает аргументы для вызова searcher
    for (let i = 0; i < args.length; i++) {
        if (args[i] == "-n") ob.n_mode = true;
        if (args[i] == "-i") ob.i_mode = true;
        if (args[i] == "-e") ob.e_mode = true;
        if (args[i] == "-m") {
            ob.m_mode = true;
            ob.digit_for_m = args[i+1];
            i++;
            continue;
        }
        if (args[i] != "-n" && args[i] != "-i" && args[i] != "-m" && args[i] != "-e" && found == false) {
            ob.str = args[i];
            found = true;                 //была найдена строка для поиска (ее нужно подавать перед файлами)
            continue;
        }
        if (args[i] != "-n" && args[i] != "-i" && args[i] != "-m" && found == true) ob.file_s.push(args[i]);
    }
    return ob;
}
const rl = readline.createInterface( {
    input: process.stdin,
    output: process.stdout
})

rl.question('Обработка стадартного ввода (приоритетная обработка: командная строка): ', (input) => {
    var args = [];   //массив с аргументами, который потом будет проанализирован
    var files = [];
    var ob = {
        n_mode: false,
        m_mode: false,
        e_mode: false,
        digit_for_m: 0,
        i_mode: 0,
        file_s: [],
        str:  ''
    };
    if (process.argv.length > 2) {
        for (let i = 2; i < process.argv.length; i++) args.push(process.argv[i]);
    }
    else {
         var input_array = input.split(' ');
         for (let i = 0; i < input_array.length; i++){
             if (input_array[i] != '') args.push(input_array[i]); 
         }
    }
    ob = arguments_maker(args, ob, false);
    for (let i = 0; i < ob.file_s.length; i++) {
        try {
            files.push(fs.readFileSync(ob.file_s[i]));
        }
        catch {
            console.log(`Файл ${ob.file_s[i]} не смог быть прочитан :(`);
            ob.file_s.splice(i, 1);        // непрочитанный файл удаляется из списка файлов
            i--;
            continue;
        }
    }
    for (let i = 0; i < files.length; i++) {
        console.log(`Current file: ${ob.file_s[i]}`);
        if (ob.i_mode) searcher_with_i(files[i], ob.str, ob.n_mode, ob.m_mode, ob.digit_for_m);
        else {
            if (ob.e_mode) {
                let reg = new RegExp(ob.str);       //строка преобразуется в регулярное выражение
                searcher_with_e(files[i], reg, ob.n_mode, ob.m_mode, ob.digit_for_m);
            }
            else searcher(files[i], ob.str, ob.n_mode, ob.m_mode, ob.digit_for_m);
        }
    }

    rl.close();
});
