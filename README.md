# ActiveDirectory

Open a Microsoft account at outlook.com. Secure it with mfa and ensure security question answers aren't guessable. Use this to create volume license service centre account, mms.microsoft.com, manage.windowsazure.com (Azure AD) and portal.office.com accounts.

Engage supplier to sort volume license out if enough users. Products to include are Windows server (physical deployment as AWS and Azure include license), Windows 10, Enterprise Mobility Suite (EMS), Office 365, Microsoft Desktop Optimisation Pack (MDOP).

This high level design doc is fairly generic. A low level design doc will cover whether to use Azure, AWS or Hyper-V to provision services.

 - 1 or 2 domain controllers. Running latest patched Windows Server core. DCs also run DHCP and DNS. Install agent from the MMS portal created earlier. 
 - Set up alerts on portal to monitor and alert changes to domain admin, schema admin, enterprise admin etc groups and changes to DSRM password.
 - Deploy Advanced Threat Analytics from the Enterprise Mobility Suite or Volume License.
 - Secure AD and increase alerts as per other github repo
 - Deploy Advanced Group Policy Manager from MDOP.
 - Deploy Microsoft BitLocker Administration and Monitoring from MDOP.
 - Deploy ADFS​ on a server core ​ & configure Azure Monitoring - https://azure.microsoft.com/en-us/documentation/articles/active-directory-aadconnect-health/
  - Set-ADFSProperties -LogLevel $((Get-ADFSProperties).LogLevel + "SuccessAudits" + "FailureAudits") 
 - Deploy AD Sync and configure it in full ADFS mode. This relies on an Azure AD being created earlier and domains being validated.
 - Ensure that all servers are setting local admin passwords using LAPS.
 - Configure a DFS Namespace for hosting file shares. Ensure that Access Based Enumeration is enabled.

​At this point we have AD deployed for the customer, it's secured using best practice. Security Logs are being exported to Microsoft Operations Management, processed and alerting where necessary.​  We have Intune in place for managing all clients and mobile devices. ​ 

All client should be deployed using the latest Windows 10 Enterprise (key for AppLocker) deployment and patches. Selection of the Anti-Virus software is part of the low level design process. All client machines should have a TPM Module, BitLocker Drive Encryption and Secure Boot Enabled. Network Unlock feature can be deployed to save entering a PIN on a secured network (i.e. the office)

​Software to be deployed to clients:
 - Microsoft ​LAPS​​
 - Microsoft Intune Client​ 

Plan to Generate a script to configure Ideal AD Setup. 

 - New-ADKey for Group Managed Service Accounts
 - DNS Signed Zone & GPO for using signed responses.
 - Enable AD Recycle Bin
   Enable-ADOptionalFeature –Identity ‘CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=contoso,DC=com’ –Scope ForestOrConfigurationSet –Target ‘contoso.com’
 - Import GPO for deploying Microsoft LAPS
 - Import GPO for BitLocker on laptops
 - Configure Auditing on the domain
 - Configure EFS Recovery Agent
 - Import GPO for default AppLocker policy