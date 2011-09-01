module MiniTest::Assertions

  # @example
  #
  #   #                name | optional | type  | match | within
  #   assert_argument ["arg", false,     String, /ab*c/, %w(a bb abc)], argument
  def assert_argument(exp, act, msg=nil)
    [:@name, :@optional, :@type, :@match, :@within].each_with_index do |sym, i|
      assert_equal(exp[i], act.instance_variable_get(sym)) if exp[i]
    end
  end
end
