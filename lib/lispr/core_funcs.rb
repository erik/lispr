require 'lispr/types'
require 'lispr/scope'

module Lispr
  $scope = Scope.new
  $scope["true"]  = LispSymbol.new true
  $scope["false"] = LispSymbol.new false
  $scope["nil"]   = LispSymbol.new nil

  #Math functions

  add = lambda do |scope, *args|
    return 0 if args.nil? || args.empty? || args == $scope["nil"]
    return args.each.inject(LispNumeric.new 0) {|x, t| x.eval(scope) + t.eval(scope)}
  end
  $scope["+"]    = add

  sub = lambda do |scope, first, *args|
    return -first if args.size == 0
    return args.each.inject(first) {|x, t| x.eval(scope) - t.eval(scope)}
  end
  $scope["-"]    = sub

  mul = lambda do |scope, *args|
    return 1 if args.size == 0
    return args.each.inject(LispNumeric.new 1){|x, t| x.eval(scope) * t.eval(scope)}
  end
  $scope["*"]    = mul

  div = lambda do |scope, first, *rest|
    return 1/first if rest.size == 0
    return rest.each.inject(LispNumeric.new first) {|x, t| x.eval(scope) / t.eval(scope)}
  end
  $scope["/"]    = div

  mod = lambda { |scope, first, second| first.eval(scope) % second.eval(scope) }
  $scope["%"]    = mod
  $scope["mod"]  = mod

  lt = lambda { |scope, first, second| first.eval(scope) < second.eval(scope)}
  $scope["<"]    = lt

  #standard utility functions

  class_ = lambda { |scope, first| first.eval(scope).class }
  $scope["class"] = class_

  eql = lambda{ |scope, first, second| first.eql? scope, second }
  $scope["="] = eql

  comment = lambda { |scope, *args| $scope["nil"]}
  $scope["comment"] = comment

  #TODO: make def work on a local scope rather than global!
  def_ = lambda { |scope, symbol, value| $scope[symbol.to_s] = value.eval(scope)}
  $scope["def"]  = def_

  #cast to Ruby classes

  int = lambda { |scope, value| Integer(value.eval(scope).value) }
  $scope["int"] = int

  float = lambda { |scope, value| Float(value.eval(scope).value) }
  $scope["float"] = float

end

