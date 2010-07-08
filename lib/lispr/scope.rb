module Lispr
  class Scope
    attr_reader :scope
    def initialize(parent=nil)
      @scope = {}
      @parent = parent
    end

    def [](symbol)
      if @scope.has_key? symbol
        return @scope[symbol]
      else
        if @parent
          return @parent[symbol] if @parent.scope.has_key? symbol
        end
        raise "#{symbol} is not defined!"
      end
    end

    def []=(sym, val)
      @scope[sym] = val
    end
  end
end

