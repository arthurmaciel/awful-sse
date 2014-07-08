;; Copyright (c) 2010-2014, Arthur Maciel
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in the
;;    documentation and/or other materials provided with the distribution.
;; 3. The name of the authors may not be used to endorse or promote products
;;    derived from this software without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS
;; OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
;; GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
;; IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
;; OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
;; IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(module awful-sse
 
 (define-page/sse send-sse-data send-sse-retry)
 
 (import scheme chicken data-structures extras posix)
 (use awful spiffy intarweb)
 
 (define (add-sse-resource! path proc vhost-root-path redirect-path)
   (add-resource! path
		  (or vhost-root-path (root-path))
		  (lambda (#!optional given-path)
		    (let ((accept (header-values 'accept
						 (request-headers (current-request)))))
		      (if (memq 'text/event-stream accept)
			  (lambda ()
			    (with-headers '((content-type text/event-stream)
					    (cache-control no-cache)
					    (connection keep-alive))
					  (lambda ()
					    (write-logged-response)
					    (proc))))
			  (redirect-to redirect-path)))) 
		  'GET))
 
 (define (write-body data)
   (display data (response-port (current-response)))
   (finish-response-body (current-response)))
 
 (define (send-sse-data data #!key event id)
   (let ((msg (conc (if id (conc "id: " id "\n") "")
		    (if event (conc "event: " event "\n") "")
		    "data: " data "\n\n")))
     (write-body msg)))
 
 (define (send-sse-retry retry)
   (write-body (conc "retry: " retry "\n\n")))
 
 (define (define-page/sse path contents sse-path sse-proc #!rest rest)
   (apply define-page (append (list path contents) rest))
   (add-sse-resource! sse-path sse-proc (get-keyword vhost-root-path: rest) path))

) ; End of module

