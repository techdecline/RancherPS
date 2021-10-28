function Start-RancherNode {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory)]
        [String]$Endpoint,

        [Parameter(Mandatory)]
        [securestring]$Token,

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreSSLWarning,

        [Parameter(Mandatory)]
        [string]$NodeId
    )
      
    process {
        $paramsNode = @{
            EndPoint = $Endpoint
            Token = $Token
            IgnoreSSLWarning = $true
            Method = "Post"
            Action = "uncordon"
            ResourceClass = "nodes"
            resourceId = $NodeId
            Property = @{
                deleteLocalData = if ($DeleteLocalData) {"true"} else {"false"}
                force = if ($Force) {"true"} else {"false"}
                gracePeriod = $GracePeriod
                ignoreDaemonSets = if ($IgnoreDaemonSets) {"true"} else {"false"}
                timeout = $Timeout
            }
        }
        
        Write-Verbose "Uncordorning node: $NodeId"
        $result = Invoke-RancherMethod @paramsNode
        return $result
    }
}