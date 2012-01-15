module MiniTest::Assertions

  def assert_true obj, msg = nil
    msg = message(msg) { "Expected #{mu_pp(obj)} to be true" }
    assert(obj == true, msg)
  end

  def assert_false obj, msg = nil
    msg = message(msg) { "Expected #{mu_pp(obj)} to be false" }
    assert(obj == false, msg)
  end

  def assert_has o1, op, o2 = UNDEFINED, msg = nil
    return assert_predicate o1, op, msg if UNDEFINED == o2
    msg = message(msg) { "Expected #{mu_pp(o1)} to have #{op} #{mu_pp(o2)}" }
    assert o1.__send__(op, o2), msg
  end

  def refute_has o1, op, o2 = UNDEFINED, msg = nil
    return refute_predicate o1, op, msg if UNDEFINED == o2
    msg = message(msg) { "Expected #{mu_pp(o1)} to not have #{op} #{mu_pp(o2)}" }
    refute o1.__send__(op, o2), msg
  end

  def assert_has_option obj, name, msg = nil
    msg = message(msg) { "Expected #{mu_pp(obj)} to have the option #{name}" }
    assert obj.has_option?(name), msg
  end

  def assert_has_command obj, name, msg = nil
    msg = message(msg) { "Expected #{mu_pp(obj)} to have the command #{name}" }
    assert obj.has_command?(name), msg
  end

end


module MiniTest::Expectations

  # this { ... }.must_raise ExceptionalException
  alias_method :this, :proc

  infect_an_assertion :assert_has, :must_have, :reverse
  infect_an_assertion :refute_has, :wont_have, :reverse

  infect_an_assertion :assert_true,  :must_be_true,  :unary
  infect_an_assertion :assert_false, :must_be_false, :unary

  alias_method :wont_be_false, :must_be_true
  alias_method :wont_be_true, :must_be_false

  infect_an_assertion :assert_has_option,  :must_have_option,  :reverse
  infect_an_assertion :assert_has_command, :must_have_command, :reverse

  # @example
  #
  #   arg.must_be_argument :name => :arg, :optional => true, :type => Integer
  #
  def must_be_argument(opts)
    opts.each do |k,v|
      self.instance_variable_get("@#{k}").must_equal v
    end
  end

end

class Hash

  # @example
  #
  #   hsh = {:a => 5}
  #   hsh.must_contain :a => 5
  #
  def must_contain(kv)
    kv.all? {|k,v| self[k].must_equal v }
  end

  # @example
  #
  #   hsh = {:a => 5}
  #   hsh.wont_contain :b => 5
  #
  def wont_contain(kv)
    kv.any? {|k,v| self[k].wont_equal v }
  end
end
