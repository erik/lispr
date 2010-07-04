#TODO: LispString is busted

require 'lispr/command_line'
require 'lispr/reader'
require 'lispr/repl'
require 'lispr/scope'
require 'lispr/types'
require 'lispr/version'



module Lispr
  $scope = Scope.new
  $scope["true"]  = LispSymbol.new true
  $scope["false"] = LispSymbol.new false
  $scope["nil"]   = LispSymbol.new nil

  add = lambda do |scope, *args|
    return 0 if args.nil? || args.empty? || args == $scope["nil"]
    return args[0..-2].each.inject(LispNumeric.new 0) {|x, t| x.eval(scope) + t.eval(scope)}
  end
  $scope["+"]    = add
end

