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
    end

    def read_list
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
      str
    end

    def read_num
      num = self.current
      until self.shift =~ /[)]|#{@@ws}/
        num << self.current
      end
      return Float(num)   if num =~ /\./
      return Integer(num)
    end

    def read_symbol
    end

    def read_keyword
    end
  end
end

