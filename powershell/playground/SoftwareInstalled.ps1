<#
// "AS-IS" sample MOF file for returning the two uninstall registry subkeys

// Unsupported, provided purely as a sample

// Requires compilation. Example: mofcomp.exe sampleproductslist.mof

// Implements sample classes: "SampleProductList" and "SampleProductlist32" 

//   (for 64-bit systems with 32-bit software)

 

#PRAGMA AUTORECOVER

 

[dynamic, provider("RegProv"),

ProviderClsid("{fe9af5c0-d3b6-11ce-a5b6-00aa00680c3f}"),ClassContext("local|HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall")]

class SampleProductsList {

[key] string KeyName;

[read, propertycontext("DisplayName")] string DisplayName;

[read, propertycontext("DisplayVersion")] string DisplayVersion;

};

 

[dynamic, provider("RegProv"),

ProviderClsid("{fe9af5c0-d3b6-11ce-a5b6-00aa00680c3f}"),ClassContext("local|HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")]

class SampleProductsList32 {

[key] string KeyName;

[read, propertycontext("DisplayName")] string DisplayName;

[read, propertycontext("DisplayVersion")] string DisplayVersion;

};
.LINK
    http://blogs.technet.com/b/askds/archive/2012/04/19/how-to-not-use-win32-product-in-group-policy-filtering.aspx
#>

Get-WmiObject -Class SampleProductslist32 -Namespace ROOT\DEFAULT |Select-Object -Property Displayname, DisplayVersion
Get-WmiObject -Class SampleProductslist -Namespace ROOT\DEFAULT |Select-Object -Property Displayname, DisplayVersion