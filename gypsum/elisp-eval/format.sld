(define-library (gypsum elisp-eval format)
  ;; This library defines the algorithm that replicates the behavior
  ;; of the Emacs Lisp `format` function.
  (import
    (scheme base)
    (scheme read)
    (scheme write)
    (only (gypsum elisp-eval environment) eval-error)
    )
  (export format format-to-port format-count)
  (include "format.scm"))
