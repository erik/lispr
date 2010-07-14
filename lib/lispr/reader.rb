
module Lispr
  class Reader
    @@ws = /\s+|,/
    @@delim = /[(){}]|#{@@ws}/
    def initialize(source)
      @line_num = 1
      @source   = source + "\n" 

      @index    = 0
    end

    def current
      begin
        return @source[@index].chr
      rescue Exception => e
        raise EOFError, "Unexpected EOF at line #{@line_num}"
      end
    end

    def shift
      @index += 1
      self.current
    end

    def unshift
      @index -= 1
      self.current
    end

    #not *strictly* accurate
    alias pop  shift
    alias push unshift
    alias prev unshift

    def read(single=false)
      expr = []
      while @index < @source.length - 1

        #skip over whitespace
        if self.current =~ @@ws
          @line_num += 1 if self.current == "\n"

        #skip over comments
        elsif self.current == ";"
          while self.shift != "\n"
          end
          self.unshift
          @line_num += 1

        #read in lists
        elsif self.current == '('
          expr << self.read_list

        #extraneous closing paren
        elsif self.current == ')'
          raise SyntaxError, "Unexpected closing paren on line #{@line_num}"

        elsif self.current == '{'
          expr << self.read_hash

        elsif self.current == '}'
          raise SyntaxError, "Unexpected closing brace on line #{@line_num}"

        #read a string
        elsif self.current == '"'
          expr << self.read_string

        elsif self.current == '-'
          t = self.shift
          self.unshift
          expr << self.read_num if t =~ /[0-9]/

        #read an int or floating point
        elsif self.current =~ /[0-9]/
          expr << self.read_num

        #read a keyword
        elsif self.current == ':'
          expr << self.read_keyword

        #quote
        elsif self.current == "'"
          self.shift
          expr << List.new(Array[LispSymbol.new("quote"), *self.read(true)])
          self.unshift

        #backquote
        elsif self.current == "`"
          self.shift
          expr << List.new(Array[LispSymbol.new("backquote"), *self.read(true)])
          self.unshift

        #unquote
        elsif self.current == '~'
          self.shift
          if self.current != '@'
            expr << List.new(Array[LispSymbol.new("unquote"), *self.read(true)])
          else
            self.shift
            expr << List.new(Array[LispSymbol.new("unquote-splice"), *self.read(true)])
          end
          self.unshift

        #ruby method call
        elsif self.current == '#'
          expr << LispSymbol.new("call")

        #everything else is a symbol
        else
          expr << self.read_symbol
        end

        self.shift
        return expr if single
      end
      return expr
    end

    def read_list
      expr = []
      proper = true
      until self.shift == ')'
        if self.current =~ @@ws
          @line_num += 1 if self.current == "\n"
          next 

        elsif self.current == ';'
          while self.shift !=  "\n"
          end
          self.unshift
          @line_num += 1

        elsif self.current == '('
          expr << self.read_list

        elsif self.current == '{'
          expr << self.read_hash

        elsif self.current == '}'
          raise SyntaxError, "Unexpected closing brace on line #{@line_num}"

        elsif self.current == '"'
          expr << self.read_string

        elsif self.current == '-'
          t = self.shift
          self.unshift
          if t =~ /[0-9]/
            expr << self.read_num 
          else
            expr << self.read_symbol
          end

        elsif self.current =~ /[0-9]/
          expr << self.read_num

        elsif self.current == '.'
          puts "WARNING: Using . in lists is deprecated and will be removed"
          proper = false

        elsif self.current == ':'
          expr << self.read_keyword

        elsif self.current == "'"
          self.shift
          expr << List.new(Array[LispSymbol.new("quote"), *self.read(true)])
          self.unshift
          
        elsif self.current == "`"
          self.shift
          expr << List.new(Array[LispSymbol.new("backquote"), *self.read(true)])
          self.unshift

        elsif self.current == '~'
          self.shift
          if self.current != '@'
            expr << List.new(Array[LispSymbol.new("unquote"), *self.read(true)])
          else
            self.shift
            expr << List.new(Array[LispSymbol.new("unquote-splice"), *self.read(true)])
          end
          self.unshift

        #ruby method call
        elsif self.current == '#'
          expr << LispSymbol.new("call")

        else
          expr << self.read_symbol
        end
      end
     return List.new(expr + [[]]) if proper
     List.new(expr)
    end

    def read_string
      str = ""
      while self.shift != '"'
        str << self.current unless self.current == '\\'
        if self.current == '\\'
          esc = self.shift
          case esc
            when 'a'
              str << "\a"
            when 'b'
              str << "\b"
            when 'n'
              str << "\n"
            when 'r'
              str << "\r"
            when '\\'
              str << "\\"
            when 's'
              str << "\s"
            when 't'
              str << "\t"
            else
              raise "Unrecognized escape sequence: \\#{esc}"
          end
        end
      end
      LispString.new str
    end

    def read_num
      num = self.current
      until self.shift =~ @@delim
        num << self.current
      end
      self.unshift

      return LispNumeric.new(num =~ /\./ ? Float(num) : Integer(num))
    end

    def read_symbol
      sym = self.current
      until self.shift =~ @@delim
        sym += self.current
      end
      self.unshift

      LispSymbol.new sym
    end

    def read_keyword
      keyword = ""
      until self.shift =~ @@delim
        keyword += self.current
      end
      self.unshift

      Keyword.new(keyword)
    end

    def read_hash
      self.shift
      expr = []
      until self.current == '}'
        val = self.read(true) 
        expr << val[0] unless val == []
      end
      LispHash[*expr]
    end
  end
 
end

