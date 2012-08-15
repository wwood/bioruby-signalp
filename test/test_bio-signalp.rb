require 'helper'
require 'open3'

@@signalp3_path = File.join(ENV['HOME'],'bioinfo','signalp-3.0','signalp')
@@signalp4_path = File.join(ENV['HOME'],'bioinfo','signalp-4.0','signalp')
@@binaries = [
  @@signalp3_path,
  @@signalp4_path,
]
  
class TestBioSignalp < Test::Unit::TestCase
  def setup
    log_name = 'bio-signalp'
    Bio::Log::CLI.logger('stderr')
    #Bio::Log::CLI.configure(log_name) # when commented out no debug is printed out
  end

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
  
  should 'work with different SignalP versions, this test is specific to Ben\'s machines probably' do
    binaries = {
      @@binaries[0] => Bio::SignalP::Version3::Result,
      @@binaries[1] => Bio::SignalP::Version4::Result,
    }
    binaries.each do |binary, clazz|
      acp_sequence = 'MKILLLCIIFLYYVNAFKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ'
      positive_result = Bio::SignalP::Wrapper.new.calculate(acp_sequence, :binary_path => binary)
      assert_equal true, positive_result.signal?, binary
      assert_kind_of clazz, positive_result, binary
      assert_equal 17, positive_result.cleavage_site, binary
      assert_equal 'FKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ',
        positive_result.cleave(acp_sequence), binary
      non_signal_sequence = 'KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK'
      assert_equal false, Bio::SignalP::Wrapper.new.calculate(non_signal_sequence, :binary_path => binary).signal?, binary
    end
  end
end

class TestSignalPScript < Test::Unit::TestCase
  # Known to have a signal peptide
  acp_sequence = 'MKILLLCIIFLYYVNAFKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ'
  
  should "positive control" do
    command = File.join(File.dirname(__FILE__),'..','bin','signalp.rb')
    
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
    command = File.join(File.dirname(__FILE__),'..','bin','signalp.rb')
    
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
  
  
  
  
  should 'give the right -s output for signalp 3' do
    command = File.join(File.dirname(__FILE__),'..','bin','signalp.rb')
    
    # This also tests the -b flag
    command = "#{command} -b #{@@signalp3_path} -s"
    Open3.popen3(command) do |stdin, stdout, stderr|
      stdin.puts '>positive'
      stdin.puts acp_sequence
      stdin.close
      
      @result = stdout.readlines # convert to string?
      @error  = stderr.readlines
    end
    
    expected = [
    "Name\tNN Prediction\tHMM Prediction\n",
    "positive\tT\tT\n"
    ]
    assert_equal expected, @result
    assert_equal [], @error  
  end
  
  
  
  
  should 'give the right -s output for signalp 4' do
    command = File.join(File.dirname(__FILE__),'..','bin','signalp.rb')
    
    command = "#{command} -b #{@@signalp4_path} -s"
    Open3.popen3(command) do |stdin, stdout, stderr|
      stdin.puts '>positive'
      stdin.puts acp_sequence
      stdin.close
      
      @result = stdout.readlines # convert to string?
      @error  = stderr.readlines
    end
    
    expected = [
    "Name\tPredicted?\n",
    "positive\tT\n"
    ]
    assert_equal [], @error
    assert_equal expected, @result
  end
  
end
