#!/usr/bin/pwsh

<#
    Current state:
        [V] Parse Hex to RGB.
        [V] Parse RGB to HSL.
        [ ] Sort HSL.
        [ ] Implement the "Color" class (with RGB, hex and HSL)
        [ ] Express RGB/HSL as GIMP's color format.
        [ ] build the palette file.
#>

class Color {
    [string]$HEX;
    [RGB]$RGB;
    [HSL]$HSL;

    Color([string]$Hex) {
        $this.HEX = $Hex;

        $this.RGB = $this.ConvertToRgb($Hex);
        $this.HSL = $this.ConvertToHsl($this.RGB);
    }

    [RGB]ConvertToRgb([string]$HexValue) {
        if ($HexValue[0] -eq "#") 
        {
            $HexValue = $HexValue.Substring(1,6);
        }
        
        [int]$this.Red    = ([int]($hexValue.Substring(0,2)));
        [int]$this.Green  = ([int]($hexValue.Substring(2,2)));
        [int]$this.Blue   = ([int]($hexValue.Substring(4,2)));

        <#
            TODO: change this by "new-objet" syntax.
        #>
        return [RGB]::new($this.Red,$this.Green,$this.Blue);
    }

    [HSL]ConvertToHsl([RGB]$RgbValue) {
        
        [double]$Red    = $RgbValue.Red;
        [double]$Green  = $RgbValue.Green;
        [double]$Blue   = $RgbValue.Blue;

        $this.Hue;
        $this.Saturation;
        $this.Lightness;
        $this.Chroma;

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


        if ($this.Chroma -eq 0) {
            Set-Variable    -Name   Hue `
                            -Value  0   ;
        }
        else {
            switch ($Maximum) {
                $Red        {
                    Set-Variable                                                    `
                        -Name   Hue                                                 `
                        -Value  ((60 * (($Green - $Blue) / $this.Chroma)  + 360) % 360)  ;
                }

                $Green      {
                    Set-Variable                                                    `
                        -Name   Hue                                                 `
                        -Value  (60 * (($Blue - $Red)   / $this.Chroma)  + 120)          ;
                }

                $Blue       {
                    Set-Variable                                                    `
                        -Name   Hue                                                 `
                        -Value  (60 * (($Red - $Green)  / $this.Chroma)  + 240)          ; 
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
        elseif ($this.Lightness -le 0.5) {
            Set-Variable    -Name   Saturation                                              `
                            -Value  ([double]($Maximum - $Minimum) / (2 * $this.Lightness))      ;
        }
        elseif ($this.Lightness -gt 0.5) {
            Set-Variable    -Name   Saturation                                              `
                            -Value  ([double]($Maximum - $Minimum) / (2 - 2 * $this.Lightness))  ;
        }

        return [HSL]::new($this.Hue,$this.Saturation,$this.Lightness);
    }
}


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



function Start-Main {
    New-Variable    -Name           header                                                  `
                    -Description    "List of strings. Valid header for GIMP Palette"        `
                    -Visibility     Public                                                  `
                    -Option         ReadOnly                                                `
                    -Value          (Get-Content -Path ./PaletteFileHeader)                 ;

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

    Get-Variable    -Name header                      `
                    -ValueOnly                        `
        | Out-File  -FilePath "./generatedPalette.gpl";

    Remove-Item     -Path ./generatedPalette.gpl `
                    -Force                       `
                    -Verbose                     ;
}


Start-Main;
<#
 #  set colors in file
 #>
# foreach ($hexValue in $hexValues) {
#     [RGB]$color = Convert-Color -Hex $hexValue.Substring(1,6)
#     "$($color.Red)`t$($color.Green)`t$($color.Blue)`tUntitled" | Out-File -Append -FilePath "./generatedPalette.gpl"

