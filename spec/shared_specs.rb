shared_examples_for "an option" do

  describe "#names" do
    specify { subject.names.should be_kind_of(Array) }
    specify { subject.names.each {|i| i.should be_kind_of(String) } }
  end
  
  describe "#desc" do
    specify { subject.desc.should be_kind_of(String) }
  end

  describe "#block" do
    specify { subject.block.should be_kind_of(Proc) }
  end

end