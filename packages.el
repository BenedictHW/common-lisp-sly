;;; packages.el --- Common Lisp Layer packages File for Spacemacs
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


(defconst common-lisp-sly-packages
  '(
    auto-highlight-symbol
    evil
    evil-cleverparens
    ggtags
    helm
    helm-gtags
    rainbow-identifiers
    sly
    sly-macrostep
    ))

(defun common-lisp-sly/post-init-auto-highlight-symbol ()
  (with-eval-after-load 'auto-highlight-symbol
    (add-to-list 'ahs-plugin-bod-modes 'lisp-mode)))

(defun common-lisp-sly/init-sly-macrostep ())

(defun common-lisp-sly/post-init-evil ()
  (define-advice sly-last-expression (around evil activate)
    "In normal-state or motion-state, last sexp ends at point."
    (if (and (not evil-move-beyond-eol)
             (or (evil-normal-state-p) (evil-motion-state-p)))
        (save-excursion
          (unless (or (eobp) (eolp)) (forward-char))
          ad-do-it)
      ad-do-it)))

(defun common-lisp-sly/pre-init-evil-cleverparens ()
  (spacemacs|use-package-add-hook evil-cleverparens
    :pre-init
    (progn
      (add-to-list 'evil-lisp-safe-structural-editing-modes 'common-lisp-sly-mode)
      (add-to-list 'evil-lisp-safe-structural-editing-modes 'lisp-mode))))

(defun common-lisp-sly/post-init-helm ()
  (spacemacs/set-leader-keys-for-major-mode 'lisp-mode
    "sI" 'spacemacs/helm-sly))

(defun common-lisp-sly/post-init-ggtags ()
  (add-hook 'common-lisp-sly-mode-local-vars-hook #'spacemacs/ggtags-mode-enable))

(defun common-lisp-sly/post-init-helm-gtags ()
  (spacemacs/helm-gtags-define-keys-for-mode 'common-lisp-sly-mode))

(defun common-lisp-sly/post-init-rainbow-identifiers ()
  (add-hook 'lisp-mode-hook #'colors//rainbow-identifiers-ignore-keywords))

(defun common-lisp-sly/init-sly ()
  (use-package sly
    :commands sly-mode
    :init
    (progn
      (spacemacs/register-repl 'sly 'sly)
      (setq inferior-lisp-program "sbcl")
      ;; enable fuzzy matching in code buffer and SLY REPL
      (global-company-mode)
      ;; This is set so evil keybindings do not override sly-mode-map-init
      (evil-set-initial-state 'sly-db-mode 'emacs)
      ;; (add-hook 'sly-mrepl-mode-hook #'spacemacs//deactivate-smartparens)
      (spacemacs/add-to-hooks 'sly-mode '(lisp-mode-hook))
      )
    :config
    (progn
      ;; TODO: Add bindings for the SLY debugger?
      (spacemacs/set-leader-keys-for-major-mode 'lisp-mode
        "'" 'spacemacs/sly-mrepl-dwim

        "cc" 'sly-compile-file
        "cC" 'sly-compile-and-load-file
        "cl" 'sly-load-file
        "cf" 'sly-compile-defun
        "cr" 'sly-compile-region
        "cn" 'sly-remove-notes

        "ds" 'sly-stickers-dwim
        "dS" 'sly-stickers-replay

        "eb" 'sly-eval-buffer
        "ef" 'sly-eval-defun
        "eF" 'sly-undefine-function
        "ee" 'sly-eval-last-expression
        "el" 'spacemacs/sly-eval-sexp-end-of-line
        "er" 'sly-eval-region

        "gb" 'sly-pop-find-definition-stack
        "gn" 'sly-next-note
        "gN" 'sly-previous-note

        "ha" 'sly-apropos
        "hA" 'sly-apropos-all
        "hd" 'sly-disassemble-symbol
        "hh" 'sly-describe-symbol
        "hH" 'sly-hyperspec-lookup
        "hi" 'sly-inspect-definition
        "hp" 'sly-apropos-package
        "ht" 'sly-trace-dialog
        "hT" 'sly-untrace-all
        "h<" 'sly-who-calls
        "h>" 'sly-calls-who
        ;; TODO: Add key bindings for who binds/sets globals?
        "hr" 'sly-who-references
        "hm" 'sly-who-macroexpands
        "hs" 'sly-who-specializes

        "ma" 'sly-macroexpand-all
        "mo" 'sly-macroexpand-1

        "se" 'sly-eval-last-expression-in-repl
        "si" 'sly
        "sq" 'sly-quit-lisp

        "Tf" 'sly-toggle-fancy-trace
        "Tt" 'sly-trace-dialog-toggle-trace

        ;; Add key bindings for custom eval functions
        "ec" 'spacemacs/cl-eval-current-form-sp
        "eC" 'spacemacs/cl-eval-current-form
        "es" 'spacemacs/cl-eval-current-symbol-sp)

      ;; prefix names for which-key
      (mapc (lambda (x)
              (spacemacs/declare-prefix-for-mode 'lisp-mode (car x) (cdr x)))
            '(("mh" . "help")
              ("me" . "eval")
              ("ms" . "repl")
              ("mc" . "compile")
              ("mg" . "nav")
              ("mm" . "macro")
              ("mT" . "toggle")))
      ;; change default value from slime to sly. Org babel is distributed under
      ;; org-contrib as ob-*lang*.el
      (with-eval-after-load "ob-lisp"
        (setq org-babel-lisp-eval-fn #'sly-eval))
      (with-eval-after-load "poly-org"
        ;; sly-compile-file sends entire .org file. Narrow to span as done in poly-R
        ;; https://github.com/polymode/poly-org/issues/25
        (when (fboundp 'advice-add)
          (advice-add 'sly-compile-file :around 'pm-execute-narrowed-to-span)
          (advice-add 'sly-compile-defun :around 'pm-execute-narrowed-to-span)
          (advice-add 'sly-load-file :around 'pm-execute-narrowed-to-span)
          (advice-add 'sly-eval-defun :around 'pm-execute-narrowed-to-span)
          (advice-add 'sly-eval-last-expression :around 'pm-execute-narrowed-to-span)
          (advice-add 'sly-eval-buffer :around 'pm-execute-narrowed-to-span)))
      )))
