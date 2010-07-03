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
      @car   = value.first
      @cdr   = unless value[1..-1].empty?
                 value[1..-1]
               else
                 nil
               end
    end

    def to_s
      str = '(' + @car.to_s + (@cdr.each {|e| e.to_s}.join ' ') + ')'
    end

    def eval
      if @car
        @car.eval(@cdr.eval)
      else
        nil
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


  class Keyword
    def initialize value
      @value = value
      puts @value
    end

    def to_s
      ':' + @value
    end

    def eval(scope)
      self
    end
  end
end

