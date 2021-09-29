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
    (common-lisp-snippets :requires yasnippet)
    evil
    evil-cleverparens
    ggtags
    counsel-gtags
    helm
    helm-gtags
    rainbow-identifiers
    sly
    sly-macrostep
    ))


(defun common-lisp-sly/post-init-auto-highlight-symbol ()
  (with-eval-after-load 'auto-highlight-symbol
    (add-to-list 'ahs-plugin-bod-modes 'lisp-mode)))

(defun common-lisp-sly/init-common-lisp-snippets ())

(defun common-lisp-sly/init-sly-macrostep ())

(defun common-lisp-sly/post-init-evil ()
  (defadvice sly-last-expression (around evil activate)
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

(defun common-lisp-sly/post-init-counsel-gtags ()
  (spacemacs/counsel-gtags-define-keys-for-mode 'common-lisp-sly-mode))

(defun common-lisp-sly/post-init-helm-gtags ()
  (spacemacs/helm-gtags-define-keys-for-mode 'common-lisp-sly-mode))

(defun common-lisp-sly/post-init-rainbow-identifiers ()
  (add-hook 'lisp-mode-hook #'colors//rainbow-identifiers-ignore-keywords))

(defun common-lisp-sly/init-sly ()
  (use-package sly
    :commands sly-mode
    :init
    (progn
      ;; This is set so evil keybindings do not override sly-mode-map-init
      (evil-set-initial-state 'sly-db-mode 'emacs)
      (spacemacs/register-repl 'sly 'sly)
      (setq sly-contribs '(sly-autodoc
                           sly-fancy
                           sly-fancy-inspector
                           sly-fancy-trace
                           sly-fontifying-fu
                           sly-indentation
                           sly-mrepl
                           sly-package-fu
                           sly-profiler
                           sly-retro
                           sly-scratch
                           sly-stickers
                           sly-trace-dialog
                           sly-tramp)
            inferior-lisp-program "sbcl")
      ;; enable fuzzy matching in code buffer and SLY REPL
      (add-hook 'sly-mrepl-mode-hook #'spacemacs//deactivate-smartparens)
      (global-company-mode)
      ;; Replace default behavior. "M-p" unchanged from
      ;; "sly-mrepl-previous-input-or-button" but "M-n" for
      ;; "sly-mrepl-next-input-or-button" has been replaced by the more useful
      ;; "helm-comint-input-ring"
      (define-key sly-mrepl-mode-map (kbd "M-n") 'helm-comint-input-ring))
    :config
    (progn
      (sly-setup)
      ;; TODO: Add bindings for the SLY debugger?
      (spacemacs/set-leader-keys-for-major-mode 'lisp-mode
        "'" 'sly

        "cc" 'sly-compile-file
        "cC" 'sly-compile-and-load-file
        "cl" 'sly-load-file
        "cf" 'sly-compile-defun
        "cr" 'sly-compile-region
        "cn" 'sly-remove-notes

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
        "ht" 'sly-toggle-trace-fdefinition
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

        "tf" 'sly-toggle-fancy-trace

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
              ("mt" . "toggle")))

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
