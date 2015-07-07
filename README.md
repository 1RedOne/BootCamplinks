# Copy this to your Azure VM
Download this whole Repo as a .zip file using the link on the right side.  Unzip it to your Azure VM's C:\PowerShell folder.  

#Enable Remoting
If you haven't yet, On your VM, launch PowerShell as an admin, and run ‘winrm QuickConfig’

#Copy the two folders from the ZIP to your Vm's Modules Directory
From PowerShell on your VM, run this command : explorer $env:ProgramFiles\WindowsPowerShell\Modules
Go back to your C:\PowerShell folder and copy the two folders from the ZIP to the Modules folder. 

You should have two folders, xActiveDirectory and xComputerManagement.

#Use Desired State Configuration to build your AD Test Environment
Double-click the BootCampMachineConfig.PS1 file
