# FeedsAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**platformsWebrcadeFeedApiWebrcadeFeedGet**](FeedsAPI.md#platformswebrcadefeedapiwebrcadefeedget) | **GET** /api/webrcade/feed | Platforms Webrcade Feed
[**tinfoilIndexFeedApiTinfoilFeedGet**](FeedsAPI.md#tinfoilindexfeedapitinfoilfeedget) | **GET** /api/tinfoil/feed | Tinfoil Index Feed


# **platformsWebrcadeFeedApiWebrcadeFeedGet**
```swift
    open class func platformsWebrcadeFeedApiWebrcadeFeedGet(completion: @escaping (_ data: WebrcadeFeedSchema?, _ error: Error?) -> Void)
```

Platforms Webrcade Feed

Get webrcade feed endpoint https://docs.webrcade.com/feeds/format/  Args:     request (Request): Fastapi Request object  Returns:     WebrcadeFeedSchema: Webrcade feed object schema

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Platforms Webrcade Feed
FeedsAPI.platformsWebrcadeFeedApiWebrcadeFeedGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**WebrcadeFeedSchema**](WebrcadeFeedSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tinfoilIndexFeedApiTinfoilFeedGet**
```swift
    open class func tinfoilIndexFeedApiTinfoilFeedGet(slug: String? = nil, completion: @escaping (_ data: TinfoilFeedSchema?, _ error: Error?) -> Void)
```

Tinfoil Index Feed

Get tinfoil custom index feed endpoint https://blawar.github.io/tinfoil/custom_index/  Args:     request (Request): Fastapi Request object     slug (str, optional): Platform slug. Defaults to \"switch\".  Returns:     TinfoilFeedSchema: Tinfoil feed object schema

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let slug = "slug_example" // String |  (optional) (default to "switch")

// Tinfoil Index Feed
FeedsAPI.tinfoilIndexFeedApiTinfoilFeedGet(slug: slug) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String** |  | [optional] [default to &quot;switch&quot;]

### Return type

[**TinfoilFeedSchema**](TinfoilFeedSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

