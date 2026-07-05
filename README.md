# PowerShell-HttpClientWrapper
Wrapper class for System.Net.Http.HttpClient for use in PowerShell since Invoke-WebRequest doesn't work for most situations. Tested only on PowerShell 5.1. 

**WARNING**:

This is written to work with self-signed certificates, thus **explicitly turns off certificate validation**. Ensure you are aware of this before using.

# Usage
Only provides the following HTTP methods, extend it if you need other methods: 
- Get
- Post
- Delete (with and without payload)
- Put

Content type is assumed to be `application/json` by default. Override it using either the class method or the param constructor.

```powershell
# create a new client object without a url
$client = [HttpClientWrapper]::new()
$client.Get("https://[url to something]/path")

# set url
$client.SetUrl("https://[baseurl to something]")
# set content type
$client.SetContentType("text/plain")
# set other headers
$client.SetHeader("Authorization", "Basic [basic-auth-here]")

# create a new client object with a url
$client = [HttpClientWrapper]::new("https://[baseurl to something]")
$client.Get("/somepath")

# create a new client object with a url + content type
$client = [HttpClientWrapper]::new("https://[baseurl to something]", 'text/plain')
$client.Get("/somepath")
```
