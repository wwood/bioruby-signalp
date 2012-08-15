# bio-signalp

A wrapper for the signal peptide prediction algorithm SignalP.

Using ```bio-signalp``` requires SignalP to be locally installed and configured correctly. http://www.cbs.dtu.dk/services/SignalP/ has instructions on how it may be downloaded. This gem works best when the signalp executable is available from the command line (i.e. running 'signalp' by itself works at the commandline).

# Installation

First you need to setup SignalP itself. ```bio-signalp``` is tested with SignalP versions 3.0 and 4.0.

1. Download SignalP and unpack the archive
2. Modify the signalp script in the unpacked directory. Specific instructions are provided in the script itself.
3. Add the unpacked directory to your path (or alternately, give the path to the signalp executable to the ```calculate``` method)

Then you need to install this bio-gem

```sh
gem install bio-signalp
```

# Usage

Usage as a script:
```
Usage: signalp.rb my.fasta

my.fasta is the name of the fasta file you want to analyse ($stdin also accepted). Default output is all the sequences with their signal sequences cleaved.

This default output can be changed by using one (only) of -s, -S, -v, -f, -F.

-s, --summary                    print a tab separated table indicating if the sequence had a signal peptide results (if Signalp 3 is used, HMM and NN predictions are both given, respectively [default: no]
-S, --bigger-summary             like -s, except also includes where the cleavage site is predicted [default: no]
-v, --verbose-summary            much like -s except more details of the prediction are predicted [default: no]
-f, --filter-in                  filter in: print those sequences that have a signal peptide [default: no]
-F, --filter-out                 filter out: print those sequences that don't have a signal peptide [default: no]
-b, --binary-path SIGNALP_PATH   path to the signalp binary e.g. /usr/local/bin/signalp-4.0/signalp [default: 'signalp' i.e. whatever is on the PATH]
```

Usage as a programmatic interface
```ruby
require 'bio-signalp'

# The Plasmodium falciparum ACP sequence is known to have a signal peptide (one that helps direct it to the apicoplast)
acp_sequence = 'MKILLLCIIFLYYVNAFKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ'

# Run SignalP. The version is automatically detected
result = Bio::SignalP::Wrapper.new.calculate(acp_sequence) #=> Either a Bio::SignalP::Version3::Result or a Bio::SignalP::Version4::Result object

result.signal? #=> true. ACP has a predicted signal peptide.
result.cleavage_site #=> 17. The Ymax output from SignalP gives the predicted cleavage site.
result.cleave(acp_sequence) #=> 'FKNTQKDGVSLQILKKKRSNQVNFLNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ'. The acp_sequence after signal peptide cleavage.
```

# Copyright

Copyright (c) 2011-2012 Ben J Woodcroft. See LICENSE.txt for
further details.

