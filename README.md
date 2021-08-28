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

Keeps track of whether or not the function made any changes to the object. Useful to determine you are changing a pre-existing object, and need to know whether to save it or not.
```powershell
[bool]$changed = $false
$obj = [PSCustomObject]@{ }
Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "foo" -hasChanged ([ref]$changed) #test has changed
Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "bar" -hasChanged ([ref]$changed) #test property that pre-exist
Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "bar" -hasChanged ([ref]$changed) #test haschanged not flipping back on nil change
$obj | ConvertTo-JSON 
```
