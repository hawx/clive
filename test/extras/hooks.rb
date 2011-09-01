module MiniTestWithHooks
  class Unit < MiniTest::Unit

    attr_reader :before_suites, :after_suites

    def before_suites
      (@before_suites ||= []) << block
    end
    
    def after_suites(&block)
      (@after_suites ||= []) << block
    end
    
    def _run_suites(suites, type)
      begin
        before_suites.each(&:call)
        super(suites, type)
      ensure
        after_suites.each(&:call)
      end
    end
    
    def _run_suites(suite, type)
      begin
        suite.before_suite.each(&:call) if suite.respond_to?(:before_suite)
        super(suite, type)
      ensure
        suite.after_suite.each(&:call) if suite.respond_to?(:after_suite)
      end
    end
    
  end
end


class MiniTest::Unit
  class << self
  
    def before_each_test(&block)
      TestCase.add_setup_hook(&block)
    end
    
    def after_each_test(&block)
      TestCase.add_teardown_hook(&block)
    end
  
  end
end

MiniTest::Unit.runner = MiniTestWithHooks::Unit.new
