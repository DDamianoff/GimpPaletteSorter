#!/usr/bin/pwsh

<#
    Current state:
        [V] Parse Hex to RGB.
        [V] Parse RGB to HSL.
        [ ] Sort HSL.
        [V] Implement the "Color" class (with RGB, hex and HSL)
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
        
        [int]$Red    = [Convert]::ToInt16($hexValue.Substring(0,2),16);
        [int]$Green  = [Convert]::ToInt16($hexValue.Substring(2,2),16);
        [int]$Blue   = [Convert]::ToInt16($hexValue.Substring(4,2),16);

        <#
            TODO: change this by "new-objet" syntax.
        #>
        return [RGB]::new($Red,$Green,$Blue);
    }

    [HSL]ConvertToHsl([RGB]$RgbValue) {
        
        [double]$Red    = $RgbValue.Red;
        [double]$Green  = $RgbValue.Green;
        [double]$Blue   = $RgbValue.Blue;

        [int]   $Hue             = 0;
        [double]$Saturation      = 0;
        [double]$Lightness       = 0;
        [double]$Chroma          = 0;

        [double]$Maximum = 0;
        [double]$Minimum = 0;

                        #[int] for ignore floating values if are provided.
        Set-Variable    -Name   Red                     `
                        -Value  (([int]$Red)   / 256)   ;
        
        Set-Variable    -Name   Green                   `
                        -Value  (([int]$Green) / 256)   ;
        
        Set-Variable    -Name   Blue                    `
                        -Value  (([int]$Blue)  / 256)   ;


        Set-Variable    -Name Maximum                                                    `
                        -Value ((@($Red,$Green,$Blue) | Measure-Object -Maximum).Maximum);

        Set-Variable    -Name Minimum                                                    `
                        -Value ((@($Red,$Green,$Blue) | Measure-Object -Minimum).Minimum);
        
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
            -Value  ([double](($Maximum + $Minimum) / 2))   ;



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

        return [HSL]::new($Hue,$Saturation,$Lightness);
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
    [double]$Saturation    = 0
    [double]$Lightness     = 0

    HSL($hue,$saturation,$lightness){
        $this.Hue          = $hue;
        $this.Saturation   = $saturation;
        $this.Lightness    = $lightness;
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

    New-Variable    -Name       resultFileName          `
                    -Value      "generatedPalette.gpl"  `
                    -Option     ReadOnly                ;

    New-Item        -ItemType   File                    `
                    -Name       $resultFileName         ;
    <#
    #  set the header of the palette file.
    #>

    Get-Variable    -Name header                        `
                    -ValueOnly                          `
        | Out-File  -FilePath $resultFileName           ;

    Remove-Item     -Path $resultFileName               `
                    -Force                              `
                    -Verbose                            ;
}

Start-Main;