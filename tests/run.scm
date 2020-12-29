(import (chicken base) 
        (chicken io)
        awful http-client intarweb uri-common server-test test)

(awful-apps (list "client.scm"))

(with-test-server
 (lambda ()
   (awful-start
    (lambda ()
      (load-apps (awful-apps)))))
 (lambda ()   
   (test "data: sse\n\n"
	 (with-input-from-request
	  (make-request
	   uri: (uri-reference "http://localhost:8080/sse")
	   headers: (headers '((accept text/event-stream))))
	  #f
	  read-string))))

(test-exit)
