;;; wisp-mode.el --- Major mode for Wisp code.

;; Copyright 2013 Kris Jenkins

;; Author: Kris Jenkins <krisajenkins@gmail.com>
;; Maintainer: Kris Jenkins <krisajenkins@gmail.com>
;; Author: Kris Jenkins
;; URL: https://github.com/krisajenkins/wisp-mode
;; Created: 18th April 2013
;; Version: 0.1.0
;; Package-Requires: ((clojure-mode "0") (nrepl-eval-sexp-fu "0"))

;;; Commentary:
;;
;; A major mode for the Lisp->JavaScript language Wisp: http://jeditoolkit.com/wisp/

(require 'clojure-mode)
(require 'nrepl-eval-sexp-fu)
(require 'font-lock)

;;; Code:
(defgroup wisp nil
  "A major mode for wisp"
  :group 'languages)

(defadvice lisp-eval-region (around lisp-eval-region-flash activate)
  "Flash any calls to lisp-eval-region (and the functions that depend on it, like lisp-eval-defun)."
  (let* ((start (ad-get-arg 0))
		 (end (ad-get-arg 1))
		 (flasher (nrepl-eval-sexp-fu-flash (cons start end)))
		 (hi (cadr flasher))
		 (unhi (caddr flasher)))
	(nrepl-eval-sexp-fu-flash-doit-simple '(lambda () ad-do-it) hi unhi)))

(defmacro wispscript-mode/add-word-chars (&rest chars)
  "Convenient way to add many word-constituent characters to the syntax table.

Optional argument CHARS Characters to add to the syntax table."
  (cons 'progn
        (mapcar (lambda (char)
                  `(modify-syntax-entry ,char "w" wisp-mode-syntax-table))
                chars)))

;;;###autoload
(define-derived-mode wisp-mode clojure-mode "Wisp"
  "Major mode for Wisp"
  (wispscript-mode/add-word-chars ?_ ?~ ?. ?- ?> ?< ?! ??)
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
