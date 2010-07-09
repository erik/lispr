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

  macro = lambda {|scope, bindings, body|
    mac = Macro.new(bindings, body)
  }
  $scope["macro"] = macro

  backquote = lambda {|scope, val|
    return val unless val.is_a?(List)

    list = []
    val.value.each {|elem|
      unless elem.is_a?(List)
        list << elem
        next
      end

      if elem.car.value == "unquote"
        list << elem.cdr.value[0].eval(scope)

      elsif elem.car.value == "unquote-splice"
        puts "FIXME: UNQUOTE-SPLICE!"      
      else
        list << elem
      end
    }
    List.new(list)
  }
  $scope["backquote"] = backquote

  #TODO: make def work on a local scope rather than global!
  #lies! def is always global!
  def_ = lambda { |scope, symbol, value| $scope[symbol.to_s] = value.eval(scope)}
  $scope["def"]  = def_

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

  inspect = lambda {|scope, value|
    value.eval(scope).inspect
  }
  $scope["inspect"] = inspect

end

