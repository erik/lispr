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
            exprs = Reader.new(input).read
            exprs.each do |exp|
              print " => "
              val = exp.eval($scope)
              if val.is_a?(String)
                puts "\"#{val.to_s}\""
              elsif val.nil?
                puts "nil"
              else
                puts val.to_s
              end
            end
          rescue EOFError => e
            input += gets
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
          raise e unless e.is_a?(SignalException)
          exit 0
        end
      end
    end
  end
end

