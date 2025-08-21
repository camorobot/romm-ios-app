# StatesAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addStateApiStatesPost**](StatesAPI.md#addstateapistatespost) | **POST** /api/states | Add State
[**deleteStatesApiStatesDeletePost**](StatesAPI.md#deletestatesapistatesdeletepost) | **POST** /api/states/delete | Delete States
[**getStateApiStatesIdGet**](StatesAPI.md#getstateapistatesidget) | **GET** /api/states/{id} | Get State
[**getStatesApiStatesGet**](StatesAPI.md#getstatesapistatesget) | **GET** /api/states | Get States
[**updateStateApiStatesIdPut**](StatesAPI.md#updatestateapistatesidput) | **PUT** /api/states/{id} | Update State


# **addStateApiStatesPost**
```swift
    open class func addStateApiStatesPost(romId: Int, emulator: String? = nil, completion: @escaping (_ data: StateSchema?, _ error: Error?) -> Void)
```

Add State

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let romId = 987 // Int | 
let emulator = "emulator_example" // String |  (optional)

// Add State
StatesAPI.addStateApiStatesPost(romId: romId, emulator: emulator) { (response, error) in
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
 **emulator** | **String** |  | [optional] 

### Return type

[**StateSchema**](StateSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteStatesApiStatesDeletePost**
```swift
    open class func deleteStatesApiStatesDeletePost(completion: @escaping (_ data: [Int]?, _ error: Error?) -> Void)
```

Delete States

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Delete States
StatesAPI.deleteStatesApiStatesDeletePost() { (response, error) in
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

**[Int]**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStateApiStatesIdGet**
```swift
    open class func getStateApiStatesIdGet(id: Int, completion: @escaping (_ data: StateSchema?, _ error: Error?) -> Void)
```

Get State

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Get State
StatesAPI.getStateApiStatesIdGet(id: id) { (response, error) in
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
 **id** | **Int** |  | 

### Return type

[**StateSchema**](StateSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStatesApiStatesGet**
```swift
    open class func getStatesApiStatesGet(romId: Int? = nil, platformId: Int? = nil, completion: @escaping (_ data: [StateSchema]?, _ error: Error?) -> Void)
```

Get States

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let romId = 987 // Int |  (optional)
let platformId = 987 // Int |  (optional)

// Get States
StatesAPI.getStatesApiStatesGet(romId: romId, platformId: platformId) { (response, error) in
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
 **romId** | **Int** |  | [optional] 
 **platformId** | **Int** |  | [optional] 

### Return type

[**[StateSchema]**](StateSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateStateApiStatesIdPut**
```swift
    open class func updateStateApiStatesIdPut(id: Int, completion: @escaping (_ data: StateSchema?, _ error: Error?) -> Void)
```

Update State

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Update State
StatesAPI.updateStateApiStatesIdPut(id: id) { (response, error) in
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
 **id** | **Int** |  | 

### Return type

[**StateSchema**](StateSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

