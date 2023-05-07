import enum
from abc import ABC
from copy import deepcopy



class Position:
    def __init__(self, program):
        self.__line = 1
        self.__pos = 1
        self.__index = 0
        self.__program = program

    def get_char(self):
        return self.__program[self.__index]

    def __str__(self):
        return f'({self.__line}, {self.__pos})'

    def is_new_line(self):
        if self.__index == '\r' and self.__index + 1 < len(self.__program):
            return self.__program[self.__index + 1] == '\n'
        return self.__program[self.__index] == '\n'

    def is_digit(self):
        return self.__program[self.__index].isdigit() or 'a' <= self.__program[self.__index].lower() <= 'f'

    def is_decimal_digit(self):
        return self.__program[self.__index].isdigit()

    def is_letter(self):
        return self.__program[self.__index].isalpha()

    def is_space(self):
        return self.__program[self.__index].isspace()

    def next(self):
        if self.__index != len(self.__program):
            if self.is_new_line():
                if self.__program[self.__index] == '\r':
                    self.__index += 1
                self.__line += 1
                self.__pos = 1
            else:
                self.__pos += 1
            self.__index += 1

    def raise_error(self):
        print("Не удалось распознать лексему: " + self.__str__())
        while not self.is_space() and not self.is_new_line():
            self.next()
            if self.is_new_line():
                self.next()
        self.skip_spaces()

    def skip_spaces(self):
        while self.is_space():
            self.next()


class Fragment:
    def __init__(self, start, follow):
        self.__start = start
        self.__follow = follow

    def __str__(self):
        return self.__start.__str__() + "-" + self.__follow.__str__()


class DomainTag(enum.Enum):
    IDENT = 0
    NUMBER = 1
    KEY = 2
    END_OF_PROGRAM = 3


class Token(ABC):

    def __init__(self, tag, start, follow):
        self.tag = tag
        self.coords = Fragment(start, follow)
        super().__init__()


class IdentToken(Token):
    def __init__(self, code, start, follow):
        super(IdentToken, self).__init__(DomainTag.IDENT, start, follow)
        self.code = code

    def __str__(self):
        return 'IDENT ' + self.coords.__str__() + ": " + str(self.code)


class NumberToken(Token):
    def __init__(self, value, start, follow):
        super(NumberToken, self).__init__(DomainTag.NUMBER, start, follow)
        self.value = value

    def __str__(self):
        return 'NUMBER ' + self.coords.__str__() + ": " + str(self.value)


class KeyToken(Token):
    def __init__(self, word, start, follow):
        super(KeyToken, self).__init__(DomainTag.NUMBER, start, follow)
        self.word = word

    def __str__(self):
        return 'KEY ' + self.coords.__str__() + ": " + self.word


class EndToken(Token):
    def __init__(self, start, follow):
        super(EndToken, self).__init__(DomainTag.END_OF_PROGRAM, start, follow)

    def __str__(self):
        return 'END ' + self.coords.__str__()


class Lexer:
    def __init__(self, input_text):
        self.__name_codes = {}
        input_text += " " + chr(0)
        self.pos = Position(list(input_text))

    def __add_name(self, name):
        if name in self.__name_codes:
            return self.__name_codes[name]
        else:
            code = len(self.__name_codes)
            self.__name_codes[name] = code
            return code

    def print_dict(self):
        print(self.__name_codes)

    def __get_number(self):
        number_string = ""
        start = deepcopy(self.pos)
        cur = self.pos
        while not self.pos.is_space():
            if not self.pos.is_digit():
                self.pos.raise_error()
                return False
            number_string += self.pos.get_char()
            cur = self.pos
            self.pos.next()
        value = int("0x" + number_string.lower().lstrip('0'), 16)
        return NumberToken(value, start, cur)

    def __get_ident(self):
        ident = ""
        start = deepcopy(self.pos)
        cur = self.pos
        while not self.pos.is_space():
            if not self.pos.is_letter() and not self.pos.is_digit():
                self.pos.raise_error()
                return False
            ident += self.pos.get_char()
            cur = self.pos
            self.pos.next()
        if ident == 'qeq' or ident == 'xx' or ident == 'xxx':
            return KeyToken(ident, start, cur)
        if ident[-1].isalpha():
            return IdentToken(self.__add_name(ident), start, cur)
        else:
            ident = ident.lower()
            for c in ident:
                if not (c.isdigit() or 'a' <= c <= 'f'):
                    self.pos.raise_error()
                    return False
            value = int("0x" + ident.lstrip('0'), 16)
            return NumberToken(value, start, cur)


    def next_token(self):
        self.pos.skip_spaces()
        if self.pos.get_char() == chr(0):
            return EndToken(self.pos, self.pos)
        if not (self.pos.is_digit() or self.pos.is_letter()):
            self.pos.raise_error()
            return self.next_token()
        if self.pos.is_decimal_digit():
            token = self.__get_number()
            if token:
                return token
            else:
                return self.next_token()
        else:
            token = self.__get_ident()
            if token:
                return token
            else:
                return self.next_token()


if __name__ == '__main__':
    with open('input.txt', 'r') as f:
        text = f.read()
    lexer = Lexer(text)
    token = None
    while type(token) != EndToken:
        token = lexer.next_token()
        print(token)
    lexer.print_dict()


