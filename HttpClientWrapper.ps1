class HttpClientWrapper {
    hidden [System.Net.Http.HttpClient]$client
    hidden [System.Net.Http.HttpClientHandler]$handler
    hidden [string]$contentType = "application/json"

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

    # sets the content type of all requests
    [void] SetContentType([string]$contentType) {
        $this.contentType = $contentType
        $this.SetHeader("Accept", $contentType)
    }

    # get request, returns a string
    [string] Get([string]$path) {
        return $this.AsyncRequest($path, $null, "GET")
    }

    # delete request without a payload, returns a string
    [string] Delete([string]$path) {
        return $this.AsyncRequest($path, $null, "DELETE") 
    }

    # delete request with a payload, returns a string
    [string] Delete([string]$path, $deleteContent) {
        return $this.AsyncRequest($path, $deleteContent, "DELETE")
    }

    # post request without a payload, returns a string
    [string] Post([string]$path) {
        return $this.AsyncRequest($path, $null, "POST")
    }

    # post request with a payload, returns a string
    [string] Post([string]$path, $postContent) {
        return $this.AsyncRequest($path, $postContent, "POST")
    }

    # put request, returns a string
    [string] Put([string]$path, $putContent) {
        return $this.AsyncRequest($path, $putContent, "PUT")
    }

    # internal method for abstracting SendAsync requests for all HTTP methods 
    hidden [string] AsyncRequest([string]$path, $requestContent, [string]$requestType) {
        $content = [System.Net.Http.HttpRequestMessage]::new($requestType, $path)

        if ($requestContent -ne $null) {
            $content.Content = [System.Net.Http.StringContent]::new($requestContent, [System.Text.Encoding]::UTF8, $this.contentType)
        }

        $result = $this.client.SendAsync($content).GetAwaiter().GetResult()
        return $result.Content.ReadAsStringAsync().Result
    }

    # internal method to set http options, enforces at least tls1.2 & tls1.3, accepts any certificate without validation
    hidden [void] SetOptions() {
        $this.handler = [System.Net.Http.HttpClientHandler]::new()
        $this.handler.ServerCertificateCustomValidationCallback = [System.Net.Http.HttpClientHandler]::DangerousAcceptAnyServerCertificateValidator
        $this.handler.SslProtocols = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

        $this.client = [System.Net.Http.HttpClient]::new($this.handler)
    }
}
