require 'helper'

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
