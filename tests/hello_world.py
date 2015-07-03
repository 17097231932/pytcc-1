import pytcc

g = pytcc.Tcc()

g.compile_string("int main(){printf(\"Hello world!\\n\");}")

g.run([""])
