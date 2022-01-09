#!/usr/bin/pwsh

<#
    Current state:
        [V] Parse Hex to RGB.
        [ ] Parse RGB to HSL.
        [ ] Sort HSL.
        [ ] Implement the "Color" class (with RGB, hex and HSL)
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
function ConvertTo-Rgb {
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

function ConvertTo-Hsl {
    param (
        [Parameter()]
        [ValidateRange(0,255)]
        [double]$Red,

        [Parameter()]
        [ValidateRange(0,255)]
        [double]$Green,

        [Parameter()]
        [ValidateRange(0,255)]
        [double]$Blue)
    
    New-Variable -Name Hue;
    New-Variable -Name Saturation;
    New-Variable -Name Lightness;
    New-Variable -Name Chroma;

    <# ensure values are int #>
    Set-Variable    -Name   Red             `
                    -Value  ([int]$Red)     ;

    Set-Variable    -Name   Green           `
                    -Value  ([int]$Green)   ;

    Set-Variable    -Name   Blue            `
                    -Value  ([int]$Blue)    ;


    Set-Variable    -Name   Red             `
                    -Value  ($Red   / 256)  ;
    
    Set-Variable    -Name   Green           `
                    -Value  ($Green / 256)  ;
    
    Set-Variable    -Name   Blue            `
                    -Value  ($Blue  / 256)  ;


    [double]$Maximum = (@($Red,$Green,$Blue) | Measure-Object -Maximum).Maximum;
    [double]$Minimum = (@($Red,$Green,$Blue) | Measure-Object -Minimum).Minimum;
    
    Set-Variable    -Name   Chroma                  `
                    -Value  ($Maximum - $Minimum)   ;


    if ($Chroma -eq 0) {
        Set-Variable    -Name   Hue `
                        -Value  0   ;
    }
    else {
        switch ($Maximum) {
            $Red        {
                Set-Variable                                                    `
                    -Name   Hue                                                 `
                    -Value  ((60 * (($Green - $Blue) / $Chroma)  + 360) % 360)  ;
            }

            $Green      {
                Set-Variable                                                    `
                    -Name   Hue                                                 `
                    -Value  (60 * (($Blue - $Red)   / $Chroma)  + 120)          ;
            }

            $Blue       {
                Set-Variable                                                    `
                    -Name   Hue                                                 `
                    -Value  (60 * (($Red - $Green)  / $Chroma)  + 240)          ; 
            }

            $Minimum    {
                Set-Variable    -Name   Hue `
                                -Value  0   ;
            }
        }

        Remove-Variable -Name "Switch";
    }


    Set-Variable                                        `
        -Name   Lightness                               `
        -Value  ([double](($Maximum + $Maximum) / 2))   ;



    if ($Maximum -eq $Minimum) {
        Set-Variable            `
            -Name   Saturation  `
            -Value  0           ;
    }
    elseif ($Lightness -le 0.5) {
        Set-Variable    -Name   Saturation                                              `
                        -Value  ([double]($Maximum - $Minimum) / (2 * $Lightness))      ;
    }
    elseif ($Lightness -gt 0.5) {
        Set-Variable    -Name   Saturation                                              `
                        -Value  ([double]($Maximum - $Minimum) / (2 - 2 * $Lightness))  ;
    }

    return @($Hue, $Saturation, $Lightness);
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
