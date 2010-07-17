#opening up some classes to add a value method
class Object; def value; self; end; def eval(scope); self; end; end
class TrueClass; def value; true; end; end
class FalseClass; def value; false; end; end
class Numeric; def value; self; end; end
class Hash
  def call(scope, sym)
    val = sym.eval(scope)
    self[val]
  end
end

class Array 
  def call(scope, *vals)
    self[*vals.collect{|e| e.eval(scope).value}]
  end
end

class String
  def count
    Lispr::LispNumeric.new self.length
  end

  def flatten
    self
  end

  def car
    if self.size > 0
      self[0].chr
    else
      $global[:namespaces][:global]["nil"]
    end
  end

  def cdr
    if self.size == 0
      $global[:namespaces][:global]["nil"]

    else
      self[1..-1]
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
