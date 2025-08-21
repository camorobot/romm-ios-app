# PlatformsAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addPlatformApiPlatformsPost**](PlatformsAPI.md#addplatformapiplatformspost) | **POST** /api/platforms | Add Platform
[**deletePlatformApiPlatformsIdDelete**](PlatformsAPI.md#deleteplatformapiplatformsiddelete) | **DELETE** /api/platforms/{id} | Delete Platform
[**getPlatformApiPlatformsIdGet**](PlatformsAPI.md#getplatformapiplatformsidget) | **GET** /api/platforms/{id} | Get Platform
[**getPlatformsApiPlatformsGet**](PlatformsAPI.md#getplatformsapiplatformsget) | **GET** /api/platforms | Get Platforms
[**getSupportedPlatformsApiPlatformsSupportedGet**](PlatformsAPI.md#getsupportedplatformsapiplatformssupportedget) | **GET** /api/platforms/supported | Get Supported Platforms
[**updatePlatformApiPlatformsIdPut**](PlatformsAPI.md#updateplatformapiplatformsidput) | **PUT** /api/platforms/{id} | Update Platform


# **addPlatformApiPlatformsPost**
```swift
    open class func addPlatformApiPlatformsPost(bodyAddPlatformApiPlatformsPost: BodyAddPlatformApiPlatformsPost, completion: @escaping (_ data: PlatformSchema?, _ error: Error?) -> Void)
```

Add Platform

Create a platform.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let bodyAddPlatformApiPlatformsPost = Body_add_platform_api_platforms_post(fsSlug: "fsSlug_example") // BodyAddPlatformApiPlatformsPost | 

// Add Platform
PlatformsAPI.addPlatformApiPlatformsPost(bodyAddPlatformApiPlatformsPost: bodyAddPlatformApiPlatformsPost) { (response, error) in
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
 **bodyAddPlatformApiPlatformsPost** | [**BodyAddPlatformApiPlatformsPost**](BodyAddPlatformApiPlatformsPost.md) |  | 

### Return type

[**PlatformSchema**](PlatformSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePlatformApiPlatformsIdDelete**
```swift
    open class func deletePlatformApiPlatformsIdDelete(id: Int, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Delete Platform

Delete a platform.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Platform id.

// Delete Platform
PlatformsAPI.deletePlatformApiPlatformsIdDelete(id: id) { (response, error) in
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
 **id** | **Int** | Platform id. | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlatformApiPlatformsIdGet**
```swift
    open class func getPlatformApiPlatformsIdGet(id: Int, completion: @escaping (_ data: PlatformSchema?, _ error: Error?) -> Void)
```

Get Platform

Retrieve a platform by ID.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Platform id.

// Get Platform
PlatformsAPI.getPlatformApiPlatformsIdGet(id: id) { (response, error) in
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
 **id** | **Int** | Platform id. | 

### Return type

[**PlatformSchema**](PlatformSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlatformsApiPlatformsGet**
```swift
    open class func getPlatformsApiPlatformsGet(completion: @escaping (_ data: [PlatformSchema]?, _ error: Error?) -> Void)
```

Get Platforms

Retrieve platforms.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Get Platforms
PlatformsAPI.getPlatformsApiPlatformsGet() { (response, error) in
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

[**[PlatformSchema]**](PlatformSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSupportedPlatformsApiPlatformsSupportedGet**
```swift
    open class func getSupportedPlatformsApiPlatformsSupportedGet(completion: @escaping (_ data: [PlatformSchema]?, _ error: Error?) -> Void)
```

Get Supported Platforms

Retrieve the list of supported platforms.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Get Supported Platforms
PlatformsAPI.getSupportedPlatformsApiPlatformsSupportedGet() { (response, error) in
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

[**[PlatformSchema]**](PlatformSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlatformApiPlatformsIdPut**
```swift
    open class func updatePlatformApiPlatformsIdPut(id: Int, bodyUpdatePlatformApiPlatformsIdPut: BodyUpdatePlatformApiPlatformsIdPut? = nil, completion: @escaping (_ data: PlatformSchema?, _ error: Error?) -> Void)
```

Update Platform

Update a platform.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Platform id.
let bodyUpdatePlatformApiPlatformsIdPut = Body_update_platform_api_platforms__id__put(aspectRatio: "aspectRatio_example", customName: "customName_example") // BodyUpdatePlatformApiPlatformsIdPut |  (optional)

// Update Platform
PlatformsAPI.updatePlatformApiPlatformsIdPut(id: id, bodyUpdatePlatformApiPlatformsIdPut: bodyUpdatePlatformApiPlatformsIdPut) { (response, error) in
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
 **id** | **Int** | Platform id. | 
 **bodyUpdatePlatformApiPlatformsIdPut** | [**BodyUpdatePlatformApiPlatformsIdPut**](BodyUpdatePlatformApiPlatformsIdPut.md) |  | [optional] 

### Return type

[**PlatformSchema**](PlatformSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

