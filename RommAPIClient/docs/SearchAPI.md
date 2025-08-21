# SearchAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**searchCoverApiSearchCoverGet**](SearchAPI.md#searchcoverapisearchcoverget) | **GET** /api/search/cover | Search Cover
[**searchRomApiSearchRomsGet**](SearchAPI.md#searchromapisearchromsget) | **GET** /api/search/roms | Search Rom


# **searchCoverApiSearchCoverGet**
```swift
    open class func searchCoverApiSearchCoverGet(searchTerm: String? = nil, completion: @escaping (_ data: [SearchCoverSchema]?, _ error: Error?) -> Void)
```

Search Cover

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let searchTerm = "searchTerm_example" // String |  (optional) (default to "")

// Search Cover
SearchAPI.searchCoverApiSearchCoverGet(searchTerm: searchTerm) { (response, error) in
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
 **searchTerm** | **String** |  | [optional] [default to &quot;&quot;]

### Return type

[**[SearchCoverSchema]**](SearchCoverSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchRomApiSearchRomsGet**
```swift
    open class func searchRomApiSearchRomsGet(romId: Int, searchTerm: String? = nil, searchBy: String? = nil, completion: @escaping (_ data: [SearchRomSchema]?, _ error: Error?) -> Void)
```

Search Rom

Search for rom in metadata providers  Args:     request (Request): FastAPI request     rom_id (int): Rom ID     source (str): Source of the rom     search_term (str, optional): Search term. Defaults to None.     search_by (str, optional): Search by name or ID. Defaults to \"name\".     search_extended (bool, optional): Search extended info. Defaults to False.  Returns:     list[SearchRomSchema]: List of matched roms

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let romId = 987 // Int | 
let searchTerm = "searchTerm_example" // String |  (optional)
let searchBy = "searchBy_example" // String |  (optional) (default to "name")

// Search Rom
SearchAPI.searchRomApiSearchRomsGet(romId: romId, searchTerm: searchTerm, searchBy: searchBy) { (response, error) in
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
 **searchTerm** | **String** |  | [optional] 
 **searchBy** | **String** |  | [optional] [default to &quot;name&quot;]

### Return type

[**[SearchRomSchema]**](SearchRomSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

