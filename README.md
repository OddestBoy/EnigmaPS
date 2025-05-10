A powershell script to emulate an enigma machine.
Usable interactively or from the command line.

The simplest way to use this is to just run the script and enter the text you want to process. Will only process letters; characters and numbers are ommitted (but see CleanUp option)

Remember, Enigma is reversible! If you enter ciphertext (with the same settings used for ecryption) it will decrypt it. Try "ZKKGSMEGJDQZGYNLLXUTJPYERTILHIK" with default settings

It can also be used from the command line. Open powershell and cd to the folder containg the script. Run the script from here with command line arguments as you wish (you may want to add an alias to your $profile).
It will accept piped text, and can send it's output to the pipeline (recomended to use -quiet). It can even be piped into itself (with different rotor settings) for multiple rounds of encryption!

Accepts these command line arguments:
-InputText : Alias "In" Text to process. This is the first argument (doesn't need explicitly calling) also taken from the pipeline. If not specified, you can enter text later, or specifify a file to read from with InputFile
-RotorAChoice : Alias "A". The rotor to use in position A (fast). Defaults to 1 if not specified.
-RotorBChoice : Alias "B". The rotor to use in position B (medium). Defaults to 2 if not specified.
-RotorCChoice : Alias "C". The rotor to use in position C (slow). Defaults to 3 if not specified.
-RotorAPosition : Alias "Apos".The start position for rotor A. Defaults to 0 if not specified.
-RotorBPosition : Alias "Bpos".The start position for rotor B. Defaults to 0 if not specified.
-RotorCPosition : Alias "Cpos".The start position for rotor C. Defaults to 0 if not specified.
-PlugboardAddition : Alias "Plug","p". Manual additions to the plugboard, overwriting any settings in plugboard.txt. In the format "A=B,B=A". Note it must be reversible.
-Quiet : Alias "Q". Non verbose, will just output the cipher text with no stats.
-OutputBlocks : Breaks the output up into this many character chunks. If not specified, will do one continuous stream.
-InputFile : Alias "InF" A file to read input text from. Can't be used with InputText or text from the pipeline
-OutputFile : Alias "Out". File to write the output to, in addition to any on screen display
-Cleanup : Substitute numbers with their word form ie 1 -> ONE, 2 -> TWO etc. This increaces processing time by ~30%
-Pad : Prepend and append 5-25 random characters to the cleartext before encrypting, plus START and END to main message. If used with -OutputBlocks, it will add padding to make a round number of blocks. DO NOT USE THIS WHEN DECRYPTING!
-ShowTable : show step by step the path that a letter takes through the machine.
-StepByStep : Used with -ShowTable, waits for you to press enter before moving to the next character
-Help : Alias "h" or "?". What you're reading right now!

Examples:

Writes output and stats to screen:
    Engima -InputText "This is some test text to encrypt with default settings"
    Engima "VQMQSXTMVRKAVWQGKXXLFWDNOZBMSSNBOIYQMWVYQRYQWY"

Writes output only, using specific rotors, start positions, and plugboard:
    Enigma -InputText "This is some example text using some specific rotors and positions" -RotorAChoice "3" -RotorAPosition "15" -RotorBChoice "2" -RotorBPosition "10" -RotorCChoice "1" -RotorCPosition "5" -PlugboardAddition "A=G,G=A,Z=O,O=Z" -Quiet
    Enigma "ZEHBOAQGIIJUQNYKGSABXAXLOBCYRDULDDMKSAGQSEQTEZRZIEJDFYOB" -A 3 -Apos 15 -B 2 -Bpos 10 -C 1 -Cpos 5 -p "A=G,G=A,Z=O,O=Z" -q

Reading from and writing to pipeline:
    (invoke-restmethod "https://haveibeenpwned.com/api/v3/latestbreach").Description | Enigma -cleanup -quiet | write-host -ForegroundColor Red -BackgroundColor White
