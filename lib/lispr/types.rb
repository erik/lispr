require 'lispr/ruby_extensions'

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

    def == (other)
      other.is_a?(self.class) and other.value == self.value
    end
  end

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
        $global[:namespaces][:global]["nil"]
      end
    end

    def cdr
      if @value.size == 0 or @value == [[]]
        $global[:namespaces][:global]["nil"]

      elsif @value[-1] == []
        List.new @value[1..-1]

      else
        @value[1]
      end
    end

    def count
      LispNumeric.new @value.flatten.length
    end

    def flatten
      @value.flatten
    end

    def to_s
      return '()' if @value.size == 0 or @value == [[]]
      str = '(' + @value[0...-1].each {|x| x.to_s}.join(' ').rstrip + ')'
    end

    def eval(scope)
      if @value.size == 0 or @value == [[]]
        LispSymbol.new "nil"

      else

        self.car.eval(scope).call(scope, *self.cdr.value[0...-1])
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
      if @value =~ /\./
        tmp = @value.split /\./
        ns  = tmp[0...-1]
        sym = tmp[-1]

        namespace = $global[:namespaces]
        ns.each {|n|
          n = :global if n == ""
          raise "Namespace #{n} doesn't exist!" unless namespace.is_a?(Hash) \
            and namespace.has_key? n
          namespace = namespace[n]
        }
        namespace[sym]                
      else
        scope[@value]
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

    def eql? scope, other
      other.eval(scope).is_a?(Keyword) and other.eval(scope).value == @value
    end

    def to_s
      ':' + @value
    end

    def eval(scope)
      self
    end
  end

  class Lambda
    include Generic
    
    def initialize(bindings, body)
      @bindings = bindings
      @body     = body

      #minimum number of arguments the fn can operate with
      @min_args = 0
      #maximum number of arguments the fn can accept. -1 if unlimited
      @max_args = 0
      
      #only one optional argument is allowed, so have we used it already?
      opt_args = false
      #same for rest args
      rest_args = false
      
      #determine min and max args
      @bindings.value.flatten.each_with_index {|exp, i|
        if exp.value =~ /\?\Z/
          raise "Only one optional argument if allowed!" if opt_args
          opt_args = true
          @max_args += 1
        elsif exp.value =~ /&\Z/
          raise "Rest argument must be last!" unless (@bindings.value[i] \
                                                      == @bindings.flatten.value[-1])
          raise "Only one rest argument permitted!" if rest_args
          rest_args = true
          @max_args = -1
        else
          @min_args += 1
          @max_args += 1
        end
      }
    end

    def eval(scope)
      self
    end

    #(defn func (x y? z) )
    #(func 1 2 3) => x 1, y 2, z 3
    #(func 1 3)   => x 1, y :not-provided, z 3

    #(defn func (x y &z)
    #(func 1 2 3) => x 1, y 2, z '(3)
    #(func 1 2)   => x 1, y 2, z '()
    #(func 1 2 3 4 5) => x 1, y 2, z '(3 4 5)

    #(fn (x y) (+ x y))
    def call(scope, *args)
      #local scope
      local = Scope.new(scope)

      bind_ctr = 0
      arg_ctr  = 0

      if @max_args != -1
        raise "Expected between #{@min_args} and #{@max_args} arguments for function, " +
          "but got #{args.length}" unless args.length.between?(@min_args, @max_args)
      else
        raise "Expected at least #{@min_args} arguments for function, " +
          "but got #{args.length}" unless args.length >= @min_args
      end

      while bind_ctr < @bindings.value.length - 1 and (arg_ctr <  args.length \
                                                       or arg_ctr < @max_args \
                                                       or @max_args == -1)
        arg_eval = args[arg_ctr].eval(scope)
        val = @bindings.value[bind_ctr].value
        if val =~ /\?$/ and (args.length <  @max_args)
          local[val[0...-1]] = LispSymbol.new("not-provided")
        elsif val =~ /\&$/
          local[val[0...-1]] = List.new(arg_ctr < args.length ? args[arg_ctr..-1] :  [])
          break
        else
          val = val[0...-1] if val =~ /\?$/
          local[val] = arg_eval
          arg_ctr += 1
        end
        bind_ctr += 1
      end

      @body.eval(local)
    end

    def to_s
      "(fn #{@bindings.to_s} #{@body.to_s})"
    end
  end

  class Macro < Lambda

    def call(scope, *args)
      local = Scope.new(scope)

      bind_ctr = 0
      arg_ctr  = 0
      
      if @max_args != -1
        raise "Expected between #{@min_args} and #{@max_args} arguments for function, " +
          "but got #{args.length}" unless args.length.between?(@min_args, @max_args)
      else
        raise "Expected at least #{@min_args} arguments for function, " +
          "but got #{args.length}" unless args.length >= @min_args
      end

      while bind_ctr < @bindings.value.length - 1 and (arg_ctr <  args.length \
                                                       or arg_ctr < @max_args \
                                                       or @max_args == -1)
        val = @bindings.value[bind_ctr].value
        if val =~ /\?$/ and (args.length <  @max_args)
          local[val[0...-1]] = LispSymbol.new("not-provided")
        elsif val =~ /\&$/
          local[val[0...-1]] = List.new(arg_ctr < args.length ? args[arg_ctr..-1] :  [])
          break
        else
          val = val[0...-1] if val =~ /\?$/
          local[val] = args[arg_ctr]
          arg_ctr += 1
        end
        bind_ctr += 1
      end

      @body.flatten!

      @body[0...-1].each{|exp|
        exp.eval(local)
      }
      @body[-1].eval(local).eval(scope)

    end   

    alias [] call   

    def to_s
      "(macro #{@bindings.to_s} #{@body.to_s})"
    end
  end

  class LispHash < Hash
    def [](val)
      self.keys.each {|key|
        return self.fetch(key) if val.is_a?(key.class) and key.value == val.value
      }
      nil
    end
    # slightly prettier to_s
    def to_s
      str = "{ "
      keys.each {|key|
        str << "#{key} => #{self[key].to_s}, "
      }
      str << "\b\b }"
    end
  end
end

