## Returns a list of devices set (if single device then it's standalone) in the GUI. Also returns details of each device
function getF5DeviceList{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential
    )
    return Invoke-RestMethod "https://$server/mgmt/tm/cm/device" -Credential $credential
}

## Checks the Active/Standby seen in the GUI.
function getF5FailOverStatus{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential
    )
    return Invoke-RestMethod "https://$server/mgmt/tm/shared/bigip-failover-state" -Credential $credential
}
function getF5PoolList{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential
    )
    return Invoke-RestMethod "https://$server/mgmt/tm/ltm/pool/" -Credential $credential
}

function getF5Pool{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential,
        [Parameter(Mandatory=$true)] [string] $poolFullPath
    )
    $path = $poolFullPath -replace '/', '~'
    return Invoke-RestMethod "https://$server/mgmt/tm/ltm/pool/$path" -Credential $credential
}

function getF5PoolMembers{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential,
        [Parameter(Mandatory=$true)] [string] $poolFullPath
    )
    $path = $poolFullPath -replace '/', '~'
    $temp = Invoke-RestMethod "https://$server/mgmt/tm/ltm/pool/$path" -Credential $credential
    $membersURI = "https://$server" + [regex]::matches($temp.membersReference.link,"/mgmt/.*").value
    return Invoke-RestMethod -Uri $membersURI -Credential $credential
}

function getF5VirtualServerList{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential
    )
    return Invoke-RestMethod "https://$server/mgmt/tm/ltm/virtual" -Credential $credential
}

function getF5VirtualServer{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential,
        [Parameter(Mandatory=$true)] [string] $vServerFullPath
    )
    $path = $vServerFullPath -replace '/', '~'
    return Invoke-RestMethod -Method Get -Uri "https://$server/mgmt/tm/ltm/virtual/$path" -Credential $credential
}

<# 
Example request body:
{
    "destination":  "/Common/someIP:someport",
    "name":  "KevinsPostTest"
}
#>
function createF5VirtualServer{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential,
        [Parameter(Mandatory=$true)] [hashtable] $postObject
    )
    $postObject_JSON = $postObject | ConvertTo-Json
    $header = @{"Content-Type" = "application/json"}
    return Invoke-RestMethod -Method Post -Uri "https://$server/mgmt/tm/ltm/virtual/" -Credential $credential -Body $postObject_JSON -Headers $header
}
    
function updateF5VirtualServer_patch{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential,
        [Parameter(Mandatory=$true)] [string] $vServerFullPath,
        [Parameter(Mandatory=$true)] [hashtable] $patchDocument
    )
    $path = $vServerFullPath -replace '/', '~'
    $patchDocument_JSON = $patchDocument | ConvertTo-Json
    $header = @{"Content-Type" = "application/json"}
    if(($vServerFullPath -eq $null) -or ($vServerFullPath -eq "")){
        Write-Debug "vServer is null or an empty string. vServer must be specified otherwise a new resource will be made instead of a resource update."
        return -1
    }else{
        return Invoke-RestMethod -Method Patch -Uri "https://$server/mgmt/tm/ltm/virtual/$path" -Credential $credential -Body $patchDocument_JSON -Headers $header
    }
}

function getF5iAppTemplateList{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential
    )
    return Invoke-RestMethod -Method Get -Uri "https://$server/mgmt/tm/sys/application/template" -Credential $credential
}

function getF5iAppTemplate{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential,
        [Parameter(Mandatory=$true)] [string] $IAppTemplateFullPath
    )
    $path = $IAppTemplateFullPath -replace '/', '~'
    return Invoke-RestMethod -Method Get -Uri "https://$server/mgmt/tm/sys/application/template/$path" -Credential $credential
}

function getF5AppServiceList{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential
    )
    return Invoke-RestMethod -Method Get -Uri "https://$server/mgmt/tm/sys/application/service" -Credential $credential
}

function getF5AppService{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential,
        [Parameter(Mandatory=$true)] [string] $appServiceFullPath
    )
    $path = $appServiceFullPath -replace '/', '~'
    return Invoke-RestMethod -Method Get -Uri "https://$server/mgmt/tm/sys/application/service/$path" -Credential $credential
}

function createF5AppService{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential,
        [Parameter(Mandatory=$true)] [hashtable] $postObject
    )
    $postObject_JSON = $postObject | ConvertTo-Json
    $header = @{"Content-Type" = "application/json"}
    return Invoke-RestMethod -Method Post -Uri "https://$server/mgmt/tm/sys/application/service" -Credential $credential -Body $postObject_JSON -Headers $header
}

function updateF5AppService_patch{
    param(
        [string] $server,
        [System.Management.Automation.PSCredential] $credential,
        [Parameter(Mandatory=$true)] [string] $appServiceFullPath,
        [Parameter(Mandatory=$true)] [hashtable] $patchDocument
    )
    $path = $appServiceFullPath -replace '/', '~'
    $patchDocument_JSON = $patchDocument | ConvertTo-Json
    $header = @{"Content-Type" = "application/json"}
    if(($appServiceFullPath -eq $null) -or ($appServiceFullPath -eq "")){
        Write-Debug "AppService is null or an empty string. AppService must be specified otherwise a new resource will be made instead of a resource update."
        return -1
    }else{
        return Invoke-RestMethod -Method Patch -Uri "https://$server/mgmt/tm/sys/application/service/$path" -Credential $credential -Body $patchDocument_JSON -Headers $header
    }
}

