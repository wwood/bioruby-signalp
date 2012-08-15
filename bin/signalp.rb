#!/usr/bin/env ruby

require 'rubygems'
require 'bio'
require 'optparse'


# always load from the directory relative to the current script's directory
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'bio-signalp'



# Parse command line options into the options hash
SCRIPT_NAME = File.basename(__FILE__)
options = {
  :logger => 'stderr',
  :binary_path => nil,
}
o = OptionParser.new do |opts|
  opts.banner = "
    Usage: #{SCRIPT_NAME} my.fasta
    
    my.fasta is the name of the fasta file you want to analyse. Default output is all the sequences with their signal sequences cleaved.
      
    This default output can be changed by using one (only) of -s, -S, -v, -f, -F.\n\n"
    
  opts.on("-s", "--summary", "print a tab separated table indicating if the sequence had a signal peptide results (if Signalp 3 is used, HMM and NN predictions are both given, respectively [default: #{options[:eg]}]") do |arg|
    options['s'] = true
  end
  opts.on("-S", "--bigger-summary", "like -s, except also includes where the cleavage site is predicted [default: no]") do
    options['S'] = true
  end
  opts.on("-v", "--verbose-summary", "much like -s except more details of the prediction are predicted [default: no]") do
    options['c'] = true
  end
  opts.on("-f", "--filter-in", "filter in: print those sequences that have a signal peptide [default: no]") do
    options['f'] = true
  end
  opts.on("-F", "--filter-out", "filter out: print those sequences that don't have a signal peptide [default: no]") do
    options['F'] = true
  end
  opts.on("-b", "--binary-path SIGNALP_PATH", "path to the signalp binary e.g. /usr/local/bin/signalp-4.0/signalp [default: 'signalp' i.e. whatever is on the PATH]") do |arg|
    options[:binary_path] = arg
  end
end
o.parse!
if ARGV.length > 1
  $stderr.puts o
  exit 1
end


printed_header = false
signalp_version = nil
runner = Bio::SignalP::Wrapper.new

Bio::FlatFile.open(ARGF).each do |seq|
  result = runner.calculate(seq.seq, :binary_path => options[:binary_path])
  if result.nil?
    $stderr.puts "Unexpected empty sequence detected, ignoring: #{seq.definition}"
    next
  end
  
  if !printed_header
    printed_header = true
    
    # Different headers are printed for the different versions (if at all)
    if result.kind_of?(Bio::SignalP::Version3::Result)
      signalp_version = 3
      if options['s']
        puts [
          'Name',
          'NN Prediction',
          'HMM Prediction'
        ].join("\t")
      elsif options['S']
        puts [
          'Name',
          'NN Prediction',
          'HMM Prediction',
          'Predicted?',
          'Cleavege site (if predicted)'
        ].join("\t")
      
      elsif options['v']
        #       [:nn_Cmax, :nn_Cmax_position, :nn_Cmax_prediction, 
        #      :nn_Ymax, :nn_Ymax_position, :nn_Ymax_prediction, 
        #      :nn_Smax, :nn_Smax_position, :nn_Smax_prediction, 
        #      :nn_Smean, :nn_Smean_prediction,
        #      :nn_D, :nn_D_prediction]
        #    @@hmm_results = [
        #      :hmm_result, :hmm_Cmax, :hmm_Cmax_position, :hmm_Cmax_prediction, :hmm_Sprob, :hmm_Sprob_prediction]
        puts [
          'Name',
          'NN Cmax',
          'NN Cmax position',
          'NN Cmax prediction',
          'NN Ymax',
          'NN Ymax position',
          'NN Ymax prediction',
          'NN Smax',
          'NN Smax position',
          'NN Smax prediction',
          'NN Smean',
          'NN Smean prediction',
          'NN D',
          'NN D prediction',
          'HMM result',
          'HMM Cmax',
          'HMM Cmax position',
          'HMM Cmax prediction',
          'HMM Sprob',
          'HMM Sprob prediction',
        ].join("\t")
      end
      
    elsif result.kind_of?(Bio::SignalP::Version4::Result)
      signalp_version = 4
      
      if options['s']
        puts [
          'Name',
          'Predicted?',
        ].join("\t")
      elsif options['S']
        puts [
          'Name',
          'Predicted?',
          'Cleavege site (if predicted)'
        ].join("\t")
      
      elsif options['v']
        #:Cmax, :Cmax_position,
        #:Ymax, :Ymax_position,
        #:Smax, :Smax_position,
        #:Smean,
        #:D,
        #:prediction,
        #:Dmaxcut,
        #:networks_used
        puts [
          'Name',
          'Cmax',
          'Cmax position',
          'Ymax',
          'Ymax position',
          'Smax',
          'Smax position',
          'Smean',
          'D',
          'prediction',
          'Dmaxcut',
          'networks_used'
        ].join("\t")
      end
    else
      raise "Unexpected bio-signalp result object seen: #{result.inspect}"
    end
  end
  
  if options['s']
    if signalp_version == 3
      puts [
      seq.entry_id,
      result.nn_D_prediction ? 'T' : 'F',
      result.hmm_Sprob_prediction ? 'T' : 'F'
      ].join("\t")
    elsif signalp_version == 4
      puts [
      seq.entry_id,
      result.prediction ? 'T' : 'F',
      ].join("\t")
    else
      raise "Programming error"
    end
  elsif options['S']
    if signalp_version == 3
      puts [
      seq.entry_id,
      result.nn_D_prediction ? 'T' : 'F',
      result.hmm_Sprob_prediction ? 'T' : 'F',
      result.signal? ? 'T' : 'F',
      result.signal? ? result.cleavage_site : 0,
      ].join("\t")
    elsif signalp_version == 4
      puts [
      seq.entry_id,
      result.signal? ? 'T' : 'F',
      result.signal? ? result.cleavage_site : 0,
      ].join("\t")
    else
      raise "Programming error"
    end

  elsif options['v']
    taputs = [seq.definition]
    extras = []
    if signalp_version == 3
      extras = [:nn_Cmax, :nn_Cmax_position, :nn_Cmax_prediction, 
      :nn_Ymax, :nn_Ymax_position, :nn_Ymax_prediction, 
      :nn_Smax, :nn_Smax_position, :nn_Smax_prediction, 
      :nn_Smean, :nn_Smean_prediction,
      :nn_D, :nn_D_prediction,
      :hmm_result, :hmm_Cmax, :hmm_Cmax_position, :hmm_Cmax_prediction, 
      :hmm_Sprob, :hmm_Sprob_prediction]
    elsif signalp_version == 4
      extras = [
        :Cmax, :Cmax_position,
        :Ymax, :Ymax_position,
        :Smax, :Smax_position,
        :Smean,
        :D,
        :prediction,
        :Dmaxcut,
        :networks_used
      ]
    end
    
    extras.each do |meth|
      taputs.push result.send(meth)
    end
    puts taputs.join("\t")
  elsif options['f']
    if result.signal?
      puts seq
    end
  elsif options['F']
    if !result.signal?
      puts seq
    end
  else
    puts ">#{seq.entry_id}\n#{result.cleave(seq.seq)}"
  end
end
