;; Standard library functions

;;need to allow unquote splicing here
(def defmacro (macro (n a  b) `(def ~n (macro ~a ~b))))
(defmacro defn (name args body) `(def ~name (fn ~args ~body)))

(defmacro if (test t f)
 `(cond
  ~test ~t
   :else ~f))

;;Numbers
(defn inc (num) (+ num 1))
(defn dec (num) (- num 1))

(defmacro zero? (num)
 `(if (= 0 ~num)
    true
    false))
(defmacro pos? (num)
 `(if (> ~num 0)
    true
    false))
(defmacro neg? (num)
 `(if (< ~num 0)
    true
    false))
(defmacro even? (num)
 `(if (= 0 (% ~num 2))
    true
    false))
(defmacro odd? (num)
 `(if (even? ~num)
    false
    true))


