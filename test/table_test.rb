require File.join(File.dirname(__FILE__), 'test_helper')

class Hirb::Helpers::TableTest < Test::Unit::TestCase
  def table(*args)
    Hirb::Helpers::Table.render(*args)
  end
  before(:all) { reset_config }

  context "basic table" do
    test "renders" do
      expected_table = <<-TABLE.unindent
      +---+---+
      | a | b |
      +---+---+
      | 1 | 2 |
      | 3 | 4 |
      +---+---+
      2 rows in set
      TABLE
      table([{:a=>1, :b=>2}, {:a=>3, :b=>4}]).should == expected_table
    end

    test "with no headers renders" do
      expected_table = <<-TABLE.unindent
      +---+---+
      | 1 | 2 |
      +---+---+
      1 row in set
      TABLE
      table([{:a=>1, :b=>2}], :headers=>nil).should == expected_table
    end

    test "with string keys renders" do
      expected_table = <<-TABLE.unindent
      +---+---+
      | a | b |
      +---+---+
      | 1 | 2 |
      | 3 | 4 |
      +---+---+
      2 rows in set
      TABLE
      table([{'a'=>1, 'b'=>2}, {'a'=>3, 'b'=>4}]).should == expected_table
    end

    test "with array only rows renders" do
      expected_table = <<-TABLE.unindent
      +---+---+
      | 0 | 1 |
      +---+---+
      | 1 | 2 |
      | 3 | 4 |
      +---+---+
      2 rows in set
      TABLE
      table([[1,2], [3,4]]).should == expected_table
    end

    test "with too many fields raises error" do
      assert_raises(Hirb::Helpers::Table::TooManyFieldsForWidthError) { table([Array.new(70, 'AAA')]) }
    end

    test "with no rows renders" do
      table([]).should == "0 rows in set"
    end
  end

  context "table with" do
    test "fields option renders" do
      expected_table = <<-TABLE.unindent
      +---+---+
      | b | a |
      +---+---+
      | 2 | 1 |
      | 4 | 3 |
      +---+---+
      2 rows in set
      TABLE
      table([{:a=>1, :b=>2}, {:a=>3, :b=>4}], :fields=>[:b, :a]).should == expected_table
    end

    test "fields option and array only rows" do
      expected_table = <<-TABLE.unindent
      +---+---+
      | 0 | 2 |
      +---+---+
      | 1 | 3 |
      +---+---+
      1 row in set
      TABLE
      table([[1,2,3]], :fields=>[0,2]).should == expected_table
    end

    test "fields and number options copies fields option and does not modify it" do
      options = {:fields=>[:f1], :number=>true}
      table({:f1=>1, :f2=>2}, options)
      options[:fields].should == [:f1]
    end

    test "invalid fields option renders empty columns" do
      expected_table = <<-TABLE.unindent
      +---+---+
      | b | c |
      +---+---+
      | 2 |   |
      | 4 |   |
      +---+---+
      2 rows in set
  TABLE
      table([{:a=>1, :b=>2}, {:a=>3, :b=>4}], :fields=>[:b, :c]).should == expected_table
    end

    test "invalid fields in field_lengths option renders" do
      expected_table = <<-TABLE.unindent
      +------------+---+
      | a          | b |
      +------------+---+
      | AAAAAAA... | 2 |
      +------------+---+
      1 row in set
  TABLE
      table([{:a=> "A" * 50, :b=>2}], :field_lengths=>{:a=>10,:c=>10}).should == expected_table
    end

    test "field_lengths option and field_lengths less than 3 characters renders" do
      expected_table = <<-TABLE.unindent
      +----+---+
      | a  | b |
      +----+---+
      | AA | 2 |
      +----+---+
      1 row in set
  TABLE
      table([{:a=> "A" * 50, :b=>2}], :field_lengths=>{:a=>2}).should == expected_table
    end

    test "field_lengths option renders" do
      expected_table = <<-TABLE.unindent
      +------------+---+
      | a          | b |
      +------------+---+
      | AAAAAAA... | 2 |
      +------------+---+
      1 row in set
  TABLE
      table([{:a=> "A" * 50, :b=>2}], :field_lengths=>{:a=>10}).should == expected_table
    end

    test "max_width option renders" do
      expected_table = <<-TABLE.unindent
      +-----------+---+-----------+
      | a         | b | c         |
      +-----------+---+-----------+
      | AAAAAA... | 2 | CCCCCC... |
      +-----------+---+-----------+
      1 row in set
  TABLE
      table([{:a=> "A" * 50, :b=>2, :c=>"C"*10}], :max_width=>30).should == expected_table
    end

    test "max_width option nil renders full table" do
      expected_table = <<-TABLE.unindent
      +----------------------------------------------------+---+------------+
      | a                                                  | b | c          |
      +----------------------------------------------------+---+------------+
      | AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA | 2 | CCCCCCCCCC |
      +----------------------------------------------------+---+------------+
      1 row in set
  TABLE
      table([{:a=> "A" * 50, :b=>2, :c=>"C"*10}], :max_width=>nil).should == expected_table
    end

    test "global width renders" do
      expected_table = <<-TABLE.unindent
      +-----------+---+-----------+
      | a         | b | c         |
      +-----------+---+-----------+
      | AAAAAA... | 2 | CCCCCC... |
      +-----------+---+-----------+
      1 row in set
  TABLE
      Hirb::View.load_config
      Hirb::View.resize(30)
      table([{:a=> "A" * 50, :b=>2, :c=>"C"*10}]).should == expected_table
      reset_config
    end

    test "headers option and headers longer than fields renders" do
      expected_table = <<-TABLE.unindent
      +---+---------+---------+
      | a | field B | field C |
      +---+---------+---------+
      | A | 2       | C       |
      +---+---------+---------+
      1 row in set
  TABLE
      table([{:a=> "A", :b=>2, :c=>"C"}], :headers=>{:b=>"field B", :c=>"field C"}).should == expected_table
    end

    test "headers option and headers shortened by field_lengths renders" do
      expected_table = <<-TABLE.unindent
      +-------+---+
      | fi... | b |
      +-------+---+
      | A     | 2 |
      +-------+---+
      1 row in set
  TABLE
      table([{:a=> "A", :b=>2}], :headers=>{:a=>"field A"}, :field_lengths=>{:a=>5}).should == expected_table
    end

    test "headers option as an array renders" do
      expected_table = <<-TABLE.unindent
      +---+---+
      | A | B |
      +---+---+
      | 1 | 2 |
      | 3 | 4 |
      +---+---+
      2 rows in set
      TABLE
      table([[1,2], [3,4]], :headers=>['A', 'B']).should == expected_table
    end

    test "filters option renders" do
      expected_table = <<-TABLE.unindent
      +-----------+---+
      | 0         | 1 |
      +-----------+---+
      | s,o,m,e   | 2 |
      | t,h,i,n,g | 1 |
      +-----------+---+
      2 rows in set
      TABLE
      table([['some', {:num=>2}], ['thing', {:num=>1}]], :filters=>{0=>lambda {|e| e.split("").join(",")},
        1=>[:[], :num]}).should == expected_table
    end

    test "number option renders" do
      expected_table = <<-TABLE.unindent
      +--------+---+---+
      | number | 0 | 1 |
      +--------+---+---+
      | 1      | a | b |
      | 2      | c | d |
      +--------+---+---+
      2 rows in set
      TABLE
      table([['a','b'], ['c', 'd']], :number=>true).should == expected_table
    end
  end

  context "object table" do
    before(:all) {
      @pets = [stub(:name=>'rufus', :age=>7, :to_s=>'rufus'), stub(:name=>'alf', :age=>101, :to_s=>'alf')]
    }
    test "renders" do
      expected_table = <<-TABLE.unindent
      +-------+-----+
      | name  | age |
      +-------+-----+
      | rufus | 7   |
      | alf   | 101 |
      +-------+-----+
      2 rows in set
      TABLE
      Hirb::Helpers::ObjectTable.render(@pets, :fields=>[:name, :age]).should == expected_table
    end

    test "with no options defaults to to_s field" do
      expected_table = <<-TABLE.unindent
      +-------+
      | value |
      +-------+
      | rufus |
      | alf   |
      +-------+
      2 rows in set
      TABLE
      Hirb::Helpers::ObjectTable.render(@pets).should == expected_table
    end

    test "renders simple arrays" do
      expected_table = <<-TABLE.unindent
      +-------+
      | value |
      +-------+
      | 1     |
      | 2     |
      | 3     |
      | 4     |
      +-------+
      4 rows in set
      TABLE
      Hirb::Helpers::ObjectTable.render([1,2,3,4]).should == expected_table
    end
  end

  context "activerecord table" do
    before(:all) {
      @pets = [stub(:name=>'rufus', :age=>7, :class=>mock(:column_names=>[:age, :name])), stub(:name=>'alf', :age=>101)]
    }
    test "renders" do
      expected_table = <<-TABLE.unindent
      +-----+-------+
      | age | name  |
      +-----+-------+
      | 7   | rufus |
      | 101 | alf   |
      +-----+-------+
      2 rows in set
      TABLE
      Hirb::Helpers::ActiveRecordTable.render(@pets).should == expected_table
    end
  end

  context "auto table" do
    test "converts nonarrays to arrays and renders" do
      require 'set'
      expected_table = <<-TABLE.unindent
      +-------+
      | value |
      +-------+
      | 1     |
      | 2     |
      | 3     |
      +-------+
      3 rows in set
      TABLE
      Hirb::Helpers::AutoTable.render(::Set.new([1,2,3])).should == expected_table
    end
  end

  context "vertical table" do
    test "should display vertically" do
      require "set"
      expected_table = <<-TABLE.unindent
      *** 1. row ***
      a: A
      b: B
      c: C
      1 row in set
      TABLE

      table([{:a => "A", :b => "B", :c => "C"}], :vertical => true).should == expected_table
    end
  end

  test "restrict_field_lengths ensures columns total doesn't exceed max width" do
    @table = Hirb::Helpers::Table.new([{:f1=>'f1', :f2=>'2', :f3=>'3', :f4=>'4'}])
    field_lengths = {:f1=>135, :f2=>45, :f3=>4, :f4=>55}
    width = 195
    @table.restrict_field_lengths(field_lengths, width)
    field_lengths.values.inject {|a,e| a+=e}.should <= width
  end

  test "restrict_field_lengths sets columns by relative lengths" do
    @table = Hirb::Helpers::Table.new([{:a=>'a', :b=>'b', :c=>'c'}])
    field_lengths = {:a=>30, :b=>30, :c=>40}
    width = 60
    @table.restrict_field_lengths(field_lengths, width)
    field_lengths.values.inject {|a,e| a+=e}.should <= width
    field_lengths.values.uniq.size.should_not == 1
  end

  test "restrict_field_lengths sets all columns equal when no long_field and relative methods don't work" do
    @table = Hirb::Helpers::Table.new([{:field1=>'f1', :field2=>'f2', :field3=>'f3'}])
    field_lengths = {:field1=>10, :field2=>15, :field3=>100}
    width = 20
    @table.restrict_field_lengths(field_lengths, width)
    field_lengths.values.inject {|a,e| a+=e}.should <= width
    field_lengths.values.uniq.size.should == 1
  end
end
