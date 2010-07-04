require 'optparse'
require 'lispr'

module Lispr
  class CommandLine
    def initialize(args)
      @args     = args
      @options  = {}
    end

    #Parse command line args. This is called by parse! which will
    #handle exceptions thrown from here
    def parse
      @opts = OptionParser.new do |opts|
        opts.banner = "Usage #{$0} [options] [file]"

        opts.on("-v", "--version", "Display version an exit") do
          puts "lispr v#{::Lispr::VERSION}"
          exit 0
        end

        opts.on("-i [prompt]", "--interative [prompt]",
          "Start a REPL, optionally specifying a prompt") do |prompt|
            @options[:prompt]       = prompt
            @options[:interactive]  = true
          end

        opts.on("-?", "-h", "--help", "Display this help message") do
          puts @opts
          exit 0
        end

        opts.on("-t", "--trace", "Provide more specific errors") do
          @options[:trace] = true
        end

        opts.on("-e code", "--evaluate code", "Evaluate a single line of code") do |code|
          Lispr::Reader.new(code+"\n").read.each {|x| puts x.eval($scope)}
          exit 0
        end

      end

      @opts.parse!(@args)

      process_result

      @options
    end

    def parse!
      begin
        parse
      rescue Exception => e
        raise e if @options[:trace] || e.is_a?(SystemExit)

        if e.kind_of?(OptionParser::ParseError)
          puts e.message
          puts @opts
        else
          print "#{e.class}: " unless e.class == RuntimeError
          puts  "#{e.message}"
        end
        exit 1
      end
      exit 0
    end

    def process_result
      args = @args.dup
      file_name = args.shift
      if @options[:interative] || (not file_name)
        Lispr::REPL.new().repl unless @options[:prompt]
        Lispr::REPL.new(@options[:prompt]).repl if @options[:prompt]
      end

    end
  end
end

