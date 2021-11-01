function Stop-RancherNode {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory=$false)]
        [String]$Endpoint = $env:RancherEndpoint,

        [Parameter(Mandatory=$false)]
        [securestring]$Token = (ConvertTo-SecureString -AsPlainText -Force $Env:RancherToken),

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreSSLWarning = $env:RancherIgnoreSSLWarning,

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
        $paramGet = @{
            EndPoint = $Endpoint
            Token = $Token
            IgnoreSSLWarning = $true
            NodeId = $NodeId
        }
        $currentState = (Get-RancherNode @paramGet).state

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
        else {
            # Only run when Mode is cordon
            If ($currentState -eq "cordoned" ) {
                Write-Verbose "Node $NodeId is already cordoned"
                return
            }
        }

        Write-Verbose "Stopping node: $NodeId"
        $null = Invoke-RancherMethod @paramsNode
        return
    }
}