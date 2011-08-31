require 'spec_helper'

describe Rasync::Extensions do

  context 'Array should have the extensions' do

    before(:each) do
      @a = [ 1, 2 ]
    end
    
    it "should delegate a call to async_send to the async_send_opts method" do
      @a.should_receive(:async_send_opts).with(:sort, {}, 'abc' )
      @a.async_send(:sort, 'abc')
    end

    it "should delegate a call to async_send_opts to the Queue.put_call! method" do
      Rasync::Queue.should_receive(:put_call!).with(@a, :sort, {:pri => 5}, ['abc'])

      @a.async_send_opts(:sort, {:pri => 5}, 'abc')
    end

  end

  context 'Hash should have the extensions' do

    before(:each) do
      @h = { :a1 => 1 }
    end
    
    it "should delegate a call to async_send to the async_send_opts method" do
      @h.should_receive(:async_send_opts).with(:sort, {}, 'abc' )
      @h.async_send(:sort, 'abc')
    end

    it "should delegate a call to async_send_opts to the Queue.put_call! method" do
      Rasync::Queue.should_receive(:put_call!).with(@h, :sort, {:pri => 5}, ['abc'])

      @h.async_send_opts(:sort, {:pri => 5}, 'abc')
    end

  end

  context 'Module should have the extensions' do

    module TMod
    end

    it "should delegate a call to async_send to the async_send_opts method" do
      TMod.should_receive(:async_send_opts).with(:sort, {}, 'abc' )
      TMod.async_send(:sort, 'abc')
    end

    it "should delegate a call to async_send_opts to the Queue.put_call! method" do
      Rasync::Queue.should_receive(:put_call!).with(TMod, :sort, {:pri => 5}, ['abc'])

      TMod.async_send_opts(:sort, {:pri => 5}, 'abc')
    end

  end

  context "Classes with the rrepr method" do

    module AMod
    end

    it "should render a symbol to look like a symbol" do
      :doggie.rrepr.should == ':doggie'
    end

    it "should render a module as the name of the module" do
      AMod.rrepr.should == 'AMod'
    end
    
    it "should render a nil class as the word nil" do
      nil.rrepr.should == 'nil'
    end

    it "should render a false class as the word false" do
      false.rrepr.should == 'false'
    end

    it "should render a true class as the word true" do
      true.rrepr.should == 'true'
    end

    it "should render a numeric object as the number" do
      1233.rrepr.should == '1233'
    end

    it "should render a string as a quoted string" do
      "dave".rrepr.should == '"dave"'
    end

    it "should render a string as an array with the values rendered as appropriate" do
      [ :a, 2, 'dave' ].rrepr.should == '[:a, 2, "dave"]'
    end

    it "should render a hash as a hash" do
      { :a => 'dave', 'uon' => 3 }.rrepr.should == '{:a=>"dave", "uon"=>3}'
    end

    it "should render a range as a range" do
      (1..8).rrepr.should == '(1..8)'
    end

    it "should render a time as a time" do
      Time.new(2001, 02, 03, 8,7,6).rrepr.should == "Time.parse('2001-02-03 08:07:06 -0700')"
    end

    it "should render a date as a date" do
      Date.new(2001, 02, 03).rrepr.should == "Date.parse('2001-02-03')"
    end
  end

end
