import parser_edsl as pe
from abc import ABC
from dataclasses import dataclass


ENTRY = pe.NonTerminal("ENTRY")
PROGRAM = pe.NonTerminal("PROGRAM")
FUNCTION = pe.NonTerminal("FUNCTION")
ARGS = pe.NonTerminal("ARGS")
ARG = pe.NonTerminal("ARG")
ARGS1 = pe.NonTerminal("ARGS1")
TYPE = pe.NonTerminal("TYPE")
TUPLE = pe.NonTerminal("TUPLE")
TUPLE1 = pe.NonTerminal("TUPLE1")
EXPR = pe.NonTerminal("EXPR")
BOOL_EXPR = pe.NonTerminal("BOOL_EXPR")
BOOL_EXPR1 = pe.NonTerminal("BOOL_EXPR1")
BOOL_EXPR2 = pe.NonTerminal("BOOL_EXPR2")
BOOL_CONST = pe.NonTerminal("BOOL_CONST")
SIMP_EXPR = pe.NonTerminal("SIMP_EXPR")
LIST_EXPR = pe.NonTerminal("LIST_EXPR")
IN_LIST = pe.NonTerminal("IN_LIST")
IN_LIST1 = pe.NonTerminal("IN_LIST1")
TUPLE_EXPR = pe.NonTerminal("TUPLE_EXPR")
TUPLE_EXPR1 = pe.NonTerminal("TUPLE_EXPR1")
ARITH_EXPR = pe.NonTerminal("ARITH_EXPR")
MULT_EXPR = pe.NonTerminal("MULT_EXPR")
ELEM = pe.NonTerminal("ELEM")
FUNC_CALL = pe.NonTerminal("FUNC_CALL")
OR_OP = pe.NonTerminal("OR_OP")
AND_OP = pe.NonTerminal("AND_OP")
ADD_OP = pe.NonTerminal("ADD_OP")
MUL_OP = pe.NonTerminal("MUL_OP")
IDENT = pe.Terminal("IDENT", r'[A-Za-z][A-Za-z0-9_]*', str)
NUMBER = pe.Terminal("NUMBER", r'[0-9]+', int, priority=7)


class SemanticError(pe.Error):
    def __init__(self, pos, message):
        self.pos = pos
        self.__message = message

    @property
    def message(self):
        return self.__message


class Type(ABC):
    def __eq__(self, o):
        pass


@dataclass
class IntType(Type):
    def __eq__(self, o):
        return type(self) == type(o) or type(o) == type(AnyType())

    def __hash__(self):
        return 1


@dataclass
class AnyType(Type):
    def __eq__(self, o):
        return True

    def __hash__(self):
        return 2


@dataclass
class BoolType(Type):
    def __eq__(self, o):
        return type(self) == type(o) or type(o) == type(AnyType())

    def __hash__(self):
        return 3


@dataclass
class ListType(Type):
    contains: Type

    def __eq__(self, o):
        return type(self) == type(o) and self.contains == o.contains or type(o) == type(AnyType())

    def __hash__(self):
        return 4


@dataclass
class TupleType(Type):
    elems: [Type]

    def __eq__(self, o):
        return type(self) == type(o) and all(map(lambda t: t[0] == t[1], zip(self.elems, o.elems))) or type(o) == type(
            AnyType())

    def __hash__(self):
        return 5


@dataclass
class Arg:
    name: str
    type: Type


class Expr(ABC):
    type: Type

    def check(self, defined_funcs, named_args):
        pass


@dataclass()
class IfExpr(Expr):
    condition: Expr
    then_block: Expr
    else_block: Expr
    pos: pe.Fragment

    @pe.ExAction
    def create(attrs, coords, res_coord):
        cond, block1, block2 = attrs
        return IfExpr(cond, block1, block2, res_coord)

    def check(self, defined_funcs, named_args):
        self.condition.check(defined_funcs, named_args)
        self.then_block.check(defined_funcs, named_args)
        self.else_block.check(defined_funcs, named_args)

        if self.condition.type != BoolType():
            raise SemanticError(self.pos, f'ожидалось bool, получено {self.condition.type} : {self.condition}')

        if self.then_block.type != self.else_block.type:
            raise SemanticError(self.pos,
                                f'типы блоков then и else должны совпадать: {self.then_block.type} {self.else_block.type}')

        self.type = self.then_block.type


@dataclass
class IdentUse(Expr):
    ident_name: str
    pos: pe.Fragment

    @pe.ExAction
    def create(attrs, coords, res_coord):
        ident_name = attrs[0]
        # cleft, cop, cright = coords
        return IdentUse(ident_name, coords)

    def check(self, defined_funcs, named_args):
        if self.ident_name not in named_args:
            raise SemanticError(self.pos, f'не найден именованный параметр: {self.ident_name}')

        self.type = named_args[self.ident_name]


@dataclass
class FuncCall(Expr):
    function_name: str
    func_args: [Expr]
    pos: pe.Fragment

    @pe.ExAction
    def create(attrs, coords, res_coord):
        funcname, args = attrs
        return FuncCall(funcname, args, res_coord)

    def check(self, defined_funcs, named_args):
        for a in self.func_args:
            a.check(defined_funcs, named_args)

        if self.function_name == 'car':
            if len(self.func_args) != 1:
                raise SemanticError(self.pos, f'ожидалcя 1 аргумент, получено {len(self.func_args)}: {self.func_args}')
            if self.func_args[0].type != ListType(AnyType()):
                raise SemanticError(self.pos,
                                    f'в функции {self.function_name} аргумент {1}: ожидался {ListType(AnyType())}, получен {self.func_args[0].type}: {self.func_args[0]}')
            self.type = self.func_args[0].type.contains
            return

        if self.function_name == 'cdr':
            if len(self.func_args) != 1:
                raise SemanticError(self.pos, f'ожидался 1 аргумент, получено {len(self.func_args)}: {self.func_args}')
            if self.func_args[0].type != ListType(AnyType()):
                raise SemanticError(self.pos,
                                    f'в функции {self.function_name} аргумент {1}: ожидался {ListType(AnyType())}, получено {self.func_args[0].type}: {self.func_args[0]}')
            self.type = self.func_args[0].type
            return

        if self.function_name == 'cons':
            if len(self.func_args) != 2:
                raise SemanticError(self.pos,
                                    f'ожидалость 2 аргумента, получено {len(self.func_args)}: {self.func_args}')
            t1 = self.func_args[0].type
            if self.func_args[1].type != ListType(t1):
                raise SemanticError(self.pos,
                                    f'в функции {self.function_name} аргумент {2}: ожидался {ListType(t1)}, получен {self.func_args[1].type}: {self.func_args[1]}')
            self.type = self.func_args[1].type
            return

        if self.function_name == 'null':
            if len(self.func_args) != 1:
                raise SemanticError(self.pos, f'ожидался 1 аргумент, получено {len(self.func_args)}: {self.func_args}')
            if self.func_args[0].type != ListType(AnyType()):
                raise SemanticError(self.pos,
                                    f'в функции {self.function_name} аргумент {1}: ожидался {ListType(AnyType())}, получен {self.func_args[0].type}: {self.func_args[0]}')
            self.type = BoolType()
            return

        if self.function_name not in defined_funcs:
            raise SemanticError(self.pos, f'функция {self.function_name} нигде не определена')

        func = defined_funcs[self.function_name]
        self.type = func.return_type

        if len(self.func_args) != len(func.args):
            raise SemanticError(self.pos,
                                f'ожидалость {len(func.args)} аргументов, получено {len(self.func_args)}: {self.func_args}')

        for i in range(len(self.func_args)):
            if self.func_args[i].type != func.args[i].type:
                raise SemanticError(self.pos,
                                    f'в функции {self.function_name} аргумент {i + 1}: ожидался {func.args[i].type}, получен {self.func_args[i].type}: {self.func_args[i]}')


@dataclass
class IntConst(Expr):
    value: int
    type = IntType()


@dataclass
class BoolConst(Expr):
    value: bool
    type = BoolType()


@dataclass
class BinOp(Expr):
    left: Expr
    op: str
    right: Expr
    pos: pe.Fragment

    @pe.ExAction
    def create(attrs, coords, res_coord):
        left, op, right = attrs
        return BinOp(left, op, right, res_coord)

    def check(self, defined_funcs, named_args):
        self.left.check(defined_funcs, named_args)
        self.right.check(defined_funcs, named_args)

        self.type = self.left.type

        if self.op in ['+', '-', '/', '*'] and self.left.type != IntType():
            raise SemanticError(self.pos,
                                f'тип левого операнда операции {self.op} должет быть {IntType()}, получен {self.left.type} : {self.left}')
        if self.op in ['+', '-', '/', '*'] and self.right.type != IntType():
            raise SemanticError(self.pos,
                                f'тип правого операнда операции {self.op} должет быть {IntType()}, получен {self.right.type} : {self.right}')

        if self.op in ['and', 'or'] and self.left.type != BoolType():
            raise SemanticError(self.pos,
                                f'тип левого операнда операции {self.op} должет быть {BoolType()}, получен {self.left.type} : {self.left}')
        if self.op in ['and', 'or'] and self.right.type != BoolType():
            raise SemanticError(self.pos,
                                f'тип правого операнда операции {self.op} должет быть {BoolType()}, получен {self.right.type} : {self.right}')

        if self.left.type != self.right.type:
            raise SemanticError(self.pos,
                                f'типы операндов операции {self.op} должны совпадать: {self.left.type} {self.right.type}')


@dataclass
class ListExpr(Expr):
    elems: [Expr]
    pos: pe.Fragment

    @pe.ExAction
    def create(attrs, coords, res_coord):
        elems = attrs[0]
        return ListExpr(elems, res_coord)

    def check(self, defined_funcs, named_args):
        for x in self.elems:
            x.check(defined_funcs, named_args)

        if len(self.elems) == 0:
            self.type = ListType(AnyType())
        elif len(set(map(lambda x: x.type, self.elems))) >= 2:
            raise SemanticError(self.pos, f'элементы списка должны быть одного типа: {self}')
        else:
            self.type = ListType(self.elems[0].type)


@dataclass
class TupleExpr(Expr):
    elems: [Expr]

    def check(self, defined_funcs, named_args):
        for x in self.elems:
            x.check(defined_funcs, named_args)

        self.type = TupleType([x.type for x in self.elems])


@dataclass
class FuncDef:
    name: str
    args: [Arg]
    return_type: Type
    body: Expr
    pos: pe.Fragment

    @pe.ExAction
    def create(attrs, coords, res_coord):
        name, args, ret, body = attrs
        return FuncDef(name, args, ret, body, res_coord)

    def check(self, defined_funcs):
        if len(self.args) != len(set(map(lambda x: x.name, self.args))):
            raise SemanticError(self.pos, f'у функции {self.name} найдены одноименные параметры')

        named_args = dict([(arg.name, arg.type) for arg in self.args])
        self.body.check(defined_funcs, named_args)


@dataclass
class Entry:
    funcDefs: [FuncDef]

    def check(self):
        defined_funcs = {'car': None, 'cdr': None, 'cons': None, 'null': None}
        for func in self.funcDefs:
            if func.name in defined_funcs:
                raise SemanticError(func.pos, f'нельзя повторно определять {func.name}')
            defined_funcs[func.name] = func

        for func in self.funcDefs:
            func.check(defined_funcs)


ENTRY |= PROGRAM, Entry
PROGRAM |= FUNCTION, PROGRAM, lambda x, y: [x] + y
PROGRAM |= lambda: []
FUNCTION |= IDENT, '(', ARGS, ')', ':', TYPE, '=', EXPR, ';', FuncDef.create
ARGS |= ARG, ARGS1, lambda x, y: [x] + y
ARGS |= lambda: []
ARGS1 |= ',', ARG, ARGS1, lambda x, y: [x] + y
ARGS1 |= lambda: []
ARG |= IDENT, ":", TYPE, Arg
TYPE |= 'int', IntType
TYPE |= 'bool', BoolType
TYPE |= "[", TYPE, "]", ListType
TYPE |= TUPLE
TUPLE |= "(", TYPE, ",", TYPE, TUPLE1, ")", lambda x, y, z: TupleType([x, y] + z)
TUPLE1 |= ",", TYPE, TUPLE1, lambda x, y: [x] + y
TUPLE1 |= lambda: []
EXPR |= "if", BOOL_EXPR, "then", EXPR, "else", EXPR, IfExpr.create
EXPR |= SIMP_EXPR
EXPR |= BOOL_CONST
BOOL_EXPR |= BOOL_EXPR, OR_OP, BOOL_EXPR1, BinOp.create
OR_OP |= 'or', lambda: 'or'
BOOL_EXPR |= BOOL_EXPR1
BOOL_EXPR1 |= BOOL_EXPR1, AND_OP, BOOL_EXPR2, BinOp.create
AND_OP |= 'and', lambda: "and"
BOOL_EXPR1 |= BOOL_EXPR2
BOOL_EXPR2 |= IDENT, IdentUse.create
BOOL_EXPR2 |= FUNC_CALL
BOOL_EXPR2 |= '(', BOOL_EXPR, ')'
BOOL_EXPR2 |= BOOL_CONST
BOOL_CONST |= 'true', lambda x: BoolConst(True)
BOOL_CONST |= 'false', lambda x: BoolConst(False)
SIMP_EXPR |= LIST_EXPR
SIMP_EXPR |= TUPLE_EXPR
SIMP_EXPR |= ARITH_EXPR
IN_LIST |= EXPR, IN_LIST1, lambda x, y: [x] + y
IN_LIST |= lambda: []
IN_LIST1 |= ",", EXPR, IN_LIST1, lambda x, y: [x] + y
IN_LIST1 |= lambda: []
TUPLE_EXPR |= "(", EXPR, ",", EXPR, TUPLE_EXPR1, ")", lambda x, y, z: TupleExpr([x, y] + z)
TUPLE_EXPR1 |= ",", EXPR, TUPLE_EXPR1, lambda x, y: [x] + y
TUPLE_EXPR1 |= lambda: []
FUNC_CALL |= IDENT, "(", IN_LIST, ")", FuncCall.create
ELEM |= NUMBER, IntConst
ELEM |= IDENT, IdentUse.create
ELEM |= FUNC_CALL
ARITH_EXPR |= ARITH_EXPR, ADD_OP, MULT_EXPR, BinOp.create
ADD_OP |= '+', lambda: '+'
ADD_OP |= '-', lambda: '-'
MUL_OP |= '*', lambda: '*'
MUL_OP |= '/', lambda: "/"
ARITH_EXPR |= MULT_EXPR
MULT_EXPR |= MULT_EXPR, MUL_OP, ELEM, BinOp.create
MULT_EXPR |= ELEM
LIST_EXPR |= '[', IN_LIST, ']', ListExpr.create

if __name__ == "__main__":
    for i in range(1, 11):
        p = pe.Parser(ENTRY)
        assert p.is_lalr_one()
        p.add_skipped_domain('\\s')
        p.add_skipped_domain('--[^\n]*\n')
        try:
            with open("test" + str(i) + ".txt") as f:
                tree = p.parse(f.read())
                tree.check()
                print("RIGHT")
        except pe.Error as e:
            print(f'Ошибка {e.pos}: {e.message}')
        except Exception as e:
            print(type(e))
            print(e)
