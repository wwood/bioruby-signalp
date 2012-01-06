# Methods to wrap around the signal peptide prediction program SignalP (version 3.0)
require 'open3'

# Wrapper around a locally installed SignalP program
module Bio
  class SignalP
    NUM_FIELDS_IN_SHORT_OUTPUT = 21
    
    class Wrapper
      # Given an amino acid sequence, return a SignalPResult
      # representing it taken from the file.
      def calculate(sequence)
        command = 'signalp -trunc 70 -format short -t euk'
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          stdin.puts '>wrapperSeq'
          stdin.puts "#{sequence}"
          stdin.close
          
          result = stdout.readlines
          error = stderr.readlines
          
          unless error.empty?
            raise Exception, "There appears to be a problem while running signalp:\n#{error}"
          end
          
          # Error checking
          num_expected_result_lines = 3
          unless result.length == num_expected_result_lines
            raise Exception, "Unexpected number of lines found in SignalP output (#{result.length}, expected #{num_expected_result_lines}):\n#{result}"
          end
          
          splits = result[2].strip.split(/[ \t]+/)
          if splits.length != NUM_FIELDS_IN_SHORT_OUTPUT
            raise Exception, "Bad SignalP output line found. Are you using SignalP 3.0? (expected #{NUM_FIELDS_IN_SHORT_OUTPUT} fields, found #{splits.length} fields):\n#{result[2]}"
          end
          
          return Result.create_from_line(result[2].strip)
        end
      end
    end
    
    # The result of a SignalP program. Create using the output from
    # -format short output and create_from_line()
    class Result
      @@nn_results = 
      [:nn_Cmax, :nn_Cmax_position, :nn_Cmax_prediction, 
      :nn_Ymax, :nn_Ymax_position, :nn_Ymax_prediction, 
      :nn_Smax, :nn_Smax_position, :nn_Smax_prediction, 
      :nn_Smean, :nn_Smean_prediction,
      :nn_D, :nn_D_prediction]
      @@hmm_results = [
      :hmm_result, :hmm_Cmax, :hmm_Cmax_position, :hmm_Cmax_prediction, :hmm_Sprob, :hmm_Sprob_prediction]
      
      @@nn_results.each do |sym|
        attr_accessor sym
      end
      @@hmm_results.each do |sym|
        attr_accessor sym
      end
      
      # Create a new SignalpResult using a line from the signal p 'short' output format,
      # version 3.0
      def self.create_from_line(line)
        # e.g.
        # # name                Cmax  pos ?  Ymax  pos ?  Smax  pos ?  Smean ?  D     ?   # name      !  Cmax  pos ?  Sprob ?
        # 526.m04658            0.734  19 Y  0.686  19 Y  0.933   6 Y  0.760 Y  0.723 Y 526.m04658  Q  0.037  19 N  0.004 N
        matches = line.split(/[ \t]+/)
        if matches.length != NUM_FIELDS_IN_SHORT_OUTPUT
          raise Exception, "Bad SignalP Short Line Found (#{matches.length}): '#{line}'"
        end
        
        i = 1
        result = Result.new
        result.nn_Cmax = matches[i].to_f; i += 1
        result.nn_Cmax_position = matches[i].to_i; i += 1
        result.nn_Cmax_prediction = to_bool matches[i]; i += 1
        result.nn_Ymax = matches[i].to_f; i += 1
        result.nn_Ymax_position = matches[i].to_i; i += 1
        result.nn_Ymax_prediction = to_bool matches[i]; i += 1
        result.nn_Smax = matches[i].to_f; i += 1
        result.nn_Smax_position = matches[i].to_i; i += 1
        result.nn_Smax_prediction = to_bool matches[i]; i += 1
        result.nn_Smean = matches[i].to_f; i += 1
        result.nn_Smean_prediction = to_bool matches[i]; i += 1
        result.nn_D = matches[i].to_f; i += 1
        result.nn_D_prediction = to_bool matches[i]; i += 1
        
        i+= 1
        result.hmm_result = matches[i]; i += 1
        result.hmm_Cmax = matches[i].to_f; i += 1
        result.hmm_Cmax_position = matches[i].to_i; i += 1
        result.hmm_Cmax_prediction = to_bool matches[i]; i += 1
        result.hmm_Sprob = matches[i].to_f; i += 1
        result.hmm_Sprob_prediction = to_bool matches[i]; i += 1
        
        return result
      end
      
      def self.to_bool(string)
        if string === 'Y'
          return true
        elsif string === 'N'
          return false
        else
          return nil
        end
      end
      
      # Does it have a signal peptide? It can be this class (default), 
      # or another class that responds to :nn_D_prediction and :hmm_Sprob_prediction
      def signal?(clazz=self)
        return (clazz.send(:nn_D_prediction) or clazz.send(:hmm_Sprob_prediction))
      end
      
      def classical_signal_sequence?
        return @nn_D_prediction
      end
      
      def signal_anchor?
        return @hmm_Sprob_prediction
      end
      
      # Return an array of all the results. NN then HMM, as per SignalP short format
      def all_results
        all = []
        
        @@nn_results.each do |sym|
          all.push self.send(sym)
        end
        
        @@hmm_results.each do |sym|
          all.push self.send(sym)
        end
        
        return all
      end
      
      # Return an array of symbols representing the names of the columns
      def self.all_result_names
        return [@@nn_results, @@hmm_results].flatten
      end
      
      # Return the number of the residue after the cleavage site
      # ie. the first residue of the mature protein
      # Taken from the Y score, as it was decided this is the best prediction
      def cleavage_site
        @nn_Ymax_position
      end
      
      # Given an amino acid sequence (as a string),
      # chop it off and return the remnants
      def cleave(sequence)
        if signal?
          return sequence[cleavage_site-1..sequence.length-1]
        else
          return sequence
        end
      end
    end
  end
end