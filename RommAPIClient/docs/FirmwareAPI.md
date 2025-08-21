# FirmwareAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addFirmwareApiFirmwarePost**](FirmwareAPI.md#addfirmwareapifirmwarepost) | **POST** /api/firmware | Add Firmware
[**deleteFirmwareApiFirmwareDeletePost**](FirmwareAPI.md#deletefirmwareapifirmwaredeletepost) | **POST** /api/firmware/delete | Delete Firmware
[**getFirmwareApiFirmwareIdGet**](FirmwareAPI.md#getfirmwareapifirmwareidget) | **GET** /api/firmware/{id} | Get Firmware
[**getFirmwareContentApiFirmwareIdContentFileNameGet**](FirmwareAPI.md#getfirmwarecontentapifirmwareidcontentfilenameget) | **GET** /api/firmware/{id}/content/{file_name} | Get Firmware Content
[**getPlatformFirmwareApiFirmwareGet**](FirmwareAPI.md#getplatformfirmwareapifirmwareget) | **GET** /api/firmware | Get Platform Firmware
[**headFirmwareContentApiFirmwareIdContentFileNameHead**](FirmwareAPI.md#headfirmwarecontentapifirmwareidcontentfilenamehead) | **HEAD** /api/firmware/{id}/content/{file_name} | Head Firmware Content


# **addFirmwareApiFirmwarePost**
```swift
    open class func addFirmwareApiFirmwarePost(platformId: Int, files: [URL], completion: @escaping (_ data: AddFirmwareResponse?, _ error: Error?) -> Void)
```

Add Firmware

Upload firmware files endpoint  Args:     request (Request): Fastapi Request object     platform_slug (str): Slug of the platform where to upload the files     files (list[UploadFile], optional): List of files to upload  Raises:     HTTPException  Returns:     AddFirmwareResponse: Standard message response

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let platformId = 987 // Int | 
let files = [URL(string: "https://example.com")!] // [URL] | 

// Add Firmware
FirmwareAPI.addFirmwareApiFirmwarePost(platformId: platformId, files: files) { (response, error) in
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
 **platformId** | **Int** |  | 
 **files** | [**[URL]**](URL.md) |  | 

### Return type

[**AddFirmwareResponse**](AddFirmwareResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteFirmwareApiFirmwareDeletePost**
```swift
    open class func deleteFirmwareApiFirmwareDeletePost(completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Delete Firmware

Delete firmware endpoint  Args:     request (Request): Fastapi Request object.         {             \"firmware\": List of firmware IDs to delete         }     delete_from_fs (bool, optional): Flag to delete rom from filesystem. Defaults to False.  Returns:     MessageResponse: Standard message response

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Delete Firmware
FirmwareAPI.deleteFirmwareApiFirmwareDeletePost() { (response, error) in
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

# **getFirmwareApiFirmwareIdGet**
```swift
    open class func getFirmwareApiFirmwareIdGet(id: Int, completion: @escaping (_ data: FirmwareSchema?, _ error: Error?) -> Void)
```

Get Firmware

Get firmware endpoint  Args:     request (Request): Fastapi Request object     id (int): Firmware internal id  Returns:     FirmwareSchema: Firmware stored in the database

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Get Firmware
FirmwareAPI.getFirmwareApiFirmwareIdGet(id: id) { (response, error) in
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

[**FirmwareSchema**](FirmwareSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFirmwareContentApiFirmwareIdContentFileNameGet**
```swift
    open class func getFirmwareContentApiFirmwareIdContentFileNameGet(id: Int, fileName: String, completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Get Firmware Content

Download firmware endpoint  Args:     request (Request): Fastapi Request object     id (int): Rom internal id     file_name (str): Required due to a bug in emulatorjs  Returns:     FileResponse: Returns the firmware file

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 
let fileName = "fileName_example" // String | 

// Get Firmware Content
FirmwareAPI.getFirmwareContentApiFirmwareIdContentFileNameGet(id: id, fileName: fileName) { (response, error) in
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
 **fileName** | **String** |  | 

### Return type

**AnyCodable**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlatformFirmwareApiFirmwareGet**
```swift
    open class func getPlatformFirmwareApiFirmwareGet(platformId: Int? = nil, completion: @escaping (_ data: [FirmwareSchema]?, _ error: Error?) -> Void)
```

Get Platform Firmware

Get firmware endpoint  Args:     request (Request): Fastapi Request object  Returns:     list[FirmwareSchema]: Firmware stored in the database

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let platformId = 987 // Int |  (optional)

// Get Platform Firmware
FirmwareAPI.getPlatformFirmwareApiFirmwareGet(platformId: platformId) { (response, error) in
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
 **platformId** | **Int** |  | [optional] 

### Return type

[**[FirmwareSchema]**](FirmwareSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **headFirmwareContentApiFirmwareIdContentFileNameHead**
```swift
    open class func headFirmwareContentApiFirmwareIdContentFileNameHead(id: Int, fileName: String, completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Head Firmware Content

Head firmware content endpoint  Args:     request (Request): Fastapi Request object     id (int): Rom internal id     file_name (str): Required due to a bug in emulatorjs  Returns:     FileResponse: Returns the response with headers

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 
let fileName = "fileName_example" // String | 

// Head Firmware Content
FirmwareAPI.headFirmwareContentApiFirmwareIdContentFileNameHead(id: id, fileName: fileName) { (response, error) in
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
 **fileName** | **String** |  | 

### Return type

**AnyCodable**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

