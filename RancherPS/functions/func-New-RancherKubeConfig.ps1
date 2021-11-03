function New-RancherKubeConfig {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory=$false)]
        [String]$Endpoint = $env:RancherEndpoint,

        [Parameter(Mandatory=$false)]
        [securestring]$Token = (ConvertTo-SecureString -AsPlainText -Force $Env:RancherToken),

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreSSLWarning = $env:RancherIgnoreSSLWarning,

        [Parameter(Mandatory)]
        [string]$ClusterId,

        [Parameter(Mandatory=$false)]
        [string]$DestinationPath
    )
      
    process {
        $paramsCluster = @{
            EndPoint = $Endpoint
            Token = $Token
            IgnoreSSLWarning = $true
            Method = "Post"
            ResourceClass = "cluster"
            ResourceId = $ClusterId
            Action = "generateKubeconfig"
        }

        $kubeConfig = (Invoke-RancherMethod @paramsCluster).config
        if ($kubeConfig) {
            if ($DestinationPath) {
                $destinationFile = join-path -Path $DestinationPath -ChildPath ([System.IO.Path]::getrandomfilename())
            }
            else {
                $destinationFile = [System.IO.Path]::GetTempFileName()
            }
            write-verbose "Kubeconfig will be saved to: $destinationFile"
            try {
                Set-Content -Path $destinationFile -Value $kubeConfig
                return (get-item $destinationFile)
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
        else {
            return $null
        }
    }
}