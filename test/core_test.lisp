; various tests to make sure the core library isn't complete garbage 

(test.assert (= true (if (nil? '()) true false)))
(test.assert (= true (unless 7 false true)))

(test.assert (= 10 (reduce + 0 (range 1 5))))

(test.assert (= (str (first "bc") "c") "bc"))
(test.assert (= '(1 2 3 4) (rest '( 0 1 2 3 4))))
(test.assert (= (third '( 1 2 3 )) 3))
(test.assert (= (chr (nth "abcdef" 2 )) "c"))

(test.assert (= (drop 2 '(0 1 2 3 4 5)) '(2 3 4 5)))
(test.assert (= (drop-while neg? '(-2 -1 0 1 2)) '(0 1 2)))

(test.assert (= (take 2 "abc") '("a" "b")))
(test.assert (= (take-while neg? '(-2 -1 0 1 2)) '(-2 -1 )))

(test.assert (= (range 0 4) '(0 1 2 3)))
(test.assert (= (count "abc") 3))
(test.assert (some? zero? '(1 2 3 4 0)))

(test.assert (= (class (#new Object)) Object))
(test.assert (= (inspect Object) "Object"))

(test.assert (= (chr 65) "A"))
(test.assert (= (num "A") 65))
(test.should-raise (num "abc") ArgumentError)

(test.assert (= 120 (math.fact 5)))

(test.should-raise (/ 1 0 ) ZeroDivisionError)
(test.should-raise (raise ArgumentError "BOOM") ArgumentError)

(puts "Done. All tests passed.")
