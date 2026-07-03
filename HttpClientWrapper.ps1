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
        $this.AddHeader("Accept", $this.contentType)
    }

    # adds a header to the client settings
    [void] AddHeader([string]$key, [string]$value) {
        $this.client.DefaultRequestHeaders.Add($key, $value) 
    }

    # sets the base url of all requests
    [void] SetUrl([string]$url) {
        $this.client.BaseAddress = $url
    }

    # sets the content type of all requests
    [void] SetContentType([string]$contentType) {
        $this.AddHeader("Accept", $contentType)
    }

    # get request, returns a string
    [string] Get([string]$path) {
        $result = $this.client.GetStringAsync($path).GetAwaiter().GetResult()

        return $result
    }

    # delete request without a payload, returns a string
    [string] Delete([string]$path) {
        $result = $this.client.DeleteAsync($path).GetAwaiter().GetResult()

        return $result.Content.ReadAsStringAsync().Result
    }

    # delete request with a payload, returns a string
    [string] Delete([string]$path, $deleteContent) {
        $content = [System.Net.Http.HttpRequestMessage]::new("DELETE", $path)
        $content.Content = [System.Net.Http.StringContent]::new($deleteContent, [System.Text.Encoding]::UTF8, $this.contentType)

        $result = $this.client.SendAsync($content).GetAwaiter().GetResult()
        return $result.Content.ReadAsStringAsync().Result
    }

    # post request, returns a string
    [string] Post([string]$path, $postContent) {
        $content = [System.Net.Http.HttpRequestMessage]::new("POST", $path)
        $content.Content = [System.Net.Http.StringContent]::new($postContent, [System.Text.Encoding]::UTF8, $this.contentType)

        $result = $this.client.SendAsync($content).GetAwaiter().GetResult()
        return $result.Content.ReadAsStringAsync().Result
    }

    # put request, returns a string
    [string] Put([string]$path, $putContent) {
        $content = [System.Net.Http.HttpRequestMessage]::new("PUT", $path)
        $content.Content = [System.Net.Http.StringContent]::new($putContent, [System.Text.Encoding]::UTF8, $this.contentType)

        $result = $this.client.SendAsync($content).GetAwaiter().GetResult()
        return $result.Content.ReadAsStringAsync().Result
    }

    # internal method to set http options, enforces at tls1.2 & tls1.3, accepts any certificate without validation
    hidden [void] SetOptions() {
        $this.handler = [System.Net.Http.HttpClientHandler]::new()
        $this.handler.ServerCertificateCustomValidationCallback = [System.Net.Http.HttpClientHandler]::DangerousAcceptAnyServerCertificateValidator
        $this.handler.SslProtocols = [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls13

        $this.client = [System.Net.Http.HttpClient]::new($this.handler)
    }
}
