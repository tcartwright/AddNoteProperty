# PowerShell Add-NoteProperty

This function will allow you to create very complex PSCustomObject's easily.

## What it can and cannot do:

  - It can 
  	- Add or edit complex custom properties to objects
  	- Add complex arrays with sub objects to those arrays
  	- Add simple arrays of value types
  - It can not:
  	- Edit arrays. To edit an array item, pass the individual item into the -InputObject parameter	

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

The optional \[ref\]$hasChanged parameter can be used to keep track of whether or not the function made any changes to the object. Useful to determine you are changing a pre-existing object, and need to know whether to save it or not.
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

Working with complex objects and arrays
```powershell
$obj = [PSCustomObject]@{ }
Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "foo" -ArrayProperty "Testing" -IsNew
Add-NoteProperty -InputObject $obj -Properties "Testing" -Value "bar" -ArrayProperty "Testing"

Add-NoteProperty -InputObject $obj -Properties "Person", "Name", "First" -Value "Tim"
Add-NoteProperty -InputObject $obj -Properties "Person", "Name", "Last" -Value "Cartwright"
Add-NoteProperty -InputObject $obj -Properties "Person", "Age" -Value "Older than an ant, younger than a mountain"

# we are going to add an array of phones, each new phone must be marked off with -isnew
$ArrayProperty = "Phones"
Add-NoteProperty -InputObject $obj -Properties "Person", "Phones", "Number" -Value "281-867-5309" -ArrayProperty $ArrayProperty -IsNew
Add-NoteProperty -InputObject $obj -Properties "Person", "Phones", "Type" -Value "Home" -ArrayProperty $ArrayProperty

Add-NoteProperty -InputObject $obj -Properties "Person", "Phones", "Number" -Value "713-867-5309" -ArrayProperty $ArrayProperty -IsNew
Add-NoteProperty -InputObject $obj -Properties "Person", "Phones", "Type" -Value "Mobile" -ArrayProperty $ArrayProperty

Add-NoteProperty -InputObject $obj -Properties "Person", "Phones", "Number" -Value "555-867-5309" -ArrayProperty $ArrayProperty -IsNew
Add-NoteProperty -InputObject $obj -Properties "Person", "Phones", "Type" -Value "Work" -ArrayProperty $ArrayProperty


# we are going to add an array of addresses, each new address must be marked off with -isnew 
$ArrayProperty = "Addresses"
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "Address 1" -Value "123 Foo Lane" -ArrayProperty $ArrayProperty -IsNew
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "Address 2" -Value "APT 987" -ArrayProperty $ArrayProperty 
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "City" -Value "Houston"  -ArrayProperty $ArrayProperty 
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "State" -Value "Texas" -ArrayProperty $ArrayProperty
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "Zip" -Value "8675309" -ArrayProperty $ArrayProperty
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "Type" -Value "home" -ArrayProperty $ArrayProperty

Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "Address 1" -Value "555 Blueberry Hill" -ArrayProperty $ArrayProperty -IsNew
#leave off this property
#Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "Address 2" -Value "" -ArrayProperty $ArrayProperty 
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "City" -Value "Houston" -ArrayProperty $ArrayProperty 
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "State" -Value "Texas"  -ArrayProperty $ArrayProperty
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "Zip" -Value "77777" -ArrayProperty $ArrayProperty
Add-NoteProperty -InputObject $obj -Properties "Person", "Addresses", "Type" -Value "work" -ArrayProperty $ArrayProperty

Clear-Host
$obj | ConvertTo-JSON 
```

Outputs:
```json
{
  "Testing": ["foo", "bar"],
  "Person": {
    "Name": {
      "First": "Tim",
      "Last": "Cartwright"
    },
    "Age": "Older than an ant, younger than a mountain",
    "Phones": [
      "@{Number=281-867-5309; Type=Home}",
      "@{Number=713-867-5309; Type=Mobile}",
      "@{Number=555-867-5309; Type=Work}"
    ],
    "Addresses": [
      "@{Address 1=123 Foo Lane; Address 2=APT 987; City=Houston; State=Texas; Zip=8675309; Type=home}",
      "@{Address 1=555 Blueberry Hill; City=Houston; State=Texas; Zip=77777; Type=work}"
    ]
  }
}
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
    - added ability add arrays    
	
[1]: https://stackoverflow.com/a/57183818/1988507/
[2]: https://stackoverflow.com/users/5650875/j-peter


