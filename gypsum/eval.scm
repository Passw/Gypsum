;; This library defines parameters that can be shared among various
;; back-end implementations. The API completely replaces the (scheme
;; eval) library with APIs that can all be parameterized to make it
;; easier to control the behavior of `EVAL` used by the Gypsum
;; interpreter.

;; (define (emacs-environment)
;;   (environment
;;    '(scheme base)
;;    '(scheme case-lambda)
;;    '(scheme lazy)
;;    '(scheme char)
;;    '(scheme complex)
;;    '(scheme inexact)
;;    '(scheme cxr)
;;    '(gypsum backend guile-gi gtk3)))

(define *null-environment-procedure* (make-parameter scheme:null-environment))
(define (null-environment version) ((*null-environment-procedure*) version))

(define *scheme-report-environment-procedure* (make-parameter scheme:scheme-report-environment))
(define (scheme-report-environment version) ((*scheme-report-environment-procedure*) version))

(define *interaction-environment-procedure* (make-parameter scheme:interaction-environment))
(define (interaction-environment) ((*interaction-environment-procedure*)))

(define *the-environment-procedure* (make-parameter scheme:null-environment))
(define (the-environment) ((*the-environment-procedure*)))

(define *eval-procedure* (make-parameter scheme:eval))

(define eval
  (case-lambda
    ((expr) (eval expr #f))
    ((expr env) ((*eval-procedure*) expr env))))

(define *eval-string-procedure*
  (make-parameter
   (case-lambda
     ((str) ((*eval-string-procedure*) str (the-environment)))
     ((str env) (display "eval-string: ")(write str)(newline)))))

(define eval-string
  (case-lambda
    ((str) (eval-string str (the-environment)))
    ((str env) ((*eval-string-procedure*) str env))
    ))
