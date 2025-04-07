;;; cil-mode.el --- Major mode for editing cil files
;; A basic major mode for the cil language, developed at https://github.com/jtimon/cil.

(defconst cil-mode-syntax-table
  (with-syntax-table (copy-syntax-table)
    ;; Comments: // and #
    (modify-syntax-entry ?/ ". 124b")
    (modify-syntax-entry ?# "< b")
    (modify-syntax-entry ?\n "> b")
    ;; Strings
    (modify-syntax-entry ?\" "\"")
    ;; Punctuation
    (modify-syntax-entry ?: ".")
    (modify-syntax-entry ?= ".")
    (modify-syntax-entry ?( "()")
    (modify-syntax-entry ?) ")(")
    (modify-syntax-entry ?{ "(}")
    (modify-syntax-entry ?} "){")
    (modify-syntax-entry ?, ".")
    (syntax-table))
  "Syntax table for `cil-mode'.")

(defconst cil-keywords
  '("mode" "mut" "struct" "enum" "func" "proc" "ext_func" "ext_proc" "macro" "return" "returns" "if" "else" "while" "switch" "case"))

(defconst cil-highlights
  `((,(regexp-opt cil-keywords 'symbols) . font-lock-keyword-face)))

(defun cil-indent-line ()
  "Indent current line as cil code."
  (interactive)
  (let ((indent-col 0))
    (save-excursion
      (beginning-of-line)
      (cond
       ;; Closing brace: align with its opening brace
       ((looking-at-p "[ \t]*}")
        (condition-case nil
            (progn
              (backward-up-list 1) ; Move to matching {
              (setq indent-col (current-indentation)))
          (error (setq indent-col 0))))
       ;; Case statement: align with enclosing switch
       ((looking-at-p "[ \t]*case")
        (condition-case nil
            (progn
              (backward-up-list 1) ; Move to enclosing {
              (setq indent-col (current-indentation))) ; Use switch's indent
          (error (setq indent-col 0))))
       ;; Other lines: indent based on open braces
       (t
        (condition-case nil
            (while t
              (backward-up-list 1)
              (when (looking-at "{")
                (setq indent-col (+ indent-col 4))))
          (error nil)))))
    (indent-line-to indent-col)))

(define-derived-mode cil-mode prog-mode "cil"
  "Major Mode for editing cil source code."
  :syntax-table cil-mode-syntax-table
  (setq font-lock-defaults '(cil-highlights))
  (setq indent-line-function 'cil-indent-line)
  (setq-local indent-tabs-mode nil)        ; Use spaces, not tabs
  (setq-local tab-width 4)                 ; Set tab width to 4 spaces
  (setq-local comment-start "// ")         ; Default comment prefix for region commenting
  (setq-local comment-start-skip "//+\\s-*") ; Only recognize // for highlighting and commenting
  (setq-local comment-end "")              ; Single-line comments, no end delimiter
  (setq-local comment-multi-line nil))     ; Enforce single-line comment style

(add-to-list 'auto-mode-alist '("\\.cil\\'" . cil-mode))

(provide 'cil-mode)
