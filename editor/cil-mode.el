;;; cil-mode.el --- Major mode for editing cil files
;; A basic major mode for the cil language, developed at https://github.com/jtimon/cil.
;; This file was mostly generated using grok

(defconst cil-mode-syntax-table
  (with-syntax-table (copy-syntax-table)
    (modify-syntax-entry ?/ ". 124b")
    (modify-syntax-entry ?# "< b")
    (modify-syntax-entry ?\n "> b")
    (modify-syntax-entry ?\" "\"")
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

(defconst cil-highlights
  `(;; Keywords
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
    ;; Constant arguments (no 'mut', in function signatures)
    ("\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*:\\s-*[a-zA-Z_][a-zA-Z0-9_]*\\s-*[,)]" 1 font-lock-constant-face)
    ;; Inferred constants (no 'mut', with ':=')
    ("\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*:=\\s-*" 1 font-lock-constant-face)
    ;; WIP Inferred constants (no 'mut', with ': =', ie with spaces inbetween the ':' and the '=')
    ;; ("\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*: *\\s*=\\s-*" 1 font-lock-constant-face)
    ;; ("\\<\\(?!mut\\s-+\\)\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*:\\s*=\\s-*[0-9]+\\|\"[^\"]*\"\\|'[^']*'\\|true\\|false" 1 font-lock-constant-face)
    ;; WIP Non inferred constants (no 'mut', with : type '=')
    ;; ("\\<\\(?!mut\\s-+\\)\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*:\\s-*[a-zA-Z_][a-zA-Z0-9_]*\\s-*=\\s-*[0-9]+\\|\"[^\"]*\"\\|'[^']*'\\|true\\|false" 1 font-lock-constant-face)
    ;; TODO Enum values as constants
))

(defun cil-indent-line ()
  "Indent current line as cil code."
  (interactive)
  (beginning-of-line)
  (let ((not-indented t)
        (cur-indent 0))
    (while not-indented
      (cond
       ((looking-at "^[ \t]*}") ; Closing brace
        (save-excursion
          (backward-up-list 1)
          (setq cur-indent (current-indentation)))
        (indent-line-to cur-indent)
        (setq not-indented nil))
       ((looking-at "^[ \t]*case") ; Case statement
        (save-excursion
          (backward-up-list 1)
          (setq cur-indent (current-indentation)))
        (indent-line-to cur-indent)
        (setq not-indented nil))
       ((looking-at "^[ \t]*{") ; Opening brace (shouldn't happen at start, but handle it)
        (indent-line-to cur-indent)
        (setq not-indented nil))
       (t
        (save-excursion
          (condition-case nil
              (progn
                (backward-up-list 1)
                (when (looking-at "{")
                  (setq cur-indent (+ (current-indentation) 4))))
            (error (setq cur-indent 0)))
          (indent-line-to cur-indent)
          (setq not-indented nil)))))))

(define-derived-mode cil-mode prog-mode "cil"
  "Major Mode for editing cil source code."
  :syntax-table cil-mode-syntax-table
  (setq font-lock-defaults '(cil-highlights))
  (setq indent-line-function 'cil-indent-line)
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (setq-local comment-start "// ")
  (setq-local comment-start-skip "//+\\s-*")
  (setq-local comment-end "")
  (setq-local comment-multi-line nil))

(add-to-list 'auto-mode-alist '("\\.cil\\'" . cil-mode))

(provide 'cil-mode)
