# RomsAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addRomApiRomsPost**](RomsAPI.md#addromapiromspost) | **POST** /api/roms | Add Rom
[**addRomManualsApiRomsIdManualsPost**](RomsAPI.md#addrommanualsapiromsidmanualspost) | **POST** /api/roms/{id}/manuals | Add Rom Manuals
[**deleteRomsApiRomsDeletePost**](RomsAPI.md#deleteromsapiromsdeletepost) | **POST** /api/roms/delete | Delete Roms
[**getRomApiRomsIdGet**](RomsAPI.md#getromapiromsidget) | **GET** /api/roms/{id} | Get Rom
[**getRomContentApiRomsIdContentFileNameGet**](RomsAPI.md#getromcontentapiromsidcontentfilenameget) | **GET** /api/roms/{id}/content/{file_name} | Get Rom Content
[**getRomfileApiRomsfilesIdGet**](RomsAPI.md#getromfileapiromsfilesidget) | **GET** /api/romsfiles/{id} | Get Romfile
[**getRomfileContentApiRomsfilesIdContentFileNameGet**](RomsAPI.md#getromfilecontentapiromsfilesidcontentfilenameget) | **GET** /api/romsfiles/{id}/content/{file_name} | Get Romfile Content
[**getRomsApiRomsGet**](RomsAPI.md#getromsapiromsget) | **GET** /api/roms | Get Roms
[**headRomContentApiRomsIdContentFileNameHead**](RomsAPI.md#headromcontentapiromsidcontentfilenamehead) | **HEAD** /api/roms/{id}/content/{file_name} | Head Rom Content
[**updateRomApiRomsIdPut**](RomsAPI.md#updateromapiromsidput) | **PUT** /api/roms/{id} | Update Rom
[**updateRomUserApiRomsIdPropsPut**](RomsAPI.md#updateromuserapiromsidpropsput) | **PUT** /api/roms/{id}/props | Update Rom User


# **addRomApiRomsPost**
```swift
    open class func addRomApiRomsPost(xUploadPlatform: Int, xUploadFilename: String, completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Add Rom

Upload a single rom.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let xUploadPlatform = 987 // Int | Platform internal id.
let xUploadFilename = "xUploadFilename_example" // String | The name of the file being uploaded.

// Add Rom
RomsAPI.addRomApiRomsPost(xUploadPlatform: xUploadPlatform, xUploadFilename: xUploadFilename) { (response, error) in
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
 **xUploadPlatform** | **Int** | Platform internal id. | 
 **xUploadFilename** | **String** | The name of the file being uploaded. | 

### Return type

**AnyCodable**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addRomManualsApiRomsIdManualsPost**
```swift
    open class func addRomManualsApiRomsIdManualsPost(id: Int, xUploadFilename: String, completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Add Rom Manuals

Upload manuals for a rom.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Rom internal id.
let xUploadFilename = "xUploadFilename_example" // String | The name of the file being uploaded.

// Add Rom Manuals
RomsAPI.addRomManualsApiRomsIdManualsPost(id: id, xUploadFilename: xUploadFilename) { (response, error) in
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
 **id** | **Int** | Rom internal id. | 
 **xUploadFilename** | **String** | The name of the file being uploaded. | 

### Return type

**AnyCodable**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRomsApiRomsDeletePost**
```swift
    open class func deleteRomsApiRomsDeletePost(bodyDeleteRomsApiRomsDeletePost: BodyDeleteRomsApiRomsDeletePost, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Delete Roms

Delete roms.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let bodyDeleteRomsApiRomsDeletePost = Body_delete_roms_api_roms_delete_post(roms: [123], deleteFromFs: [123]) // BodyDeleteRomsApiRomsDeletePost | 

// Delete Roms
RomsAPI.deleteRomsApiRomsDeletePost(bodyDeleteRomsApiRomsDeletePost: bodyDeleteRomsApiRomsDeletePost) { (response, error) in
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
 **bodyDeleteRomsApiRomsDeletePost** | [**BodyDeleteRomsApiRomsDeletePost**](BodyDeleteRomsApiRomsDeletePost.md) |  | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRomApiRomsIdGet**
```swift
    open class func getRomApiRomsIdGet(id: Int, completion: @escaping (_ data: DetailedRomSchema?, _ error: Error?) -> Void)
```

Get Rom

Retrieve a rom by ID.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Rom internal id.

// Get Rom
RomsAPI.getRomApiRomsIdGet(id: id) { (response, error) in
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
 **id** | **Int** | Rom internal id. | 

### Return type

[**DetailedRomSchema**](DetailedRomSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRomContentApiRomsIdContentFileNameGet**
```swift
    open class func getRomContentApiRomsIdContentFileNameGet(id: Int, fileName: String, fileIds: String? = nil, completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Get Rom Content

Download a rom.  This endpoint serves the content of the requested rom, as: - A single file for single file roms. - A zipped file for multi-part roms, including a .m3u file if applicable.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Rom internal id.
let fileName = "fileName_example" // String | Zip file output name
let fileIds = "fileIds_example" // String | Comma-separated list of file ids to download for multi-part roms. (optional)

// Get Rom Content
RomsAPI.getRomContentApiRomsIdContentFileNameGet(id: id, fileName: fileName, fileIds: fileIds) { (response, error) in
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
 **id** | **Int** | Rom internal id. | 
 **fileName** | **String** | Zip file output name | 
 **fileIds** | **String** | Comma-separated list of file ids to download for multi-part roms. | [optional] 

### Return type

**AnyCodable**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRomfileApiRomsfilesIdGet**
```swift
    open class func getRomfileApiRomsfilesIdGet(id: Int, completion: @escaping (_ data: RomFileSchema?, _ error: Error?) -> Void)
```

Get Romfile

Retrieve a rom file by ID.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Rom file internal id.

// Get Romfile
RomsAPI.getRomfileApiRomsfilesIdGet(id: id) { (response, error) in
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
 **id** | **Int** | Rom file internal id. | 

### Return type

[**RomFileSchema**](RomFileSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRomfileContentApiRomsfilesIdContentFileNameGet**
```swift
    open class func getRomfileContentApiRomsfilesIdContentFileNameGet(id: Int, fileName: String, completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Get Romfile Content

Download a rom file.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Rom file internal id.
let fileName = "fileName_example" // String | File name to download

// Get Romfile Content
RomsAPI.getRomfileContentApiRomsfilesIdContentFileNameGet(id: id, fileName: fileName) { (response, error) in
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
 **id** | **Int** | Rom file internal id. | 
 **fileName** | **String** | File name to download | 

### Return type

**AnyCodable**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRomsApiRomsGet**
```swift
    open class func getRomsApiRomsGet(searchTerm: String? = nil, platformId: Int? = nil, collectionId: Int? = nil, virtualCollectionId: String? = nil, matched: Bool? = nil, favourite: Bool? = nil, duplicate: Bool? = nil, playable: Bool? = nil, missing: Bool? = nil, hasRa: Bool? = nil, verified: Bool? = nil, groupByMetaId: Bool? = nil, selectedGenre: String? = nil, selectedFranchise: String? = nil, selectedCollection: String? = nil, selectedCompany: String? = nil, selectedAgeRating: String? = nil, selectedStatus: String? = nil, selectedRegion: String? = nil, selectedLanguage: String? = nil, orderBy: String? = nil, orderDir: String? = nil, limit: Int? = nil, offset: Int? = nil, completion: @escaping (_ data: CustomLimitOffsetPageSimpleRomSchema?, _ error: Error?) -> Void)
```

Get Roms

Retrieve roms.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let searchTerm = "searchTerm_example" // String | Search term to filter roms. (optional)
let platformId = 987 // Int | Platform internal id. (optional)
let collectionId = 987 // Int | Collection internal id. (optional)
let virtualCollectionId = "virtualCollectionId_example" // String | Virtual collection internal id. (optional)
let matched = true // Bool | Whether the rom matched a metadata source. (optional)
let favourite = true // Bool | Whether the rom is marked as favourite. (optional)
let duplicate = true // Bool | Whether the rom is marked as duplicate. (optional)
let playable = true // Bool | Whether the rom is playable from the browser. (optional)
let missing = true // Bool | Whether the rom is missing from the filesystem. (optional)
let hasRa = true // Bool | Whether the rom has RetroAchievements data. (optional)
let verified = true // Bool | Whether the rom is verified by Hasheous from the filesystem. (optional)
let groupByMetaId = true // Bool | Whether to group roms by metadata ID (IGDB / Moby / ScreenScraper / RetroAchievements / LaunchBox). (optional) (default to false)
let selectedGenre = "selectedGenre_example" // String | Associated genre. (optional)
let selectedFranchise = "selectedFranchise_example" // String | Associated franchise. (optional)
let selectedCollection = "selectedCollection_example" // String | Associated collection. (optional)
let selectedCompany = "selectedCompany_example" // String | Associated company. (optional)
let selectedAgeRating = "selectedAgeRating_example" // String | Associated age rating. (optional)
let selectedStatus = "selectedStatus_example" // String | Game status, set by the current user. (optional)
let selectedRegion = "selectedRegion_example" // String | Associated region tag. (optional)
let selectedLanguage = "selectedLanguage_example" // String | Associated language tag. (optional)
let orderBy = "orderBy_example" // String | Field to order results by. (optional) (default to "name")
let orderDir = "orderDir_example" // String | Order direction, either 'asc' or 'desc'. (optional) (default to "asc")
let limit = 987 // Int | Page size limit (optional) (default to 50)
let offset = 987 // Int | Page offset (optional) (default to 0)

// Get Roms
RomsAPI.getRomsApiRomsGet(searchTerm: searchTerm, platformId: platformId, collectionId: collectionId, virtualCollectionId: virtualCollectionId, matched: matched, favourite: favourite, duplicate: duplicate, playable: playable, missing: missing, hasRa: hasRa, verified: verified, groupByMetaId: groupByMetaId, selectedGenre: selectedGenre, selectedFranchise: selectedFranchise, selectedCollection: selectedCollection, selectedCompany: selectedCompany, selectedAgeRating: selectedAgeRating, selectedStatus: selectedStatus, selectedRegion: selectedRegion, selectedLanguage: selectedLanguage, orderBy: orderBy, orderDir: orderDir, limit: limit, offset: offset) { (response, error) in
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
 **searchTerm** | **String** | Search term to filter roms. | [optional] 
 **platformId** | **Int** | Platform internal id. | [optional] 
 **collectionId** | **Int** | Collection internal id. | [optional] 
 **virtualCollectionId** | **String** | Virtual collection internal id. | [optional] 
 **matched** | **Bool** | Whether the rom matched a metadata source. | [optional] 
 **favourite** | **Bool** | Whether the rom is marked as favourite. | [optional] 
 **duplicate** | **Bool** | Whether the rom is marked as duplicate. | [optional] 
 **playable** | **Bool** | Whether the rom is playable from the browser. | [optional] 
 **missing** | **Bool** | Whether the rom is missing from the filesystem. | [optional] 
 **hasRa** | **Bool** | Whether the rom has RetroAchievements data. | [optional] 
 **verified** | **Bool** | Whether the rom is verified by Hasheous from the filesystem. | [optional] 
 **groupByMetaId** | **Bool** | Whether to group roms by metadata ID (IGDB / Moby / ScreenScraper / RetroAchievements / LaunchBox). | [optional] [default to false]
 **selectedGenre** | **String** | Associated genre. | [optional] 
 **selectedFranchise** | **String** | Associated franchise. | [optional] 
 **selectedCollection** | **String** | Associated collection. | [optional] 
 **selectedCompany** | **String** | Associated company. | [optional] 
 **selectedAgeRating** | **String** | Associated age rating. | [optional] 
 **selectedStatus** | **String** | Game status, set by the current user. | [optional] 
 **selectedRegion** | **String** | Associated region tag. | [optional] 
 **selectedLanguage** | **String** | Associated language tag. | [optional] 
 **orderBy** | **String** | Field to order results by. | [optional] [default to &quot;name&quot;]
 **orderDir** | **String** | Order direction, either &#39;asc&#39; or &#39;desc&#39;. | [optional] [default to &quot;asc&quot;]
 **limit** | **Int** | Page size limit | [optional] [default to 50]
 **offset** | **Int** | Page offset | [optional] [default to 0]

### Return type

[**CustomLimitOffsetPageSimpleRomSchema**](CustomLimitOffsetPageSimpleRomSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **headRomContentApiRomsIdContentFileNameHead**
```swift
    open class func headRomContentApiRomsIdContentFileNameHead(id: Int, fileName: String, fileIds: String? = nil, completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Head Rom Content

Retrieve head information for a rom file download.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Rom internal id.
let fileName = "fileName_example" // String | File name to download
let fileIds = "fileIds_example" // String | Comma-separated list of file ids to download for multi-part roms. (optional)

// Head Rom Content
RomsAPI.headRomContentApiRomsIdContentFileNameHead(id: id, fileName: fileName, fileIds: fileIds) { (response, error) in
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
 **id** | **Int** | Rom internal id. | 
 **fileName** | **String** | File name to download | 
 **fileIds** | **String** | Comma-separated list of file ids to download for multi-part roms. | [optional] 

### Return type

**AnyCodable**

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateRomApiRomsIdPut**
```swift
    open class func updateRomApiRomsIdPut(id: Int, removeCover: Bool? = nil, unmatchMetadata: Bool? = nil, artwork: URL? = nil, completion: @escaping (_ data: DetailedRomSchema?, _ error: Error?) -> Void)
```

Update Rom

Update a rom.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Rom internal id.
let removeCover = true // Bool | Whether to remove the cover image for this rom. (optional) (default to false)
let unmatchMetadata = true // Bool | Whether to remove the metadata matches for this game. (optional) (default to false)
let artwork = URL(string: "https://example.com")! // URL |  (optional)

// Update Rom
RomsAPI.updateRomApiRomsIdPut(id: id, removeCover: removeCover, unmatchMetadata: unmatchMetadata, artwork: artwork) { (response, error) in
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
 **id** | **Int** | Rom internal id. | 
 **removeCover** | **Bool** | Whether to remove the cover image for this rom. | [optional] [default to false]
 **unmatchMetadata** | **Bool** | Whether to remove the metadata matches for this game. | [optional] [default to false]
 **artwork** | **URL** |  | [optional] 

### Return type

[**DetailedRomSchema**](DetailedRomSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateRomUserApiRomsIdPropsPut**
```swift
    open class func updateRomUserApiRomsIdPropsPut(id: Int, bodyUpdateRomUserApiRomsIdPropsPut: BodyUpdateRomUserApiRomsIdPropsPut? = nil, completion: @escaping (_ data: RomUserSchema?, _ error: Error?) -> Void)
```

Update Rom User

Update rom data associated to the current user.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | Rom internal id.
let bodyUpdateRomUserApiRomsIdPropsPut = Body_update_rom_user_api_roms__id__props_put(updateLastPlayed: false, removeLastPlayed: false) // BodyUpdateRomUserApiRomsIdPropsPut |  (optional)

// Update Rom User
RomsAPI.updateRomUserApiRomsIdPropsPut(id: id, bodyUpdateRomUserApiRomsIdPropsPut: bodyUpdateRomUserApiRomsIdPropsPut) { (response, error) in
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
 **id** | **Int** | Rom internal id. | 
 **bodyUpdateRomUserApiRomsIdPropsPut** | [**BodyUpdateRomUserApiRomsIdPropsPut**](BodyUpdateRomUserApiRomsIdPropsPut.md) |  | [optional] 

### Return type

[**RomUserSchema**](RomUserSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

