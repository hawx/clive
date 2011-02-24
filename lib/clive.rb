require 'ast_ast'
require 'attr_plus'

require 'clive/parser'
require 'clive/exceptions'
require 'clive/tokens'

require 'clive/option'
require 'clive/command'
require 'clive/switch'
require 'clive/flag'
require 'clive/bool'

require 'clive/output'
require 'clive/formatter'

# Clive is a simple dsl for creating command line interfaces
#
# @example Simple Example
#
#   require 'clive'
#
#   class CLI
#     include Clive::Parser
#     
#     desc 'A switch'
#     switch :s, :switch do
#       puts "You used a switch"
#     end
#     
#     desc 'A flag'
#     flag :hello, :args => "NAME" do |name|
#       puts "Hello, #{name}"
#     end
#     
#     desc 'True or false'
#     bool :which do |which|
#       case which
#       when true
#         puts "true, yay"
#       when false
#         puts "false, not yay"
#       end
#     end
#     
#     option_list :purchases
#     
#     command :new, :buy do
#       switch :toaster do
#         purchases << :toaster
#       end
#       
#       switch :tv do
#         purchases << :tv
#       end
#     end
#     
#   end
#
#   CLI.parse(ARGV)
#
module Clive
  
end
