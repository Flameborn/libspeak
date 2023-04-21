# libspeak

Forked from speaker - Multiplatform Speech synthesis library wrapper for Common Lisp at https://github.com/epuccini/speaker

This speech synthesis library is a cffi interface to an adapter library which interfaces to a speech library of the platform. It enables text-to-speech and -recognition (recognition only on Mac OSX). Dependency is only cffi. The MacOSX version uses Cocoa NSSpeechSynthesizer, Windows uses Speech API, Linux uses QtTextToSpeech.

# Compiling 

You can compile libspeak via Opening it in the appropriate IDE XCode/Visual Studio/QtCreator project "libspeak" and building the library.

Licensed under the GNU LESSER GENERAL PUBLIC LICENSE.
