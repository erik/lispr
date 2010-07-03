require 'lispr/reader'
require 'lispr/version'
module Lispr
  class REPL
    def initialize(prompt='lispr> ')
      @prompt = prompt
    end

    def repl
      puts "lispr v#{::Lispr::VERSION}"
      while true
        begin
          print @prompt
          input = gets
          begin
            Reader.new(input).read
          rescue EOFError => e
            input += gets
            retry
          end
        rescue Exception => e
          #subclasses of StandardError are not usually serious, and can be
          #reported without exitting
          if e.is_a?(StandardError) || e.is_a?(ScriptError)
            print "#{e.class}: "
            puts  "#{e.message}"
            next
          end
          raise e unless e.is_a?(SignalException)
          exit 0
        end
      end
    end
  end
end

