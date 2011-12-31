module MiniTest::Expectations
  # a.must_have :key?, :yay
  alias_method :must_have, :must_be
  # a.wont_have :key?, :boo
  alias_method :wont_have, :wont_be
  # this { ... }.must_raise ExceptionalException
  alias_method :this, :proc
  
  # true.must_be_true
  infect_an_assertion :assert, :must_be_true
  # true.wont_be_false
  alias_method :wont_be_false, :must_be_true
  
  # false.must_be_false
  infect_an_assertion :refute, :must_be_false
  # false.wont_be_true
  alias_method :wont_be_true, :must_be_false
  
  # @example
  #   arg.must_be_argument :name => :arg, :optional => true, :type => Integer
  #
  def must_be_argument(opts)
    opts.each do |k,v|
      self.instance_variable_get("@#{k}").must_equal v
    end
  end
  
  def must_have_option(opt)
    self.has_option?(opt).must_be_true
  end
  
  def must_have_command(opt)
    self.has_command?(opt).must_be_true
  end
end
