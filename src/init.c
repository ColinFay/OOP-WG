#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP method_(SEXP, SEXP, SEXP);
extern SEXP method_call_(SEXP, SEXP, SEXP);
extern SEXP S7_class_(SEXP, SEXP);
extern SEXP S7_object_();

static const R_CallMethodDef CallEntries[] = {
    {"method_", (DL_FUNC) &method_, 3},
    {"method_call_", (DL_FUNC) &method_call_, 3},
    {"S7_object_", (DL_FUNC) &S7_object_, 0},
    {NULL, NULL, 0}
};

SEXP parent_sym;
SEXP name_sym;
SEXP ANY_sym;

void R_init_S7(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
    parent_sym = Rf_install("parent");
    name_sym = Rf_install("name");
    ANY_sym = Rf_install("ANY");
}
