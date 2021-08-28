# PowerShell Add-NoteProperty

This function will allow you to create very complex PSCustomObject's easily.

### Examples: 

Installs the latest version of the module from the Powershell Gallery
```powershell
Install-Module -Name AddNoteProperty -Force
```

Overwrites an existing property on an object with a new value
```powershell
$obj = [PSCustomObject]@{ Testing = "foo"}
Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "bar"
```

Adding properties with special characters
```powershell
$obj = [PSCustomObject]@{}
Add-NoteProperty -InputObject $obj -Properties "Build", "system.debug" -Value $true
Add-NoteProperty -InputObject $obj -Properties "Build", "configuration" -Value "release"
Add-NoteProperty -InputObject $obj -Properties "Build", "platform" -Value "any cpu"
$obj | ConvertTo-JSON 
```

Outputs:
```json
{
  "Build": {
    "system.debug": true,
    "configuration": "release",
    "platform": "any cpu"
  }
}
```

Adds a complex structure onto an object
```powershell
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
```

Outputs:
```json
{
  "Person": {
    "Name": {
      "First": "Tim",
      "Last": "Cartwright"
    },
    "Age": "Old",
    "Phones": {
      "Home": "281-867-5309",
      "Mobile": "713-867-5309"
    },
    "Address": {
      "City": "Houston",
      "State": "Texas",
      "Zip": "8675309"
    }
  }
}
```

The optional \[ref\]$hasChanged parametercan be used to keep track of whether or not the function made any changes to the object. Useful to determine you are changing a pre-existing object, and need to know whether to save it or not.
```powershell
[bool]$changed = $false
$obj = [PSCustomObject]@{ Testing = "foo" }

#test has changed, with nil change
Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "foo" -hasChanged ([ref]$changed) 
"1. HasChanged: $changed"

#test property that pre-exists
Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "bar" -hasChanged ([ref]$changed) 
"2. HasChanged: $changed"

#test haschanged not flipping back on nil change
Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "bar" -hasChanged ([ref]$changed) 
"3. HasChanged: $changed"
```

Outputs:
```powershell
1. HasChanged: False
2. HasChanged: True
3. HasChanged: True
```

### Credits 	

  - Original idea came from [here][1]
  - [Original author][2]
  - Modifications:
    - Rewrote to loop instead of recursion
    - modified property string to property string array, allows w/e to be passed in as the property, no need to split / replace
    - can handle adding very complex structures
    - will add or replace last value property
    - can pipeling in the original object, made the main parameters mandatory
    - added haschanged so if changing an existing object you can determine if any changes have occured. once true, never resets to false        
	
[1]: https://stackoverflow.com/a/57183818/1988507/
[2]: https://stackoverflow.com/users/5650875/j-peter


