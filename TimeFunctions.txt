function getEpochTime{
    param(
        $date
    )
    $unixStartTime = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
    $unixTime = (New-TimeSpan -Start $unixStartTime -End $date.ToUniversalTime()).TotalSeconds
    return $unixTime

}
