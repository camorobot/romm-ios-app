# ScreenshotsAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addScreenshotApiScreenshotsPost**](ScreenshotsAPI.md#addscreenshotapiscreenshotspost) | **POST** /api/screenshots | Add Screenshot


# **addScreenshotApiScreenshotsPost**
```swift
    open class func addScreenshotApiScreenshotsPost(romId: Int, completion: @escaping (_ data: ScreenshotSchema?, _ error: Error?) -> Void)
```

Add Screenshot

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let romId = 987 // Int | 

// Add Screenshot
ScreenshotsAPI.addScreenshotApiScreenshotsPost(romId: romId) { (response, error) in
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
 **romId** | **Int** |  | 

### Return type

[**ScreenshotSchema**](ScreenshotSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

