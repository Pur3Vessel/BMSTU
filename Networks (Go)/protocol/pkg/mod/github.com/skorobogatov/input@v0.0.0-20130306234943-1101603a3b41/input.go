
package input

// #include <stdlib.h>
// #include "input.h"
//
// #cgo CFLAGS: -O3 -Wno-error=format-security -Wno-format-nonliteral -Wno-format-extra-args -Wno-format-security
//
import "C"

import "unsafe"

func Scanf(format string, a ...interface{}) (n int) {
	var buf []byte
	i, arg := 0, 0
	for {
		for ; i < len(format) && format[i] != '%'; i++ {
			buf = append(buf, format[i])
		}

		if i == len(format) {
			if len(buf) > 0 {
				fmt := C.CString(string(buf))
				n += int(C.scanverbatim(fmt))
				C.free(unsafe.Pointer(fmt))
			}
			break
		}

		buf = append(buf, '%')
		if i++; i == len(format) {
			panic("input.Scanf: format string ends with '%'")
		} else if format[i] == '%' {
			buf = append(buf, '%')
		} else {
			spec := format[i]
			if arg == len(a) {
				panic("input.Scanf: the number of format specifiers exeeds the number of arguments")
			}

			if a[arg] == nil {
				panic("input.Scanf: nil pointer passed as argument")
			}

			if spec == 'd' {
				switch p := a[arg].(type) {
				case *uint: {
					buf = append(buf, ([]byte)("llu")...)
					fmt := C.CString(string(buf))
					var res C.ulonglong
					n += int(C.scanuint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = uint(res)
				}
				case *uint8: {
					buf = append(buf, 'l', 'l' ,'u')
					fmt := C.CString(string(buf))
					var res C.ulonglong
					n += int(C.scanuint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = uint8(res)
				}
				case *uint16: {
					buf = append(buf, 'l', 'l' ,'u')
					fmt := C.CString(string(buf))
					var res C.ulonglong
					n += int(C.scanuint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = uint16(res)
				}
				case *uint32: {
					buf = append(buf, 'l', 'l' ,'u')
					fmt := C.CString(string(buf))
					var res C.ulonglong
					n += int(C.scanuint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = uint32(res)
				}
				case *uint64: {
					buf = append(buf, 'l', 'l' ,'u')
					fmt := C.CString(string(buf))
					var res C.ulonglong
					n += int(C.scanuint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = uint64(res)
				}
				case *int: {
					buf = append(buf, 'l', 'l' ,'d')
					fmt := C.CString(string(buf))
					var res C.longlong
					n += int(C.scanint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = int(res)
				}
				case *int8: {
					buf = append(buf, 'l', 'l' ,'d')
					fmt := C.CString(string(buf))
					var res C.longlong
					n += int(C.scanint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = int8(res)
				}
				case *int16: {
					buf = append(buf, 'l', 'l' ,'d')
					fmt := C.CString(string(buf))
					var res C.longlong
					n += int(C.scanint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = int16(res)
				}
				case *int32: {
					buf = append(buf, 'l', 'l' ,'d')
					fmt := C.CString(string(buf))
					var res C.longlong
					n += int(C.scanint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = int32(res)
				}
				case *int64: {
					buf = append(buf, 'l', 'l' ,'d')
					fmt := C.CString(string(buf))
					var res C.longlong
					n += int(C.scanint(fmt, &res))
					C.free(unsafe.Pointer(fmt))
					*p = int64(res)
				}
				default:
					panic("input.Scanf: argument must be pointer to some integer variable")
				}

				buf = buf[:0]
			} else if spec == 'c' {
				buf = append(buf, 'l', 'c')
				fmt := C.CString(string(buf))
				var res C.wchar_t
				n += int(C.scanchar(fmt, &res))
				C.free(unsafe.Pointer(fmt))

				switch p := a[arg].(type) {
				case *uint: *p = uint(res)
				case *uint8: *p = uint8(res)
				case *uint16: *p = uint16(res)
				case *uint32: *p = uint32(res)
				case *uint64: *p = uint64(res)
				case *int: *p = int(res)
				case *int8: *p = int8(res)
				case *int16: *p = int16(res)
				case *int32: *p = int32(res)
				case *int64: *p = int64(res)
				default:
					panic("input.Scanf: argument must be pointer to some integer variable")
				}

				buf = buf[:0]
			} else if spec == 'f' {
				buf = append(buf, 'l', 'f')
				fmt := C.CString(string(buf))
				var res C.double
				n += int(C.scandouble(fmt, &res))
				C.free(unsafe.Pointer(fmt))
				
				switch p := a[arg].(type) {
				case *float32: *p = float32(res)
				case *float64: *p = float64(res)
				default:
					panic("input.Scanf: argument must be pointer to some floating-point variable")
				}

				buf = buf[:0]
			} else if spec == 's' {
				buf = append(buf, 'm', 's')
				fmt := C.CString(string(buf))
				buf = buf[:0]
				var res *C.char
				count := int(C.scanstring(fmt, &res))
				C.free(unsafe.Pointer(fmt))

				if count == 1 {
					n++
					if p, ok := a[arg].(*string); ok {
						*p = C.GoString(res)
						C.free(unsafe.Pointer(res))
					} else {
						panic("input.Scanf: argument must be pointer to string variable")
					}
				}
			} else {
				panic("input.Scanf: only '%d', '%c' and 's' format specifiers allowed")
			}

			arg++
		}
		i++
	}

	return
}

func Gets() (s string) {
	cs := C.getstring()
	if cs == nil {
		panic("input.Gets: I/O error or out of memory")
	}

	s = C.GoString(cs)
	C.free(unsafe.Pointer(cs))
	return
}
