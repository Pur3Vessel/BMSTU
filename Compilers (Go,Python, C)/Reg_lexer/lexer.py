import re


class Token:
    def __init__(self, token_type, value, line, position):
        self.token_type = token_type
        self.value = value
        self.line = line
        self.position = position


class Lexer:
    def __init__(self, text):
        self.text = text
        self.line = 1
        self.position = 1
        self.tokens = []
        self.rules = [
            ('STRING', r"'(?:[^']|'')*'"),
            ('NUMBER', r'-?\d+(\.\d+)?'),
            ('IDENTIFIER', r'[a-zA-Z][\w\.]*'),
            ('space', r"\s+")
        ]

    def tokenize(self):
        lines = self.text.splitlines()
        for line_num, line in enumerate(lines):
            self.position = 1
            self.line = line_num + 1
            while self.position < len(line) + 1:
                for rule in self.rules:
                    match = re.match(rule[1], line[self.position - 1:])
                    if match:
                        if rule[0] != 'space':
                            value = match.group()
                            self.tokens.append(Token(rule[0], value, self.line, self.position))
                        self.position += match.end()
                        break
                else:
                    print(f'syntax error ({self.line}, {self.position})\n')
                    is_match = False
                    while not is_match:
                        self.position += 1
                        if self.position == len(line) + 1:
                            break
                        for rule in self.rules:
                            match = re.match(rule[1], line[self.position - 1:])
                            if match:
                                is_match = True

        return iter(self.tokens)


if __name__ == "__main__":
    with open('input.txt', 'r') as f:
        text = f.read()
    lexer = Lexer(text)
    for token in lexer.tokenize():
        print(token.token_type, token.value, token.line, token.position)
