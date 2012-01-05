$: << File.dirname(__FILE__)

require 'clive/error'
require 'clive/output'
require 'clive/version'
require 'clive/struct_hash'
require 'clive/formatter'
require 'clive/formatter/plain'
require 'clive/formatter/colour'

require 'clive/type'
require 'clive/argument'
require 'clive/arguments'
require 'clive/arguments/parser'
require 'clive/option/runner'
require 'clive/option'
require 'clive/command'
require 'clive/parser'
require 'clive/base'


# Clive is a DSL for creating command line interfaces. Generally to use it you
# will inherit from it with your own class.
#
#   class CLI < Clive
#     opt :working, 'Test if it is working' do
#       puts "YEP!".green
#     end
#   end
#
#   CLI.run ARGV
#
#   # app.rb --working
#   #=> "YEP!"
#
# But it is possible to create a new instance of Clive instead in almost the
# same way.
#
#   cli = Clive.new do
#     opt :working, 'Test if it is working' do
#       puts "YEP!".green
#     end
#  end
#
#  cli.run ARGV
#
# For very small tasks where you _just_ need to collect options passed and query
# about them you can use {Kernel#Clive}.
#
#   r = Clive(:working).run(ARGV)
#   if r.working
#     puts "YEP!".green
#   end
#
class Clive

  extend Type::Lookup

  class << self
    attr_accessor :instance

    # Sets up proxy methods for each relevent method in {Base} to an instance of {Base}.
    def inherited(klass)
      klass.instance = Base.new

      str = (Base.instance_methods(false) | Command.instance_methods(false)).map do |sym|
        <<-EOS
          def self.#{sym}(*args, &block)
            instance.send(:#{sym}, *args, &block)
          end
        EOS
      end.join("\n")
      klass.instance_eval str
    end

    def method_missing(sym, *args, &block)
      instance.send(sym, *args, &block)
    end

    if Kernel.respond_to?(:respond_to_missing?)
      def respond_to_missing?(sym, include_private=false)
        instance.respond_to?(sym, include_private)
      end
    else
      def respond_to?(sym, include_private=false)
        instance.respond_to?(sym, include_private)
      end
    end
  end

  # This allows you to use Clive without defining a class, but while keeping all
  # of the control.
  #
  # @example
  #
  #   c = Clive.new { opt :v, :verbose }
  #   r = c.run ARGV
  #
  def self.new(&block)
    Base.new(&block)
  end

end

module Kernel

  # The quickest way to grab a few options. This form does not allow arguments or
  # commands! It is meant to be quick and simple.
  #
  # @example
  #
  #   r = Clive(:verbose, [:b, :bare]).run(%w(--verbose))
  #   r.bare     #=> false
  #   r.verbose  #=> true
  #
  #
  #   # The above example is equivalent to
  #   r = Clive.new {
  #     opt :verbose
  #     opt :b, :bare
  #   }.run(%w(--verbose))
  #
  # @param names [#to_sym, Array<#to_sym>] List of names to create options for
  # @return [Clive] A clive instance setup with the correct options
  #
  def Clive(*names)
    c = Clive::Base.new
    names.each do |o|
      c.option *Array(o).map(&:to_sym)
    end
    c
  end

end
