# Проверяется принадлежность к языку, порождаемому следующей регуляркой: (b*ab*ab*)*
# Используется генератор ANTLR4
# ANTLR4 осуществляет нисходящий синтаксический анализ, соответственно грамматика должна быть LL(k)
# Грамматика должна подаваться в файле с расширением .g4 в виде РБНФ (на самом деле не совсем она, но очень схоже)
# Нетерминалы, которые переписываются в нетерминалы должны записываться со строчной буквы (parser rules)
# Нетерминалы, которые переписываются только в терминалы должны записываться с заглавной буквы (lexer rules)
# Команда, чтобы сгенерировать код на python - antlr4 -Dlanguage=Python3 Reg.g4. Помимо питона поддерживаются также C++, Java, C#, Go, Swift, Js
from RegParser import RegParser
from RegLexer import RegLexer
from antlr4 import *


# Добавил буквально пару строчек в RegParser.py, чтобы при строке, не принадежащей языку, порождалось исключение
if __name__ == "__main__":
    inputStream = InputStream("aaaabbaaaabaa")
    lexer = RegLexer(inputStream)
    stream = CommonTokenStream(lexer)
    parser = RegParser(stream)
    try:
        parser.s()
        print('Готово')
    except RecognitionException as e:
        pass