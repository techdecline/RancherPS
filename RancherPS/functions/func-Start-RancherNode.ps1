function Start-RancherNode {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory=$false)]
        [String]$Endpoint = $env:RancherEndpoint,

        [Parameter(Mandatory=$false)]
        [securestring]$Token = (ConvertTo-SecureString -AsPlainText -Force $Env:RancherToken),

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreSSLWarning = $env:RancherIgnoreSSLWarning,

        [Parameter(Mandatory)]
        [string]$NodeId
    )
      
    process {
        $paramGet = @{
            EndPoint = $Endpoint
            Token = $Token
            IgnoreSSLWarning = $true
            NodeId = $NodeId
        }
        $currentState = (Get-RancherNode @paramGet).state
        Write-Verbose "Current State of $NodeId is: $currentState"
        if (@("cordoned","drained") -contains $currentState ) {
            $paramsNode = @{
                EndPoint = $Endpoint
                Token = $Token
                IgnoreSSLWarning = $true
                Method = "Post"
                Action = "uncordon"
                ResourceClass = "nodes"
                resourceId = $NodeId
            }
    
            Write-Verbose "Uncordorning node: $NodeId"
            try {
                $null = Invoke-RancherMethod @paramsNode
                return
            }
            catch {
                throw "Unable to uncordon node: $($error[0].exception.message)"
            }
        } 
        else {
            # Nothing to do
            return
        }      
    }
}