;; Standard library functions

;;need to allow unquote splicing here
(def defmacro (macro (n a  b) `(def ~n (macro ~a ~b))))
(defmacro defn (name args body) `(def ~name (fn ~args ~body)))


