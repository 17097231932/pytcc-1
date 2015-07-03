import tcc

g = tcc.Tcc()

g.compile_string("int main(){printf(\"Hello world!\\n\");}")

g.run([""])
