(define-library (gypsum elisp-eval environment)
  ;; This library defines functions and record data types that are
  ;; essential to the operation of an Emacs Lisp interpreter, but the
  ;; interpreter itself is not defined here. The interpreter includes
  ;; many built-in procedures which are defined across a few different
  ;; Scheme libraries, all of which import this library. The
  ;; interpreter itself is defined in the `(GYPSUM ELISP-EVAL)`
  ;; library.
  (import
    (scheme base)
    (scheme eval)
    (scheme cxr)
    (scheme case-lambda)
    (only (scheme write) display write)
    (only (srfi 1) assq)
    (only (gypsum editor command) command-type? command-procedure)
    (only (gypsum hash-table)
          hash-table?
          hash-table-empty?
          make-hash-table
          alist->hash-table
          hash-table->alist
          hash-table-set!
          hash-table-delete!
          hash-table-ref/default
          hash-table-walk
          string-hash
          )
    (only (gypsum lens)
          unit-lens  record-unit-lens  lens
          lens-set  lens-set!  endo-view  view
          update  endo-update  update&view
          *default-hash-table-constructor*
          default-unit-lens-updater  default-unit-lens-setter
          =>canonical  =>view-only-lens  =>hash-key!  =>hash-key*!)
    (only (gypsum lens vector) mutable-vector-type?)
    (only (gypsum cursor)
          new-cursor  cursor-ref  cursor-step!
          cursor-end?  cursor-type?
          cursor-collect-list  new-cursor-if-iterable)
    (only (rapid match) match match* -> unquote guard)
    )

  (export
   ;; Quoting Scheme literals
   elisp-quote-scheme-type?  elisp-quote-scheme  elisp-unquote-scheme

   ;; Converting data between Scheme and Elisp
   scheme->elisp  elisp->scheme  elisp-null?
   pure  pure*  pure*-typed  pure*-numbers

   ;; Emacs Lisp constant symbols
   nil t

   ;; Environment objects
   new-empty-environment
   elisp-environment-type?
   env-push-new-elstkfrm!
   env-pop-elstkfrm!
   env-resolve-function
   =>env-symbol!
   env-intern!    ;; TODO: replace with a lens?
   env-setq-bind! ;; TODO: replace with a lens?
   *default-obarray-size*
   *elisp-input-port*
   *elisp-output-port*
   *elisp-error-port*

   =>interp-cur!  =>interp-env!  =>interp-stk!
   =>env-obarray-key!
   =>env-lexstack*!
   =>env-obarray*!
   =>env-lexical-mode?!

   ;; Symbol objects
   sym-type?  new-symbol
   =>sym-value*!  =>sym-function*!  =>sym-plist*!
   =>sym-name  =>sym-value!  =>sym-function!  =>sym-plist!
   ensure-string  symbol/string?  any-symbol?

   ;; Function objects
   lambda-type?  new-lambda
   =>lambda-kind!  =>lambda-args!  =>lambda-optargs!  =>lambda-rest!
   =>lambda-docstring!  =>lambda-declares!  =>lambda-lexenv!  =>lambda-body!
   =>lambda-declares*!  =>lambda-interactive*!
   =>lambda-body*!  =>lambda-kind*!  =>lambda-docstring*!

   ;; Macro objects
   make<macro>  macro-type?  macro-procedure  elisp-void-macro

   ;; Error objects
   raise-error-impl*  eval-raise  eval-error
   elisp-eval-error-type?  =>elisp-eval-error-message  =>elisp-eval-error-irritants

   ;; Stack frames
   new-elstkfrm  stack-lookup
   =>elstkfrm-lexstack-key*!  =>elstkfrm-dynstack-key*!  =>elstkfrm*!
   =>elstkfrm-lexstack*!   =>elstkfrm-dynstack*!
   elstkfrm-from-args  elstkfrm-sym-intern!
   )

  (include "environment.scm")
  )
