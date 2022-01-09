#!/usr/bin/pwsh

function Convert-ToHsl {
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

    New-Variable -Name Segment;
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

Convert-ToHsl -Red 201 -Green 201 -Blue 199
