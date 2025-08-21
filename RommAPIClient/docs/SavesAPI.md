# SavesAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addSaveApiSavesPost**](SavesAPI.md#addsaveapisavespost) | **POST** /api/saves | Add Save
[**deleteSavesApiSavesDeletePost**](SavesAPI.md#deletesavesapisavesdeletepost) | **POST** /api/saves/delete | Delete Saves
[**getSaveApiSavesIdGet**](SavesAPI.md#getsaveapisavesidget) | **GET** /api/saves/{id} | Get Save
[**getSavesApiSavesGet**](SavesAPI.md#getsavesapisavesget) | **GET** /api/saves | Get Saves
[**updateSaveApiSavesIdPut**](SavesAPI.md#updatesaveapisavesidput) | **PUT** /api/saves/{id} | Update Save


# **addSaveApiSavesPost**
```swift
    open class func addSaveApiSavesPost(romId: Int, emulator: String? = nil, completion: @escaping (_ data: SaveSchema?, _ error: Error?) -> Void)
```

Add Save

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let romId = 987 // Int | 
let emulator = "emulator_example" // String |  (optional)

// Add Save
SavesAPI.addSaveApiSavesPost(romId: romId, emulator: emulator) { (response, error) in
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

[**SaveSchema**](SaveSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteSavesApiSavesDeletePost**
```swift
    open class func deleteSavesApiSavesDeletePost(completion: @escaping (_ data: [Int]?, _ error: Error?) -> Void)
```

Delete Saves

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Delete Saves
SavesAPI.deleteSavesApiSavesDeletePost() { (response, error) in
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

# **getSaveApiSavesIdGet**
```swift
    open class func getSaveApiSavesIdGet(id: Int, completion: @escaping (_ data: SaveSchema?, _ error: Error?) -> Void)
```

Get Save

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Get Save
SavesAPI.getSaveApiSavesIdGet(id: id) { (response, error) in
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

[**SaveSchema**](SaveSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSavesApiSavesGet**
```swift
    open class func getSavesApiSavesGet(romId: Int? = nil, platformId: Int? = nil, completion: @escaping (_ data: [SaveSchema]?, _ error: Error?) -> Void)
```

Get Saves

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let romId = 987 // Int |  (optional)
let platformId = 987 // Int |  (optional)

// Get Saves
SavesAPI.getSavesApiSavesGet(romId: romId, platformId: platformId) { (response, error) in
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

[**[SaveSchema]**](SaveSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSaveApiSavesIdPut**
```swift
    open class func updateSaveApiSavesIdPut(id: Int, completion: @escaping (_ data: SaveSchema?, _ error: Error?) -> Void)
```

Update Save

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Update Save
SavesAPI.updateSaveApiSavesIdPut(id: id) { (response, error) in
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

[**SaveSchema**](SaveSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

