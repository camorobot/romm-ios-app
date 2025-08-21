# ConfigAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addExclusionApiConfigExcludePost**](ConfigAPI.md#addexclusionapiconfigexcludepost) | **POST** /api/config/exclude | Add Exclusion
[**addPlatformBindingApiConfigSystemPlatformsPost**](ConfigAPI.md#addplatformbindingapiconfigsystemplatformspost) | **POST** /api/config/system/platforms | Add Platform Binding
[**addPlatformVersionApiConfigSystemVersionsPost**](ConfigAPI.md#addplatformversionapiconfigsystemversionspost) | **POST** /api/config/system/versions | Add Platform Version
[**deleteExclusionApiConfigExcludeExclusionTypeExclusionValueDelete**](ConfigAPI.md#deleteexclusionapiconfigexcludeexclusiontypeexclusionvaluedelete) | **DELETE** /api/config/exclude/{exclusion_type}/{exclusion_value} | Delete Exclusion
[**deletePlatformBindingApiConfigSystemPlatformsFsSlugDelete**](ConfigAPI.md#deleteplatformbindingapiconfigsystemplatformsfsslugdelete) | **DELETE** /api/config/system/platforms/{fs_slug} | Delete Platform Binding
[**deletePlatformVersionApiConfigSystemVersionsFsSlugDelete**](ConfigAPI.md#deleteplatformversionapiconfigsystemversionsfsslugdelete) | **DELETE** /api/config/system/versions/{fs_slug} | Delete Platform Version
[**getConfigApiConfigGet**](ConfigAPI.md#getconfigapiconfigget) | **GET** /api/config | Get Config


# **addExclusionApiConfigExcludePost**
```swift
    open class func addExclusionApiConfigExcludePost(completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Add Exclusion

Add platform exclusion to the configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Add Exclusion
ConfigAPI.addExclusionApiConfigExcludePost() { (response, error) in
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

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addPlatformBindingApiConfigSystemPlatformsPost**
```swift
    open class func addPlatformBindingApiConfigSystemPlatformsPost(completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Add Platform Binding

Add platform binding to the configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Add Platform Binding
ConfigAPI.addPlatformBindingApiConfigSystemPlatformsPost() { (response, error) in
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

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addPlatformVersionApiConfigSystemVersionsPost**
```swift
    open class func addPlatformVersionApiConfigSystemVersionsPost(completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Add Platform Version

Add platform version to the configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Add Platform Version
ConfigAPI.addPlatformVersionApiConfigSystemVersionsPost() { (response, error) in
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

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteExclusionApiConfigExcludeExclusionTypeExclusionValueDelete**
```swift
    open class func deleteExclusionApiConfigExcludeExclusionTypeExclusionValueDelete(exclusionType: String, exclusionValue: String, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Delete Exclusion

Delete platform binding from the configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let exclusionType = "exclusionType_example" // String | 
let exclusionValue = "exclusionValue_example" // String | 

// Delete Exclusion
ConfigAPI.deleteExclusionApiConfigExcludeExclusionTypeExclusionValueDelete(exclusionType: exclusionType, exclusionValue: exclusionValue) { (response, error) in
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
 **exclusionType** | **String** |  | 
 **exclusionValue** | **String** |  | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePlatformBindingApiConfigSystemPlatformsFsSlugDelete**
```swift
    open class func deletePlatformBindingApiConfigSystemPlatformsFsSlugDelete(fsSlug: String, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Delete Platform Binding

Delete platform binding from the configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let fsSlug = "fsSlug_example" // String | 

// Delete Platform Binding
ConfigAPI.deletePlatformBindingApiConfigSystemPlatformsFsSlugDelete(fsSlug: fsSlug) { (response, error) in
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
 **fsSlug** | **String** |  | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePlatformVersionApiConfigSystemVersionsFsSlugDelete**
```swift
    open class func deletePlatformVersionApiConfigSystemVersionsFsSlugDelete(fsSlug: String, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Delete Platform Version

Delete platform version from the configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let fsSlug = "fsSlug_example" // String | 

// Delete Platform Version
ConfigAPI.deletePlatformVersionApiConfigSystemVersionsFsSlugDelete(fsSlug: fsSlug) { (response, error) in
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
 **fsSlug** | **String** |  | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getConfigApiConfigGet**
```swift
    open class func getConfigApiConfigGet(completion: @escaping (_ data: ConfigResponse?, _ error: Error?) -> Void)
```

Get Config

Get config endpoint  Returns:     ConfigResponse: RomM's configuration

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Get Config
ConfigAPI.getConfigApiConfigGet() { (response, error) in
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

[**ConfigResponse**](ConfigResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

