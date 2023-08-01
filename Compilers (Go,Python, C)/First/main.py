from lexer import Lexer
from parser import Parser
from nodes import *


def first_of_seq(seq, first):
    out = set()
    for elem in seq:
        if isinstance(elem, TermNode):
            out.add(elem.content)
            break
        if isinstance(elem, EmptyNode):
            break
        if isinstance(elem, NTermNode):
            out = out.union(first[elem.content])
            if "" not in first[elem.content]:
                break
        if isinstance(elem, RepeatNode):
            out = out.union(first_of_seq(elem.contents, first))
        if isinstance(elem, AltNode):
            skip = False
            for alt in elem.contents:
                if isinstance(alt, EmptyNode):
                    out.add("")
                    skip = True
                else:
                    seq = first_of_seq(alt, first)
                    if "" in seq:
                        skip = True
                    out = out.union(seq)
            if not skip:
                break

    return out

def compute_first(nterms, rules):
    first = {}
    for nterm in nterms:
        first[nterm] = set()

    updated = True
    while updated:
        updated = False
        for nterm, right in rules:
            old_power = len(first[nterm])
            for elem in right:
                if isinstance(elem, TermNode):
                    first[nterm].add(elem.content)
                    break
                if isinstance(elem, NTermNode):
                    first[nterm] = first[nterm].union(first[elem.content])
                    if "" not in first[elem.content]:
                        break
                if isinstance(elem, RepeatNode):
                    first[nterm] = first[nterm].union(first_of_seq(elem.contents, first))
                if type(elem) == EmptyNode:
                    first[nterm].add("")
                if isinstance(elem, AltNode):
                    skip = False
                    for alt in elem.contents:
                        if isinstance(alt, EmptyNode):
                            first[nterm].add("")
                            skip = True
                        else:
                            seq = first_of_seq(alt, first)
                            if "" in seq:
                                skip = True
                            first[nterm] = first[nterm].union(seq)
                    if not skip:
                        break
            if old_power != len(first[nterm]):
                updated = True

    return first


if __name__ == "__main__":
    with open('test.txt', 'r') as f:
        text = f.read()
    lexer = Lexer(text + "$")
    try:
        iterator = lexer.tokenize()
        parser = Parser(iterator)
        terms, nterms, rules = parser.parse()
        # print(terms)
        # print(nterms)
        # for rule in rules:
        # print(f"{rule[0]} -> {list(map(str, rule[1]))}")
        # for token in iterator:
        # print(token)
        first = compute_first(nterms, rules)
        print(first)
    except ValueError as v:
        print(v)
