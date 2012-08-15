# Methods to wrap around the signal peptide prediction program SignalP (version 3.0)
require 'open3'

# Wrapper around a locally installed SignalP program
module Bio
  module SignalP
    class Version4
      # The result of a SignalP program. Create using the output from
      # -format short output and create_from_line()
      class Result
        include Bio::SignalP::Common
        
        @@output_fields = [
                           :Cmax, :Cmax_position,
                           :Ymax, :Ymax_position,
                           :Smax, :Smax_position,
                           :Smean,
                           :D,
                           :prediction,
                           :Dmaxcut,
                           :networks_used,
        ]
        
        @@output_fields.each do |sym|
          attr_accessor sym
        end
        
        # Create a new SignalpResult using a line from the signal p 'short' output format,
        def self.create_from_line(line)
          # e.g.
          #$ ~/bioinfo/signalp-4.0/signalp /tmp/acp 
          ## SignalP-4.0 euk predictions
          ## name                     Cmax  pos  Ymax  pos  Smax  pos  Smean   D     ?  Dmaxcut    Networks-used
          #acp                        0.871  17  0.863  17  0.886   1  0.844   0.853 Y  0.450      SignalP-noTM
          matches = line.split(/[ \t]+/)
          if matches.length != Bio::SignalP::NUM_FIELDS_IN_VERSION4_SHORT_OUTPUT
            raise Exception, "Bad SignalP Short Line Found (#{matches.length}): '#{line}'"
          end
          
          i = 1
          result = Result.new
          result.Cmax = matches[i].to_f; i += 1
          result.Cmax_position = matches[i].to_i; i += 1
          result.Ymax = matches[i].to_f; i += 1
          result.Ymax_position = matches[i].to_i; i += 1
          result.Smax = matches[i].to_f; i += 1
          result.Smax_position = matches[i].to_i; i += 1
          result.Smean = matches[i].to_f; i += 1
          result.D = matches[i].to_f; i += 1
          result.prediction = result.to_bool matches[i]; i += 1
          result.Dmaxcut = matches[i].to_f; i += 1
          result.networks_used = matches[i]; i += 1
          
          return result
        end
          
        # Does it have a signal peptide? It can be this class (default), 
        # or another class that responds to :nn_D_prediction and :hmm_Sprob_prediction
        def signal?(clazz=self)
          return clazz.send(:prediction)
        end
        
        # Return the number of the residue after the cleavage site
        # ie. the first residue of the mature protein
        # Taken from the Y score, as it was decided this is the best prediction
        def cleavage_site
          @Ymax_position
        end
      end
    end
  end
end