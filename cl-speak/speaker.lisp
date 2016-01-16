; -------------------------------------------------------------
; Edward Alan Puccini 16.01.2016
; -------------------------------------------------------------
; CL-Speak cffi
; -------------------------------------------------------------
; file: speker.lisp
; -------------------------------------------------------------
; Define library exampple callbacks and c-function-wrapper
; -------------------------------------------------------------

(in-package :cl-sp)

(require 'cffi)

;; ---------------------------------
;; Setup library (platform specific)
;;----------------------------------

(define-foreign-library libspeak
  (:darwin  (:or "libspeak.dylib" "/usr/local/lib/libspeak.dylib"))
  (:windows (:or "libspeak.dll" "c:\\WINDOWS\\system32\\libspeak.dll"))
  (:unix (:or "libspeak.so" "/usr/local/lib/libspeak.so"))
  (t (:default "libspeak")))

#+darwin 
(load-foreign-library "libspeak.dylib")

#+windows 
(load-foreign-library "libspeak.dll")

#+linux
(load-foreign-library "libspeak.so")

;; -----------------------
;; Error handling
;; -----------------------

(defun cl-speak-error-handler (condition)
  (format *error-output* "~&~A~&" condition)
  (throw 'common-parse niL))

; -------------------------------------------------------------
; These function wrap basic c-functions working with
; single speakers. No objects. Designed to fast use.
; Disadvantage: no callback - only single speakers
; -------------------------------------------------------------

(defun init-with-speech (speech)
  "Initialize synth with given speech."
  (handler-case 
	  (with-foreign-string (foreign-speech speech)
		(foreign-funcall "init_with_speech" :string foreign-speech :void))
	(error (condition)
	  (format *error-output* 
			  "CL-Speak: error in 'init-with-speech': ~A~%" condition))))


(defun speak(text)
  "Speaks a lisp-string text. Initialization is needed."
  (handler-case
	  (with-foreign-strings ((foreign-text text)
							 (foreign-speech "com.apple.speech.synthesis.voice.Alex"))
		(foreign-funcall "speak" :string foreign-text :void))
	(error (condition)
	  (format *error-output* 
			  "CL-Speak: error in 'speak': ~A~%" condition))))


(defun start-speaking-string(text)
  "Wrapper for the function with the same name.
Look at documentation for 'speak'."
  (handler-case
	  (with-foreign-strings ((foreign-text text)
							 (foreign-speech "com.apple.speech.synthesis.voice.Alex"))
		
		(foreign-funcall "start_speaking_string" :string foreign-text :void))
	(error (condition)
	  (format *error-output* 
			  "CL-Speak: error in 'start-speaking-string': ~A~%" condition))))


(defun available-voices-count ()
  "Get the amount of all available voices."
  (handler-case
	  (let ((retval (foreign-funcall "available_voices_count" :uint)))
		retval)
	(error (condition)
	  (format *error-output* 
			  "CL-Speak: error in 'available-voices-count': ~A~%" condition))))


(defun set-voice (idx)
  "Set voice with id 'idx'."
  (handler-case
	  (foreign-funcall "set_voice" :uint idx :void)
	(error (condition)
	  (format *error-output* 
			  "CL-Speak: error in 'set-voice': ~A~%" condition))))
  

(defun get-voice-name (idx)
  "Get name of a voice with index 'idx'."
  (handler-case
	  (with-foreign-pointer-as-string (voice-c-str 255)
		(setf (mem-ref voice-c-str :char) 0)
		(foreign-funcall "get_voice_name" :uint idx :pointer voice-c-str :void)
		(foreign-string-to-lisp voice-c-str))
	(error (condition)
	  (format *error-output* 
			  "CL-Speak: error in 'get-voice-name': ~A~%" condition))))


; -------------------------------------------------------------
; These function wrap objective-c class methods
; First call have to be make-speaker to create
; a Speaker-class instance
; Avantage: callbacks - multiple speakers
; -------------------------------------------------------------

(defun make-speaker (speech)
  "Create speaker instance and initialize
created synth instance with given speech."
  (handler-case 
	  (with-foreign-string (foreign-speech speech)
		(let ((speaker (foreign-funcall "make_speaker" :string foreign-speech :pointer)))
		  speaker))
	(error (condition)
	  (format *error-output* "CL-Speak: error in 'make-speaker': ~A~%" condition))))

(defun speak-with (speaker text)
  "Speak text with synth container 'Speaker'."
  (handler-case 
	  (with-foreign-string (foreign-text text)
		(foreign-funcall "speak_with" :pointer 
						 speaker :string 
						 foreign-text :void))
	(error (condition) 
	  (format *error-output* "CL-Speak: error in 'speak-with': ~A~%" condition))))

(defun set-voice-with (speaker voiceid)
  "Set voiceid in synth container 'Speaker'."
  (handler-case 
	  (foreign-funcall "set_voice_with" :pointer speaker :uint voiceid :void)
	(error (condition) 
	  (format *error-output* "CL-Speak: error in 'set-voice-with': ~A~%" condition))))


;; ------------------------------------------------------
;; Lisp callbacks are called within objective-c delegates
;; ------------------------------------------------------

(defun register-will-speak-word-callback (speaker callback)
  "Register callback for 'willSpeakWord' delegate."
  (handler-case
	  (foreign-funcall "register_will_speak_word_callback" 
					   :pointer speaker :pointer callback :void)
	(error (condition) 
	  (format *error-output* 
			  "CL-Speak: error in 'register-will-speak-word-callback': ~A~%" condition))))


(defun register-will-speak-phoneme-callback (speaker callback)
  "Register callback for 'willSpeakPhoneme' delegate."
  (handler-case
	  (foreign-funcall "register_will_speak_phoneme_callback" 
					   :pointer speaker :pointer callback :void)
	(error (condition) 
	  (format *error-output* 
			  "CL-Speak: error in 'register-will-speak-phoneme-callback': ~A~%" condition))))


(defun register-did-finish-speaking-callback (speaker callback)
  "Register callback for 'didFinishSpeaking' delegate."
  (handler-case
	  (foreign-funcall "register_did_finish_speaking_callback" 
					   :pointer speaker :pointer callback :void)
	(error (condition) 
	  (format *error-output* 
			  "CL-Speak: error in 'register-did-finish-speaking-cakkback': ~A~%" condition))))

