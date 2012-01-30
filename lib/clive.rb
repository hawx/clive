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
#   end
#
#  cli.run ARGV
#
# For very small tasks where you _just_ need to collect options passed and query
# about them you can use the {Kernel#Clive} method.
#
#   r = Clive(:quiet, :verbose).run(ARGV)
#
#   $log = Logger.new(STDOUT)
#   $log.level = Logger::FATAL if r.quiet
#   $log.level = Logger::DEBUG if r.verbose
#
#   # do some stuff
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

    def respond_to_missing?(sym, include_private=false)
      instance.respond_to?(sym, include_private)
    end

    unless Kernel.respond_to?(:respond_to_missing?)
      def respond_to?(sym, include_private=false)
        respond_to_missing?(sym, include_private)
      end
    end

  end

  # This allows you to use Clive without defining a class, but while keeping all
  # of the control.
  #
  # There is one caveat though when using this style: types can not be
  # referenced with just the type name. Instead the full class path/name must be
  # given. So instead of using +opt :num, as: Integer+ you need to use +opt
  # :num, as: Clive::Type::Integer+, and similarly for all types.
  #
  # @param opts [Hash] Options to create with, see {Base#initialize}
  # @example
  #
  #   c = Clive.new { opt :v, :verbose }
  #   r = c.run ARGV
  #
  def self.new(opts={}, &block)
    Base.new(opts, &block)
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
