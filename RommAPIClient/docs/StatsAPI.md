# StatsAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**statsApiStatsGet**](StatsAPI.md#statsapistatsget) | **GET** /api/stats | Stats


# **statsApiStatsGet**
```swift
    open class func statsApiStatsGet(completion: @escaping (_ data: StatsReturn?, _ error: Error?) -> Void)
```

Stats

Endpoint to return the current RomM stats  Returns:     dict: Dictionary with all the stats

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Stats
StatsAPI.statsApiStatsGet() { (response, error) in
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

[**StatsReturn**](StatsReturn.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

