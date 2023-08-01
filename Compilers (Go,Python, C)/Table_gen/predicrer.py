class TreeNode:
    num = 0

    def __init__(self, content):
        TreeNode.num += 1
        self.num = TreeNode.num
        self.content = content
        self.children = []

    def replace_name(self, name):
        for child in self.children:
            if child.content == "NAME" or child.content == "<n>" or child.content == '<name>':
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
    def __init__(self, token_iterator, terminals, nonterminals, table, axiom):
        self.magazine = []
        self.terminals = terminals
        self.nonterminals = nonterminals
        self.tokens = token_iterator
        self.table = table
        self.axiom = axiom
        self.end = 'END'
        #print(self.terminals, self.nonterminals, self.axiom, self.end)
        #print(self.table)

    def top_down_parse(self):
        self.magazine.append(TreeNode(self.end))
        root = TreeNode(self.axiom)
        self.magazine.append(root)
        a = next(self.tokens)

        cur_x = None
        while True:
            x = self.magazine[-1]
            if x.content == self.end:
                break
            if x.content in self.terminals:
                if x.content == a.token_type:
                    if x.content == self.end:
                        break
                    if a.token_type == "NAME" or a.token_type == "<n>" or a.token_type == "<name>":
                        cur_x.replace_name(a.value)
                    self.magazine.pop()
                    a = next(self.tokens)
                else:
                    raise ValueError(f"Проблема с токеном {a.token_type} {a.value}: ({a.line}, {a.position})")
            elif (x.content, a.token_type) in self.table:
                self.magazine.pop()
                new_nodes = []
                for i in range(len(self.table[(x.content, a.token_type)])):
                    new_nodes.append(TreeNode(self.table[(x.content, a.token_type)][i]))
                if len(new_nodes) == 0:
                    x.add_child(TreeNode("epsilon"))
                for y in new_nodes:
                    x.add_child(y)
                cur_x = x
                for y in new_nodes[::-1]:
                    self.magazine.append(y)
            else:
                raise ValueError(f"Проблема с токеном {a.token_type} {a.value}: ({a.line}, {a.position})")
        return root
