(import
  (scheme base)
  (scheme case-lambda)
  (srfi 64) ;;testing
  ;;(srfi  1) ;;lists
  (only (scheme file) open-input-file open-binary-input-file)
  (only (srfi 111) box box? unbox set-box!)
  (only (gypsum elisp-eval environment)
        =>lambda-args!
        =>lambda-optargs!
        =>lambda-rest!
        =>lambda-body!
        )
  (gypsum elisp-eval)
  (gypsum lens)
  (gypsum pretty)
  (only (gypsum cursor) new-cursor cursor-step!)
  (only (gypsum lens vector)
        mutable-vector-type? =>mvector-index!
        new-mutable-vector
        mutable-vector-length
        mutable-vector-append!)
  (only (gypsum elisp-eval parser) read-elisp)
  (prefix (gypsum editor-impl) *impl/)
  )
(cond-expand
  ((or guile gambit stklos)
   (import
     (only (srfi 69)
           hash-table-size
           hash-table-ref/default
           alist->hash-table))
   )
  ((mit))
  (else
   (import (srfi 125))))


(test-begin "gypsum_elisp_eval_tests")

;;--------------------------------------------------------------------------------------------------

(define test-elisp-env (new-environment (*elisp-init-env*)))

;; Raw results of evaluation
(define (test-elisp-reset-env!)
  (set! test-elisp-env (new-environment (*elisp-init-env*))))

(define (test-elisp-eval! expr)
  (elisp-eval! expr test-elisp-env))

(define (test-error-elisp-eval! expr)
  (let ((result (test-elisp-eval! expr)))
    (and (elisp-eval-error-type? result)
         (view result =>elisp-eval-error-message))))


(test-assert (elisp-environment-type? test-elisp-env))

(test-equal "hello" (test-elisp-eval! "hello"))

(test-eqv 3 (test-elisp-eval! '(+ 1 2)))

(test-eq #t (test-elisp-eval! '(eq nil nil)))

(test-eq '() (test-elisp-eval! '(eq nil t)))

(test-eq #t (test-elisp-eval! '(eq 5 5)))

(test-eq #t (test-elisp-eval! '(= 5 5 5)))

(test-eq '() (test-elisp-eval! '(= 5 5 6)))

(test-equal "wrong type argument"
  (test-error-elisp-eval! '(= 5 "hello")))

(test-equal "wrong type argument"
  (test-error-elisp-eval! '(+ 5 "hello")))

(test-equal '(1 2 3) (test-elisp-eval! '(list 1 2 (+ 1 2))))

(test-eq #t (test-elisp-eval! '(equal (list 5) (list 5))))

(test-eq '() (test-elisp-eval! '(equal (list 5) (list 5 6))))

(test-eqv 2 (test-elisp-eval! '(progn 1 2)))

(test-eqv 3 (test-elisp-eval! '(progn 1 2 (+ 1 2))))

(test-eqv 4 (test-elisp-eval! '(progn (setq a 4) a)))

(test-eqv 5 (test-elisp-eval! '(prog1 5 4 3 2 1)))

(test-eqv 4 (test-elisp-eval! '(prog2 5 4 3 2 1)))

(test-eqv 2 (test-elisp-eval! '(prog1 (+ 1 1) (+ 1 2) (+ 2 3))))

(test-eqv 3 (test-elisp-eval! '(prog2 (+ 1 1) (+ 1 2) (+ 2 3))))

(test-eq #t (test-elisp-eval! '(or nil nil nil t)))

(test-eq #t (test-elisp-eval! '(or (= 1 1 1) nil nil)))

(test-eq '() (test-elisp-eval! '(or nil nil nil (= 0 0 1))))

(test-eq '() (test-elisp-eval! '(and nil nil nil t)))

(test-eq '() (test-elisp-eval! '(and (= 1 1 1) nil nil)))

(test-eq #t (test-elisp-eval! '(and t t t (= 0 0 0))))

(test-eqv 10 (test-elisp-eval! '(if t 10 20)))

(test-eqv 20 (test-elisp-eval! '(if (null t) 10 20)))

(test-eqv 30 (test-elisp-eval! '(if (null t) 10 20 30)))

(test-eqv 30
  (test-elisp-eval!
   '(cond (nil 10) (nil 20) (t 30) (t 40) (nil 50))))

(test-eqv 30
  (test-elisp-eval!
   '(cond ((or nil nil) 10) ((and t nil) 20) ((or t nil) 30) (t 40))))

(test-eqv 5
  (test-elisp-eval!
   '(progn
     (setq a 2 b 3)
     (+ a b)
     )))

(test-eqv 8
  (test-elisp-eval!
   '(progn
     (setq a 3 b 5 c (+ a b))
     c)))

(test-equal "wrong number of arguments, setq"
  (test-error-elisp-eval! '(setq a)))

(test-eqv 13
  (test-elisp-eval!
   '(let ((a 5) (b 8)) (+ a b))))

(test-eqv 21
  (test-elisp-eval!
   '(let*((a 8) (b (+ 5 a))) (+ a b))))

(test-eqv 34
  (test-elisp-eval!
   '(let ((a 21))
      (setq a (+ a 13))
      a)))

(test-equal '(89 55)
  (test-elisp-eval!
   '(progn
     (setq a 21)
     (list
      (let ((b 34))
        (setq a (+ a b))
        (setq b (+ a b))
        b)
      a))))

(test-eq '() (test-elisp-eval! '(setq)))

(test-equal '() (test-elisp-eval! '(quote ())))

(test-equal '(1 2 3) (test-elisp-eval! '(quote (1 2 3))))

(test-equal '(1 2 3) (test-elisp-eval! '(backquote (1 2 (|,| (+ 1 2))))))

(test-equal '() (test-elisp-eval! '(backquote ())))

(test-equal '(1 2 3) (test-elisp-eval! '(|`| (1 2 (|,| (+ 1 2))))))

(test-equal '(1 2 3) (apply test-elisp-eval! '(`(1 2 ,(+ 1 2)))))

(test-equal '((+ 3 5) = 8)
  (test-elisp-eval! '(backquote ((+ ,(+ 1 2) ,(+ 2 3)) = ,(+ 1 2 2 3)))))

(test-assert
  (let ((func (test-elisp-eval! '(lambda () nil))))
    (and
     (null? (view func =>lambda-args!))
     (null? (view func =>lambda-optargs!))
     (not (view func =>lambda-rest!))
     (equal? '(nil) (view func =>lambda-body!)))
    ))

(test-equal '(1 + 2 = 3)
  (test-elisp-eval!
   '(progn
     (setq a 3 b 5)
     (apply
      (lambda (a b)
        (list a '+ b '= (+ a b)))
      '(1 2)))))

(test-equal '(2 + 3 = 5)
  (test-elisp-eval!
   '(progn
     (setq a 5 b 8)
     (defun f (a b) (list a '+ b '= (+ a b)))
     (f 2 3)
     )))


(test-equal '(13 + 21 = 34)
  (test-elisp-eval!
   '(progn
     (setq a 13 b 21)
     (defmacro mac1 (a b) `(list ,a '+ ,b '= ,(+ a b)))
     (mac1 a b))
   ))

(test-equal '(list 13 '+ 21 '= 34)
  (test-elisp-eval!
   '(progn
     (setq a 13 b 21)
     (macroexpand '(mac1 a b))
     )))

(test-eqv 45
  (test-elisp-eval!
   '(let ((sum 0) (i 0))
      (while (< i 10)
        (setq sum (+ sum i))
        (setq i (1+ i)))
      sum)))

(test-eqv 55
  (test-elisp-eval!
   '(let ((sum 0))
      (dotimes (n 11 sum)
        (setq sum (+ sum n))
        nil))))

(test-eqv (+ 1 1 2 3 5 8 13 21 34)
  (test-elisp-eval!
   '(let ((sum 0))
      (dolist (n '(1 1 2 3 5 8 13 21 34) sum)
        (setq sum (+ n sum))
        nil))))

(test-equal (new-symbol "hello" 5)
  (test-elisp-eval!
   '(let ((a (make-symbol "hello")))
      (set a 5)
      a)))

(test-equal "hello"
  (test-elisp-eval!
   '(let ((a (make-symbol "hello")))
      (symbol-name a))))

;;--------------------------------------------------------------------------------------------------

(define (test-elisp-eval-both-ports! expr)
  (call-with-port (open-output-string)
    (lambda (out)
      (call-with-port (open-output-string)
        (lambda (err)
          (parameterize
              ((*impl/elisp-output-port* out)
               (*impl/elisp-error-port*  err)
               )
            (let ((result (elisp-eval! expr test-elisp-env)))
              (list result (get-output-string out) (get-output-string err))
              )))))))

(define (test-elisp-eval-out-port! expr)
  (call-with-port (open-output-string)
    (lambda (out)
      (parameterize
          ((*impl/elisp-output-port* out))
        (let ((result (elisp-eval! expr test-elisp-env)))
          (list result (get-output-string out))
          )))))


(test-equal (list "Hello, world!" "Hello, world!")
  (test-elisp-eval-out-port!
   '(princ "Hello, world!")))

(test-equal (list (list "a" "b" "c") "(a b c)")
  (test-elisp-eval-out-port!
   '(princ (list "a" "b" "c"))))

(test-equal (list "Hello, world!\n" "\"Hello, world!\\n\"")
  (test-elisp-eval-out-port!
   '(prin1 "Hello, world!\n")))

(test-equal (list (list "a" "b" "c") "(\"a\" \"b\" \"c\")")
  (test-elisp-eval-out-port!
   '(prin1 (list "a" "b" "c"))))

;;--------------------------------------------------------------------------------------------------

(define test-elisp-progn-var-scope-test
  '(progn
     (message "------------------------------")
     (setq glo "top")
     (defun printglo (who) (message (format "%s: glo = %s" who glo)))
     (defun runfn (sym)
       (message "--begin-- %s" sym)
       (funcall sym)
       (message "----end-- %s" sym)
       )
     (defun fn-A ()
       (printglo 'fn-A)
       (setq glo "in-fn-A")
       (printglo 'fn-A)
       )
     (defun fn-B ()
       (printglo 'fn-B)
       (let ((glo "in-fn-B"))
         (printglo 'fn-B-let1)
         (runfn 'fn-A)
         (printglo 'fn-B-let2)
         (setq glo "fn-B-after-setq")
         (printglo 'fn-b-let3)
         (runfn 'fn-A)
         (printglo 'fn-b-let4)
         )
       (printglo 'fn-B))
     (runfn 'fn-A)
     (printglo 'top)
     (setq glo "top")
     (printglo 'top-reset-A)
     (runfn 'fn-B)
     (printglo 'top)
     (message "------------------------------")
     t)
  )

(define lexical-scope-test-expected-result
  "------------------------------
--begin-- fn-A
fn-A: glo = top
fn-A: glo = in-fn-A
----end-- fn-A
top: glo = in-fn-A
top-reset-A: glo = top
--begin-- fn-B
fn-B: glo = top
fn-B-let1: glo = top
--begin-- fn-A
fn-A: glo = top
fn-A: glo = in-fn-A
----end-- fn-A
fn-B-let2: glo = in-fn-A
fn-b-let3: glo = in-fn-A
--begin-- fn-A
fn-A: glo = in-fn-A
fn-A: glo = in-fn-A
----end-- fn-A
fn-b-let4: glo = in-fn-A
fn-B: glo = in-fn-A
----end-- fn-B
top: glo = in-fn-A
------------------------------
")

(define dynamic-scope-test-expected-result
  "------------------------------
--begin-- fn-A
fn-A: glo = top
fn-A: glo = in-fn-A
----end-- fn-A
top: glo = in-fn-A
top-reset-A: glo = top
--begin-- fn-B
fn-B: glo = top
fn-B-let1: glo = in-fn-B
--begin-- fn-A
fn-A: glo = in-fn-B
fn-A: glo = in-fn-A
----end-- fn-A
fn-B-let2: glo = in-fn-A
fn-b-let3: glo = fn-B-after-setq
--begin-- fn-A
fn-A: glo = fn-B-after-setq
fn-A: glo = in-fn-A
----end-- fn-A
fn-b-let4: glo = in-fn-A
fn-B: glo = top
----end-- fn-B
top: glo = top
------------------------------
")

;;--------------------------------------------------------------------------------------------------

(test-end "gypsum_elisp_eval_tests")

;;--------------------------------------------------------------------------------------------------

(define *verbose* (make-parameter 1))

(define (file-read-all-forms bx filepath)
  (let*((verbose (*verbose*))
        (mutvec (unbox bx))
        (mutvec (if mutvec mutvec (new-mutable-vector 64))))
    (call-with-port (open-input-file filepath)
      (lambda (port)
        (let loop ()
          (let ((form (read-elisp port)))
            (cond
             ((eof-object? form) mutvec)
             (else
              (mutable-vector-append! mutvec form)
              (when (> verbose 1)
                (pretty (print (mutable-vector-length mutvec) ": " form (line-break))))
              (loop)
              ))))))
    (when (> verbose 0)
      (pretty
       (print
        ";;read " (mutable-vector-length mutvec)
        " forms from " (qstr filepath) (line-break)
        )))
    (set-box! bx mutvec)
    (values)
    ))

(define *subr.el* (box #f))
(define *map.el* (box #f))
(define *pp.el* (box #f))

(define (load-subr-forms) (file-read-all-forms *subr.el* "./elisp/subr.el"))
(define (load-map-forms) (file-read-all-forms *map.el* "./elisp/subr.el"))
(define (load-pp-forms) (file-read-all-forms *pp.el* "./elisp/pp.el"))

(define (make-indexer loader b)
  (lambda (i)
    (unless (unbox b) (loader))
    (let ((b (unbox b)))
      (if (>= i (mutable-vector-length b)) #f
          (view b (=>mvector-index! i)))
      )))

(define subr.el (make-indexer load-subr-forms *subr.el*))
(define map.el (make-indexer load-map-forms *subr.el*))
(define pp.el (make-indexer load-pp-forms *pp.el*))

(define current-document #f)

(define (edit bx filepath)
  (let ((result (file-read-all-forms bx filepath)))
    (cond
     ((and result (mutable-vector-type? result)) (set! current-document result))
     (else (error "file-read-all-forms returned non-mutable-vector type object" result)))
    ))

(define current-form #f)

(define (select-form form.el linenum)
  (let ((form (form.el linenum)))
    (set! current-form (new-cursor form))
    (display ";;cursor is now inspecting form:\n")
    (write form) (newline)
    ))


