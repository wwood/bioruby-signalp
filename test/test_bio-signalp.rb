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
  should "positive control" do
  # Known to have a signal peptide
    acp_sequence = 'MKILLLCIIFLYYVNAFKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ'

    command = "RUBYLIB="+
    File.join(File.dirname(__FILE__),'..','lib')+' '+
    File.join(File.dirname(__FILE__),'..','bin','signalp.rb')
    Open3.popen3(command) do |stdin, stdout, stderr|
      stdin.puts '>positive'
      stdin.puts acp_sequence
      stdin.close
      
      @result = stdout.readlines # convert to string?
      @error  = stderr.readlines
    end
    p @result
    p @error
  end
end
