require 'lispr/reader'
require 'lispr/version'
require 'readline'

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
              #because [].to_s returns "" and [].inspect returns "[]"
              elsif val.is_a?(Array)
                puts val.inspect
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

