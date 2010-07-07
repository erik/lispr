#lispr
lispr is a Ruby implementation of Lisp. As of right now, it is mostly an
unfinished implementation based on McCarthy's original Lisp, but hopefully will
be able to work seamlessly with Ruby classes and objects eventually

Some basic concepts, such as the structure of the reader, were adapted from
programble's similar project [lispy](http://github.com/programble/lispy).

It was a great help in getting a working draft produced fairly quickly.


As of now, there are still a bunch of things to implement, such as macros,
lambdas and a standard library for instance. Besides that, it is working however
and you can use it for great profit.

##Examples
Check out lib/lispr/core_funcs.rb for other functions

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

