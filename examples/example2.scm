;; Run with {{awful example2.scm}}.
;; Open two web browsers and point both to [[http://localhost:8080/client]].
;; Try clicking on the blue and the red div and see them changing their
;; boolean values on BOTH browsers.
(use awful-sse awful spiffy json posix srfi-18)

;; Global variables are not good practice, but will suffice for the moment.
(define one #t)
(define two #f)

(define (swap1!)
  (set! one (not one)))
(define (swap2!)
  (set! two (not two)))

(define (prepare-json one two)
  (with-output-to-string
    (lambda ()
      (json-write (list->vector `(("one" . ,one) ("two" . ,two)))))))

(define (sse-proc)
  (let loop ()
    (send-sse-data (prepare-json one two))
    (thread-sleep! 1)
    (loop)))

(define-page/sse "/client"
  (lambda ()
    (add-javascript
     "var source = new EventSource('/sse');
      source.addEventListener('message', function(e) {
          var data = JSON.parse(e.data);
          document.getElementById('one').innerHTML = data.one;
          document.getElementById('two').innerHTML = data.two;
      }, false);")

    (add-css "div #one, #two { padding: 1em; margin: 1em; border-width: 1px; border-style: solid; }")
    
    (ajax "one" 'one 'click
          (lambda ()
            (swap1!)))
    (ajax "two" 'two 'click
          (lambda ()
            (swap2!)))
    
    `((div (div (@ (id "one")
                   (style "border-color: blue;"))
                "")
           (div (@ (id "two")
                   (style "border-color: red;"))
                ""))))
  "/sse"
  sse-proc
  use-sxml: #t
  use-ajax: #t)
