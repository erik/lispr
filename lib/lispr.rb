require 'lispr/command_line'
require 'lispr/reader'
require 'lispr/repl'
require 'lispr/scope'
require 'lispr/types'
require 'lispr/version'
#require 'lispr/core_scope'


module Lispr
  $scope = Scope.new
  $scope["true"]  = LispSymbol.new true
  $scope["false"] = LispSymbol.new false
  $scope["nil"]   = LispSymbol.new nil

  add = lambda do |scope, *args|
    puts args[0].each.inject(LispNumeric.new 0) {|x, t| x + t}
  end
  $scope["+"]    = add
end

