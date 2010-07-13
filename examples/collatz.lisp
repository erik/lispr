; collatz conjecture

(defn collatz (num)
    (loop (n num)
        (puts n)
        (cond
            (<= n 1)   n
            (even? n) (recur (/ n 2))
            (odd? n)  (recur (+ 1 (* 3 n))))))
            
(puts "Collatz!")

(loop ()
    (puts "Enter a number: ")
    (collatz (#to_i (gets)))
    (recur))


