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
end

