function Get-RancherCluster {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory=$false)]
        [String]$Endpoint = $env:RancherEndpoint,

        [Parameter(Mandatory=$false)]
        [securestring]$Token = (ConvertTo-SecureString -AsPlainText -Force $Env:RancherToken),

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreSSLWarning = $env:RancherIgnoreSSLWarning,

        [Parameter(Mandatory,ParameterSetName="ByName")]
        [string]$ClusterName,

        [Parameter(Mandatory,ParameterSetName="ByClusterId")]
        [string]$ClusterId
    )
      
    process {
        $paramsCluster = @{
            EndPoint = $Endpoint
            Token = $Token
            IgnoreSSLWarning = $true
            Method = "Get"
            ResourceClass = "cluster"
            # Filter = @{
            #     clusterId = "c-qpsrs"
            #     nodeName = "ff2-ab-p-0-1"
            # }
        }
        switch ($PSCmdlet.ParameterSetName) {
            "ByName" {
                Write-Verbose "Cluster will be queried by Name"
                $paramsCluster.Add(
                    "Filter",@{
                        name = "$ClusterName"
                    }
                )
            }
            "ByClusterId" {
                Write-Verbose "Cluster will be queried by Id"
                $paramsCluster.Add(
                    "ResourceId",$ClusterId
                )
            }
        }
        $cluster = Invoke-RancherMethod @paramsCluster
        return $cluster
    }
}