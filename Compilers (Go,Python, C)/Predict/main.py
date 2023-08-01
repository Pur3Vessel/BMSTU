# T = {NAME, DOT, COMMA, start, is, tokens, END}; N = {GRAMMAR, BLOCKS, BLOCK, TOKENS, TERMS, RULES, RULE, NAMES, AXIOM};
# S = GRAMMAR;

# GRAMMAR := BLOCK BLOCKS AXIOM
# BLOCKS := BLOCK BLOCKS | eps
# BLOCK := TOKENS RULE RULES
# TOKENS := tokens NAME TERMS
# TERMS := COMMA NAME TERMS | DOT
# RULES := RULE RULES | eps
# RULE := NAME is NAMES DOT
# NAMES := NAME NAMES | eps
# AXIOM := start NAME DOT

#               tokens                 NAME                    start      is      DOT         COMMA            END
# GRAMMAR    BLOCK BLOCKS AXIOM
# BLOCKS       BLOCK BLOCKS                                     eps
# BLOCK      TOKENS RULE RULES
# TOKENS     tokens NAME TERMS
# TERMS                                                                           dot       COMMA NAME TERMS
# RULES           eps                RULE RULES                 eps
# RULE                            NAME is NAMES DOT
# NAMES                              NAME NAMES                                   eps
# AXIOM                                                    start NAME DOT END

from lexer import Lexer, Token

GRAMMAR = "GRAMMAR"
BLOCKS = "BLOCKS"
BLOCK = "BLOCK"
TOKENS = "TOKENS"
TERMS = "TERMS"
RULES = "RULES"
RULE = "RULE"
NAMES = "NAMES"
AXIOM = "AXIOM"

tokens = "tokens"
start = "START"
is_t = "IS"
DOT = "DOT"
COMMA = "COMMA"
NAME = "NAME"
END = "END"


class TreeNode:
    num = 0

    def __init__(self, content):
        TreeNode.num += 1
        self.num = TreeNode.num
        self.content = content
        self.children = []

    def replace_name(self, name):
        for child in self.children:
            if child.content == "NAME":
                child.content = name
                break

    def add_child(self, child):
        self.children.append(child)

    def __repr__(self):
        return str(self.content)

    def print_graph(self, f):
        f.write(f'{self.num} [label = "{str(self.content)}"]\n')
        for child in self.children:
            f.write(f'{self.num} -> {child.num}\n')
        for child in self.children:
            child.print_graph(f)


class Predicter:
    def __init__(self, token_iterator):
        self.magazine = []
        self.terminals = [tokens, start, is_t, DOT, COMMA, NAME]
        self.nonterminals = [GRAMMAR, BLOCK, BLOCKS, TOKENS, TERMS, RULES, RULE, NAMES, AXIOM]
        self.tokens = token_iterator
        self.table = {
            (GRAMMAR, tokens): [BLOCK, BLOCKS, AXIOM],
            (BLOCKS, tokens): [BLOCK, BLOCKS],
            (BLOCK, tokens): [TOKENS, RULE, RULES],
            (TOKENS, tokens): [tokens, NAME, TERMS],
            (RULES, tokens): [],
            (RULES, NAME): [RULE, RULES],
            (RULE, NAME): [NAME, is_t, NAMES, DOT],
            (NAMES, NAME): [NAME, NAMES],
            (BLOCKS, start): [],
            (RULES, start): [],
            (AXIOM, start): [start, NAME, DOT, END],
            (TERMS, DOT): [DOT],
            (NAMES, DOT): [],
            (TERMS, COMMA): [COMMA, NAME, TERMS]
        }

    def top_down_parse(self):
        self.magazine.append(TreeNode(END))
        root = TreeNode(GRAMMAR)
        self.magazine.append(root)
        a = next(self.tokens)
        result = []
        cur_x = None
        while True:
            x = self.magazine[-1]
            if x.content == END:
                break
            if x.content in self.terminals:
                if x.content == a.token_type:
                    if a.token_type == "NAME":
                        cur_x.replace_name(a.value)
                    self.magazine.pop()
                    a = next(self.tokens)
                else:
                    raise ValueError(f"Проблема с токеном {a.token_type}: {a.token_value}")
            elif (x.content, a.token_type) in self.table:
                self.magazine.pop()
                new_nodes = []
                for i in range(len(self.table[(x.content, a.token_type)])):
                    new_nodes.append(TreeNode(self.table[(x.content, a.token_type)][i]))
                if len(new_nodes) == 0:
                    x.add_child(TreeNode("epsilon"))
                for y in new_nodes:
                    cur_x = x
                    x.add_child(y)
                for y in new_nodes[::-1]:
                    self.magazine.append(y)
                result.append((x.content, self.table[(x.content, a.token_type)]))
            else:
                raise ValueError(f"Проблема с токеном {a.token_type}: {a.token_value}")
        return root


if __name__ == "__main__":
    with open('test1.txt', 'r') as f:
        text = f.read()
    lexer = Lexer(text + "$")
    try:
        iterator = lexer.tokenize()
        # for token in iterator:
        #    print(token)
        predicter = Predicter(iterator)
        root = predicter.top_down_parse()
        with open('graph.dot', 'w') as f:
            f.write('digraph {\n')
            root.print_graph(f)
            f.write('}')
        # for r in result:
        # print(r)
    except ValueError as v:
        print(v)
