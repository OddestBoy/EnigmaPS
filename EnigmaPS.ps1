param (
    [Alias("In")][Parameter(ValueFromPipeline)][String]$InputText,
    [Alias("A")][Parameter()][String]$RotorAChoice,
    [Alias("B")][Parameter()][String]$RotorBChoice,
    [Alias("C")][Parameter()][String]$RotorCChoice,
    [Alias("Apos")][Parameter()][int]$RotorAPosition,
    [Alias("Bpos")][Parameter()][int]$RotorBPosition,
    [Alias("Cpos")][Parameter()][int]$RotorCPosition,
    [Alias("q")][Parameter()][Switch]$Quiet,
    [Alias("Plug","p")][Parameter()][String]$PlugboardAddition,
    [Parameter()][Int]$OutputBlocks,
    [Alias("InF")][Parameter()][String]$InputFile,
    [Alias("Out")][Parameter()][String]$OutputFile,
    [Parameter()][Switch]$CleanUp,
    [Parameter()][Switch]$Pad,
    [Parameter()][Switch]$ShowTable,
    [Parameter()][Switch]$StepByStep,
    [Alias("h","?")][Parameter()][Switch]$Help
)
function Help-Text{
    Write-Output "
+++++ OddestBoy's marvelous non-mechanical engima machine ++++++

The simplest way to use this is to just run the script and enter the text you want to process. Will only process letters; characters and numbers are ommitted (but see CleanUp option)

Remember, Enigma is reversible! If you enter ciphertext (with the same settings used for ecryption) it will decrypt it. Try `"ZKKGSMEGJDQZGYNLLXUTJPYERTILHIK`" with default settings

It can also be used from the command line (you may want to add an alias to your `$profile).
It will accept piped text, and can send it's output to the pipeline (recomended to use -quiet). It can even be piped into itself (with different rotor settings) for multiple rounds of encryption!

Accepts these command line arguments:
-InputText : Alias `"In`" Text to process. This is the first argument (doesn't need explicitly calling) also taken from the pipeline. If not specified, you can enter text later, or specifify a file to read from with InputFile
-RotorAChoice : Alias `"A`". The rotor to use in position A (fast). Defaults to 1 if not specified.
-RotorBChoice : Alias `"B`". The rotor to use in position B (medium). Defaults to 2 if not specified.
-RotorCChoice : Alias `"C`". The rotor to use in position C (slow). Defaults to 3 if not specified.
-RotorAPosition : Alias `"Apos`".The start position for rotor A. Defaults to 0 if not specified.
-RotorBPosition : Alias `"Bpos`".The start position for rotor B. Defaults to 0 if not specified.
-RotorCPosition : Alias `"Cpos`".The start position for rotor C. Defaults to 0 if not specified.
-PlugboardAddition : Alias `"Plug`",`"p`". Manual additions to the plugboard, overwriting any settings in plugboard.txt. In the format `"A=B,B=A`". Note it must be reversible.
-Quiet : Alias `"Q`". Non verbose, will just output the cipher text with no stats.
-OutputBlocks : Breaks the output up into this many character chunks. If not specified, will do one continuous stream.
-InputFile : Alias `"InF`" A file to read input text from. Can't be used with InputText or text from the pipeline
-OutputFile : Alias `"Out`". File to write the output to, in addition to any on screen display
-Cleanup : Substitute numbers with their word form ie 1 -> ONE, 2 -> TWO etc. This increaces processing time by ~30%
-Pad : Prepend and append 5-25 random characters to the cleartext before encrypting, plus START and END to main message. If used with -OutputBlocks, it will add padding to make a round number of blocks. DO NOT USE THIS WHEN DECRYPTING!
-ShowTable : show step by step the path that a letter takes through the machine.
-StepByStep : Used with -ShowTable, waits for you to press enter before moving to the next character
-Help : Alias `"h`" or `"?`". What you're reading right now!

Examples:

Writes output and stats to screen:
    Engima -InputText `"This is some test text to encrypt with default settings`"
    Engima `"VQMQSXTMVRKAVWQGKXXLFWDNOZBMSSNBOIYQMWVYQRYQWY`"

Writes output only, using specific rotors, start positions, and plugboard:
    Enigma -InputText `"This is some example text using some specific rotors and positions`" -RotorAChoice `"3`" -RotorAPosition `"15`" -RotorBChoice `"2`" -RotorBPosition `"10`" -RotorCChoice `"1`" -RotorCPosition `"5`" -PlugboardAddition `"A=G,G=A,Z=O,O=Z`" -Quiet
    Enigma `"ZEHBOAQGIIJUQNYKGSABXAXLOBCYRDULDDMKSAGQSEQTEZRZIEJDFYOB`" -A 3 -Apos 15 -B 2 -Bpos 10 -C 1 -Cpos 5 -p `"A=G,G=A,Z=O,O=Z`" -q

Reading from and writing to pipeline:
    (invoke-restmethod `"https://haveibeenpwned.com/api/v3/latestbreach`").Description | Enigma -cleanup -quiet | write-host -ForegroundColor Red -BackgroundColor White
"
    exit
}
if($Help){
    Help-Text
}
$Folder = $PSScriptRoot
if($InputText){
    if($InputText -match "^[?]$"){
        Help-Text
    }
    $Cleartext = $InputText
} elseif($InputFile){
    try {
        $Cleartext = Get-Content "$InputFile" -ErrorAction Stop | Out-String
    }
    catch {
        Write-Host "Error reading from file $InputFile - $($PSItem.Exception.Message)"
        exit
    }
} else {
    $Cleartext = Read-Host "Cleartext"
    $PauseWhenDone = $True
}
$StartTime = Get-date
if($Pad){
    $Alphabet = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
    $PadLength = get-random -Maximum 25 -Minimum 5
    $Padding = $Alphabet | get-random -Count $PadLength
    $Cleartext = $Padding + "START" + $Cleartext
    $PadLength = get-random -Maximum 25 -Minimum 5
    $Padding = $Alphabet | get-random -Count $PadLength
    $Cleartext = $Cleartext + "END" + $Padding
}
if(!$Quiet){Write-Host "Processing input"}
if($CleanUp){
    $Cleartext = $Cleartext.replace("1","ONE")
    $Cleartext = $Cleartext.replace("2","TWO")
    $Cleartext = $Cleartext.replace("3","THREE")
    $Cleartext = $Cleartext.replace("4","FOUR")
    $Cleartext = $Cleartext.replace("5","FIVE")
    $Cleartext = $Cleartext.replace("6","SIX")
    $Cleartext = $Cleartext.replace("7","SEVEN")
    $Cleartext = $Cleartext.replace("8","EIGHT")
    $Cleartext = $Cleartext.replace("9","NINE")
    $Cleartext = $Cleartext.replace("0","ZERO")
    $Cleartext = $Cleartext.replace(".","STOP")
    $Cleartext = $Cleartext.replace("!","STOP")
    $Cleartext = $Cleartext.replace("?","STOP")
}
$Cleartext = $Cleartext.ToUpper() #all upper case
$Cleartext = $Cleartext.ToCharArray() #split into characters
$ProcessText = @()
$Cleartext | ForEach-Object { #character validation. Only if upper case a-z
    if($_ -match "[A-Z]"){
        $ProcessText = $ProcessText + $_
    }
}
if($OutputBlocks -and $Pad){
    if(($Cleartext.Length % $OutputBlocks) -ne 0){
        $AddPadd = $OutputBlocks - ($Cleartext.Length % $OutputBlocks)
        while($AddPadd -ne 0){
            $ProcessText = $ProcessText + ($Alphabet | get-random)
            $AddPadd = $AddPadd -1
        }
    }
}
$Length = $ProcessText.Length
if(!$Quiet){
    write-host "`nCleartext: "($ProcessText -join "")"`n"
}

### Rotor selection ###
#Will take rotor selection and start positions from command line arguments, if none are specified will use 1 2 3 all starting at 0
$RotorSize = 26 #IN THEORY you can change this if you want to add more characters to your rotors (ie numbers). I've not tested this, and the input character validation on earlier in the script would also need tweaking (or you won't be able to decrypt). You'd also want to extend the plugboard
if(!$RotorAChoice){$RotorAChoice = "1"}
if(!$RotorAPosition){$RotorAPosition = 0}
$RotorAPosition = $RotorAPosition % $RotorSize #limit to $RotorSize positions
if(!$RotorBChoice){$RotorBChoice = "2"}
if(!$RotorBPosition){$RotorBPosition = 0}
$RotorBPosition = $RotorBPosition % $RotorSize
if(!$RotorCChoice){$RotorCChoice = "3"}
if(!$RotorCPosition){$RotorCPosition = 0}
$RotorCPosition = $RotorCPosition % $RotorSize

function Load-Rotor { #this reads a specified rotor file into a hashtable
    param (
        [string]$RotorNumber,
        [int]$Position
    )
    $Rotor = @{}
    try {
        $RotorProcess = Get-Content "$Folder\Rotor$RotorNumber.rotor" -ErrorAction Stop
    }
    catch {
        Write-Host "Error reading from rotor $Folder\Rotor$RotorNumber.rotor - $($PSItem.Exception.Message)"
        exit
    }
    $RotorProcess | ForEach-Object {
        $RotorSubProcess = $_.split("=")
        $Rotor.($RotorSubProcess[0]) = $RotorSubProcess[1]
    }
    return $Rotor
}

function Advance-Rotor {
    param (
        [hashtable]$Rotor
    )
    $notch = $Rotor.notch
    $Rotor.Remove('notch')
    $keys = $Rotor.keys | Sort-Object
    $PrevValue = $Rotor
    $FirstValue = $PrevValue.A
    foreach($key in $keys){
        $index = $keys.IndexOf($key) + 1
        if($index -eq $RotorSize){
            $Rotor.$key = $FirstValue
        } else {
            $Rotor.$key = $PrevValue[$keys[$index]]
        }
    }
    $Rotor.notch = $notch
    return $Rotor
}
function Cipher-Plugboard {
    param (
        [string]$ClearCharacter
    )
    if($Plugboard.$ClearCharacter){
        $CipherCharacter = $Plugboard.$ClearCharacter
    } else {
        $CipherCharacter = $ClearCharacter #if charactor not in plugboard, will pass cleartext through. So can operate with no or partial plugboard
    }
    return $CipherCharacter
}
function Cipher-Rotor {
    param (
        [hashtable]$Rotor,
        [string]$ClearCharacter,
        [switch]$Reverse
    )
    if($Reverse){
        $Rotor.Keys | ForEach-Object {
            if($Rotor.$_ -eq $ClearCharacter){
                $CipherCharacter = $_
                return $CipherCharacter
            }
        }
    } else {
        if($Rotor.$ClearCharacter){
            $CipherCharacter = $Rotor.$ClearCharacter
            return $CipherCharacter
        } else {
            Write-Host "Something has gone terribly wrong! Trying to encrypt character `"$ClearCharacter`" on:"
            return "error"
        }
    }
}

#UKW-B reflector wiring
$Reflector = @{
    A="Y"
    B="R"
    C="U"
    D="H"
    E="Q"
    F="S"
    G="L"
    H="D"
    I="P"
    J="X"
    K="N"
    L="G"
    M="O"
    N="K"
    O="M"
    P="I"
    Q="E"
    R="B"
    S="F"
    T="Z"
    U="C"
    V="W"
    W="V"
    X="J"
    Y="A"
    Z="T"
}

function Cipher-Reflector {
    param (
        [string]$ClearCharacter
    )
    if($Reflector.$ClearCharacter){
        $CipherCharacter = $Reflector.$ClearCharacter
        return $CipherCharacter
    } else {
        Write-Host "Something has gone terribly wrong! Trying to encrypt character `"$ClearCharacter`" on:"
        return "error"
    }
}

#Plugboard setup and validation
$PlugboardFile = "$Folder\Plugboard.txt"
$PlugboardProcess = Get-Content $PlugboardFile
$Plugboard = @{}
$PlugboardProcess | ForEach-Object {
    $PlugProcess = $_.split("=")
    $Plugboard.($PlugProcess[0]) = $PlugProcess[1]
}
if($PlugboardAddition){
    $PlugboardProcess = $PlugboardAddition.ToUpper()
    $PlugboardProcess.split(",") | ForEach-Object {
        try {
            $PlugProcess = $_.split("=")
        }
        catch {
            Write-Host "Error processing manual plugboard additions! $_"
        }
        $Plugboard.($PlugProcess[0]) = $PlugProcess[1]
    }
}
$PlugboardError = $False
$Plugboard.keys | ForEach-Object { #confirm that plugboard is reversible
    $value = $Plugboard.$_
    if(($Plugboard.ContainsKey($value))){
        if($Plugboard.$value -ne $_){
            Write-Host "Invalid plugboard! Non reversable, error on $_ = $value. Must also contain $value = $_"
            $PlugboardError = $True
        }
    }
}
if($PlugboardError){
    exit
}

$RotorA = Load-Rotor $RotorAChoice $RotorAPosition
$RotorACount = 0
while($RotorACount -ne $RotorAPosition){
    $RotorA = Advance-Rotor $RotorA
    $RotorACount = $RotorACount + 1
}
$RotorB = Load-Rotor $RotorBChoice $RotorBPosition
$RotorBCount = 0
while($RotorBCount -ne $RotorBPosition){
    $RotorB = Advance-Rotor $RotorB
    $RotorBCount = $RotorBCount + 1
}
$RotorC = Load-Rotor $RotorCChoice $RotorCPosition
$RotorCCount = 0
while($RotorCCount -ne $RotorCPosition){
    $RotorC = Advance-Rotor $RotorC
    $RotorCCount = $RotorCCount + 1
}


#Odometers
$RotorAOdo = 0
$RotorBOdo = 0
$RotorCOdo = 0
$CipherLength = 1
if(!$Quiet){Write-Host "Encrypting/Decrypting input"}
if($ShowTable){write-host "`nI-Input P-Plugboard A-Fast rotor B-Middle rotor C-Slow rotor O-Out"; write-host "`nIN  I->P   P->A   A->B   B->C   R->R   C->B   B->A   A->P   P->O  OUT"; write-host "----------------------------------------------------------------------"}
$CipherText = ""
$ProcessText | ForEach-Object {
    $ProcessCharacter = $_
    if($ShowTable){$DebugText = "$ProcessCharacter   $ProcessCharacter"}
    $ProcessCharacter = Cipher-Plugboard $ProcessCharacter
    if($ShowTable){$DebugText = $DebugText + "->$ProcessCharacter   $ProcessCharacter"}
    $ProcessCharacter = Cipher-Rotor $RotorA $ProcessCharacter
    if($ShowTable){$DebugText = $DebugText + "->$ProcessCharacter   $ProcessCharacter"}
    if($ProcessCharacter -eq "error"){write-host "Rotor A forwards path, passed from plugboard"; if($ShowTable){write-host $DebugText} ; exit}
    $ProcessCharacter = Cipher-Rotor $RotorB $ProcessCharacter
    if($ShowTable){$DebugText = $DebugText + "->$ProcessCharacter   $ProcessCharacter"}
    if($ProcessCharacter -eq "error"){write-host "Rotor B forwards path, passed from rotor $RotorAChoice" ; if($ShowTable){write-host $DebugText} ; exit}
    $ProcessCharacter = Cipher-Rotor $RotorC $ProcessCharacter
    if($ShowTable){$DebugText = $DebugText + "->$ProcessCharacter   $ProcessCharacter"}
    if($ProcessCharacter -eq "error"){write-host "Rotor C forwards path, passed from rotor $RotorBChoice" ; if($ShowTable){write-host $DebugText} ; exit}
    $ProcessCharacter = Cipher-Reflector $ProcessCharacter
    if($ShowTable){$DebugText = $DebugText + "->$ProcessCharacter   $ProcessCharacter"}
    if($ProcessCharacter -eq "error"){write-host "Reflector, passed from rotor $RotorCChoice" ; if($ShowTable){write-host $DebugText} ; exit}
    $ProcessCharacter = Cipher-Rotor $RotorC $ProcessCharacter -Reverse
    if($ShowTable){$DebugText = $DebugText + "->$ProcessCharacter   $ProcessCharacter"}
    if($ProcessCharacter -eq "error"){write-host "Rotor C reverse path, passed from reflector" ; if($ShowTable){write-host $DebugText} ; exit}
    $ProcessCharacter = Cipher-Rotor $RotorB $ProcessCharacter -Reverse
    if($ShowTable){$DebugText = $DebugText + "->$ProcessCharacter   $ProcessCharacter"}
    if($ProcessCharacter -eq "error"){write-host "Rotor B reverse path, passed from rotor $RotorCChoice" ; if($ShowTable){write-host $DebugText} ; exit}
    $ProcessCharacter = Cipher-Rotor $RotorA $ProcessCharacter -Reverse
    if($ShowTable){$DebugText = $DebugText + "->$ProcessCharacter   $ProcessCharacter"}
    if($ProcessCharacter -eq "error"){write-host "Rotor A reverse path, passed from rotor $RotorBChoice" ; if($ShowTable){write-host $DebugText} ; exit}
    $ProcessCharacter = Cipher-Plugboard $ProcessCharacter
    if($ShowTable){$DebugText = $DebugText + "->$ProcessCharacter   $ProcessCharacter"}
    $CipherLength = $CipherLength + 1
    $CipherText = $CipherText + $ProcessCharacter
    if($OutputBlocks){
        if(($CipherLength % $OutputBlocks) -eq 1){
            $CipherText = $CipherText + " "
            if($ShowTable){write-host ""}
        }
    }
    #Step Rotor A - every time
    if($RotorAChoice -ne "0"){$RotorA = Advance-Rotor $RotorA}
    $RotorACount = $RotorACount + 1
    if($ShowTable){$DebugText = $DebugText + "     + Rotor A step"}

    #Step C if B is at notch, and double step
    if($RotorBCount -eq $RotorB.notch){
        if($ShowTable){$DebugText = $DebugText + " + Rotor C step"}
        $RotorBCount = $RotorBCount - $RotorSize
        $RotorBOdo = $RotorBOdo + 1
        $RotorC = Advance-Rotor $RotorC
        $RotorCCount = $RotorCCount + 1
        $RotorB = Advance-Rotor $RotorB #double step
        if($ShowTable){$DebugText = $DebugText + " + Rotor B double step"}
        $RotorBCount = $RotorBCount + 1
    }

    #Step B if A is at notch
    if($RotorACount -eq $RotorA.notch){
        $RotorACount = $RotorACount - $RotorSize
        $RotorAOdo = $RotorAOdo + 1
        $RotorB = Advance-Rotor $RotorB
        $RotorBCount = $RotorBCount + 1
        if($ShowTable){$DebugText = $DebugText + " + Rotor B step"}
    }
    if($ShowTable -and $StepByStep){
        Read-Host "$DebugText"
    }
    elseif($ShowTable){
        write-host $DebugText
    }
}
$EndTime = Get-Date
$Time = [math]::Round(($EndTime - $StartTime).TotalSeconds,2)
if(!$Quiet){
    Write-Host "`nCiphertext:"
    Write-output $CipherText
    Write-Host ""
    Write-Host "Processed $Length chracters in $Time seconds"
    Write-Host "Rotors start positions: $RotorAChoice-$RotorAPosition $RotorBChoice-$RotorBPosition $RotorCChoice-$RotorCPosition"
    Write-Host "Rotors end positions: $RotorAChoice-$($RotorACount % $RotorSize) $RotorBChoice-$($RotorBCount % $RotorSize) $RotorCChoice-$($RotorCCount % $RotorSize)"
    Write-Host "Total rollovers: $RotorAChoice-$RotorAOdo $RotorBChoice-$RotorBOdo $RotorCChoice-$RotorCOdo `n"
        if($Pad){Write-Host "Note: -Pad option used. This is for encryption only!`n"}

} else {
    Write-output $CipherText
}
if($OutputFile){
    try {
        $CipherText | Out-File "$OutputFile" -ErrorAction Stop
    }
    catch {
        Write-Host "Error writing to file $OutputFile! $($PSItem.Exception.Message)"
    }
}

if($PauseWhenDone -eq $True){
    Read-Host
}
