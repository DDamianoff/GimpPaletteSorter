#!/usr/bin/pwsh

<#
    Current state:
        [V] Parse Hex to RGB.
        [ ] Parse RGB to HSL.
        [ ] Sort HSL.
        [ ] Express RGB/HSL as GIMP's color format.
        [ ] build the palette file.
#>

class RGB {
    <#
        TODO: Try to encapsulate.
    #>
    [int]$Red      = ([int]0)
    [int]$Green    = ([int]0)
    [int]$Blue     = ([int]0)

    RGB($red,$green,$blue){
        $this.Red   = $red;
        $this.Green = $green;
        $this.Blue  = $blue;
    }
}

class HSL {
    [int]$Hue           = 0
    [int]$Saturation    = 0
    [int]$Lightness     = 0

    HSL($hue,$saturation,$lightness){
        $this.$Hue          = $hue;
        $this.$Saturation   = $saturation;
        $this.$Lightness    = $lightness;
    }
}


<#
    TODO: simplify and integrate in RGB constructor.
#>
function Convert-ToRgb {
    param(  [Parameter(ParameterSetName = "HexValue", position = 0)]
            [ValidateScript( {$_ -match '[A-Fa-f0-9]{6}'})]
            [string]$HexValue)

        if ($HexValue[0] -eq "#") 
        {
            Set-Variable -Name HexValue -Value $HexValue.Substring(1,6);
        }
        
        New-Variable -Name red      -Value ([int]($hexValue.Substring(0,2)));
        New-Variable -Name green    -Value ([int]($hexValue.Substring(2,2)));
        New-Variable -Name blue     -Value ([int]($hexValue.Substring(4,2)));

        <#
            TODO: change this by "new-objet" syntax.
        #>
        return [RGB]::new($red,$green,$blue);
}

New-Variable    -Name           header                                              `
                -Description    "List of strings. Valid header for GIMP Palette"    `
                -Visibility     Public                                              `
                -Option         ReadOnly                                            `
                -Value          (Get-Content -Path ./PaletteFileHeader)             ;

New-Variable    -Name           hexValues                                               `
                -Description    "Array of strings. Spected hex colors, one per line."   `
                -Value          (Get-Content -Path "./palette.txt")                     ;


<#
    TODO: check if file exists and prompt user for what
    want t0do: replace or quit.
#>

New-Variable    -Name       resultFileName      `
                -Value      generatedPalette.gpl`
                -Option     ReadOnly            ;

New-Item        -ItemType   File                `
                -Name       $resultFileName     ;
<#
 #  set the header of the palette file.
 #>

Get-Variable -Name header -ValueOnly | Out-File -FilePath "./generatedPalette.gpl"

Remove-Item -Path ./generatedPalette.gpl `
            -Force                       `
            -Verbose                     ;

<#
 #  set colors in file
 #>
# foreach ($hexValue in $hexValues) {
#     [RGB]$color = Convert-Color -Hex $hexValue.Substring(1,6)
#     "$($color.Red)`t$($color.Green)`t$($color.Blue)`tUntitled" | Out-File -Append -FilePath "./generatedPalette.gpl"

