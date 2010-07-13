; a tiny IRC bot

(ruby "$SAFE = 4")

; for TCPSocket
(require "socket")

; default port setting
(def *port* 6667)

; prepend for commands
(def prepend "@")

; send a message
(defn send (type msg) (#send irc (str type " " msg "\n"), 0))
; send a PRIVMSG
(defn send-message (to msg) (send "PRIVMSG" (str to " :" msg)))

; create a thread to keep connection alive by pinging channel every 2 minutes
(defn ping-chan (chan)
    (thread 
        (loop ()
            (send "PING" chan)
            (#sleep Thread 120)
            (recur))))

; respond to a command
(defn commands (message)
    (cond
        (= message "time") (send-message *chan* (#now Time))
        (= (first message) "(" )(send-message *chan*
                                (try 
                                    (eval message)
                                    (catch Exception e (str (class e)
                                        (#message e)))))))
        
(defn handle-input (message)
    (when (#include? message "PRIVMSG")
        ; strip everything except the message
        (let (msg (#chomp (#last (#split message " :"))))
            (when (= (first msg) prepend)
                (commands (rest msg))))))

(defn connect ()
    (do
        (send "USER" "blah blah blah :blah blah")
        (send "NICK" *nick*)
        (send "JOIN" *chan*)
        (ping-chan *chan*)
        (loop (in (#gets irc))
            (puts (#chomp in))
            (when (not (nil? in))
                (do
                    (handle-input in)
                    (recur (#gets irc)))))))

(puts "Welcome to lisprbot!")
(print "IRC server>")
(def *server* (#chomp (gets)))
(print "Port (default 6667)>")
(let (port (#chomp (gets))) (when-not (#empty? port) (def *port* (#to_i port))))
(print "Nick>")
(def *nick* (#chomp (gets)))
(print "Channel>")
(def *chan* (#chomp (gets)))
(puts "Connecting to" *server* "...")
(def irc (#open TCPSocket *server* *port*))
(connect)
