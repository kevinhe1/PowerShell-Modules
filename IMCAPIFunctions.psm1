function trustAllCerts{
    add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

function xmlWebRequest{
    param(
        $URL, 
        [System.Management.Automation.PSCredential]$cred
    )
    $dummy = Invoke-WebRequest -Uri $URL -Credential $cred -ErrorAction Stop
    [xml]$XML = $dummy
    return $XML
}  

#name of check is case sensitive
function getTaskID{
    param(
        [string]$nameOfCheck,
        [string]$server,
        [System.Management.Automation.PSCredential]$cred
    )
    $nameOfCheckEncoded = $nameOfCheck -replace ' ','%20'
    $URI = $server + "/imcrs/perf/task?name=" + $nameOfCheckEncoded
    $dummy = xmlWebRequest -URL $URI -cred $cred
    return $dummy.list.task.taskId
}

function getDevID{
    param(
        [string]$devIP,
        [string]$server,
        [System.Management.Automation.PSCredential]$cred
    )
    $URI = $server + "/imcrs/plat/res/device/allMsg/" + $devIP
    $dummy = xmlWebRequest -URL $URI -cred $cred
    return $dummy.deviceInfo.id
}

function getObjIndex{
    param(
        [string]$interface,
        [string]$server, 
        [int]$taskID, 
        [int]$devID, 
        [int]$granularity,
        [System.Management.Automation.PSCredential]$cred
    )
    $URI = $server + "/imcrs/perf/summaryData/details?taskId=" + $taskID + "&devId="+ $devID + "&dataGranularity=" + $granularity
    $dummy = xmlWebRequest -URL $URI -cred $cred
    $interfaceList = $dummy.list.perfSummaryData.objIndexDesc
    if($interfaceList -ne $null){
        ## May need to tweak string to search for ease of user to input config file.
        $arrayIndex = [array]::IndexOf($interfaceList, "[interface:"+$interface + "]")
        if($arrayIndex -eq -1){
            Write-Output "getObjIndex - $interface does not exist or isn't being monitored"
            return -1
        }
        $objIndex = $dummy.list.perfSummaryData.objIndex[$arrayIndex]
        return $objIndex
    }else{
        #Returned interface list is null
        return -1
    }
} 

function getIntPerfData{
    param(
        [string]$server, 
        [int]$taskID, 
        [int]$devID, 
        [int]$objIndex, 
        [int]$granularity,
        [System.Management.Automation.PSCredential]$cred,
        [Parameter(Mandatory=$false)] [AllowNull()] $beginTime = $null,
        [Parameter(Mandatory=$false)] [AllowNull()] $endTime = $null
    )
    if(($beginTime -eq $null) -and ($endTime -eq $null)){
        $URI = $server + "/imcrs/perf/summaryData/interface?taskId=" + $taskID + "&devId="+ $devID + "&objIndex=" + $objIndex + "&dataGranularity=" + $granularity
    } elseif(($beginTime -ne $null) -and ($endTime -ne $null)){
        $URI = $server + "/imcrs/perf/summaryData/interface?taskId=" + $taskID + "&devId="+ $devID +"&beginTime="+$beginTime + '&endTime=' + $endTime + "&objIndex=" + $objIndex + "&dataGranularity=" + $granularity  
    }else{
        Write-Output "Only one of either beginTime and endTime is set. Please set both or none at all"
        return -1
    }
    $dummy = xmlWebRequest -URL $URI -cred $cred
    return $dummy
}

function getAssetInfo{
    param(
        [string]$server, 
        [string]$devIP, 
        [System.Management.Automation.PSCredential]$cred
    )
    $URI = $server + "/imcrs/netasset/asset?assetDevice.ip=" + $devIP
    $dummy = xmlWebRequest -URL $URI -cred $cred
    return $dummy
}

function getAllDevices{
    param(
        [string]$server,
        [System.Management.Automation.PSCredential]$cred
    )
    $URI = $server + "/imcrs/plat/res/device?resPrivilegeFilter=false&start=0&size=1000&orderBy=id&desc=false&total=false&exact=false"
    $dummy = xmlWebRequest -URL $URI -cred $cred
    return $dummy
}

