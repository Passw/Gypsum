;;; Rapid Scheme --- An implementation of R7RS

;; Copyright (C) 2017 Marc Nieper-Wißkirchen

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;; Copyright (c) 2005, 2006, 2007, 2012, 2013 Per Bothner
;; Added "full" support for Chicken, Gauche, Guile and SISC.
;;   Alex Shinn, Copyright (c) 2005.
;; Modified for Scheme Spheres by Álvaro Castro-Castilla, Copyright (c) 2012.
;; Support for Guile 2 by Mark H Weaver <mhw@netris.org>, Copyright (c) 2014.
;;
;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use, copy,
;; modify, merge, publish, distribute, sublicense, and/or sell copies
;; of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.


(define-library (rapid test-test)
  (export run-tests)
  (import (scheme base)
	  (rapid test))
  (begin
    (define (run-tests)
      
      (test-begin "SRFI 64 - Meta-Test Suite")

      (test-begin "1. Simple test-cases")

      (test-begin "1.1. test-assert")

      (test-equal
       "1.1.1. Very simple"
       '(("a") ("b") () () () (1 1 0 0 0))
       (t))

      (test-equal
       "1.1.2. A test with no name"
       '(("a") ("") () () () (1 1 0 0 0))
       (triv-runner (lambda () (test-assert "a" #t) (test-assert #f))))

      (test-equal
       "1.1.3. Tests can have the same name"
       '(("a" "a") () () () () (2 0 0 0 0))
       (triv-runner (lambda () (test-assert "a" #t) (test-assert "a" #t))))

      (test-equal
       "1.1.4. One way to FAIL is to throw an error"
       '(() ("a") () () () (0 1 0 0 0))
       (triv-runner (lambda () (test-assert "a" (choke)))))

      (test-end);1.1

      (test-begin "1.2. test-eqv")

      (test-equal
       "1.2.1.  Simple numerical equivalence"
       '(("c") ("a" "b") () () () (1 2 0 0 0))
       (triv-runner
	(lambda ()
	  (test-eqv "a" (mean 3 5) 4)
	  (test-eqv "b" (mean 3 5) 4.5)
	  (test-eqv "c" (mean 3 5) 4.0))))

      (test-end);1.2

      (test-end "1. Simple test-cases")

      (test-begin "2. Tests for catching errors")

      (test-begin "2.1. test-error")

      (test-equal
       "2.1.1. Baseline test; PASS with no optional args"
       '(("") () () () () (1 0 0 0 0))
       (triv-runner
	(lambda ()
	  ;; PASS
	  (test-error (vector-ref '#(1 2) 9)))))

      (test-equal
       "2.1.2. Baseline test; FAIL with no optional args"
       ;; FIXME: Larceny gives: '(("") ("") () () () (1 1 0 0 0))       
       '(() ("") () () () (0 1 0 0 0))
       (triv-runner
	(lambda ()
	  ;; FAIL: the expr does not raise an error and `test-error' is
	  ;;       claiming that it will, so this test should FAIL
	  (test-error (vector-ref '#(1 2) 0)))))

      (test-equal
       "2.1.3. PASS with a test name and error type"
       '(("a") () () () () (1 0 0 0 0))
       (triv-runner
	(lambda ()
	  ;; PASS
	  (test-error "a" #t (vector-ref '#(1 2) 9)))))

      (test-end "2.1. test-error")

      (test-end "2. Tests for catching errors")

      (test-begin "3. Test groups and paths")

      (test-equal
       "3.1. test-begin with unspecific test-end"
       '(("b") () () () () (1 0 0 0 0))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-assert "b" #t)
	  (test-end))))

      (test-equal
       "3.2. test-begin with name-matching test-end"
       '(("b") () () () () (1 0 0 0 0))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-assert "b" #t)
	  (test-end "a"))))

      (test-error
       "3.3. test-begin with mismatched test-end"
       #t
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-assert "b" #t)
	  (test-end "x"))))

      (test-equal
       "3.4. test-begin with name and count"
       '(("b" "c") () () () () (2 0 0 0 0))
       (triv-runner
	(lambda ()
	  (test-begin "a" 2)
	  (test-assert "b" #t)
	  (test-assert "c" #t)
	  (test-end "a"))))

      ;; similarly here, a mismatched count is a lexical error
      ;; and not a test failure...

      (test-error
       "3.5. test-begin with mismatched count"
       #t
       (triv-runner
	(lambda ()
	  (test-begin "a" 99)
	  (test-assert "b" #t)
	  (test-end "a"))))

      (test-equal
       "3.6. introspecting on the group path"
       '((() "w")
	 (("a" "b") "x")
	 (("a" "b") "y")
	 (("a") "z"))
       ;;
       ;;  `path-revealing-runner' is designed to return a list
       ;;  of the tests executed, in order.  Each entry is a list
       ;;  (GROUP-PATH TEST-NAME), and each GROUP-PATH is a list
       ;;  of test groups starting from the topmost
       ;;
       (path-revealing-runner
	(lambda ()
	  (test-assert "w" #t)
	  (test-begin "a")
	  (test-begin "b")
	  (test-assert "x" #t)
	  (test-assert "y" #t)
	  (test-end)
	  (test-assert "z" #t))))


      (test-end "3. Test groups and paths")

      (test-begin "4. Handling set-up and cleanup")

      (test-equal "4.1. Normal exit path"
		  '(in 1 2 out)
		  (let ((ex '()))
		    (define (do s)
		      (set! ex (cons s ex)))
		    ;;
		    (triv-runner
		     (lambda ()
		       (test-group-with-cleanup
			"foo"
			(do 'in)
			(do 1)
			(do 2)
			(do 'out))))
		    (reverse ex)))
      
      (test-equal "4.2. Exception exit path"
		  '(in 1 out)
		  (let ((ex '()))
		    (define (do s)
		      (set! ex (cons s ex)))
		    ;;
		    ;; the outer runner is to run the `test-error' in, to
		    ;; catch the exception raised in the inner runner,
		    ;; since we don't want to depend on any other
		    ;; exception-catching support
		    ;;
		    (triv-runner
		     (lambda ()
		       (test-error
			(triv-runner
			 (lambda ()
			   (test-group-with-cleanup
			    "foo"
			    (do 'in) (test-assert #t)
			    (do 1)   (test-assert #t)
			    (choke)  (test-assert #t)
			    (do 2)   (test-assert #t)
			    (do 'out)))))))
		    (reverse ex)))

      (test-end "4. Handling set-up and cleanup")

      (test-begin "5. Test specifiers")

      (test-begin "5.1. test-match-named")

      (test-equal "5.1.1. match test names"
		  '(("y") () () () ("x") (1 0 0 0 1))
		  (triv-runner
		   (lambda ()
		     (test-skip (test-match-name "x"))
		     (test-assert "x" #t)
		     (test-assert "y" #t))))

      (test-equal "5.1.2. but not group names"
		  '(("z") () () () () (1 0 0 0 0))
		  (triv-runner
		   (lambda ()
		     (test-skip (test-match-name "x"))
		     (test-begin "x")
		     (test-assert "z" #t)
		     (test-end))))

      (test-end)

      (test-begin "5.2. test-match-nth")
      ;; See also: [6.4. Short-circuit evaluation]

      (test-equal "5.2.1. skip the nth one after"
		  '(("v" "w" "y" "z") () () () ("x") (4 0 0 0 1))
		  (triv-runner
		   (lambda ()
		     (test-assert "v" #t)
		     (test-skip (test-match-nth 2))
		     (test-assert "w" #t)             ; 1
		     (test-assert "x" #t)             ; 2 SKIP
		     (test-assert "y" #t)             ; 3
		     (test-assert "z" #t))))          ; 4

      (test-equal "5.2.2. skip m, starting at n"
		  '(("v" "w" "z") () () () ("x" "y") (3 0 0 0 2))
		  (triv-runner
		   (lambda ()
		     (test-assert "v" #t)
		     (test-skip (test-match-nth 2 2))
		     (test-assert "w" #t)             ; 1
		     (test-assert "x" #t)             ; 2 SKIP
		     (test-assert "y" #t)             ; 3 SKIP
		     (test-assert "z" #t))))          ; 4

      (test-end)

      (test-begin "5.3. test-match-any")
      (test-equal "5.3.1. basic disjunction"
		  '(("v" "w" "z") () () () ("x" "y") (3 0 0 0 2))
		  (triv-runner
		   (lambda ()
		     (test-assert "v" #t)
		     (test-skip (test-match-any (test-match-nth 3)
						(test-match-name "x")))
		     (test-assert "w" #t)             ; 1
		     (test-assert "x" #t)             ; 2 SKIP(NAME)
		     (test-assert "y" #t)             ; 3 SKIP(COUNT)
		     (test-assert "z" #t))))          ; 4

      (test-equal "5.3.2. disjunction is commutative"
		  '(("v" "w" "z") () () () ("x" "y") (3 0 0 0 2))
		  (triv-runner
		   (lambda ()
		     (test-assert "v" #t)
		     (test-skip (test-match-any (test-match-name "x")
						(test-match-nth 3)))
		     (test-assert "w" #t)             ; 1
		     (test-assert "x" #t)             ; 2 SKIP(NAME)
		     (test-assert "y" #t)             ; 3 SKIP(COUNT)
		     (test-assert "z" #t))))          ; 4

      (test-end)

      (test-begin "5.4. test-match-all")
      (test-equal "5.4.1. basic conjunction"
		  '(("v" "w" "y" "z") () () () ("x") (4 0 0 0 1))
		  (triv-runner
		   (lambda ()
		     (test-assert "v" #t)
		     (test-skip (test-match-all (test-match-nth 2 2)
						(test-match-name "x")))
		     (test-assert "w" #t)             ; 1
		     (test-assert "x" #t)             ; 2 SKIP(NAME) & SKIP(COUNT)
		     (test-assert "y" #t)             ; 3 SKIP(COUNT)
		     (test-assert "z" #t))))          ; 4

      (test-equal "5.4.2. conjunction is commutative"
		  '(("v" "w" "y" "z") () () () ("x") (4 0 0 0 1))
		  (triv-runner
		   (lambda ()
		     (test-assert "v" #t)
		     (test-skip (test-match-all (test-match-name "x")
						(test-match-nth 2 2)))
		     (test-assert "w" #t)             ; 1
		     (test-assert "x" #t)             ; 2 SKIP(NAME) & SKIP(COUNT)
		     (test-assert "y" #t)             ; 3 SKIP(COUNT)
		     (test-assert "z" #t))))          ; 4

      (test-end)

      (test-end "5. Test specifiers")

      (test-begin "6. Skipping selected tests")

      (test-equal
       "6.1. Skip by specifier - match-name"
       '(("x") () () () ("y") (1 0 0 0 1))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-skip (test-match-name "y"))
	  (test-assert "x" #t)      ; PASS
	  (test-assert "y" #f)      ; SKIP
	  (test-end))))

      (test-equal
       "6.2. Shorthand specifiers"
       '(("x") () () () ("y") (1 0 0 0 1))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-skip "y")
	  (test-assert "x" #t)      ; PASS
	  (test-assert "y" #f)      ; SKIP
	  (test-end))))

      (test-begin "6.3. Specifier Stack")

      (test-equal
       "6.3.1. Clearing the Specifier Stack"
       '(("x" "x") ("y") () () ("y") (2 1 0 0 1))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-skip "y")
	  (test-assert "x" #t)      ; PASS
	  (test-assert "y" #f)      ; SKIP
	  (test-end)
	  (test-begin "b")
	  (test-assert "x" #t)      ; PASS
	  (test-assert "y" #f)      ; FAIL
	  (test-end))))

      (test-equal
       "6.3.2. Inheriting the Specifier Stack"
       '(("x" "x") () () () ("y" "y") (2 0 0 0 2))
       (triv-runner
	(lambda ()
	  (test-skip "y")
	  (test-begin "a")
	  (test-assert "x" #t)      ; PASS
	  (test-assert "y" #f)      ; SKIP
	  (test-end)
	  (test-begin "b")
	  (test-assert "x" #t)      ; PASS
	  (test-assert "y" #f)      ; SKIP
	  (test-end))))

      (test-end);6.3

      (test-begin "6.4. Short-circuit evaluation")

      (test-equal
       "6.4.1. In test-match-all"
       '(("x") ("y" "x" "z") () () ("y") (1 3 0 0 1))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-skip (test-match-all "y" (test-match-nth 2)))
	  ;; let's label the substructure forms so we can
	  ;; see which one `test-match-nth' is going to skip
	  ;;                        ; #   "y"  2   result
	  (test-assert "x" #t)      ; 1 - #f   #f  PASS   
	  (test-assert "y" #f)      ; 2 - #t   #t  SKIP 
	  (test-assert "y" #f)      ; 3 - #t   #f  FAIL
	  (test-assert "x" #f)      ; 4 - #f   #f  FAIL
	  (test-assert "z" #f)      ; 5 - #f   #f  FAIL
	  (test-end))))

      (test-equal
       "6.4.2. In separate skip-list entries"
       '(("x") ("x" "z") () () ("y" "y") (1 2 0 0 2))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-skip "y")
	  (test-skip (test-match-nth 2))
	  ;; let's label the substructure forms so we can
	  ;; see which one `test-match-nth' is going to skip
	  ;;                        ; #   "y"  2   result
	  (test-assert "x" #t)      ; 1 - #f   #f  PASS   
	  (test-assert "y" #f)      ; 2 - #t   #t  SKIP 
	  (test-assert "y" #f)      ; 3 - #t   #f  SKIP
	  (test-assert "x" #f)      ; 4 - #f   #f  FAIL
	  (test-assert "z" #f)      ; 5 - #f   #f  FAIL
	  (test-end))))

      (test-begin "6.4.3. Skipping test suites")

      (test-equal
       "6.4.3.1. Introduced using 'test-begin'"
       '(("x") () () () () (1 0 0 0 0))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-skip "b")
	  (test-begin "b")            ; not skipped
	  (test-assert "x" #t)
	  (test-end "b")
	  (test-end "a"))))

      (test-expect-fail 1) ;; ???
      (test-equal
       "6.4.3.2. Introduced using 'test-group'"
       '(() () () () () (0 0 0 0 1))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-skip "b")
	  (test-group 
	   "b"            ; skipped
	   (test-assert "x" #t))
	  (test-end "a"))))

      (test-equal
       "6.4.3.3. Non-skipped 'test-group'"
       '(("x") () () () () (1 0 0 0 0))
       (triv-runner
	(lambda ()
	  (test-begin "a")
	  (test-skip "c")
	  (test-group "b" (test-assert "x" #t))
	  (test-end "a"))))

      (test-end) ; 6.4.3
      
      (test-end);6.4

      (test-end "6. Skipping selected tests")

      (test-begin "7. Expected failures")

      (test-equal "7.1. Simple example"
		  '(() ("x") ("z") () () (0 1 1 0 0))
		  (triv-runner
		   (lambda ()
		     (test-assert "x" #f)
		     (test-expect-fail "z")
		     (test-assert "z" #f))))

      (test-equal "7.2. Expected exception"
		  '(() ("x") ("z") () () (0 1 1 0 0))
		  (triv-runner
		   (lambda ()
		     (test-assert "x" #f)
		     (test-expect-fail "z")
		     (test-assert "z" (choke)))))

      (test-equal "7.3. Unexpectedly PASS"
		  '(() () ("y") ("x") () (0 0 1 1 0))
		  (triv-runner
		   (lambda ()
		     (test-expect-fail "x")
		     (test-expect-fail "y")
		     (test-assert "x" #t)
		     (test-assert "y" #f))))
      


      (test-end "7. Expected failures")

      (test-begin "8. Test-runner")

      (test-begin "8.1. test-runner-current")
      (test-assert "8.1.1. automatically restored"
		   (let ((a 0)
			 (b 1)
			 (c 2))
					;
		     (triv-runner
		      (lambda ()
			(set! a (test-runner-current))
			;;
			(triv-runner
			 (lambda ()
			   (set! b (test-runner-current))))
			;;
			(set! c (test-runner-current))))
		     ;;
		     (and (eq? a c)
			  (not (eq? a b)))))
      
      (test-end)

      (test-begin "8.2. test-runner-simple")
      (test-assert "8.2.1. default on-test hook"
		   (eq? (test-runner-on-test-end (test-runner-simple))
			test-on-test-end-simple))
      (test-assert "8.2.2. default on-final hook"
		   (eq? (test-runner-on-final (test-runner-simple))
			test-on-final-simple))
      (test-end)

      (test-begin "8.3. test-runner-factory")

      (test-assert "8.3.1. default factory"
		   (eq? (test-runner-factory) test-runner-simple))

      (test-assert "8.3.2. settable factory"
		   (with-factory-saved
		    (lambda ()
		      (test-runner-factory test-runner-null)
		      ;; we have no way, without bringing in other SRFIs,
		      ;; to make sure the following doesn't print anything,
		      ;; but it shouldn't:
		      (test-with-runner
		       (test-runner-create)
		       (lambda ()
			 (test-begin "a")
			 (test-assert #t)             ; pass
			 (test-assert #f)             ; fail
			 (test-assert (vector-ref '#(3) 10))  ; fail with error
			 (test-end "a")))
		      (eq? (test-runner-factory) test-runner-null))))
      
      (test-end)

      (test-begin "8.4. test-runner-create")
      (test-end)

      (test-begin "8.5. test-runner-factory")
      (test-end)

      (test-begin "8.6. test-apply")
      (test-equal "8.6.1. Simple (form 1) test-apply"
		  '(("w" "p" "v") () () () ("x") (3 0 0 0 1))
		  (triv-runner
		   (lambda ()
		     (test-begin "a")
		     (test-assert "w" #t)
		     (test-apply
		      (test-match-name "p")
		      (lambda ()
			(test-begin "p")
			(test-assert "x" #t)
			(test-end)
			(test-begin "z")
			(test-assert "p" #t)  ; only this one should execute in here
			(test-end)))
		     (test-assert "v" #t))))

      (test-equal "8.6.2. Simple (form 2) test-apply"
		  '(("w" "p" "v") () () () ("x") (3 0 0 0 1))
		  (triv-runner
		   (lambda ()
		     (test-begin "a")
		     (test-assert "w" #t)
		     (test-apply
		      (test-runner-current)
		      (test-match-name "p")
		      (lambda ()
			(test-begin "p")
			(test-assert "x" #t)
			(test-end)
			(test-begin "z")
			(test-assert "p" #t)  ; only this one should execute in here
			(test-end)))
		     (test-assert "v" #t))))

      (test-expect-fail 1) ;; depends on all test-match-nth being called.
      (test-equal "8.6.3. test-apply with skips"
		  '(("w" "q" "v") () () () ("x" "p" "x") (3 0 0 0 3))
		  (triv-runner
		   (lambda ()
		     (test-begin "a")
		     (test-assert "w" #t)
		     (test-skip (test-match-nth 2))
		     (test-skip (test-match-nth 4))
		     (test-apply
		      (test-runner-current)
		      (test-match-name "p")
		      (test-match-name "q")
		      (lambda ()
                                        ; only execute if SKIP=no and APPLY=yes
			(test-assert "x" #t)  ; # 1 SKIP=no  APPLY=no
			(test-assert "p" #t)  ; # 2 SKIP=yes APPLY=yes
			(test-assert "q" #t)  ; # 3 SKIP=no  APPLY=yes
			(test-assert "x" #f)  ; # 4 SKIP=yes APPLY=no
			0))
		     (test-assert "v" #t))))

      (test-end)

      (test-begin "8.7. test-with-runner")
      (test-end)

      (test-begin "8.8. test-runner components")

      (test-equal "8.8.1. test-runner-aux-value"
		  '("x" "" "y")
		  (auxtrack-runner
		   (lambda ()
		     (test-assert "x" #t)
		     (test-begin "a")
		     (test-assert #t)
		     (test-end)
		     (test-assert "y" #f))))

      (test-end) ; 8.8

      (test-end "8. Test-runner")

      (test-begin "9. Test Result Properties")

      (test-begin "9.1. test-result-alist")

      (test-assert (symbol-alist?
		    (car (on-test-runner
			  (lambda ()
			    (test-assert #t))
			  (lambda (r)
			    (test-result-alist r))))))

      (test-assert (symbol-alist?
		    (car (on-test-runner
			  (lambda ()
			    (test-assert #t))
			  (lambda (r)
			    (test-result-alist r))))))

      (test-equal '((result-kind . pass))
		  (prop-runner
		   '(result-kind)
		   (lambda ()
		     (test-assert #t)))
		  )

      (test-equal 
       '((result-kind . fail)
	 (expected-value . 2)
	 (actual-value . 3))
       (prop-runner
	'(result-kind expected-value actual-value)
	(lambda ()
	  (test-equal 2 (+ 1 2)))))

      (test-end "9.1. test-result-alist")

      (test-begin "9.2. test-result-ref")

      (test-equal '(pass)
		  (on-test-runner
		   (lambda ()
		     (test-assert #t))
		   (lambda (r)
		     (test-result-ref r 'result-kind))))

      (test-equal '(pass)
		  (on-test-runner
		   (lambda ()
		     (test-assert #t))
		   (lambda (r)
		     (test-result-ref r 'result-kind))))

      (test-equal '(fail pass)
		  (on-test-runner
		   (lambda ()
		     (test-assert (= 1 2))
		     (test-assert (= 1 1)))
		   (lambda (r)
		     (test-result-ref r 'result-kind))))

      (test-end "9.2. test-result-ref")

      (test-begin "9.3. test-result-set!")

      (test-equal '(100 100)
		  (on-test-runner
		   (lambda ()
		     (test-assert (= 1 2))
		     (test-assert (= 1 1)))
		   (lambda (r)
		     (test-result-set! r 'foo 100)
		     (test-result-ref r 'foo))))

      (test-end "9.3. test-result-set!")

      (test-end "9. Test Result Properties")

      (test-end "SRFI 64 - Meta-Test Suite")
      
      #t)

      (define (prop-runner props thunk)
	(let ((r (test-runner-null))
	      (plist '()))
	  ;;
	  (test-runner-on-test-end!
	   r
	   (lambda (runner)
	     (set! plist (test-result-alist runner))))
	  ;;
	  (test-with-runner r (thunk))

	  (map (lambda (k)
		 (assq k plist))
	       props)))


      (define (on-test-runner thunk visit)
	(let ((r (test-runner-null))
	      (results '()))
	  ;;
	  (test-runner-on-test-end!
	   r
	   (lambda (runner)
	     (set! results (cons (visit r) results))))
	  ;;
	  (test-with-runner r (thunk))
	  (reverse results)))

      (define (triv-runner thunk)
	(let ((r (test-runner-null))
	      (accum-pass '())
	      (accum-fail '())
	      (accum-xfail '())
	      (accum-xpass '())
	      (accum-skip '()))
	  ;;
	  (test-runner-on-bad-count!
	   r
	   (lambda (runner count expected-count)
	     (error (string-append "bad count " (number->string count)
				   " but expected "
				   (number->string expected-count)))))
	  (test-runner-on-bad-end-name!
	   r
	   (lambda (runner begin end)
	     (error (string-append "bad end group name " end
				   " but expected " begin))))
	  (test-runner-on-test-end! 
	   r
	   (lambda (runner)
	     (let ((n (test-runner-test-name runner)))
	       (case (test-result-kind runner)
		 ((pass) (set! accum-pass (cons n accum-pass)))
		 ((fail) (set! accum-fail (cons n accum-fail)))
		 ((xpass) (set! accum-xpass (cons n accum-xpass)))
		 ((xfail) (set! accum-xfail (cons n accum-xfail)))
		 ((skip) (set! accum-skip (cons n accum-skip)))))))
	  ;;
	  (test-with-runner r (thunk))
	  (list (reverse accum-pass)    ; passed as expected
		(reverse accum-fail)    ; failed, but was expected to pass
		(reverse accum-xfail)   ; failed as expected
		(reverse accum-xpass)   ; passed, but was expected to fail
		(reverse accum-skip)    ; was not executed
		(list (test-runner-pass-count r)
		      (test-runner-fail-count r)
		      (test-runner-xfail-count r)
		      (test-runner-xpass-count r)
		      (test-runner-skip-count r)))))

      (define (path-revealing-runner thunk)
	(let ((r (test-runner-null))
	      (seq '()))
	  ;;
	  (test-runner-on-test-end! 
	   r 
	   (lambda (runner)
	     (set! seq (cons (list (test-runner-group-path runner)
				   (test-runner-test-name runner))
			     seq))))
	  (test-with-runner r (thunk))
	  (reverse seq)))

      (define (t)
	(triv-runner
	 (lambda ()
	   (test-assert "a" #t)
	   (test-assert "b" #f))))

      (define (with-factory-saved thunk)
	(let* ((saved (test-runner-factory))
	       (result (thunk)))
	  (test-runner-factory saved)
	  result))

      (define (choke)
	(vector-ref '#(1 2) 3))

      (define (mean x y)
	(/ (+ x y) 2.0))

      (define (auxtrack-runner thunk)
	(let ((r (test-runner-null)))
	  (test-runner-aux-value! r '())
	  (test-runner-on-test-end! r (lambda (r)
					(test-runner-aux-value!
					 r
					 (cons (test-runner-test-name r)
					       (test-runner-aux-value r)))))
	  (test-with-runner r (thunk))
	  (reverse (test-runner-aux-value r))))

      (define (symbol-alist? l)
	(if (null? l)
	    #t
	    (and (pair? l)
		 (pair? (car l))
		 (symbol? (caar l))
		 (symbol-alist? (cdr l)))))))
