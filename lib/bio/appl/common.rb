module Bio
  module SignalP
    NUM_FIELDS_IN_VERSION3_SHORT_OUTPUT = 21
    NUM_FIELDS_IN_VERSION4_SHORT_OUTPUT = 12

    class Wrapper
      def log
        log = Bio::Log::LoggerPlus['bio-signalp']
      end

      # Given an amino acid sequence, return a SignalP Result
      # representing it taken from the file. The version of SignalP used
      # is auto-detected (versions 3 and 4 are supported)
      #
      # options:
      # :binary_path: full path to signalp binary e.g. '/usr/local/bin/signalp-4.0/signalp' [default: 'signalp' i.e. signalp is in the PATH]
      #
      # Returns nil if the sequence is empty
      def calculate(sequence, options={})
        return nil if sequence.nil? or sequence == ''

        default_options = {
          :binary_path => 'signalp'
        }
        options = default_options.merge options
        raise "Unexpected option parameters passed in #{options.inspect}" unless options.length == default_options.length
        options[:binary_path] ||= default_options[:binary_path] #in case nil is passed here

        # This command needs to work with all versions of SignalP (currently v3 and v4)
        command = "#{options[:binary_path]} -f short -t euk"
        log.debug "Running signalp command: #{command}" if log.debug?
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          stdin.puts '>wrapperSeq'
          stdin.puts "#{sequence[0..500]}" #Only give the first 500 amino acids because v3 fails on massive aaseqs
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
          if splits.length == NUM_FIELDS_IN_VERSION3_SHORT_OUTPUT
            # SignalP 3 detected, use that
            log.debug "Detected SignalP version 3 type output, parsing" if log.debug?
            return Bio::SignalP::Version3::Result.create_from_line(result[2].strip)
          elsif splits.length == NUM_FIELDS_IN_VERSION4_SHORT_OUTPUT
            log.debug "Detected SignalP version 4 type output, parsing" if log.debug?
            return Bio::SignalP::Version4::Result.create_from_line(result[2].strip)
          else
            error_description = "Bad SignalP output line found. Are you using SignalP 3.0 or 4.0? (found #{splits.length} fields in the third line of the output):\n#{result[2]}"
            log.error error_description
            raise Exception, error_description
          end
        end
      end
    end

    # A module for methods common to different SignalP version Result classes.
    module Common
      # Given an amino acid sequence (as a string),
      # chop it off and return the remnants. Requires that the cleavage_site
      # method be implemented
      def cleave(sequence)
        if signal?
          return sequence[cleavage_site-1..sequence.length-1]
        else
          return sequence
        end
      end

      # Simple method: 'Y' => true, 'N' => false, else nil
      def to_bool(string)
        if string === 'Y'
          return true
        elsif string === 'N'
          return false
        else
          return nil
        end
      end
    end
  end
end
