require 'lispr/reader'
require 'lispr/version'
require 'readline'

class Array
  #prettier to_s
  def e_to_s
    "[" +  self.collect {|e| (e.is_a?(Array) ? e.e_to_s : e.to_s) }.join(", ") + "]"
  end
end

module Lispr
  class REPL
    def initialize(prompt='lispr> ')
      @tty_save = `stty -g`.chomp
      @prompt = prompt

    end

    def repl
      puts "lispr v#{::Lispr::VERSION}"
      while true
        begin
          input = Readline.readline(@prompt, true)
          begin
            exprs = Reader.new(input).read
            exprs.each do |exp|
              val = exp.eval($global[:namespaces][$global[:scope]])
              print " => "
              if val.is_a?(String)
                puts "\"#{val.to_s}\""
              elsif val.nil?
                puts "nil"
              #because [].to_s returns "" and e_to_s is prettier
              elsif val.is_a?(Array)
                puts val.e_to_s
              else
                puts val.to_s
              end
            end
          rescue EOFError => e
            raise e if e.message =~ /^eval:/
            input += Readline.readline('', true)
            retry
          end
        rescue Exception => e
          #subclasses of StandardError are not usually serious, and can be
          #reported without exitting
          if e.is_a?(StandardError) || e.is_a?(ScriptError)
            print "#{e.class}: " unless e.is_a?(RuntimeError)
            puts  "#{e.message}"
            next
          end
          system('stty', @tty_save)
          raise e unless e.is_a?(SignalException)
          exit 0
        end
      end
    end
  end
end

