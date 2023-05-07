package main

import (
	"fmt"
	"go/ast"
	"go/format"
	"go/parser"
	"go/token"
	"os"
)

func changeFunc(node ast.Node) bool {
	if funcType, ok := node.(*ast.FuncType); ok {
		params := funcType.Params.List
		new_params := make([]*ast.Field, 0)
		for _, field := range params {
			for _, name := range field.Names {
				newField := ast.Field{
					Doc:     field.Doc,
					Names:   make([]*ast.Ident, 0),
					Type:    field.Type,
					Tag:     field.Tag,
					Comment: field.Comment,
				}
				newField.Names = append(newField.Names, name)
				new_params = append(new_params, &newField)
			}
		}
		funcType.Params.List = new_params
	}

	return true
}

func inspect(file *ast.File) {
	ast.Inspect(file, changeFunc)
}

func main() {

	// Создаём хранилище данных об исходных файлах
	fset := token.NewFileSet()

	// Вызываем парсер
	if file, err := parser.ParseFile(
		fset,                 // данные об исходниках
		"main.go",            // имя файла с исходником программы
		nil,                  // пусть парсер сам загрузит исходник
		parser.ParseComments, // приказываем сохранять комментарии
	); err == nil {
		// Если парсер отработал без ошибок, печатаем дерево, затем  перестравиваем его
		ast.Fprint(os.Stdout, fset, file, nil)
		inspect(file)
		writer, err := os.OpenFile("main_rebuilded.go", os.O_CREATE|os.O_RDWR, 0777)
		defer writer.Close()
		if format.Node(writer, fset, file) != nil {
			fmt.Printf("Formatter error: %v\n", err)
		}

	} else {
		// в противном случае, выводим сообщение об ошибке
		fmt.Printf("Error: %v", err)
	}
}
