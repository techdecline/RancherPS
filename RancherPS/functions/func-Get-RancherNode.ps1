function Get-RancherNode {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory)]
        [String]$Endpoint,

        [Parameter(Mandatory)]
        [securestring]$Token,

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreSSLWarning,

        [Parameter(Mandatory=$false)]
        [string]$ClusterId,

        [Parameter(Mandatory=$false)]
        [string]$NodeName
    )
      
    process {
        $filter = @{}
        $paramsNode = @{
            EndPoint = $Endpoint
            Token = $Token
            IgnoreSSLWarning = $true
            Method = "Get"
            ResourceClass = "node"
        }
        
        if ($ClusterId) {
            $filter.Add("clusterId",$ClusterId)
        }
        
        if($NodeName) {
            $filter.Add("name",$NodeName)
        }

        if ($filter.Count -gt 0) {
            $paramsNode.Add("Filter",$filter)
        }
        $node = Invoke-RancherMethod @paramsNode
        return $node
    }
}