def expand_axiom(node):
    return node.children[1].content


def expand_terms(node):
    if len(node.children) > 1:
        terms = [node.children[1].content]
        terms += expand_terms(node.children[2])
        return terms
    else:
        return []


def expand_tokens(node):
    terms = [node.children[1].content]
    terms += expand_terms(node.children[2])
    return terms


def expand_names(node):
    if node.children[0].content == "epsilon":
        return []
    else:
        names = [node.children[0].content]
        names += expand_names(node.children[1])
        return names


def expand_rule(node):
    n_term = node.children[0].content
    names = expand_names(node.children[2])
    return (n_term, names)


def expand_rules(node):
    if node.children[0].content == "epsilon":
        return []
    else:
        rules = [expand_rule(node.children[0])]
        rules += expand_rules(node.children[1])
        return rules


def expand_block(node, nterms_past):

    tokens = expand_tokens(node.children[0])
    assert len(tokens) == len(set(tokens))

    rules = [expand_rule(node.children[1])]
    rules += expand_rules(node.children[2])
    nterms = []

    for rule in rules:
        nterms.append(rule[0])

    for rule in rules:
        for name in rule[1]:
            assert (name in nterms or name in tokens or name in nterms_past)

    return tokens, nterms, rules


def expand_blocks(node, nterms_past):
    if node.children[0].content == "epsilon":
        return [], [], []
    else:
        tokens, nterms, rules = expand_block(node.children[0], nterms_past)
        nterms_past = nterms_past + nterms
        tokens1, nterms1, rules1 = expand_blocks(node.children[1], nterms_past)
        tokens += tokens1
        rules += rules1
        nterms += nterms1
        return tokens, nterms, rules


def expand_grammar(root):
    terminals, nonterminals, rules = expand_block(root.children[0], [])
    terminals1, nterms1, rules1 = expand_blocks(root.children[1], nonterminals)
    terminals += terminals1
    rules += rules1
    nonterminals += nterms1
    axiom = expand_axiom(root.children[2])
    terminals = set(terminals)
    nonterminals = set(nonterminals)

    assert len(terminals.intersection(nonterminals)) == 0

    # print(terminals, rules, axiom, nonterminals)
    return terminals, nonterminals, rules, axiom


def make_first(nonterminals, terminals, rules):
    first = {}
    for nterm in nonterminals:
        first[nterm] = set()
    changed = True
    while changed:
        changed = False
        for nonterm, right in rules:
            old_power = len(first[nonterm])
            if len(right) == 0:
                first[nonterm].add("")
            for elem in right:
                if elem in terminals:
                    first[nonterm].add(elem)
                    break
                else:
                    first[nonterm] = first[nonterm].union(first[elem])
                    if "" not in first[elem]:
                        break
            if old_power != len(first[nonterm]):
                changed = True
    return first


def first_of_seq(seq, terminals, first_table):
    first = set()
    if len(seq) == 0:
        first.add("")
    for i, elem in enumerate(seq):
        if elem in terminals:
            first.add(elem)
            break
        else:
            first = first.union(first_table[elem])
            if "" in first_table[elem]:
                if i != (len(seq) - 1):
                    first = first.difference({""})
            else:
                break
    return first


def make_follow(nonterminals, terminals, rules, axiom, first):
    follow = {}
    for nterm in nonterminals:
        follow[nterm] = set()
    changed = True
    follow[axiom].add("END")
    while changed:
        changed = False
        for nterm, right in rules:
            for i, elem in enumerate(right):
                if elem in nonterminals:
                    old_power = len(follow[elem])
                    for j in range(i + 1, len(right) + 1):
                        if j == len(right):
                            follow[elem] = follow[elem].union(follow[nterm])
                        else:
                            next_symbol = right[j]
                            if next_symbol in terminals:
                                follow[elem].add(next_symbol)
                                break
                            else:
                                follow[elem] = follow[elem].union(first[next_symbol]).difference({""})
                                if "" not in first[next_symbol]:
                                    break
                    if len(follow[elem]) != old_power:
                        changed = True
    return follow


def is_ll1(rules, first, follow, nonterminals, terminals):
    for nterm in nonterminals:
        n_rules = list(filter(lambda x: x[0] == nterm, rules))
        if len(n_rules) < 2:
            continue
        for i in range(len(n_rules) - 1):
            for j in range(i + 1, len(n_rules)):
                first_u = first_of_seq(n_rules[i][1], terminals, first)
                first_v = first_of_seq(n_rules[j][1], terminals, first)
                if len(first_u.intersection(first_v)) != 0:
                    return False
                if "" in first_u:
                    if len(first_v.intersection(follow[nterm])) != 0:
                        return False
                if "" in first_v:
                    if len(first_u.intersection(follow[nterm])) != 0:
                        return False
    return True


def make_table(terminals, nonterminals, rules, first, follow, axiom, filename):
    table = {}
    assert is_ll1(rules, first, follow, nonterminals, terminals)
    for nterm, right in rules:
        first_u = first_of_seq(right, terminals, first)
        for a in first_u:
            if a != "":
                table[(nterm, a)] = right
        if "" in first_u:
            for b in follow[nterm]:
                table[(nterm, b)] = right
    to_file(terminals, nonterminals, table, axiom, filename)


def to_file(terminals, nonterminals, table, axiom, filename):
    with open(filename, 'w') as f:
        f.write(f'terminals = {repr(terminals)}\n')
        f.write(f'nonterminals = {repr(nonterminals)}\n')
        f.write(f'table = {repr(table)}\n')
        f.write(f'axiom = {repr(axiom)}\n')





