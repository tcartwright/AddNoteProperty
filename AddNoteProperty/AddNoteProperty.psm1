<#
.SYNOPSIS
	This function will allow you to create very complex PSCustomObject's easily. 

.PARAMETER InputObject
	The base object to add the properties or property to.

.PARAMETER Properties
	String array of properties to add to the object. Each Element in the array is added as a sub-object, until the last one, which adds the value property.

.PARAMETER Value
	The object value to add for the value property of the very last element in Properties.

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
        [ref]$hasChanged
    )
    process {
        $obj = $InputObject
        # loop all but the very last property
        foreach ($propName in ($Properties | Select-Object -SkipLast 1)) { 
            if (!($obj | Get-Member -MemberType NoteProperty -Name $propName)) {
                $obj | Add-Member NoteProperty -Name $propName -Value (New-Object PSCustomObject) 
                if ($hasChanged) {
                    $hasChanged.Value = $true
                }
            }
            $obj = $obj.$propName
        }
        # add the very last property using the $value, or update it if it already exists
        $propName = ($Properties | Select-Object -Last 1) 
        if (!($obj | Get-Member -MemberType NoteProperty -Name $propName)) {
            $obj | Add-Member NoteProperty -Name $propName -Value $Value 
            if ($hasChanged) {
                $hasChanged.Value = $true
            }
        } else {
            if ($hasChanged) {
                $hasChanged.Value = $hasChanged.Value -bor ($obj."$propName" -ne $value)
            }
            $obj."$propName" = $value
        }
    }
}