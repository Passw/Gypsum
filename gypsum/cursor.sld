(define-library (gypsum cursor)
  (import
    (scheme base)
    (scheme case-lambda)
    (only (gypsum lens)
          record-unit-lens view endo-set
          =>assoc-by =>bring =>find
          )
    (only (gypsum hash-table) hash-table? hash-table->alist)
    )
  (export
   new-cursor  maybe-new-cursor  new-cursor-if-iterable
   cursor-type?  cursor-object
   cursor-index  set!cursor-index  =>cursor-index!
   cursor-ref  cursor-end?  cursor-step!
   cursor-collect-list

   cursor-interface
   make<cursor-interface>
   cursor-report-end
   cursor-referencer
   cursor-stepper
   cursor-jumper
   declare-interface/cursor
   )

  (cond-expand
    (stklos (include "./gypsum/cursor.scm"))
    (guile (include "cursor.scm"))
    (else (include "cursor.scm"))
    ))
