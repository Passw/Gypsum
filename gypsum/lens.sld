(define-library (gypsum lens)
  (import
    (scheme base)
    (scheme write)
    (scheme case-lambda)
    (only (gypsum compat)
          hash-table-empty?
          vector-fold)
    )

  (cond-expand
    (guile
     (import
       (only (srfi 1) member)
       (only (srfi srfi-9 gnu) set-record-type-printer!)
       (only (srfi 28) format)
       (only (srfi 69)
             hash-table? make-hash-table alist->hash-table hash-table->alist
             hash-table-size hash-table-set! hash-table-delete! hash-table-fold
             hash-table-ref/default hash-table-update!/default)
       (only (srfi 111) unbox set-box!))
     )
    (gambit
     ;; NOTE:
     ;; Gambit does not seem to correctly implement the syntax for
     ;;     (import (only (srfi 64) ...))
     ;; as it fails with the error
     ;;     Unbound variable: _test#test-begin
     ;; even though the "test-begin" symbol is explcitly imported. The
     ;; error goes away when I use the expression
     ;;     (import (srfi 64))
     ;;
     ;; Ramin Honary <2024-10-04>
     ;; Gambit v4.9.5 20230726044844 aarch64-unknown-linux-gnu "./configure"
     (import
       (srfi 69))
     )
    (else))

  (export
   ;; -------------------- Main API --------------------
   lens view lens-set lens-swap update&view update& update
   lens-set! lens-swap! endo-set endo-update endo-view
   lens-compose endo

   ;; ------------------- Unit lenses ------------------
   ;; When defining your own lenses
   ;; use unit-lens or record-unit-lens
   %unit-lens-type? %lens-type? unit-lens
   unit-lens-view unit-lens-update unit-lens-set unit-lens-swap
   unit-lens-getter unit-lens-setter
   record-unit-lens record-immutable-lens
   unit-lens-getter unit-lens-setter unit-lens-updater unit-lens->expr
   default-unit-lens-setter  default-unit-lens-updater

   ;; ------------- Lenses introspection ---------------
   ;; Inspecting properties of lenses.
   lens-type? vector->lens lens->vector lens-view lens-unit-count

   ;; -- Extending lens indexing with other data types --
   ;; The `view` and `update&view` procedures can take integer, string, or
   ;; symbol values and automatically construct lenses out of these
   ;; for inspecting vectors and hash tables. If you have your own
   ;; record data which could also be indexed by integers, strings, or
   ;; symbols, you can use these procedures at the top-level of your
   ;; program (or in any statement that evaluates at load time), so
   ;; that `view`-ing or `update&view`-ing on constants will be able to
   ;; inspect structures of the types you constructed.
   declare-rule/index->lens
   get-rule-declaration/index->lens

   ;; ----------- Useful, pre-defined lenses -----------

   ;; Lists, and association Lists
   =>car =>cdr
   =>find-tail =>find =>bring
   =>assoc-by =>assoc =>assv =>assq

   ;; Vectors
   =>vector-index*! =>vector-index!
   *default-vector-constructor* *default-vector-copier*

   ;; Hash tables
   =>hash-key*! =>hash-key! *default-hash-table-constructor*

   ;; Utility lenses
   =>self =>const =>true =>false
   =>guard =>on-update =>canonical =>encapsulate
   =>view-only-lens

   ;; Debugging lenses
   =>trace =>assert
   )
  (cond-expand
    ((or gambit guile stklos)
     (export =>box)
     ))

  (cond-expand
    (stklos
     (include "./gypsum/lens.scm"))
    (guile
     (include "lens.scm"))
    (else
     (include "lens.scm"))
    ))
