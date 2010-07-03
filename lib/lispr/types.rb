module Lispr

  #Each type contains at least 2 methods, to_s for a string representation of it
  #and eval, for the semantic value of the object

  class Atom
    def initialize value
      @value = value
    end

    def to_s
      @value.to_s
    end

    def eval
      self
    end
  end

  class List
    attr_reader :car, :cdr

    #value is an array containing the values
    #(1 2 3)      == List.new [1, 2, 3]
    #(1 (2 (3)))  == List.new [1, List.new([2, List.new([3]) ])]
    def initialize (value)
      @value = value
      @car   = value[0]
      @cdr   = unless value[1..-1].empty?
                 value[1..-1]
               else
                 nil
               end
    end

    def to_s
      str = '(' + @car.to_s + (@cdr.each {|e| e.to_s}.join ' ') + ')'
    end

    def eval(scope)
      if @value.size != 0
        @car.eval(scope).call(scope, @cdr)
      else
        $symbol["nil"]
      end
    end

    alias first car
    alias rest cdr
  end

  #Symbol is a built in Ruby class
  class LispSymbol
    def initialize(value)
      @value = value
    end

    def to_s
      @value.to_s
    end

    def eval(scope)
     scope[@value]
    end
  end

  class LispString < String
    attr_reader :car, :cdr
    def initialize value
      @value = value
      @car   = LispString.new value[0].chr
      @cdr   = LispString.new value[1..-1]
    end

    def to_s
      @value.to_s
    end

    def eval(scope)
      self
    end
  end

  class LispNumeric

    def initialize value
      @value = value
    end

    def to_s
      @value.to_s
    end

    def eval(scope)
      self
    end

    #http://stackoverflow.com/questions/1095789/sub-classing-fixnum-in-ruby
    def method_missing(name, *args, &blk)
      ret = @value.send(name, *args, &blk)
      ret.is_a?(Numeric) ? LispNumeric.new(ret) : ret
    end

  end

  class Keyword
    def initialize value
      @value = value
    end

    def to_s
      ':' + @value
    end

    def eval(scope)
      self
    end
  end
end

