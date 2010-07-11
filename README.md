#lispr
lispr is a Ruby implementation of Lisp. As of right now, it is mostly an
unfinished implementation based on McCarthy's original Lisp, but has the ability
to play nicely with Ruby objects now, and some additional functionality soon.

Some basic concepts, such as the structure of the reader, were adapted from
programble's similar project [lispy](http://github.com/programble/lispy).

It was a great help in getting a working draft produced fairly quickly.


As of now, there are still a bunch of things to implement/finish, such as macros,
and a standard library for instance. Besides that, it is working however
and you can use it for great profit.

##Usage
        Usage bin/lispr [options] [file]
    -v, --version                    Display version an exit
    -i, --interactive [prompt]        Start a REPL, optionally specifying a prompt
    -?, -h, --help                   Display this help message
    -t, --trace                      Provide more specific errors
    -e, --evaluate code              Evaluate a single line of code

If you run Lispr without specifying a file, it will just load the core file
(lib/lispr/core.lisp) and open up a REPL. You can run a REPL explicitly with the
`-i [prompt]` switch if you want to use a custom prompt.

Right now, file evaluation is pretty rudimentary, and will be fleshed out in the
future

##Examples
Check out lib/lispr/core_funcs.rb, and lib/lispr/core.lisp for other functions

*As in Clojure, a comma is whitespace*

####Some basic usage examples:

first/car:

        (first "abc")
            => "a"

rest/cdr:

        (rest "abc")
            => "bc"
        
Comparing classes of objects:

        (= (class 42) (class (* 4 2)))
            => true

Using Lambdas:

        (def adder (fn (x) (+ x 1)))
        (adder 2)
            => 3

Defining functions:

        (defn greet (name)
            (puts (str "Hello, " name "!")))
        (greet "Sam")
            Hello, Sam!
            => nil

Cond:

        (def num 42)
        (cond
            (pos? num) (puts "pos")
            (neg? num) (puts "neg")
            (zero? num) (puts "zero")
            ; :else (like all keywords) evaluates to true
            :else (puts "WTF DID YOU DO?"))
                pos
                    => nil
            
Danger, Will Robinson!

        (= (int 1) 1)
            => false
        ;because:
        (class 1)
            => Lispr::LispNumeric
        (class (int 1))
            => Fixnum
 
This next function will probably be changed in future versions (if not removed
in favor of something else):

        (ruby "1.upto(5).each {|num| print num}")
            12345 => 1
            
####Ruby interoperability

Requiring and using files:

        (require "digest/sha1")
            => true
        ;require is a macro which expands into:
        ;   (call require Kernel "digest/sha1")
        ;
        ;# is a reader macro and is the same as call
        ;notice that there isn't a space between # and h (it is allowed, but
        ;won't be in the future)
        ;
        (#hexdigest Digest::SHA1 "secret!" )
            => "cb37de1d915a124412ff8113bef18511daec3050"

Creating Ruby Objects:
        (new Array (5, nil))
            => [nil, nil, nil, nil, nil]
        ;Alternatively:
        (#new Array 5 nil)
            => [nil, nil, nil, nil, nil]

The 'new' macro expects only 2 arguments, a class, and a single parameter for
the arguments to pass, meaning if you want to do `Array.new(5, nil)` you need to
make `5, nil` a single argument by passing it as a list. This *will* be changed.

        (def s (#new String "Hallo, World"))
            => "Hallo, World"
        ;s.gsub!("a", "e")
        (#gsub! s "a" "e")
             => "Hello, World"
        (puts s)
            Hello, World
            => nil

Exception Handling:

        (try 
            (/ 42 6)
            (/ 1 0)
            (catch TypeError _ (puts "I caught a TypeError"))
            (catch ZeroDivisionError _ (puts "Oh no! You divided by 0!"))
            ;this case should be put last, or it will be matched every time!
            (catch Exception e (puts "I caught a" (class e) "with this message:"
                                     (#message e))))
                Oh no! You divided by 0!
                    => nil

The try block will use the first catch that matches, not the most accurate. If
no matching block is found, the exception falls through. If no error is thrown,
try will return the last value evaluated
            
