; a simple lispr repl written in lispr

(def prompt "> ")

(print "Lispr" *lispr-version* "\n" prompt)

(loop (line (gets))
    (try
        (print " ==> " (eval line) "\n" prompt)
        (recur (gets))
        ; triggered by ^C
        (catch Interrupt _ (#exit Kernel 0))
        (catch Exception e (do 
            (print (class e) (#message e) "\n" prompt)
            (recur (gets))))))
