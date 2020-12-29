(import (awful sse))

(define (sse-proc)
  (send-sse-data "sse"))

(define-page/sse "/client"
  (lambda ()
    ;; Unnecessary as our client it not a browser
    ;; (add-javascript 
    ;;  "var source = new EventSource('/sse');
    ;;   source.onmessage = function (event) {
    ;;       display = document.getElementById('display');
    ;;       display.innerHTML = event.data;
    ;;   };")

    "foo") ; page contents won't be accessed anyway

  "/sse"
  sse-proc
  no-template: #t)
