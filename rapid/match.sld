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

;;> A pattern matcher.

(define-library (rapid match)
  (import
    (rename (scheme base) (|...| ellipsis))
    (except (scheme base) |...|)
    (rapid assume))

  (cond-expand
    (guile
     (export
      match match* |->| unquote guard
      ))
    (else
     (export
      match match* |->| unquote guard
      (rename ellipsis |...|)
      ))
    )

  (cond-expand
    (guile (include "match.scm"))
    (stklos (include "./rapid/match.scm"))
    (gambit
     ;; Gambit's "syntax-rules" is not R7RS-compliant, load a modified
     ;; version of the pattern matcher
     (include "match-gambit.scm")
     )
    (else (include "match.scm"))
    ))


;; Local Variables:
;; eval: (put 'match 'scheme-indent-function 1)
;; eval: (put 'match* 'scheme-indent-function 2)
;; eval: (font-lock-add-keywords 'scheme-mode
;;                               '(("(\\(match\\)\\>" 1 font-lock-keyword-face)
;;                                 ("(\\(match\\*\\)\\>" 1 font-lock-keyword-face)))
;; End:
