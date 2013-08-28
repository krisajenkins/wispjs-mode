;;; wisp-mode.el --- Major mode for Wisp code.

;; Copyright 2013 Kris Jenkins

;; Author: Kris Jenkins <krisajenkins@gmail.com>
;; Maintainer: Kris Jenkins <krisajenkins@gmail.com>
;; Author: Kris Jenkins
;; URL: https://github.com/krisajenkins/wisp-mode
;; Created: 18th April 2013
;; Version: 0.1.0
;; Package-Requires: ((clojure-mode "0"))

;;; Commentary:
;;
;; A major mode for the Lisp->JavaScript language Wisp: http://jeditoolkit.com/wisp/

(require 'clojure-mode)
(require 'font-lock)

;;; Code:

;;;###autoload
(define-derived-mode wisp-mode clojure-mode "Wisp"
  "Major mode for Wisp"
  (dolist '(lambda (char)
	     (modify-syntax-entry char "w" wisp-mode-syntax-table))
    '(?_ ?~ ?. ?- ?> ?< ?! ??))
  (add-to-list 'comint-prompt-regexp "=>")
  (add-to-list 'comint-preoutput-filter-functions (lambda (output)
						    (replace-regexp-in-string "\033\\[[0-9]+[GJK]" "" output)))
  (set (make-local-variable 'inferior-lisp-program) "wisp"))

;;;###autoload
(add-to-list 'auto-mode-alist (cons "\\.wisp\\'" 'wisp-mode))

;;;###autoload
(defun wisp-mode/compile ()
  "Invoke the Wisp compiler for the current buffer."
  (interactive)
  (let ((output-name (format "%s.js" (file-name-sans-extension (file-relative-name buffer-file-name)))))
	(shell-command-on-region (point-min)
							 (point-max)
							 "wisp"
							 output-name)
	(with-current-buffer (get-buffer output-name)
	  (save-buffer)))
  (message "Compiled."))

(provide 'wisp-mode)
;;; wisp-mode.el ends here
