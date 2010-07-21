require 'thread' # for Mutex
require 'lispr/types'
require 'lispr/scope'

module Lispr
  $global = {:namespaces => {:global => Scope.new } ,:scope => :global}
  $global[:namespaces][:global]["true"]  = LispSymbol.new true
  $global[:namespaces][:global]["false"] = LispSymbol.new false
  $global[:namespaces][:global]["nil"]   = LispSymbol.new nil

  #Math functions

  add = lambda do |scope, *args|
    return 0 if args.nil? || args.empty? || args == $global[:namespaces][:global]["nil"]
    return args.each.inject(LispNumeric.new 0) {|x, t| x.eval(scope) + t.eval(scope)}
  end
  $global[:namespaces][:global]["+"]    = add

  sub = lambda do |scope, first, *args|
    return -first if args.size == 0
    return args.each.inject(first) {|x, t| x.eval(scope) - t.eval(scope)}
  end
  $global[:namespaces][:global]["-"]    = sub

  mul = lambda do |scope, *args|
    return 1 if args.size == 0
    return args.each.inject(LispNumeric.new 1){|x, t| x.eval(scope) * t.eval(scope)}
  end
  $global[:namespaces][:global]["*"]    = mul

  div = lambda do |scope, first, *rest|
    return 1/first.eval(scope) if rest.size == 0
    return rest.each.inject(LispNumeric.new first.eval(scope)) \
     {|x, t| x.eval(scope) / t.eval(scope)}
  end
  $global[:namespaces][:global]["/"]    = div

  mod = lambda { |scope, first, second| first.eval(scope) % second.eval(scope) }
  $global[:namespaces][:global]["%"]    = mod
  $global[:namespaces][:global]["mod"]  = mod

  eql = lambda{ |scope, first, second| first.eql? scope, second }
  $global[:namespaces][:global]["="] = eql

  lt = lambda { |scope, first, second| first.eval(scope) < second.eval(scope)}
  $global[:namespaces][:global]["<"]    = lt

  lte = lambda { |scope, first, second| first.eval(scope) <= second.eval(scope)}
  $global[:namespaces][:global]["<="]   = lte

  gt = lambda { |scope, first, second| first.eval(scope) > second.eval(scope)}
  $global[:namespaces][:global][">"]    = gt

  gte = lambda { |scope, first, second| first.eval(scope) >= second.eval(scope)}
  $global[:namespaces][:global][">="]   = gte

  #standard utility functions

  comment = lambda { |scope, *args| $global[:namespaces][:global]["nil"]}
  $global[:namespaces][:global]["comment"] = comment

  quote = lambda { |scope, first, *rest| first }
  $global[:namespaces][:global]["quote"] = quote

  list = lambda { |scope, *args|
    List.new args.collect{|x| x.eval(scope)}
  }
  $global[:namespaces][:global]["list"] = list

  array = lambda {|scope, *args|
    Array[ *args.collect {|x| x.eval(scope)}]
  }
  $global[:namespaces][:global]["array"] = array

  hash = lambda {|scope, *args|
    LispHash[*args.collect {|x| x.eval(scope)}]
  }
  $global[:namespaces][:global]["hash"] = hash

  print_ = lambda{ |scope, *values|
    values.each{|val| print val.eval(scope).to_s, ' '}
    nil
  }
  $global[:namespaces][:global]["print"] = print_

  puts_ = lambda { |scope, *values|
    values.each{|val| print val.eval(scope).to_s, ' '}
    puts
    nil
  }
  $global[:namespaces][:global]["puts"] = puts_


  #(eval "(+ 1 2) (+ 4 2)") will return 3, not [3, 6] or anything like that
  #it only evaluates the first expression, and returns that

  #Possibly take Clojure's approach of read-string to create an object from a
  #string and eval to evaluate it?
  eval = lambda {|scope, string|
    begin
      exprs = Lispr::Reader.new(string.eval(scope).to_s + "\n").read
      exprs[0].eval(scope)
    rescue Exception => e
      raise e.class, "eval: #{e.message}"
    end
  }
  $global[:namespaces][:global]["eval"]  = eval

  lambda_ = lambda {|scope, bindings, body|
    lam = Lambda.new(bindings, body)
    return lam.eval(scope)
    
  }
  $global[:namespaces][:global]["fn"]     = lambda_
  $global[:namespaces][:global]["lambda"] = lambda_

  macro = lambda {|scope, bindings, *body|
    mac = Macro.new(bindings, body)
  }
  $global[:namespaces][:global]["macro"] = macro

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
    #      elem = List.new([elem, val.value[ctr += 1]])
    #      puts elem.inspect
    #    else
    #      list << elem
    #      ctr += 1
    #      next
    #    end
    #  end
    #  if elem.car.value == "unquote"
    #    list << elem.cdr.car.eval(scope)
    #  elsif elem.car.value == "unquote-splice"
    #    eval = elem.cdr.car.eval(scope)
    #    raise "unquote-splice expects a List, but got a #{eval.class}" unless \
    #      eval.is_a?(List)
    #    eval.value.each {|val|
    #      list << val unless val == []
    #    }         
    #  else
    #    list << backquote[scope, elem] #unless elem.value == []          
    #  end
    #  break if val == []
    #  ctr += 1
    #end      
    #
    #retval = List.new(list.flatten) if list.flatten.size != 1
    #retval = list[0] if list.flatten.size == 1
    #puts "RETURNING>#{retval.inspect}"
    #retval.eval(scope)

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
  $global[:namespaces][:global]["backquote"] = backquote

  def_ = lambda { |scope, symbol, value|
# save this for when readonly, and mutable variables are implemented
#    raise "Redefinition of #{symbol}!" if \
#      $global[:namespaces][$global[:scope]].scope.has_key?(symbol.to_s)
    $global[:namespaces][$global[:scope]][symbol.to_s] = value.eval(scope)
   }
  $global[:namespaces][:global]["def"]  = def_

  do_ = lambda {|scope, *args|
    args[0...-1].each {|exp|
      exp.eval(scope)
    }
    args[-1].eval(scope)
  }
  $global[:namespaces][:global]["do"] = do_

  cond = lambda {|scope, *args|
    return $global[:namespaces][:global]["nil"] if args.size == 0
    array = []

    #partition args into blocks of 2
    args.each_with_index do |x, i|
      array << [] if i % 2 == 0
      array.last << x
    end
    retval = $global[:namespaces][:global]["nil"]
    array.each {|pred, val|
      if pred.eval(scope).value
        retval = val.eval(scope)
        break
      end
    }
    return retval
  }
  $global[:namespaces][:global]["cond"] = cond

  cons = lambda {|scope, value, list|
  list_eval = list.eval(scope)
    raise "cons expects a list, but got #{list.eval(scope).class}" \
     unless list_eval.is_a?(List)
    List.new([value.eval(scope), list_eval.value].flatten)
  }
  $global[:namespaces][:global]["cons"] = cons

  append = lambda {|scope, value, list|
  list_eval = list.eval(scope)
    raise "append expects a list, but got #{list.eval(scope).class}" \
     unless list_eval.is_a?(List)
    List.new([list_eval.value, value.eval(scope)].flatten)
  }
  $global[:namespaces][:global]["append"] = append
  
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
  $global[:namespaces][:global]["let"] = let

  loop_ = lambda {|scope, binds, *body|
    #FIXME: a lot of this is just duplicate let code!
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
      local[sym.value] = val.eval(local)
    }
    
    local["recur"] = lambda {|s, *bi|
      ctr = 0
      bindings.each {|sym, _|
        next if sym == []
        raise "recur given too few values! Got #{bi.flatten.length}," + 
          " needed #{bindings[0...-1].length}" unless ctr  < bi.flatten.length
        local[sym.value] = bi[ctr].eval(local)
        ctr += 1
      }

      raise "recur given too many values! Got #{bi.flatten.length}," +
        " needed #{bindings[0...-1].length}" unless (ctr ) == bi.flatten.length
        
      body[0...-1].each {|exp|
        exp.eval(local)
      }
      return body[-1].eval(local)
    }

    body[0...-1].each {|exp|
      exp.eval(local)
    }
    #return last element of body
    body[-1].eval(local)          
  }
  $global[:namespaces][:global]["loop"] = loop_

  try = lambda {|scope, *body|
    catch_list = []
    last = nil

    #collect every catch statement into an array
    body.each {|exp|
      next unless exp.is_a?(List)
      catch_list << exp if exp.car.value == "catch"
    }

    begin
      body.each {|exp|
        #don't evaluate catch 
        next if exp.is_a?(List) and exp.car.value == "catch"
        last = exp.eval(scope)
      }
    rescue Exception => e
      matched = false
      retval = nil
      catch_list.each {|stmt|
        raise "Malformed catch statement: #{stmt}" unless stmt.count.value == 4
        dummy, ex_class, var, body = stmt.value
        if e.is_a?(ex_class.eval(scope))
          matched = true
          local = Scope.new(scope)
          local[var.value] = e
          retval = body.eval(local)
          break
        end
      }
      raise e unless matched
      return retval
    end
    last
  }
  $global[:namespaces][:global]["try"] = try

  nil_ = lambda {|scope, expr|
    eval = expr.eval(scope)
    return true if eval.nil?
    return true if eval.is_a?(LispSymbol) and eval.value == nil
    return true if eval.is_a?(List) and (eval.value.flatten.empty? or eval.value.flatten == [])
    false
  }
  $global[:namespaces][:global]["nil?"] = nil_

  #cast to Ruby classes

  int = lambda { |scope, value| Integer(value.eval(scope).value) }
  $global[:namespaces][:global]["int"] = int

  float = lambda { |scope, value| Float(value.eval(scope).value) }
  $global[:namespaces][:global]["float"] = float

  str = lambda {|scope, *values|
    val = ""
    values.each{|str| val << str.eval(scope).to_s }
    val
  }
  $global[:namespaces][:global]["str"] = str

  ruby = lambda { |scope, value|
    raise "String expected as argument!" unless value.eval(scope).is_a?(String)
    Kernel.eval value.eval(scope).to_s
  }
  $global[:namespaces][:global]["ruby"] = ruby

  call = lambda { |scope, method, class_, *args|
    class_.eval(scope).__send__(method.value, *args.collect \
      {|elem| elem.eval(scope).value})
  }
  $global[:namespaces][:global]["call"] = call

  ns = lambda {|scope, *sym|
    raise ArgumentError, "Wrong number of arguments (#{sym.length} for 1)" \
      if sym.size > 1
    sym = sym == [] ? :global : sym[0]
    raise "ns expects a symbol, but got a #{sym.class}" \
     unless sym.is_a?(LispSymbol) or sym.is_a?(Symbol)
    $global[:namespaces][sym.value] = Scope.new $global[:namespaces][:global] \
      unless $global[:namespaces][sym.value]
    $global[:scope] = sym.value
  }
  $global[:namespaces][:global]["ns"] = ns

  thread = lambda {|scope, *body|
    last = nil
    Thread.new do
      body.each {|exp|
        last = exp.eval(scope)
      }
    end
    last
  }
  $global[:namespaces][:global]["thread"] = thread

  lock = lambda {|scope, *body|
    last = nil
    Mutex.new.synchronize {
      body.each{|exp|
        last = exp.eval(scope)
      }
    }
    last
  }
  $global[:namespaces][:global]["lock"] = lock

  block = lambda {|scope, locals, *body|
    Proc.new {|*args|
      raise "Wrong number of arguments to block (#{args.length}" \
      " for #{locals.count.value})" unless args.length == locals.count.value
      local = Scope.new(scope)
      i = 0
      while i < args.length
        local[locals.value[i].value] = args[i]
        i += 1
      end
      body.each {|exp|
        exp.eval(local)
      }
    }
  }
  $global[:namespaces][:global]["block"] = block

  enum = lambda { |scope, method, obj, block|
    obj.eval(scope).__send__(method.value, &block.eval(scope))
  }
  $global[:namespaces][:global]["enum"] = enum
end

