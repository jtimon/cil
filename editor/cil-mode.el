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
  '("mode" "mut" "struct" "enum" "func" "proc"
    "ext_func" "ext_proc" "macro" "return" "returns"
    "if" "else" "while" "switch" "case" "true" "false"))

(defconst cil-types
  '("i64" "bool" "String"))

(defconst cil-builtins
  '("and" "or" "not" "eq" "str_eq" "concat" "str_len"
    "str_get_substr" "lt" "lteq" "gt" "gteq" "add" "sub"
    "mul" "div" "atoi" "itoa" "eval_to_str" "exit" "import"
    "input_read_line" "print" "println" "readfile" "runfile"))

(defconst cil-error-words
  '("static" "var" "const" "global" "fn" "function" "try" "catch" "throw" "throws")
  "Words that are invalid in cil and should be highlighted as errors.")

(defconst cil-highlights
  `(;; Error words
    (,(regexp-opt cil-error-words 'symbols) . compilation-error)
    ;; Keywords
    (,(regexp-opt cil-keywords 'symbols) . font-lock-keyword-face)
    ;; Built-in Types
    (,(regexp-opt cil-types 'symbols) . font-lock-type-face)
    ;; Builtins
    (,(regexp-opt cil-builtins 'symbols) . font-lock-builtin-face)
    ;; Type declarations: 'enum' and 'struct'
    ("\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*:=\\s-*\\(enum\\|struct\\)" 1 font-lock-type-face)
    ;; Assignments (mutable variables)
    ("\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*=\\s-*[^:=]" 1 font-lock-variable-name-face)
    ;; Types in declarations, signatures, and enum variants
    ("\\<\\(mut\\s-+\\|case\\s-+\\)?\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*:\\s-*\\([a-zA-Z_][a-zA-Z0-9_]*\\)" 3 font-lock-type-face)
    ("\\<returns\\s-+\\([a-zA-Z_][a-zA-Z0-9_]*\\)" 1 font-lock-type-face)
    ;; Function and procedure names
    ("\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*:=\\s-*\\(func\\|proc\\|macro\\|ext_func\\|ext_proc\\)" 1 font-lock-function-name-face)
    ;; Mutable variables and arguments (anything after 'mut')
    ("\\<mut\\s-+\\([a-zA-Z_][a-zA-Z0-9_]*\\)" 1 font-lock-variable-name-face)

    ;; Case identifiers: identifiers between 'case' and ':' (e.g., 'field' in 'case my_struct.field:'), treated as regular code
    ("\\<case\\s-+\\(?:[a-zA-Z_][a-zA-Z0-9_]*\\.\\)*\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*:" 1 default)

    ;; Constants: identifiers before ':' (in declarations or signatures), overridden by 'mut' rule
    ("\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*:" 1 font-lock-constant-face)

    ;; WIP Enum variants: identifiers in enum blocks (e.g., 'Variant1', 'Variant2' in 'MyEnum := enum { Variant1, Variant2 }')
    ;; ("\\<enum\\s-*{\\(?:[^}]*\\)?\\([a-zA-Z_][a-zA-Z0-9_]*\\)" 1 font-lock-constant-face)
))

(defun cil-indent-line ()
  "Indent current line as cil code using 4 spaces."
  (interactive)
  (let ((indent 0))
    (save-excursion
      (beginning-of-line)
      (skip-chars-forward " \t")
      (cond
       ;; Case statements: align with parent switch
       ((looking-at-p "\\<case\\>")
        (condition-case nil
            (progn
              (backward-up-list 1)
              (when (looking-back "\\<switch\\s-+[^}]*{" nil)
                (setq indent (current-indentation))))
          (error (setq indent 0))))
       ;; Closing brace: align with parent block
       ((looking-at-p "[ \t]*}")
        (condition-case nil
            (progn
              (backward-up-list 1)
              (setq indent (current-indentation)))
          (error (setq indent 0))))
       ;; Other lines: indent based on open blocks or parentheses
       (t
        (condition-case nil
            (progn
              (backward-up-list 1)
              (setq indent (+ (current-indentation) 4)))
          (error (setq indent 0))))))
    ;; Apply indentation
    (beginning-of-line)
    (delete-horizontal-space)
    (indent-to indent)))

(define-derived-mode cil-mode prog-mode "cil"
  "Major Mode for editing cil source code."
  :syntax-table cil-mode-syntax-table
  (setq font-lock-defaults '(cil-highlights))
  (setq indent-line-function 'cil-indent-line)
  (setq-local indent-tabs-mode nil)          ; Use spaces, not tabs
  (setq-local tab-width 4)                   ; Set tab width to 4 spaces
  (setq-local comment-start "// ")           ; Default comment prefix for region commenting
  (setq-local comment-start-skip "//+\\s-*") ; Only recognize // for highlighting and commenting
  (setq-local comment-end "")                ; Single-line comments, no end delimiter
  (setq-local comment-multi-line nil))       ; Enforce single-line comment style

(add-to-list 'auto-mode-alist '("\\.cil\\'" . cil-mode))

(provide 'cil-mode)
