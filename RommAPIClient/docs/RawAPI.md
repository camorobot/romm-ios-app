# RawAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getRawAssetApiRawAssetsPathGet**](RawAPI.md#getrawassetapirawassetspathget) | **GET** /api/raw/assets/{path} | Get Raw Asset
[**headRawAssetApiRawAssetsPathHead**](RawAPI.md#headrawassetapirawassetspathhead) | **HEAD** /api/raw/assets/{path} | Head Raw Asset


# **getRawAssetApiRawAssetsPathGet**
```swift
    open class func getRawAssetApiRawAssetsPathGet(path: String, completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Get Raw Asset

Download a single asset file  Args:     request (Request): Fastapi Request object     path (str): Relative path to the asset file  Returns:     FileResponse: Returns a single asset file  Raises:     HTTPException: 404 if asset not found or access denied

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let path = "path_example" // String | 

// Get Raw Asset
RawAPI.getRawAssetApiRawAssetsPathGet(path: path) { (response, error) in
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
 **path** | **String** |  | 

### Return type

**AnyCodable**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **headRawAssetApiRawAssetsPathHead**
```swift
    open class func headRawAssetApiRawAssetsPathHead(path: String, completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Head Raw Asset

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let path = "path_example" // String | 

// Head Raw Asset
RawAPI.headRawAssetApiRawAssetsPathHead(path: path) { (response, error) in
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
 **path** | **String** |  | 

### Return type

**AnyCodable**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

