'use strict'
//работа с построением аргументов такая же как и в grep
const fs = require('fs');
const readline = require('readline');
function arguments_maker(args, ob) {                        
    for (let i = 0; i < args.length; i++) {
        if (args[i] == "-m") ob.m_mode = true;
        if (args[i] == "-l") ob.l_mode = true;
        if (args[i] == "-c") ob.c_mode = true;
        if (args[i] == "-w") ob.w_mode = true;
        if (args[i] != "-m" && args[i] != "-l" && args[i] != "-w" && args[i] != "-c") ob.file_name = args[i];
    }
    return ob;
}
function counter (file_name, c_mode, m_mode, l_mode, w_mode) {
    let w_file = fs.readFileSync(file_name).toString();
    let stats = fs.statSync(file_name);
    let size = stats['size'];          
    let sym_count = w_file.length;
    let w_file_strings = w_file.split('\n');
    let strings_count = w_file_strings.length;
    strings_count--;
    let w_file_words = w_file.split(/ |\n/);
    let words_count =  0;
    for (let i = 0; i < w_file_words.length; i++) {
        if (w_file_words[i] != '') words_count++;
    }
    if (!(c_mode || m_mode || l_mode || w_mode)) console.log(`${strings_count} ${words_count} ${size} ${file_name}`);
    else {
        let out = '';
        if (l_mode) out += strings_count + ' ';
        if (w_mode) out += words_count + ' ';
        if (m_mode) out += sym_count + ' ';
        if (c_mode) out += size + ' ';
        out += file_name;
        console.log(out);
    }
} 
const rl = readline.createInterface ( {
    input: process.stdin,
    output: process.stdout
})
rl.question('Обработка стадартного ввода (приоритетная обработка: командная строка): ', (input) => {
    var ob = {
        c_mode: false,
        m_mode: false,
        w_mode: false,
        l_mode: false,
        file_name:  ""
    };
    var args = [];
    if (process.argv.length > 2) {
        for (let i = 2; i < process.argv.length; i++) args.push(process.argv[i]);
    }
    else {
         var input_array = input.split(' ');
         for (let i = 0; i < input_array.length; i++){
             if (input_array[i] != '') args.push(input_array[i]); 
         }
    }
    ob = arguments_maker(args, ob);
    counter(ob.file_name, ob.c_mode, ob.m_mode, ob.l_mode, ob.w_mode);
    rl.close();
});
