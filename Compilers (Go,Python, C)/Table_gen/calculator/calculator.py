import predicrer
import arith_table
import arith_lexer


class ENode:
    def __init__(self, T, E1):
        self.T = T
        self.E1 = E1

    def eval(self):
        return self.T.eval() + self.E1.eval()


class TNode:
    def __init__(self, F, T1):
        self.F = F
        self.T1 = T1

    def eval(self):
        return self.F.eval() * self.T1.eval()


class FNode:
    def __init__(self, content):
        self.content = content

    def eval(self):
        if isinstance(self.content, ENode):
            return self.content.eval()
        else:
            return self.content


class E1Node:
    def __init__(self, T, E1):
        self.T = T
        self.E1 = E1

    def eval(self):
        if self.T is None:
            return 0
        else:
            return self.T.eval() + self.E1.eval()


class T1Node:
    def __init__(self, F, T1):
        self.F = F
        self.T1 = T1

    def eval(self):
        if self.F is None:
            return 1
        else:
            return self.T1.eval() * self.F.eval()


def expand_T(node):
    F = expand_F(node.children[0])
    T1 = expand_T1(node.children[1])
    return TNode(F, T1)


def expand_E1(node):
    if node.children[0].content == "epsilon":
        return E1Node(None, None)
    else:
        T = expand_T(node.children[1])
        E1 = expand_E1(node.children[2])
        return E1Node(T, E1)


def expand_T1(node):
    if node.children[0].content == "epsilon":
        return T1Node(None, None)
    else:
        F = expand_F(node.children[1])
        T1 = expand_T1(node.children[2])
        return T1Node(F, T1)


def expand_F(node):
    if len(node.children) == 1:
        return FNode(int(node.children[0].content))
    else:
        E = expand_E(node.children[1])
        return FNode(E)


def expand_E(root):
    T = expand_T(root.children[0])
    E1 = expand_E1(root.children[1])
    return ENode(T, E1)

if __name__ == "__main__":
    with open('input_arith.txt') as f:
        text = f.read()
    lexer = arith_lexer.ArithLexer(text + "$")
    try:
        iterator = lexer.tokenize()
        predicrer_arith = predicrer.Predicter(iterator, arith_table.terminals, arith_table.nonterminals, arith_table.table,arith_table.axiom)
        root = predicrer_arith.top_down_parse()
        E = expand_E(root)
        print(E.eval())

    except ValueError as v:
        print(v)
