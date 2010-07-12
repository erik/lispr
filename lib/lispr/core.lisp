;; Standard library functions

(def *lispr-version* (ruby "Lispr::VERSION"))

;;need to allow unquote splicing here
(def defmacro (macro (n a  b) `(def ~n (macro ~a ~b))))
(defmacro defn (name args body) `(def ~name (fn ~args ~body)))
;(alias new old)
(defmacro alias (new old) `(def ~new ~old))

(defmacro if (test t f)
 `(cond
  ~test ~t
   :else ~f))

(defmacro unless (test t f)
 `(if ~test ~f ~t))

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

(defmacro when (test, body)
 `(if ~test ~body nil))

;; measure time taken to evaluate body, returns the result of evaluating body
(defmacro time (body)
 `(let (start (#now Time)
        ret   ~body)
    (puts (str "Evaluation took " (- (#now Time) start) " seconds"))
    ret))

;; make val optional!
(defmacro reduce (f val coll)
 `(unless (nil? ~coll)
    (reduce ~f (~f ~val (first ~coll)) (rest ~coll))
    ~val))

;;apply cannot be implemented until & is!
;;(defmacro apply (func coll))
  

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

; floating point random number
(defn rand () (#rand Kernel))
; integer random, between 0 (inclusive), n (exclusive)
(defn rand-int (n) (#rand Kernel n))

;;lists
(defn car (l)
  (#car l))
  
(alias first car)

(defn cdr (l)  
  (#cdr l))

(alias rest cdr)
  
(defn second (l)
  (first (rest l)))
  
(defn third (l)
  (first (rest (rest l))))
  
(defn nth (coll index)
  (#[] (#flatten coll) index))
  
(defn count (coll)
  (#count coll))
  
(defmacro some? (pred coll) 
 `(if (nil? ~coll)
     nil
     (if (~pred (first ~coll))
        (first ~coll)
        (some? ~pred (rest ~coll)))))
(alias any? some?)

;;Ruby interop

;;until & is implemented, args should be a list:
;;(new Array (3, "2"))
;;  => ["2", "2", "2"]
(defmacro new (class,  args)
  `(call new ~class ~@args))

;; require a Ruby file
(defmacro require (file)
  `(call require Kernel ~file))

(defmacro inspect (object)
  `(call inspect ~object))

(defmacro chr (i)
  `(call chr (int ~i)))

(defmacro raise (class message)
  `(call raise Kernel ~class ~message))

(defn class (object)
  (#class object))

