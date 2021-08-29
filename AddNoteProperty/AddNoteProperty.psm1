<#
.SYNOPSIS
	This function will allow you to create very complex PSCustomObject's easily.

.PARAMETER InputObject
	The base object to add the properties or property to.

.PARAMETER Properties
	String array of properties to add to the object. Each Element in the array is added as a sub-object, until the last one, which adds the value property.

.PARAMETER Value
	The object value to add for the value property of the very last element in Properties.

.PARAMETER ArrayProperty
	The name of the property in the chain that is an array. The first element in the item for the array must be marked with -IsNew. Note: Arrays can only be ADDED to. If you wish to edit an item in an array then pass in the individual item into the -InputObject.

.PARAMETER IsNew
	Switch that signifies this is the start of an an array object. Has not impact if ArrayProperty is not set

.PARAMETER hasChanged
	OPTIONAL: If the object is changed in any way the value will be flipped to true. Will not flip back to false inside the function. Can be reset to false outside of the function.

.EXAMPLE
	Overwrites an existing property on an object with a new value

	$obj = [PSCustomObject]@{ Testing = "foo"}
	Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "bar"

.EXAMPLE
	Adds a complex structure onto an object

	$obj = [PSCustomObject]@{ }
	Add-NoteProperty -InputObject $obj -Properties "Person", "Name", "First" -Value "Tim"
	Add-NoteProperty -InputObject $obj -Properties "Person", "Name", "Last" -Value "Cartwright"
	Add-NoteProperty -InputObject $obj -Properties "Person", "Age" -Value "Old"
	Add-NoteProperty -InputObject $obj -Properties "Person", "Phones", "Home" -Value "281-867-5309"
	Add-NoteProperty -InputObject $obj -Properties "Person", "Phones", "Mobile" -Value "713-867-5309"
	Add-NoteProperty -InputObject $obj -Properties "Person", "Address", "City" -Value "Houston"
	Add-NoteProperty -InputObject $obj -Properties "Person", "Address", "State" -Value "Texas"
	Add-NoteProperty -InputObject $obj -Properties "Person", "Address", "Zip" -Value "8675309"
	$obj | ConvertTo-JSON


.EXAMPLE
	Keeps track of whether or not the function made any changes to the object. Useful to determine you are changing a pre-existing object, and need to know whether to save it or not.

	[bool]$changed = $false
	$obj = [PSCustomObject]@{ }
	Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "foo" -hasChanged ([ref]$changed) #test has changed
	Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "bar" -hasChanged ([ref]$changed) #test property that pre-exist
	Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "bar" -hasChanged ([ref]$changed) #test haschanged not flipping back on nil change
	$obj | ConvertTo-JSON

.NOTES
	original code from here: https://stackoverflow.com/a/57183818/1988507 rewritten to allow very complex object creation
	original author: https://stackoverflow.com/users/5650875/j-peter
#>
function Add-NoteProperty {
    param(
        [Parameter(Mandatory=$true, ValuefromPipeline=$True)]
        [object]$InputObject,
        [Parameter(Mandatory=$true)]
        [string[]]$Properties,
        [Parameter(Mandatory=$true)]
        [object]$Value,
        [string]$ArrayProperty,
        [switch]$IsNew,
        [ref]$hasChanged
    )
    begin {
        #only test for changes if they passed in haschanged, and its false. once true, ignore.
        if ($hasChanged -and !$hasChanged.Value) {
            $InputObjectClone = $InputObject | ConvertTo-Json -Compress
        }
    }
    process {
        $obj = $InputObject
        # loop all but the very last property
        $propNames = New-Object System.Collections.ArrayList
        foreach ($p in ($Properties | Select-Object -SkipLast 1)) {
            $propNames.Add($p) | Out-Null
        }

        for($x = 0; $x -lt $propNames.Count; $x++) {
            $propName = $propNames[$x]
            $isArray = [bool]($ArrayProperty -and $ArrayProperty -ieq $propName)
            $ParentIsArray = $false
            if ($x -gt 0) {
                $ParentIsArray = [bool]($ArrayProperty -and $ArrayProperty -ieq $propNames[($x - 1)])
            }

            if ($ParentIsArray) {
                if ($IsNew.IsPresent) {
                    $tmpObj = (New-Object PSCustomObject)
                } else {
                    $tmpObj = $obj | Select-Object -Last 1
                }
                if (!($tmpObj | Get-Member -MemberType NoteProperty -Name $propName)) {
                    $tmpObj | Add-Member NoteProperty -Name $propName -Value (New-Object PSCustomObject)
                }
                $obj.Add($tmpObj) | Out-Null
                $obj = $tmpObj
            } else {
                if (!($obj | Get-Member -MemberType NoteProperty -Name $propName)) {
                    if ($isArray) {
                        $obj | Add-Member NoteProperty -Name $propName -Value (New-Object System.Collections.ArrayList)
                        $obj = $obj.$propName
                    } else {
                        $obj | Add-Member NoteProperty -Name $propName -Value (New-Object PSCustomObject)
                        $obj = $obj.$propName
                    }
                } else {
                    $obj = $obj.$propName
                }
            }
        }
        # add the very last property using the $value, or update it if it already exists
        $propName = ($Properties | Select-Object -Last 1)
        $propertyIsArray = [bool]($ArrayProperty -and $ArrayProperty -ieq $propName)
        $ParentIsArray = [bool]($ArrayProperty -and $ArrayProperty -ieq $Properties[-2])

        if ($propertyIsArray) {
            if ($IsNew.IsPresent) {
                $tmpObj = New-Object System.Collections.ArrayList
                $tmpObj.Add($Value) | Out-Null

                if (!($obj | Get-Member -MemberType NoteProperty -Name $propName)) {
                    $obj | Add-Member NoteProperty -Name $propName -Value $tmpObj
                }
            } else {
                $obj.$propName.Add($Value) | Out-Null
            }
        } elseif ($ParentIsArray) {
            if ($IsNew.IsPresent) {
                $tmpObj = (New-Object PSCustomObject)
                $obj.Add($tmpObj) | Out-Null
            } else {
                $tmpObj = $obj | Select-Object -Last 1
            }
            if (!($tmpObj | Get-Member -MemberType NoteProperty -Name $propName)) {
                $tmpObj | Add-Member NoteProperty -Name $propName -Value $Value
            }
        } else {
            if (!($obj | Get-Member -MemberType NoteProperty -Name $propName)) {
                $obj | Add-Member NoteProperty -Name $propName -Value $Value
            } else {
                $obj."$propName" = $value
            }
        }
    }
    end {
        if ($hasChanged -and !$hasChanged.Value) {
            $hasChanged.Value = [bool]($InputObjectClone -ine $InputObject | ConvertTo-Json -Compress)
        }
    }
}
