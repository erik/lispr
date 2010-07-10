;; Standard library functions

;;need to allow unquote splicing here
(def defmacro (macro (n a  b) `(def ~n (macro ~a ~b))))
(defmacro defn (name args body) `(def ~name (fn ~args ~body)))

(defmacro if (test t f)
 `(cond
  ~test ~t
   :else ~f))

(defmacro and (x y)
 `(if ~x 
    (if ~y 
        true
        false)
    false))
    
(defmacro or (x y)
 `(cond 
    ~x true
    ~y true
    :else false))

(defmacro xor (x y)
 `(cond 
    ~x (if ~y false true)
    ~y (if ~x false true)
    :else false))

(defmacro not (x)
 `(if ~x false true))


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

;;lists
(defn second (l)
  (first (rest l)))
(defn third (l)
  (first (rest (rest l))))

;;Ruby interop

;;until & is implemented, args should be a list:
;;(new Array (3, "2"))
;;  => ["2", "2", "2"]
(defmacro new (class,  args)
  `(call new ~class ~@args))

;; require a Ruby file
(defmacro require (file)
  `(call require Kernel ~file))
