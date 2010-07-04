#TODO: add support for quote, syntax quote, etc

module Lispr
  class Reader
    @@ws = /\s+/

    def initialize(source)
      @line_num = 1
      @source   = source
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

    def read
      expr = []
      while @index < @source.size - 1


        #skip over whitespace
        if self.current =~ @@ws
          @line_num += 1 if self.current == "\n"
          next

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

        #read a string
        elsif self.current == '"'
          expr << self.read_string

        #read an int or floating point
        elsif self.current =~ /[0-9]/
          expr << self.read_num

        #read a keyword
        elsif self.current == ':'
          expr << self.read_keyword

        #everything else is a symbol
        else
          expr << self.read_symbol
        end

        self.shift
      end
      return expr
    end

    def read_list
      expr = []
      proper = true
      while self.shift != ')'
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

        elsif self.current == '"'
          expr << self.read_string

        elsif self.current =~ /[0-9]/
          expr << self.read_num

        elsif self.current == '.'
          proper = false

        elsif self.current == ':'
          expr << self.read_keyword

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
        str << self.current
        if self.current == '\\'
          str << self.current
          str << self.shift
        end
      end
      LispString.new str
    end

    def read_num
      num = self.current
      until self.shift =~ /[)]|#{@@ws}/
        num << self.current
      end
      self.unshift

      return LispNumeric.new(num =~ /\./ ? Float(num) : Integer(num))
    end

    def read_symbol
      sym = self.current
      until self.shift =~ /[)]|#{@@ws}/
        sym += self.current
      end
      self.unshift

      LispSymbol.new sym
    end

    def read_keyword
      keyword = ""
      until self.shift =~ /[)]|#{@@ws}/
        keyword += self.current
      end
      self.unshift

      Keyword.new(keyword)
    end
  end
end

