class HttpClientWrapper {
    hidden [System.Net.Http.HttpClient]$client
    hidden [System.Net.Http.HttpClientHandler]$handler
    hidden [string]$contentType = "text/html; charset=UTF-8"

    # default ctor
    HttpClientWrapper() {
        $this.SetOptions()
    }

    # param ctor, use single url for all requests
    HttpClientWrapper([string]$url) {
        $this.SetOptions()
        $this.client.BaseAddress = $url
    }

    # param ctor, use single url + defines content type for all requests
    HttpClientWrapper([string]$url, [string]$contentType) {
        $this.SetOptions()
        $this.client.BaseAddress = $url 

        $this.contentType = $contentType
        $this.SetHeader("Accept", $this.contentType)
    }

    # adds a header to the client settings
    [void] SetHeader([string]$key, [string]$value) {
        $this.client.DefaultRequestHeaders.Remove($key) | Out-Null
        $this.client.DefaultRequestHeaders.Add($key, $value) 
    }

    # sets the base url of all requests
    [void] SetUrl([string]$url) {
        $this.client.BaseAddress = $url
    }

    [string] GetUrl() {
        return $this.client.BaseAddress
    }

    # sets the content type of all requests
    [void] SetContentType([string]$contentType) {
        $this.contentType = $contentType
        $this.SetHeader("Accept", $contentType)
    }

    [string] GetContentType() {
        return $this.contentType
    }

    # sets the timeout in seconds for all requests
    [void] SetTimeout([int]$timeout) {
        $this.client.Timeout = [System.TimeSpan]::FromSeconds($timeout)
    }

    [timespan] GetTimeout() {
        return $this.client.Timeout
    }

    # get request, returns a PSCustomObject from AsyncRequest
    [PSCustomObject] Get([string]$path) {
        return $this.AsyncRequest($path, $null, "GET")
    }

    # delete request without a payload, returns a PSCustomObject from AsyncRequest
    [PSCustomObject] Delete([string]$path) {
        return $this.AsyncRequest($path, $null, "DELETE") 
    }

    # delete request with a payload, returns a PSCustomObject from AsyncRequest 
    [PSCustomObject] Delete([string]$path, $deleteContent) {
        return $this.AsyncRequest($path, $deleteContent, "DELETE")
    }

    # post request without a payload, returns a PSCustomObject from AsyncRequest
    [PSCustomObject] Post([string]$path) {
        return $this.AsyncRequest($path, $null, "POST")
    }

    # post request with a payload, returns a PSCustomObject from AsyncRequest
    [PSCustomObject] Post([string]$path, $postContent) {
        return $this.AsyncRequest($path, $postContent, "POST")
    }

    # put request, returns a PSCustomObject from AsyncRequest
    [PSCustomObject] Put([string]$path, $putContent) {
        return $this.AsyncRequest($path, $putContent, "PUT")
    }

    # internal method for abstracting SendAsync requests for all HTTP methods 
    hidden [PSCustomObject] AsyncRequest([string]$path, $requestContent, [string]$requestType) {
        $content = [System.Net.Http.HttpRequestMessage]::new($requestType, $path)

        if ($requestContent -ne $null) {
            $content.Content = [System.Net.Http.StringContent]::new($requestContent, [System.Text.Encoding]::UTF8, $this.contentType)
        }

        $result = $this.client.SendAsync($content).GetAwaiter().GetResult()

        return [PSCustomObject]@{
            HTTPVersion         = $result.Version
            Content             = $result.Content.ReadAsStringAsync().Result
            Headers             = $result.Headers
            StatusCode          = $result.StatusCode # ref https://learn.microsoft.com/en-us/dotnet/api/system.net.httpstatuscode?view=net-10.0
            IsSuccessStatusCode = $result.IsSuccessStatusCode
        }
    }

    # internal method to set http options, enforces at least tls1.2 & tls1.3, accepts any certificate without validation
    hidden [void] SetOptions() {
        $this.handler = [System.Net.Http.HttpClientHandler]::new()
        $this.handler.ServerCertificateCustomValidationCallback = [System.Net.Http.HttpClientHandler]::DangerousAcceptAnyServerCertificateValidator
        $this.handler.SslProtocols = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

        $this.client = [System.Net.Http.HttpClient]::new($this.handler)
        $this.client.Timeout = [System.TimeSpan]::FromSeconds(10)
    }
}
