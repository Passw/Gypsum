(define-library (gypsum backend guile-gi gtk3-init)
  (import
    (scheme base)
    (scheme write)
    (only (scheme case-lambda) case-lambda)
    (only (scheme process-context) command-line)
    (only (scheme char) char-upcase)
    (prefix (gi) gi:)
    (only (gi util) push-duplicate-handler!)
    (only (gi) <signal>)
    (prefix (gi repository) gi-repo:)
    (only (gi types) flags->list)
    (only (gypsum lens) view record-unit-lens lens-set =>hash-key!)
    (prefix (gypsum concurrent) th:)
    (only (gypsum pretty) pretty print line-break)
    (prefix (gypsum editor) ed:)
    (prefix (gypsum editor-impl) *impl/)
    (prefix (gypsum keymap) km:)
    (prefix (gypsum eval) gypsum:)
    (only (gypsum lens vector)
          new-mutable-vector
          mutable-vector-append!
          mutable-vector-clear!)
    (only (gypsum backend guile-gi gtk3-repl)
          make-repl-thread thread-start!)
    (prefix (ice-9 eval-string) guile:)
    (only (ice-9 format) format)
    )
  (export launch-gui)
  (include "gtk3-init.scm"))
