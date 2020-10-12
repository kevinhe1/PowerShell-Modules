## Account running script needs to have the right access perform the required query to the database
function executeSQLXMLOut{
    param(
        [string] $sqlServer,
        [string] $dataBase,
        [string] $query
    )
    $connection = new-object System.Data.SqlClient.SQLConnection("Data Source=$sqlServer;Integrated Security=True;Initial Catalog=$dataBase");
    $connection.Open()
    $cmd=New-Object system.Data.SqlClient.SqlCommand($query,$connection)
    $dataSet=New-Object system.Data.DataSet
    $dataAdapter=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
    [void]$dataAdapter.fill($dataSet)
    $connection.Close()
    [xml] $data = $dataSet.GetXml()
    return $data
}

## Needed otherwise class MySql.Data.MySqlClient.MySqlConnection won't be loaded
function mySQLInit{
    Add-Type -Path 'C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.15\Assemblies\v4.5.2\MySql.Data.dll'
}

## Account running script needs to have the right access perform the required query to the mySQL database.
function executeMYSQLXMLOut{
    Param(
        [string] $mySQLHost,
        [string] $mySQLAdminUserName,
        [string] $mySQLAdminPassword,
        [string] $mySQLDatabase,
        [string] $query
    )

    $connectionString = "Server=" + $mySQLHost + ";Port=3306;user id=" + $mySQLAdminUserName + ";Password=" + $mySQLAdminPassword + ";Database="+$mySQLDatabase
    Try{
        [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
        $connection = New-Object MySql.Data.MySqlClient.MySqlConnection
        $connection.ConnectionString = $connectionString
        $connection.Open()
        $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
        $dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
        $dataSet = New-Object System.Data.DataSet
        $recordCount = $dataAdapter.Fill($dataSet, "data")
        [xml] $data = $dataSet.GetXml()
    }
    Catch{
        Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
    }
    Finally{
        $connection.Close()
    }
    return $data
}
