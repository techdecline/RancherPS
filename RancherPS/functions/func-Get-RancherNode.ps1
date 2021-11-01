function Get-RancherNode {
    [CmdletBinding(DefaultParameterSetName="ByNodeName")]
    param (
        [Parameter(Mandatory=$false)]
        [String]$Endpoint = $env:RancherEndpoint,

        [Parameter(Mandatory=$false)]
        [securestring]$Token = (ConvertTo-SecureString -AsPlainText -Force $Env:RancherToken),

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreSSLWarning = $env:RancherIgnoreSSLWarning,

        [Parameter(Mandatory=$false,ParameterSetName="ByNodeName")]
        [string]$ClusterId,

        [Parameter(Mandatory=$false,ParameterSetName="ByNodeName")]
        [string]$NodeName,

        [Parameter(Mandatory,ParameterSetName="ByNodeId")]
        [string]$NodeId
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
        
        switch ($PSCmdlet.ParameterSetName) {
            "ByNodeName" {
                if ($ClusterId) {
                    $filter.Add("clusterId",$ClusterId)
                }
                
                if($NodeName) {
                    $filter.Add("name",$NodeName)
                }
        
                if ($filter.Count -gt 0) {
                    $paramsNode.Add("Filter",$filter)
                }
            }
            "ByNodeId" {
                $paramsNode.Add("ResourceId",$NodeId)
            }
        }
        $node = Invoke-RancherMethod @paramsNode
        return $node
    }
}