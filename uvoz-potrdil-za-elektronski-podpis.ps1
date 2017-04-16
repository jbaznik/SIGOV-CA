<#

certmgr.msc

http://superuser.com/questions/647036/view-install-certificates-for-local-machine-store-on-windows-7

mmc.exe / F5 refresh

Start mmc.exe (as administrator), menu File -> Add/Remove Snap-in.., select "Certificates", press Add, select radio button "Computer account", press Finish and OK.

https://blogs.technet.microsoft.com/scotts-it-blog/2014/12/30/working-with-certificates-in-powershell/

Importing the Certificates Module

In PowerShell, capabilities are provided through modules.  A module is a set of PowerShell cmdlets, functions, etc. that allow the admin to work with a particular technology such as Active Directory or SQL Server.  A core set of these modules is added automatically when PowerShell starts up, but if the desire is to work with some other technology, its module will need to be added.  If you attempt to use a cmdlet associated with a module which is not loaded, PowerShell may add it for you (assuming the module is located in the path that PowerShell looks for it).  For the Certificates module, we will need to add it since it is not present by default.

GET-COMMAND *CERT*

Notice that there are commands like Export-Certificate and the name of the module they belong to is PKI.  This tells us which module we need to import.  We do this by simply typing

IMPORT-MODULE PKI

This ensures that the Certificates module is imported and we’re ready to work with it.

Understanding Providers

To start working with certificates in PowerShell, it’s important to have an understanding of what a provider is.  Essentially this is how PowerShell is able to access a data store.  This data store may be the Windows file system, the local registry on a computer, or things like Active Directory and a SQL Server database.  Each type of data store has its own provider, including Certificates.  Each provider enables PowerShell to access a particular type of data store.

To see which providers are available, open PowerShell (this can be done with either the Console or the ISE) and type the following:

GET-PSPROVIDER

Drives – Providers “provide” access to different data stores, and Drives are the way the access is granted.  This is easy to see by looking at the command prompt in the screenshot above.  The prompt is set to PS C:\>.  While it might not be immediately obvious, this is the Drive (or PSDrive, to use PowerShell terminology) granting access to the Windows file system, in this case the C: drive.  By looking above under the FileSystem entry, the Drives are listed as (C, A, D).  This indicates that for PowerShell to interact with the Windows file system, it needs to do so using one of these drives.  Similarly, if PowerShell wants to interact with the local Certificates store, it will need to do so through the Cert drive.
To see a list of the Drives available on the local machine, type the following:

GET-PSDRIVE

To change to a particular drive, all that’s needed is to set PowerShell’s location to the desired PSDrive, type the following within PowerShell:

SET-LOCATION <PSDRIVE>

To connect to the certificate store on the local computer, an administrator would type the following in PowerShell:

SET-LOCATION CERT:

We’ve already seen that by typing SET-LOCATION CERT: in PowerShell will access the root of the Certificates data store on the local machine.  But there are several ways to specify the specific context we’re interested in.  Below I’ve listed two ways to set PowerShell to the LocalMachine context.

First, try the following:

SET-LOCATION CERT:

DIR

As we can see, my test lab has two contexts to work with.  We are interested in LocalMachine so I can simply change to that context just as I can with the Windows file system by entering the following in the PowerShell interface:

SET-LOCATION LOCALMACHINE

It turns out that getting to these stores in PowerShell is as simple as it was to get to the context itself.  First, to see the list of stores, you can type the following:

GET-CHILDITEM


Finally, we’ll take our certificate and import it (perhaps we’re importing it to another machine, in which case we’ll need to either move the cert to the destination machine or set up a network share so the other machine can access the cert.  In my case, I will import this certificate to another Windows 2012 R2 server I have in my test lab.

To import the certificate (and we are assuming we have successfully moved the .cer file to our destination machine), do the following:

Get-ChildItem –Path c:\import\export.cer | Import-Certificate –CertStoreLocation cert:\LocalMachine\My

Depending on how we want to write our code, we can do these two steps at the same time (relatively) or as two separate commands.  I’ll show you both.

First, if we want to export a certificate we need to find the certificate of interest.  We do this using the following command:

$selectedcert = (Get-ChildItem –Path cert:\LocalMachine\My\DE53B1272E43C14545A448FB892F7C07A217A765)

Let’s look at what we’re doing here:

$selectedcert is a variable that will store the certificate we choose (and there is nothing special about the name I chose…as long as we don’t select a reserved name, we can choose anything).  You can recognize a variable because it starts with $ and in this case we’re using it to hold the information we get using Get-ChildItem
Get-ChildItem is no different than the cmdlet we ran above.  The only difference is that it’s within parentheses, which means it will run first (think ‘order of operations’ from high school math).  We are explicitly specifying the path to the certificate using the –Path parameter and we’re using its thumbprint to uniquely identify which certificate we want to export

This line on its own doesn’t do much.  Once we enter it, we can type $selectedcert at the PowerShell prompt to see what it contains.  But we need to take the next step to actually export it.  To do this, we need to type the following:

Export-Certificate –Cert $selectedcert –FilePath c:\test\export.cer

This command does the following:

Export-Certificate is the cmdlet used to export the certificate, which should be self-explanatory
-Cert $selectedcert is used to specify the cert we are exporting.  Because we stored our chosen certificate in the $selectedcert variable in step 1 above, we can simply use the variable here instead of having to type out the entire command listed in step 1 (we can do this if we want…more on that in a moment)
-File path <path> specifies where we want to send the certificate and specifies the file extension we want to use.

How can I browse the certificates in my personal user store using PowerShell?

http://windowsitpro.com/powershell/browse-certificate-store-using-powershell

Set-Location Cert:\CurrentUser\My

Get-ChildItem | Format-Table Subject, FriendlyName, Thumbprint -AutoSize

How To Make Use Of Functions in PowerShell

http://www.jonathanmedd.net/2015/01/how-to-make-use-of-functions-in-powershell.html

#>

# I need to import module pki
Import-Module pki

# SET-LOCATION CERT:

# SET-LOCATION LOCALMACHINE

Start-Sleep -Seconds 5

# where are my certificate SIGOV-CA saved to import
$sitrust = "D:\Namesti\SIGOV-CA\Zaupanja vredni overitelji korenskih potrdil\si-trust-root.crt"
$sigenca = "D:\Namesti\SIGOV-CA\Vmesni overitelji potrdil\sigen-ca.xcert.crt" 
$sigencag2 = "D:\Namesti\SIGOV-CA\Vmesni overitelji potrdil\sigen-ca-g2.xcert.crt"
$sigovca = "D:\Namesti\SIGOV-CA\Vmesni overitelji potrdil\sigov-ca.xcert.crt"
$sigovca2 = "D:\Namesti\SIGOV-CA\Vmesni overitelji potrdil\sigov-ca2.xcert.crt"

# write down function Jure in powershell

Function Set-Certifikate
{

# I need some parameters in your function Set-Certifikate

Param([parameter(Mandatory=$true)][string] $sitrust, [string] $sigenca, [string] $sigencag2, [string] $sigovca, [string] $sigovca2)

Write-Host "Uvazam certifikate: zaupanja vredni overitelji korenskih potrdil SI-TRUST in vmesni overitelji potrdil SIGEN-CA in SIGOV-CA"

Get-ChildItem –Path $sitrust | Import-Certificate –CertStoreLocation cert:\LocalMachine\Root

Get-ChildItem –Path $sigenca | Import-Certificate –CertStoreLocation cert:\LocalMachine\CA
Get-ChildItem –Path $sigencag2 | Import-Certificate –CertStoreLocation cert:\LocalMachine\CA

Get-ChildItem –Path $sigovca | Import-Certificate –CertStoreLocation cert:\LocalMachine\CA
Get-ChildItem –Path $sigovca2 | Import-Certificate –CertStoreLocation cert:\LocalMachine\CA

}

# I need to call my function Set-Certifikate
Set-Certifikate -sitrust $sitrust -sigenca $sigenca -sigencag2 $sigencag2 -sigovca $sigovca -sigovca2 $sigovca2

# registriram podpisno komponento

regsvr32.exe  /s /u "C:\Program Files (x86)\SETCCE\proXSign PDF\XSignPDF.dll"

Start-Sleep -Seconds 15

regsvr32.exe /s "C:\Program Files (x86)\SETCCE\proXSign PDF\XSignPDF.dll"

# end of script


