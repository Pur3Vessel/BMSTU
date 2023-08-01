class TermNode:
    def __init__(self, content):
        self.content = content

    def __str__(self):
        return "Term " + self.content


class NTermNode:
    def __init__(self, content):
        self.content = content

    def __str__(self):
        return "NTerm " + self.content


class RepeatNode:
    def __init__(self, contents):
        self.contents = contents

    def __str__(self):
        return f"Repeat {self.contents}"


class AltNode:
    def __init__(self, contents):
        self.contents = contents

    def __str__(self):
        return f"Alt {self.contents}"


class EmptyNode:
    def __init__(self):
        self.content = ""

    def __str__(self):
        return "Empty"
