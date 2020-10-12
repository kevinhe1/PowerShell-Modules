function fortiManagerPost(){
    param(
        [string] $method,
        $params, 
        [string] $session,
        [string] $uri
    )
	$body = @{
		method = $method
		params = $params
		id = $id++
		session = $session
	}
    $response = Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/json" -Body (ConvertTo-Json -Compress -Depth 100 $body) -ErrorVariable script:lastError -ErrorAction SilentlyContinue
	return $response
}

function fortiManagerLogin(){
    param(
        [STRING] $user,
        [string] $pass,
        [string] $uri
    )
	$response = fortiManagerPost -uri $uri -method "exec" -params @( @{
		url = "/sys/login/user"
		data = @{
			user = $user
			passwd = $pass
		}
	})
	return $response.session
}

function fortiManagerLogout(){
    param(
        [string] $session,
        [string] $uri
    )
	$response = fortiManagerPost -uri $uri -method "exec" -session $session -params @( @{
		url = "/sys/logout"
	})
	return $response
}

function getAllDevicesAdom(){
    param(
        [string] $adom,
        [string] $session,
        [string] $uri
    )
	$response = fortiManagerPost -uri $uri -method "get" -session $session -params @( @{
		url = "/dvmdb/adom/$adom/device/"
	})
	return $response
}

function getIPV4PoliciesInPkg{
    param(
        [string] $adom,
        [string] $package,
        [string] $session,
        [string] $uri
    )
    
    $response = fortiManagerPost -uri $uri -method "get" -session $session -params @(@{
        url = "/pm/config/adom/$adom/pkg/$package/firewall/policy"
    })
    return $response
}

function getProxyPoliciesInPkg{
    param(
        [string] $adom,
        [string] $package,
        [string] $session,
        [string] $uri
    )
    
    $response = fortiManagerPost -uri $uri -method "get" -session $session -params @(@{
        url = "/pm/config/adom/$adom/pkg/$package/firewall/proxy-policy"
    })
    return $response
}

function getAdomPolicyPackages{
    param(
        [string] $adom,
        [string] $session,
        [string] $uri
    )
    $response = fortiManagerPost -uri $uri -method "get" -session $session -params @(@{
        url = "/pm/pkg/adom/$adom"
    })
    return $response
}

function getAllAdoms{
    param(
        [string] $session,
        [string] $uri
    )
    $response = fortiManagerPost -uri $uri -method "get" -session $session -params @(@{
        url = "/dvmdb/adom/"
    })
    return $response
}
