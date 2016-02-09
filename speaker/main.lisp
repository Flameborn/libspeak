; -------------------------------------------------------------
; Edward Alan Puccini 16.01.2016
; -------------------------------------------------------------
; Speaker library make and loader
; -------------------------------------------------------------
; file: main.lisp 
; -------------------------------------------------------------
; make - compile, load and run
; Compile this file and every other needed file gets compiled.
; On error check path in compile-files
; -------------------------------------------------------------
; Requirements: cffi
; -------------------------------------------------------------

(in-package :speaker)

(require 'bordeaux-threads)

;; Example application

(cffi:defcallback wsw-callback :void ((text :string))
  (print "Called back and word spoken: ~A!~%" text))

(cffi:defcallback wsp-callback :void ((op-code :short))
  (format t  "Called back and phoneme spoke (op-code: ~D)!~%" op-code))

(cffi:defcallback dfs-callback :void ()
  (print "Called back and did finish!"))

(cffi:defcallback drc-callback :void ((text :string))
  (format t "Called back and did recognize: ~A." text))

(enable-async-syntax)

(defun speaker-test (speaker)
  ;; -------------------------------
  ;;
  ;; Examples with plain c interface
  ;; 
  (print "Start speaker...")
  ;; (init-speaker)
  ;; (format t "Available-voices: ~D~%" (available-voices-count))
  ;; (format t "Get-voice(~D): ~A~%" (get-voice-name 6) "")
  ;; (sleep 1)
  ;; (speak "Guten Morgen.")
  ;; (sleep 2)
  ;; (set-voice 2)
  ;; (speak "Hello world?")
  ;; (cleanup-speaker)
  ;; (sleep 2)
  ;(make-speaker nil)           ;; error test
  ;(speak-with nil "Text")      ;; "
  ;; -------------------------------
  ;;
  ;; Examples with wrapper of 
  ;; objective-c implementation
  ;;
  (register-will-speak-word-callback speaker (cffi:callback wsw-callback))
  (register-will-speak-phoneme-callback speaker (cffi:callback wsp-callback))
  (register-did-finish-speaking-callback speaker (cffi:callback dfs-callback))
  (set-voice-with speaker 11)
  (speak-with speaker "Hallo Edward.")
  (sleep 2)
  (set-voice-with speaker 7)
  (speak-with speaker "This is voice 7.")
  (sleep 3)
  (set-voice-with speaker 19)
  (speak-with speaker "Another voice is speaking 59.")
  (cleanup-with speaker))

(defun listener-test (listener)
  (add-command listener "hey")
  (add-command listener "run")
  (add-command listener "test")
  (register-did-recognize-command-callback listener (cffi:callback drc-callback))
  (start-listening listener)
  (print "Start listening")
  (sleep 5)
  (print "End listening")
  (stop-listening listener))

(defun main ()
    (let ((listener (make-listener))
		  (speaker (make-speaker)))
	  °(listener-test listener)
;;	  °(speaker-test speaker)
	  (loop for x from 0 to 10 do
		   (mainloop-listener listener))))
;;		   (mainloop-speaker speaker))))

(main)

