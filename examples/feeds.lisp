; a small atom reader

(require "rss")
(require "open-uri")

; our feed to fetch
(def feed "http://github.com/boredomist/lispr/commits/master.atom")

; (#open Kernel feed) => File object
; #readlines          => reads each line of file into an array
; #join               => creates a single string out of the array
(def content (#join (#readlines (#open Kernel feed))))

; Parse the RSS
(def rss (#parse RSS::Parser content, false))

; Print out the title of the feed, and the number of items in it
(puts "\t\t\t" (#content (#title rss)))
(puts "\t\t\t\t" (#size (#items rss)) "new entries")

; for each item in the feed, print out the content of the
; item, with <pre> and </pre> tags removed
(&each (#items rss)
    (block (item)
        (puts (#gsub (#content (#content item))
                  (#new Regexp "</?pre>") ""))))
