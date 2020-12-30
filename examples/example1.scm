;; Run with 'awful example1.scm'.
;; On web browser open http://localhost:8080/client and watch the 
;; new time coming each second from the server.
(use awful-sse awful spiffy posix srfi-18)

(define (sse-proc)
  (let loop ()
    (send-sse-data (seconds->string) id: (random 10) event: "message")
    (thread-sleep! 1)
    (loop)))

(define-page/sse "/client" 
  (lambda ()
    (add-javascript 
     "var source = new EventSource('/sse');
      source.onmessage = function (event) {
          display = document.getElementById('display');
          display.innerHTML = event.data;
      };")

    (add-css "#display { color: blue; }")

    `(div "Current time: "
          (span (@ (id "display")) "")))
  "/sse"
  sse-proc
  use-sxml: #t)
