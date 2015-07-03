import copy
cimport libtcc
from libc.stdlib cimport malloc, free

class CompilerError(Exception):
    pass

cdef void compiler_error(void *opaque, const char *msg):
    parent = <Tcc>opaque
    parent.last_error = msg

cdef class Tcc:
    cdef libtcc.TCCState* _state
    cdef bytes last_error
    
    def __cinit__(self):
        self._state = libtcc.tcc_new()
        self.last_error = <bytes>"<NO ERROR>"

        if self._state is NULL:
            raise MemoryError()

        libtcc.tcc_set_error_func(self._state, <void *>self, compiler_error)

    def err_check(self, res):
        if res == -1:
            err = self.last_error
            self.last_error = <bytes>"<NO ERROR>"
            raise CompilerError(err)
    
    def __dealloc__(self):
        if self._state is not NULL:
            libtcc.tcc_delete(self._state)


    def add_include_path(self, path_name):
        self.err_check(libtcc.tcc_add_include_path(self._state, path_name))

    def add_sysinclude_path(self, path_name):
        self.err_check(libtcc.tcc_add_sysinclude_path(self._state, path_name))

    def compile_string(self, string):
        self.err_check(libtcc.tcc_compile_string(self._state, string))

    def add_file(self, f):
        self.err_check(libtcc.tcc_add_file(self._state, f))

    def add_library_path(self, p):
        self.err_check(libtcc.tcc_add_library_path(self._state, p))

    def add_library(self, f):
        self.err_check(libtcc.tcc_add_library(self._state, f))

    def run(self, args):
        cdef char **c_argv
        args = [bytes(x) for x in args]
        c_argv = <char**>malloc(sizeof(char*) * len(args))
        for idx, s in enumerate(args):
            c_argv[idx] = s
        
        self.err_check(libtcc.tcc_run(self._state, len(args), c_argv))
