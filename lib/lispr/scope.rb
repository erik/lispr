module Lispr
  class Scope
    attr_reader :scope
    def initialize(parent=nil)
      @scope = {}
      @parent = parent
    end

    def [](symbol)
      #uppercase means Ruby class
      if symbol[0].chr =~ /[A-Z]/
        return eval(symbol)
      end
      if @scope.has_key? symbol
        return @scope[symbol]
      else
        if @parent
          return @parent[symbol] if @parent.has_key? symbol
        end
        raise "#{symbol} is not defined!"
      end
    end


    #remove duplicated code
    def has_key?(symbol)
      if symbol[0].chr =~ /[A-Z]/
        return true
      end
      if @scope.has_key? symbol
        return true
      else
        if @parent
          return true if @parent.has_key? symbol
        end
        false
      end
    end

    def []=(sym, val)
      @scope[sym] = val
    end
  end
end

