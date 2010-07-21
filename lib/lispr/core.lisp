;; Standard library functions

(def *lispr-version* Lispr::VERSION)

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

(defmacro when-not (test, body)
 `(if ~test nil ~body))

(defmacro not= (a b)
  `(not (= ~a ~b)))

;; measure time taken to evaluate body, returns the result of evaluating body
(defmacro time (body)
 `(let (start (#now Time)
        ret   ~body)
    (puts (str "Evaluation took " (- (#now Time) start) " seconds"))
    ret))


(defn reduce (f val? coll)
  (if (= val :not-provided)
      (reduce f (f (first coll)) (rest coll))
    (unless (nil? coll)
      (reduce f (f val (first coll)) (rest coll))
      val)))

(defn filter (pred, coll)
  (let (elem (first coll))
    (if (nil? elem)
        '()
        (if (pred elem)
            (cons elem (filter pred (rest coll)))
            (filter pred (rest coll))))))


;;apply cannot be implemented until & is!
;;(defmacro apply (func coll))
  

;;Numbers
(defn inc (num) (+ num 1))
(defn dec (num) (- num 1))

(defmacro zero? (num)
 `(= 0 ~num))
(defmacro pos? (num)
 `(> ~num 0))
(defmacro neg? (num)
 `(< ~num 0))
(defmacro even? (num)
 `(= 0 (% ~num 2)))
(defmacro odd? (num)
 `(not (even? ~num)))

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

(defn drop (n xs)
  (loop (num n, coll xs)
    (when (and (pos? num) (not (nil? coll)))
        (recur (dec num) (rest coll)))
    coll))

(defn drop-while (pred c)
  (loop (coll c)
    (when (and (pred (first coll)) (not (nil? coll)))
        (recur (rest coll)))
    coll))

; (take 3 '(1)) => (1)
(defn take (num coll)
  (if (and (pos? num) (not (nil? coll)))
    (cons (first coll) (take (dec num) (rest coll)))
    '()))

(defn take-while (pred coll)
  (if (and (not (nil? coll)) (pred (first coll)))
     (cons (first coll) (take-while pred (rest coll)))
      '()))

(defn repeat (n v)
    (loop (num n coll '())
        (unless (pos? num)
            coll
            (recur (dec num) (cons v coll)))))

(defn reverse (coll)
    (loop (ret '() xs coll)
    (unless (nil? xs)
        (recur (cons (first xs) ret) (rest xs))
        ret)))



(defn range (min? max)
  (if (= min :not-provided)
      (range 0 max)
      (loop (num  max, l '())
        (if (<= num min)
	  l
	  (recur (dec num) (#new List (#flatten (cons num l))))))))
      
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

(defmacro raise (class message)
  `(call raise Kernel ~class ~message))

(defn class (object)
  (#class object))

; convert 65 into 'A'
(defmacro chr (i)
  `(call chr (int ~i)))
  
; opposite of chr; converts 'A' into 65
(defn num (c)
  (do 
    (when (or (not (#is_a? c String)) (> (count c) 1))
      (raise ArgumentError (str "Bad argument: " (inspect c))))
    (#[] (str c) 0))) 

(defn gets () 
  (#readline (ruby "$stdin")))

; some math related functions
(ns math)

(defn fact (n)
    (reduce * 1 (range 1 (inc n))))

; testing utilities
(ns test)

(defmacro assert (statement)
    `(when (not ~statement)
        (raise RuntimeError (str "Assert failed - " (str `~statement)))))

(defmacro should-raise (statement exception)
    `(when-not (= (try 
                    ~statement
                    (catch ~exception _ :raised)
                    (catch Exception e (raise RuntimeError (str (str `~statement)
                        " raised " (class e) ": " (#message e) " Expected: "
                         ~exception))))
                :raised)
        (raise RuntimeError (str `~statement " didn't raise an exception"))))

(ns)

