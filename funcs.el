;;; funcs.el --- Sly Layer functions File for Spacemacs
;;
;; Copyright (c) 2012-2021 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.



;; Helm integration

(defun spacemacs//sly-helm-source (&optional table)
  (or table (setq table sly-lisp-implementations))
  `((name . "Sly")
    (candidates . ,(mapcar #'car table))
    (action . (lambda (candidate)
                (car (helm-marked-candidates))))))

(defun spacemacs/helm-sly ()
  (interactive)
  (let ((command (helm :sources (spacemacs//sly-helm-source))))
    (and command (sly (intern command)))))


;; Evil integration

(defun spacemacs/sly-eval-sexp-end-of-line ()
  "Evaluate current line."
  (interactive)
  (move-end-of-line 1)
  (sly-eval-last-expression))



;; Functions are taken from the elisp layer `eval-last-sexp' was replaced with
;; its sly equivalent `sly-eval-last-expression'

(defun spacemacs/cl-eval-current-form ()
  "Find and evaluate the current def* or set* command.
Unlike `eval-defun', this does not go to topmost function."
  (interactive)
  (save-excursion
    (search-backward-regexp "(def\\|(set")
    (forward-list)
    (call-interactively 'sly-eval-last-expression)))


(defun spacemacs/cl-eval-current-form-sp (&optional arg)
  "Call `eval-last-sexp' after moving out of one level of
parentheses. Will exit any strings and/or comments first.
An optional ARG can be used which is passed to `sp-up-sexp' to move out of more
than one sexp.
Requires smartparens because all movement is done using `sp-up-sexp'."
  (interactive "p")
  (let ((evil-move-beyond-eol t))
    ;; evil-move-beyond-eol disables the evil advices around eval-last-sexp
    (save-excursion
      (let ((max 10))
        (while (and (> max 0)
                    (sp-point-in-string-or-comment))
          (decf max)
          (sp-up-sexp)))
      (sp-up-sexp arg)
      (call-interactively 'sly-eval-last-expression))))


(defun spacemacs/cl-eval-current-symbol-sp ()
  "Call `eval-last-sexp' on the symbol around point.
Requires smartparens because all movement is done using `sp-forward-symbol'."
  (interactive)
  (let ((evil-move-beyond-eol t))
    ;; evil-move-beyond-eol disables the evil advices around eval-last-sexp
    (save-excursion
      (sp-forward-symbol)
      (call-interactively 'sly-eval-last-expression))))

(defun spacemacs/sly-mrepl-dwim ()
  "Open REPL and set PACKAGE and DIRECTORY to FILE.
Calls `sly-mrepl-sync'. If there is no current SLYNK connection,
call `sly' beforehand."
  (interactive)
  (if (sly-current-connection)
      (call-interactively 'sly-mrepl-sync)
      (call-interactively 'sly)))
