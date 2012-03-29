require 'helper'
require 'open3'

class TestBioSignalp < Test::Unit::TestCase
  should "positive control" do
  # Known to have a signal peptide
    acp_sequence = 'MKILLLCIIFLYYVNAFKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ'

    assert_equal true, Bio::SignalP::Wrapper.new.calculate(acp_sequence).signal?
  end

  should "negative control" do
  # Known to have a signal peptide
    non_signal_sequence = 'KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK'

    assert_equal false, Bio::SignalP::Wrapper.new.calculate(non_signal_sequence).signal?
  end
end

class TestSignalPScript < Test::Unit::TestCase
  command = File.join(File.dirname(__FILE__),'..','bin','signalp.rb')
  
  should "positive control" do
  # Known to have a signal peptide
    acp_sequence = 'MKILLLCIIFLYYVNAFKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ'

    Open3.popen3(command) do |stdin, stdout, stderr|
      stdin.puts '>positive'
      stdin.puts acp_sequence
      stdin.close
      
      @result = stdout.readlines # convert to string?
      @error  = stderr.readlines
    end
    assert_equal [">positive\n", "FKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ\n"], @result
    assert_equal [], @error
  end
  
  should "return gracefully when empty sequences are given" do
    acp_sequence = 'MKILLLCIIFLYYVNAFKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ'
    
    Open3.popen3(command) do |stdin, stdout, stderr|
      stdin.puts '>positive'
      stdin.puts acp_sequence
      stdin.puts '>empty'
      stdin.puts '>positive2'
      stdin.puts acp_sequence
      stdin.close
      
      @result = stdout.readlines # convert to string?
      @error  = stderr.readlines
    end
    assert_equal [">positive\n", "FKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ\n",
    ">positive2\n", "FKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ\n"], @result
    assert_equal ["Unexpected empty sequence detected, ignoring: empty\n"], @error
  end
end
