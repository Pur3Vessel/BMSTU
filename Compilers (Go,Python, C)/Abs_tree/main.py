import parser_edsl as pe
from abc import ABC
import typing
from dataclasses import dataclass
from pprint import pprint

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
IDENT = pe.Terminal("IDENT", r'[A-Za-z][A-Za-z0-9_]*', str)
NUMBER = pe.Terminal("NUMBER", r'[0-9]+', int, priority=7)

class Type(ABC):
    pass

@dataclass
class IntType(Type):
    def __repr__(self):
        return 'int'

@dataclass
class BoolType(Type):
    def __repr__(self):
        return 'bool'

@dataclass
class ListType(Type):
    type: Type

@dataclass
class TupleType(Type):
    types: [Type]

@dataclass
class Arg:
    name: str
    type: Type
class Expr(ABC):
    pass

@dataclass()
class IfExpr(Expr):
    condition: Expr
    then_block: Expr
    else_block: Expr

@dataclass
class IdentUse(Expr):
    ident_name: str

@dataclass
class FuncCall(Expr):
    function_name: str
    func_args: [Expr]

@dataclass
class IntConst(Expr):
    value: int

@dataclass
class BoolConst(Expr):
    value: bool

@dataclass
class BinOp(Expr):
    left: Expr
    op: str
    right: Expr

@dataclass
class ListExpr(Expr):
    elems: [Expr]

@dataclass
class TupleExpr(Expr):
    elems: [Expr]

@dataclass
class FuncDef:
    name: str
    args: [Arg]
    return_type: Type
    body: Expr





PROGRAM |= FUNCTION, PROGRAM, lambda x, y: [x] + y
PROGRAM |= lambda: []
FUNCTION |= IDENT, '(', ARGS, ')', ':', TYPE, '=', EXPR, ';', FuncDef
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
EXPR |= "if", BOOL_EXPR, "then", EXPR, "else", EXPR, IfExpr
EXPR |= SIMP_EXPR
EXPR |= BOOL_CONST
BOOL_EXPR |= BOOL_EXPR, 'or', BOOL_EXPR1, lambda x, y: BinOp(x, 'or', y)
BOOL_EXPR |= BOOL_EXPR1
BOOL_EXPR1 |= BOOL_EXPR1, 'and', BOOL_EXPR2, lambda x, y: BinOp(x, 'and', y)
BOOL_EXPR1 |= BOOL_EXPR2
BOOL_EXPR2 |= IDENT, IdentUse
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
TUPLE_EXPR |= "(", EXPR, ",", EXPR, TUPLE_EXPR1, ")", lambda x, y, z:  TupleExpr([x, y] + z)
TUPLE_EXPR1 |= ",", EXPR, TUPLE_EXPR1, lambda x, y: [x] + y
TUPLE_EXPR1 |= lambda: []
FUNC_CALL |= IDENT, "(", IN_LIST, ")", FuncCall
ELEM |= NUMBER, IntConst
ELEM |= IDENT, IdentUse
ELEM |= FUNC_CALL
ARITH_EXPR |= ARITH_EXPR, "+", MULT_EXPR, lambda x, y: BinOp(x, '+', y)
ARITH_EXPR |= ARITH_EXPR, "-", MULT_EXPR, lambda x, y: BinOp(x, '-', y)
ARITH_EXPR |= MULT_EXPR
MULT_EXPR |= MULT_EXPR, "*", ELEM, lambda x, y: BinOp(x, '*', y)
MULT_EXPR |= MULT_EXPR, "/", ELEM, lambda x, y: BinOp(x, '/', y)
MULT_EXPR |= ELEM
LIST_EXPR |= '[', IN_LIST, ']', ListExpr

if __name__ == "__main__":
    p = pe.Parser(PROGRAM)
    assert p.is_lalr_one()
    p.add_skipped_domain('\\s')
    p.add_skipped_domain('--[^\n]*\n')
    try:
        with open("test.txt") as f:
            tree = p.parse(f.read())
            pprint(tree)
    except pe.Error as e:
        print(f'Ошибка {e.pos}: {e.message}')
    except Exception as e:
        print(e)