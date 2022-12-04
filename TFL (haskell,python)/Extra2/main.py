import os
from parser import Parser

if __name__ == "__main__":
    filepath = os.path.join('tests', 'test2.txt')
    input_file = open(filepath, 'r')
    test = ""
    for line in input_file.readlines():
        test += line
    input_file.close()

    gram = Parser(test).parse_rules().remove_nongenerating_rules().remove_unreachable_symbols()
    gram.make_first()
    gram.make_follow()
    gram.print_first()
    gram.print_follow()