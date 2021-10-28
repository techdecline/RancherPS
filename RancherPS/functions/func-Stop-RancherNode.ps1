function Stop-RancherNode {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory)]
        [String]$Endpoint,

        [Parameter(Mandatory)]
        [securestring]$Token,

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreSSLWarning,

        [Parameter(Mandatory)]
        [string]$NodeId,

        [Parameter(Mandatory=$false)]
        [ValidateSet("drain","cordon")]
        [string]$Mode = "drain",

        [Parameter(Mandatory=$false)]
        [switch]$DeleteLocalData = $false,

        [Parameter(Mandatory=$false)]
        [switch]$Force = $false,

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreDaemonSets = $false,

        [Parameter(Mandatory=$false)]
        [int16]$GracePeriod = -1,

        [Parameter(Mandatory=$false)]
        [int16]$Timeout = 120
    )
      
    process {
        $paramsNode = @{
            EndPoint = $Endpoint
            Token = $Token
            IgnoreSSLWarning = $true
            Method = "Post"
            Action = $Mode
            ResourceClass = "nodes"
            resourceId = $NodeId
        }

        if ($Mode -eq "drain") {
            $paramsNode.Add("Property",@{
                deleteLocalData = if ($DeleteLocalData) {"true"} else {"false"}
                force = if ($Force) {"true"} else {"false"}
                gracePeriod = $GracePeriod
                ignoreDaemonSets = if ($IgnoreDaemonSets) {"true"} else {"false"}
                timeout = $Timeout
            })
        }

        Write-Verbose "Stopping node: $NodeId"
        $result = Invoke-RancherMethod @paramsNode
        return $result
    }
}