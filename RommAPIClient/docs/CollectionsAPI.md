# CollectionsAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addCollectionApiCollectionsPost**](CollectionsAPI.md#addcollectionapicollectionspost) | **POST** /api/collections | Add Collection
[**deleteCollectionsApiCollectionsIdDelete**](CollectionsAPI.md#deletecollectionsapicollectionsiddelete) | **DELETE** /api/collections/{id} | Delete Collections
[**getCollectionApiCollectionsIdGet**](CollectionsAPI.md#getcollectionapicollectionsidget) | **GET** /api/collections/{id} | Get Collection
[**getCollectionsApiCollectionsGet**](CollectionsAPI.md#getcollectionsapicollectionsget) | **GET** /api/collections | Get Collections
[**getVirtualCollectionApiCollectionsVirtualIdGet**](CollectionsAPI.md#getvirtualcollectionapicollectionsvirtualidget) | **GET** /api/collections/virtual/{id} | Get Virtual Collection
[**getVirtualCollectionsApiCollectionsVirtualGet**](CollectionsAPI.md#getvirtualcollectionsapicollectionsvirtualget) | **GET** /api/collections/virtual | Get Virtual Collections
[**updateCollectionApiCollectionsIdPut**](CollectionsAPI.md#updatecollectionapicollectionsidput) | **PUT** /api/collections/{id} | Update Collection


# **addCollectionApiCollectionsPost**
```swift
    open class func addCollectionApiCollectionsPost(artwork: URL? = nil, completion: @escaping (_ data: CollectionSchema?, _ error: Error?) -> Void)
```

Add Collection

Create collection endpoint  Args:     request (Request): Fastapi Request object  Returns:     CollectionSchema: Just created collection

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let artwork = URL(string: "https://example.com")! // URL |  (optional)

// Add Collection
CollectionsAPI.addCollectionApiCollectionsPost(artwork: artwork) { (response, error) in
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
 **artwork** | **URL** |  | [optional] 

### Return type

[**CollectionSchema**](CollectionSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteCollectionsApiCollectionsIdDelete**
```swift
    open class func deleteCollectionsApiCollectionsIdDelete(id: Int, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Delete Collections

Delete collections endpoint  Args:     request (Request): Fastapi Request object     {         \"collections\": List of rom's ids to delete     }  Raises:     HTTPException: Collection not found  Returns:     MessageResponse: Standard message response

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Delete Collections
CollectionsAPI.deleteCollectionsApiCollectionsIdDelete(id: id) { (response, error) in
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

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCollectionApiCollectionsIdGet**
```swift
    open class func getCollectionApiCollectionsIdGet(id: Int, completion: @escaping (_ data: CollectionSchema?, _ error: Error?) -> Void)
```

Get Collection

Get collections endpoint  Args:     request (Request): Fastapi Request object     id (int, optional): Collection id. Defaults to None.  Returns:     CollectionSchema: Collection

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Get Collection
CollectionsAPI.getCollectionApiCollectionsIdGet(id: id) { (response, error) in
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

[**CollectionSchema**](CollectionSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCollectionsApiCollectionsGet**
```swift
    open class func getCollectionsApiCollectionsGet(completion: @escaping (_ data: [CollectionSchema]?, _ error: Error?) -> Void)
```

Get Collections

Get collections endpoint  Args:     request (Request): Fastapi Request object     id (int, optional): Collection id. Defaults to None.  Returns:     list[CollectionSchema]: List of collections

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Get Collections
CollectionsAPI.getCollectionsApiCollectionsGet() { (response, error) in
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

[**[CollectionSchema]**](CollectionSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVirtualCollectionApiCollectionsVirtualIdGet**
```swift
    open class func getVirtualCollectionApiCollectionsVirtualIdGet(id: String, completion: @escaping (_ data: VirtualCollectionSchema?, _ error: Error?) -> Void)
```

Get Virtual Collection

Get virtual collections endpoint  Args:     request (Request): Fastapi Request object     id (str): Virtual collection id  Returns:     VirtualCollectionSchema: Virtual collection

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = "id_example" // String | 

// Get Virtual Collection
CollectionsAPI.getVirtualCollectionApiCollectionsVirtualIdGet(id: id) { (response, error) in
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
 **id** | **String** |  | 

### Return type

[**VirtualCollectionSchema**](VirtualCollectionSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVirtualCollectionsApiCollectionsVirtualGet**
```swift
    open class func getVirtualCollectionsApiCollectionsVirtualGet(type: String, limit: Int? = nil, completion: @escaping (_ data: [VirtualCollectionSchema]?, _ error: Error?) -> Void)
```

Get Virtual Collections

Get virtual collections endpoint  Args:     request (Request): Fastapi Request object  Returns:     list[VirtualCollectionSchema]: List of virtual collections

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let type = "type_example" // String | 
let limit = 987 // Int |  (optional)

// Get Virtual Collections
CollectionsAPI.getVirtualCollectionsApiCollectionsVirtualGet(type: type, limit: limit) { (response, error) in
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
 **type** | **String** |  | 
 **limit** | **Int** |  | [optional] 

### Return type

[**[VirtualCollectionSchema]**](VirtualCollectionSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateCollectionApiCollectionsIdPut**
```swift
    open class func updateCollectionApiCollectionsIdPut(id: Int, removeCover: Bool? = nil, isPublic: Bool? = nil, artwork: URL? = nil, completion: @escaping (_ data: CollectionSchema?, _ error: Error?) -> Void)
```

Update Collection

Update collection endpoint  Args:     request (Request): Fastapi Request object  Returns:     MessageResponse: Standard message response

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 
let removeCover = true // Bool |  (optional) (default to false)
let isPublic = true // Bool |  (optional)
let artwork = URL(string: "https://example.com")! // URL |  (optional)

// Update Collection
CollectionsAPI.updateCollectionApiCollectionsIdPut(id: id, removeCover: removeCover, isPublic: isPublic, artwork: artwork) { (response, error) in
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
 **removeCover** | **Bool** |  | [optional] [default to false]
 **isPublic** | **Bool** |  | [optional] 
 **artwork** | **URL** |  | [optional] 

### Return type

[**CollectionSchema**](CollectionSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

