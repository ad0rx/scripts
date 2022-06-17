;;
;; To Use
;;
;; M-x scp-set-file-url
;; enter path on bubba
;; new buffer opens
;; M-x scp-mode
;; now any saves/writes will 'put' the file on bubba
;;
;;
;; Issues
;;
;; on buffer close, scp-close or similar to kill scp-process
;; i think we need a way to clear scp-process and scp-file-url variables
;; when changing buffers
;;
;; maybe scp-close remove local copy
;;
;; Todo
;; parsable string for file url includeing hostname and port?
;; consider txn queue https://www.gnu.org/software/emacs/manual/html_node/elisp/Transaction-Queues.html
;;
;; (load "C:/Users/bwhitlock/Documents/Scripts/scp.el")
;; /mnt/projects/documents/01_standard_storage/notebooks/trip.org

(setq scp-winscp-prompt nil)

(defvar scp-local-file-backup ""
  "File name for backup of file")

(defvar scp-local-file ""
  "Local file name; full path")

(defvar scp-temp-dir "C:/winscpTemp"
  "Dir where we store local copies of files")

(defvar scp-process 0
  "")

(defvar scp-file-url ""
  "")

(setq scp-host-port-hostkey-alist
      '(("bubba"
         "65534"
         "ssh-ed25519 255 z7+9zYNGAZclCUXbVhzfEF9L+v8Rbo\
VmeMkkSa0yRrw=")

        ("plap"
         "65534"
         "")

        ))

(defun scp-get-port-alist (host alist)
  ""
  (cadr (assoc host alist)))

(defun scp-get-hostkey-alist (host alist)
  ""
  (caddr (assoc host alist)))

(defun scp-process-send-string (process string &optional continue)
  "Wrapper which keeps us in sync with winscp"

  ;; Clear the flag
  (setq scp-winscp-prompt nil)

  ;; Send the string
  (process-send-string process string)

  ;; Wait for prompt
  ;; set to true by filter function
  (unless continue
    (while (not scp-winscp-prompt)
      (accept-process-output scp-process 1 nil nil)))
    )

(defun scp-start-winscp ()
  "Start the winscp async process"
  (interactive)
  (setq scp-process
        (make-process
         :name   "winscp"
         :buffer "winscpb"
         :command  (list "C:/Program Files (x86)/WinSCP/WinSCP.com")
         :filter 'scp-filter
         ))

  (make-local-variable 'scp-process)

  )

(defun scp-open ()
  ""
  (interactive)

  (scp-process-send-string
   scp-process
   (concat
    "open"
    " sftp://bwhitlock@"
    "bubba:"
    (scp-get-port-alist "bubba" scp-host-port-hostkey-alist)
    "/ -hostkey=\""
    (scp-get-hostkey-alist "bubba" scp-host-port-hostkey-alist)
    "\"\n"))

  ;; Disable confirmations
  (scp-process-send-string
   scp-process
   "option confirm off\n")
  )

;; From elisp manual
(defun scp-filter (proc string)
  (when (buffer-live-p (process-buffer proc))
    ;;(display-buffer (process-buffer proc))
    (with-current-buffer (process-buffer proc)
      (let ((moving (= (point) (process-mark proc))))
        (save-excursion
          ;; Insert the text, advancing the process marker.
          (goto-char (process-mark proc))
          (insert string)
          (set-marker (process-mark proc) (point))

          (if (string= "winscp> "
                       (buffer-substring (- (point) 8) (point)))
              (setq scp-winscp-prompt t))

          )
        (if moving (goto-char (process-mark proc)))))))

(defun scp-close ()
  ""
  (interactive)

  (scp-process-send-string
   scp-process
   "exit\n" t)

  ;; wait a bit for process to exit cleanly
  (while (process-live-p scp-process)
    (accept-process-output scp-process 1 nil t)
    )

  (delete-process scp-process)
  (setq scp-process nil)

  ;; rename local copy as backup
  (setq scp-local-file-backup
        (concat
         (buffer-file-name)
         ".bak"))

  (rename-file (buffer-file-name) scp-local-file-backup t)
  (kill-buffer (current-buffer))

  )

(defun scp-put-file ()
  "put the file"
  (interactive)

  ;; Currently, this function is added to the after-save-hook, which
  ;; runs on every buffer, regardless of type. I'd like to set this
  ;; hook to be buffer local but haven't figured that out yet.  For
  ;; now, check that scp-mode is set on the buffer before put the
  ;; file.
  (if scp-mode
      (progn

        (scp-process-send-string
         scp-process
         (concat
          "cd "
          (file-name-directory scp-file-url)
          "\n"))

        (scp-process-send-string
         scp-process
         (concat "put "
                 (file-name-nondirectory scp-file-url)
                "\n")))
    )
  )

(defun scp-get-file ()
  "get the file"
  (interactive)

  (scp-process-send-string
   scp-process
   (concat "lcd "
           scp-temp-dir
           "\n"))

  (scp-process-send-string
   scp-process
   (concat "get "
           scp-file-url
           "\n"))

  ;; Read file size once every 100ms, and if same size
  ;; times then call it good. this is terrible...
  (setq last -1)
  (setq curr 0)
  (while (not (= last curr))
    (sleep-for 0.010)
    ;;(message "last: %d" last)
    ;;(message "curr: %d" curr)
    (setq last curr)
    (setq curr (file-attribute-size (file-attributes scp-local-file)))
    )

  )

(defun scp-test ()
  ""
  (interactive)

  (scp-mode)
  (save-excursion
    (set-buffer (get-buffer-create "winscpb"))
    (make-frame))

  (scp-set-file-url "/mnt/projects/documents/01_standard_storage/notebooks/trip.org")

  )


(defun scp-set-file-url (str)
  "Prompt user for file URL and set 'scp-file-url local var"
  (interactive "sURL: ")

  (setq scp-file-url str)

  (scp-start-winscp)
  (scp-open)
  (scp-get-file)

  ;; Generate the local file path
  (setq scp-local-file
        (concat
         scp-temp-dir "/"
         (file-name-nondirectory scp-file-url)))

  (find-file scp-local-file)

  ;; I FINALLY FOUND THE ANSWER!!
  ;; so, since the line above creates a new buffer, need to 'turn
  ;; on' scp-mode.
  (scp-mode)
)

(define-minor-mode scp-mode ()
  "scp mode TBD"
  :init-value nil
  :lighter " scp"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c f") 'scp-set-file-url)
            map)

  (add-hook 'after-save-hook 'scp-put-file t)
  )
