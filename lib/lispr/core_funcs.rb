require 'lispr/types'
require 'lispr/scope'

module Lispr
  $scope = Scope.new
  $scope["true"]  = LispSymbol.new true
  $scope["false"] = LispSymbol.new false
  $scope["nil"]   = LispSymbol.new nil

  #Math functions

  add = lambda do |scope, *args|
    return 0 if args.nil? || args.empty? || args == $scope["nil"]
    return args.each.inject(LispNumeric.new 0) {|x, t| x.eval(scope) + t.eval(scope)}
  end
  $scope["+"]    = add

  sub = lambda do |scope, first, *args|
    return -first if args.size == 0
    return args.each.inject(first) {|x, t| x.eval(scope) - t.eval(scope)}
  end
  $scope["-"]    = sub

  mul = lambda do |scope, *args|
    return 1 if args.size == 0
    return args.each.inject(LispNumeric.new 1){|x, t| x.eval(scope) * t.eval(scope)}
  end
  $scope["*"]    = mul

  div = lambda do |scope, first, *rest|
    return 1/first.eval(scope) if rest.size == 0
    return rest.each.inject(LispNumeric.new first.eval(scope)) \
     {|x, t| x.eval(scope) / t.eval(scope)}
  end
  $scope["/"]    = div

  mod = lambda { |scope, first, second| first.eval(scope) % second.eval(scope) }
  $scope["%"]    = mod
  $scope["mod"]  = mod

  eql = lambda{ |scope, first, second| first.eql? scope, second }
  $scope["="] = eql

  lt = lambda { |scope, first, second| first.eval(scope) < second.eval(scope)}
  $scope["<"]    = lt

  lte = lambda { |scope, first, second| first.eval(scope) <= second.eval(scope)}
  $scope["<="]   = lte

  gt = lambda { |scope, first, second| first.eval(scope) > second.eval(scope)}
  $scope[">"]    = gt

  gte = lambda { |scope, first, second| first.eval(scope) >= second.eval(scope)}
  $scope[">="]   = gte

  #standard utility functions

  class_ = lambda { |scope, first| first.eval(scope).class }
  $scope["class"] = class_

  comment = lambda { |scope, *args| $scope["nil"]}
  $scope["comment"] = comment

  quote = lambda { |scope, first, *rest| first }
  $scope["quote"] = quote

  list = lambda { |scope, *args|
    tmp = []
    args.each {|x| tmp << x.eval(scope)}
    tmp << []
    List.new tmp
  }
  $scope["list"] = list

  print_ = lambda{ |scope, *values|
    values.each{|val| print val.eval(scope).to_s, ' '}
    nil
  }
  $scope["print"] = print_

  puts_ = lambda { |scope, *values|
    values.each{|val| print val.eval(scope).to_s, ' '}
    puts
    nil
  }
  $scope["puts"] = puts_

  car = lambda { |scope, value|
   value.eval(scope).car
  }
  $scope["car"]   = car
  $scope["first"] = car

  cdr = lambda {|scope, value|
    value.eval(scope).cdr
  }
  $scope["cdr"]   = cdr
  $scope["rest"]  = cdr

  #(eval "(+ 1 2) (+ 4 2)") will return 3, not [3, 6] or anything like that
  #it only evaluates the first expression, and returns that

  #Possibly take Clojure's approach of read-string to create an object from a
  #string and eval to evaluate it?
  eval = lambda {|scope, string| 
    begin
      exprs = Lispr::Reader.new(string.to_s + "\n").read
      exprs[0].eval(scope)
    rescue Exception => e
      raise e.class, "eval: #{e.message}"
    end
  }
  $scope["eval"]  = eval

  lambda_ = lambda {|scope, bindings, body|
    lam = Lambda.new(bindings, body)
    return lam.eval(scope)
    
  }
  $scope["fn"]     = lambda_
  $scope["lambda"] = lambda_

  macro = lambda {|scope, bindings, *body|
    mac = Macro.new(bindings, body)
  }
  $scope["macro"] = macro

  backquote = lambda {|scope, expr|

  #FLAWED strategy, but may prove helpful
    #val.value.flatten!
    #return val unless val.is_a?(List)
    #list = []
    #ctr = 0
    #while ctr < val.value.length
    #  if val.value[ctr] == []
    #    ctr += 1
    #    next
    #  end
    #  elem = val.value[ctr]
    #
    #  unless elem.is_a?(List)
    #    if elem.value == "unquote" or elem.value == "unquote-splice"
#          elem = List.new([elem, val.value[ctr += 1]])
#          puts elem.inspect
#        else
#          list << elem
#          ctr += 1
#          next
#        end
#      end
#      if elem.car.value == "unquote"
#        list << elem.cdr.car.eval(scope)

#      elsif elem.car.value == "unquote-splice"
#        eval = elem.cdr.car.eval(scope)
#        raise "unquote-splice expects a List, but got a #{eval.class}" unless \
#          eval.is_a?(List)
#        eval.value.each {|val|
#          list << val unless val == []
#        }         

#      else

#        list << backquote[scope, elem] #unless elem.value == []          

#      end

#      break if val == []


#      ctr += 1
#    end      
#    
#    retval = List.new(list.flatten) if list.flatten.size != 1
#    retval = list[0] if list.flatten.size == 1
#    puts "RETURNING>#{retval.inspect}"
#    retval.eval(scope)

    #Working (moreso) strategy, adapted from lispy
    if expr.class != List:
        return expr
      end
    new = []
    ctr = 0
    while ctr < expr.value.length
      exp = expr.value[ctr]
      break if exp == []
      unless exp.is_a?(List)
        if exp.value == "unquote" or exp.value == "unquote-splice"
          exp = expr.value[ctr += 1].eval(scope)

        else
          new << exp
          ctr += 1
          next
        end
      end

      if exp.class == List:
        if exp.car.value == "unquote"
          new << exp.cdr.car.eval(scope)
        elsif exp.car.value == "unquote-splice"
          l = exp.cdr.car.eval(scope)
          for i in l.value[0...-1]:
            new << i
          end
        else
          new << backquote.call(scope, exp)               
        end
      else
        new << exp
      end
      
      ctr += 1
    end
    return List.new(new) if new.flatten.length != 1
    new[0]
  }
  $scope["backquote"] = backquote

  #TODO: make def work on a local scope rather than global!
  #lies! def is always global!
  def_ = lambda { |scope, symbol, value| $scope[symbol.to_s] = value.eval(scope)}
  $scope["def"]  = def_

  do_ = lambda {|scope, *args|
    args[0...-1].each {|exp|
      exp.eval(scope)
    }
    args[-1].eval(scope)
  }
  $scope["do"] = do_

  cond = lambda {|scope, *args|
    return $scope["nil"] if args.size == 0
    array = []

    #partition args into blocks of 2
    args.each_with_index do |x, i|
      array << [] if i % 2 == 0
      array.last << x
    end
    retval = $scope["nil"]
    array.each {|pred, val|
      if pred.eval(scope).value
        retval = val.eval(scope)
        break
      end
    }
    return retval
  }
  $scope["cond"] = cond

  cons = lambda {|scope, value, list|
    raise "cons expects a list, but got #{list.eval(scope).class}" \
     unless list.eval(scope).is_a?(List)
    List.new([value.eval(scope)] << list.eval(scope).value)
  }
  $scope["cons"] = cons
  
  #(let (x 1, y 2) (puts x) (puts y))
  let = lambda {|scope, binds, *body|
    local = Scope.new(scope)
    bindings = []

    #partition args into blocks of 2
    binds.value.each_with_index do |x, i|
      bindings << [] if i % 2 == 0
      bindings.last << x
    end

    bindings.each {|sym, val|
      next if val == [] or sym == []
      raise "Must bind to a symbol! Got: #{sym.inspect}" unless sym.is_a?(LispSymbol)
      local[sym.value] = val.eval(scope)
    }

    body[0...-1].each {|exp|
      exp.eval(local)
    }
    #return last element of body
    body[-1].eval(local)
  }
  $scope["let"] = let

  nil_ = lambda {|scope, expr|
    eval = expr.eval(scope)
    return true if eval.nil?
    return true if eval.is_a?(LispSymbol) and eval.value == nil
    return true if eval.is_a?(List) and eval.value.flatten.empty?
    false
  }
  $scope["nil?"] = nil_

  #cast to Ruby classes

  int = lambda { |scope, value| Integer(value.eval(scope).value) }
  $scope["int"] = int

  float = lambda { |scope, value| Float(value.eval(scope).value) }
  $scope["float"] = float

  str = lambda {|scope, *values|
    val = ""
    values.each{|str| val << str.eval(scope).to_s }
    val
  }
  $scope["str"] = str

  ruby = lambda { |scope, value|
    raise "String expected as argument!" unless value.eval(scope).is_a?(String)
    eval value.eval(scope).to_s
  }
  $scope["ruby"] = ruby

  call = lambda { |scope, method, class_, *args|
    array = []
    args.each {|elem|
      array << elem.eval(scope).value
    }
    class_.eval(scope).send(method.value, *array)
  }
  $scope["call"] = call

end

