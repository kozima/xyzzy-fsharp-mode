;;; -*- Mode: Lisp; Package: EDITOR -*-

;; this file is based on caml-mode.l: http://www9.ocn.ne.jp/~y-kwsk/luvtechno/xyzzy.html 

(provide "fsharp")

(in-package "editor")

(export '(fsharp-mode fsharp-comment-region fsharp-uncomment-region
          *fsharp-keyword-file* *fsharp-mode-hook*
	  *fsharp-mode-syntax-table* *fsharp-mode-map*
	  *fsharp-mode-abbrev-table* *fsharp-comment-column*
          *fsharp-indent-tabs-mode*))

(defvar *fsharp-mode-hook* nil)
(defvar *fsharp-mode-map* nil)
(unless *fsharp-mode-map*
  (setq *fsharp-mode-map* (make-sparse-keymap)))

(defvar *fsharp-keyword-hash-table* nil)
(defvar *fsharp-keyword-file* "F#")

(defvar *fsharp-mode-syntax-table* nil)
(unless *fsharp-mode-syntax-table*
  (setf *fsharp-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *fsharp-mode-syntax-table* c))))
  (set-syntax-symbol *fsharp-mode-syntax-table* #\_)
  (set-syntax-symbol *fsharp-mode-syntax-table* #\')
  (set-syntax-string *fsharp-mode-syntax-table* #\")
  (set-syntax-match *fsharp-mode-syntax-table* #\( #\))
  (set-syntax-match *fsharp-mode-syntax-table* #\[ #\])
  (set-syntax-match *fsharp-mode-syntax-table* #\{ #\})
  (set-syntax-start-multi-comment *fsharp-mode-syntax-table* "(*")
  (set-syntax-end-multi-comment *fsharp-mode-syntax-table* "*)")
  (set-syntax-start-c++-comment *fsharp-mode-syntax-table* #\/)
  (set-syntax-end-c++-comment *fsharp-mode-syntax-table* #\LFD)
  )


(defvar *fsharp-mode-abbrev-table* nil)
(unless *fsharp-mode-abbrev-table*
  (define-abbrev-table '*fsharp-mode-abbrev-table*))

(defvar *fsharp-comment-column* nil)

(defvar *fsharp-indent-tabs-mode* nil)

(defun fsharp-comment-region (start end &optional arg)
  (interactive "*r\nP")
  (if arg
      (fsharp-uncomment-region start end)
      (save-excursion
        (save-restriction
          (narrow-to-region start end)
          (goto-char (point-min))
          (loop
            (when (save-excursion (skip-syntax-spec-forward " ") (not (eolp)))
              (insert comment-start))
            (unless (and (forward-line 1) (not (eobp))) (return)))))))

(defun fsharp-uncomment-region (start end)
  (interactive "*r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (skip-syntax-spec-forward " ")
      (loop
        (if (looking-for comment-start) (delete-char (length comment-start)))
        (unless (and (forward-line 1) (not (eobp))) (return))))))

(defun fsharp-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'fsharp-mode)
  (setq mode-name "F#")
  (use-keymap *fsharp-mode-map*)
  (use-syntax-table *fsharp-mode-syntax-table*)
  (and *fsharp-keyword-file*
       (null *fsharp-keyword-hash-table*)
       (setq *fsharp-keyword-hash-table*
             (load-keyword-file *fsharp-keyword-file*)))
  (when *fsharp-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *fsharp-keyword-hash-table*))
  (make-local-variable 'indent-tabs-mode)
  (setf indent-tabs-mode *fsharp-indent-tabs-mode*)
  (setf comment-start "//")
  (setf comment-end "")
  (setf comment-start-skip "//[ \t]*")
  (run-hooks '*fsharp-mode-hook*))


