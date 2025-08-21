# SystemAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**heartbeatApiHeartbeatGet**](SystemAPI.md#heartbeatapiheartbeatget) | **GET** /api/heartbeat | Heartbeat


# **heartbeatApiHeartbeatGet**
```swift
    open class func heartbeatApiHeartbeatGet(completion: @escaping (_ data: HeartbeatResponse?, _ error: Error?) -> Void)
```

Heartbeat

Endpoint to set the CSRF token in cache and return all the basic RomM config  Returns:     HeartbeatReturn: TypedDict structure with all the defined values in the HeartbeatReturn class.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Heartbeat
SystemAPI.heartbeatApiHeartbeatGet() { (response, error) in
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

[**HeartbeatResponse**](HeartbeatResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

