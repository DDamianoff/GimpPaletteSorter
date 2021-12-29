#!/usr/bin/pwsh

function FunctionName {
    param (
        [Parameter(ParameterSetName = "Red",    position = 0)]
        [Parameter(ParameterSetName = "Green",  position = 1)]
        [Parameter(ParameterSetName = "Blue",   position = 2)]

        [int]$Red,
        [int]$Green,
        [int]$Blue
    )
    
    
}