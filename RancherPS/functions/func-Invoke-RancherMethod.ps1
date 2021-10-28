function Invoke-RancherMethod {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory)]
        [String]$Endpoint,

        [Parameter(Mandatory)]
        [securestring]$Token,

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreSSLWarning,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Get","Post")]
        [string]$Method = "Get",

        [Parameter(Mandatory)]
        [String]$ResourceClass,

        [Parameter(Mandatory=$false)]
        [ValidateSet("cordon","drain","uncordon")]
        [String]$Action,

        [Parameter(Mandatory=$false)]
        [hashtable]$Property,

        [Parameter(Mandatory=$false,ParameterSetName="ByFilter")]
        [hashtable]$Filter,

        [Parameter(Mandatory,ParameterSetName="ByResourceId")]
        [String]$ResourceId
    )
    
    process {
        if ($IgnoreSSLWarning) {
            Write-Verbose "SSL Warnings will be ignored"
            #region CertIgnore
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
            {
            $certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
            Add-Type $certCallback
            }
            [ServerCertificateValidationCallback]::Ignore()
            #endregion
        }

        Write-Verbose "Constructing header for REST call"
        $headers = @{Authorization = "Bearer $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token)))"}
        if (-not $Headers.ContainsKey('Accept')) {
            $Headers.Add('Accept', 'application/json')
        }

        Write-Verbose "Constructing Url for REST Call"
        $restUrl = "$Endpoint/$ResourceClass"
        if ($ResourceId) {
            Write-Verbose "Appending Resource ID to Url"
            $restUrl = "$restUrl/$ResourceId"
        }
        if ($Action) {
            Write-Verbose "Appending action to Url"
            $restUrl = "$restUrl`?action=$Action"
        }
        
        if ($Filter) {
            $filterArr = [System.Collections.ArrayList]@()
            foreach ($h in $Filter.GetEnumerator() ) {
                Write-Verbose "Appending Filter: $($h.Name)=$($h.Value)"
                $null = $filterArr.Add("$($h.Name)=$($h.Value)")
            }
            $restUrl = "$restUrl`?$($filterArr -join '&')"
        }
        Write-Verbose "Resulting REST Url will be: $restUrl"

        Write-Verbose "Constructing REST Method Parameters"
        $restParams = @{
            Method = $Method
            Uri = $restUrl
            Headers = $headers
            ContentType = "application/json"
            UserAgent = "Nona Business"
            UseBasicParsing = $true
        }

        if ($Property) {
            Write-Verbose "Adding Body from provided Properties"
            $formData = $Property | ConvertTo-Json
            $restParams.add("Body",$formData)
        }

        switch ($Method) {
            "Get" {
                try {
                    $response = Invoke-RestMethod @restParams
                    switch ($PSCmdlet.ParameterSetName) {
                        "ByResourceId" {
                            $resultObj = $response
                        }
                        default {
                            $resultObj = $response.data
                        }
                    }
                }
                catch [System.Net.WebException]{
                    $PSCmdlet.ThrowTerminatingError($_)
                }
                return $resultObj
            }
            "Post" {
                try {
                    $response = Invoke-RestMethod @restParams
                    if ($response -ne "null") {
                        return $true
                    }
                    else {
                        Write-Warning $response
                        return $false
                    }
                }
                catch [System.Net.WebException]{
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
}