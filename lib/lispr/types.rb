#opening up some classes to add a value method
class TrueClass; def value; true; end; end
class FalseClass; def value; false; end; end

module Lispr
  module Generic
    attr_reader :value
    def eql? scope, other
      val = self.eval(scope)
      oth = other.eval(scope)
      begin
        return val.value == oth.value
      rescue Exception => e
        return val == oth
      end
    end
  end

  #Each type contains at least 2 methods, to_s for a string representation of it
  #and eval, for the semantic value of the object

  class Atom
    include Generic
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
    include Generic
    attr_reader :value
    #value is an array containing the values
    #(1 2 3)      == List.new [1, 2, 3]
    #(1 (2 (3)))  == List.new [1, List.new([2, List.new([3]) ])]
    def initialize (value)
      @value = value
      @value << [] if @value[-1] != []
    end

    def car
      if @value.size > 0 and @value != [[]]
        @value[0]
      else
        $scope["nil"]
      end
    end

    def cdr
      if @value.size == 0 or @value == [[]]
        $scope["nil"]

      elsif @value[-1] == []
        List.new @value[1..-1]

      else
        @value[1]
      end
    end

    def to_s
      return '()' if @value.size == 0 or @value == [[]]
      str = '(' + @value[0...-1].each {|x| x.to_s}.join(' ') + ')'
    end

    def eval(scope)
      if @value.size == 0 or @value == [[]]
        LispSymbol.new "nil"
      elsif @value[-1] != []
        self.car.eval(scope).call(scope, self.cdr)
      else
        cdr = self.cdr.value[0..-1]
        self.car.eval(scope).call(scope, *self.cdr.value[0..-1].flatten)
      end
    end

    alias first car
    alias rest cdr
  end

  #Symbol is a built in Ruby class
  class LispSymbol
    include Generic
    def initialize(value)
      @value = value
    end

    def to_s
      return @value.to_s unless @value.nil?
      "nil"
    end

    def eval(scope)
     scope[@value]
    end
  end

  class LispString < String
    include Generic
    def initialize value
      @value = value
    end

    def to_s
      "#{@value}"
    end

    def eval(scope)
      self
    end

    def car
      if @value.size > 0
        @value[0].chr
      else
        $scope["nil"]
      end
    end

    def cdr
      if @value.size == 0
        $scope["nil"]

      else
        LispString.new @value[1..-1]
      end
    end

    def eql? scope, other
      val = self.eval(scope)
      oth = other.eval(scope)
      begin
        return val.value == oth.value
      rescue Exception => e
        return val.to_s == oth
      end
    end

  end

  class LispNumeric
    include Generic
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
    include Generic
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

