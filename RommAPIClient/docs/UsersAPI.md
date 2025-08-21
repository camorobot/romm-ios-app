# UsersAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addUserApiUsersPost**](UsersAPI.md#adduserapiuserspost) | **POST** /api/users | Add User
[**createInviteLinkApiUsersInviteLinkPost**](UsersAPI.md#createinvitelinkapiusersinvitelinkpost) | **POST** /api/users/invite-link | Create Invite Link
[**createUserFromInviteApiUsersRegisterPost**](UsersAPI.md#createuserfrominviteapiusersregisterpost) | **POST** /api/users/register | Create User From Invite
[**deleteUserApiUsersIdDelete**](UsersAPI.md#deleteuserapiusersiddelete) | **DELETE** /api/users/{id} | Delete User
[**getCurrentUserApiUsersMeGet**](UsersAPI.md#getcurrentuserapiusersmeget) | **GET** /api/users/me | Get Current User
[**getUserApiUsersIdGet**](UsersAPI.md#getuserapiusersidget) | **GET** /api/users/{id} | Get User
[**getUsersApiUsersGet**](UsersAPI.md#getusersapiusersget) | **GET** /api/users | Get Users
[**refreshRetroAchievementsApiUsersIdRaRefreshPost**](UsersAPI.md#refreshretroachievementsapiusersidrarefreshpost) | **POST** /api/users/{id}/ra/refresh | Refresh Retro Achievements
[**updateUserApiUsersIdPut**](UsersAPI.md#updateuserapiusersidput) | **PUT** /api/users/{id} | Update User


# **addUserApiUsersPost**
```swift
    open class func addUserApiUsersPost(bodyAddUserApiUsersPost: BodyAddUserApiUsersPost, completion: @escaping (_ data: UserSchema?, _ error: Error?) -> Void)
```

Add User

Create user endpoint  Args:     request (Request): Fastapi Requests object     username (str): User username     password (str): User password     email (str): User email     role (str): RomM Role object represented as string  Returns:     UserSchema: Newly created user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let bodyAddUserApiUsersPost = Body_add_user_api_users_post(username: "username_example", email: "email_example", password: "password_example", role: "role_example") // BodyAddUserApiUsersPost | 

// Add User
UsersAPI.addUserApiUsersPost(bodyAddUserApiUsersPost: bodyAddUserApiUsersPost) { (response, error) in
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
 **bodyAddUserApiUsersPost** | [**BodyAddUserApiUsersPost**](BodyAddUserApiUsersPost.md) |  | 

### Return type

[**UserSchema**](UserSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInviteLinkApiUsersInviteLinkPost**
```swift
    open class func createInviteLinkApiUsersInviteLinkPost(role: String, completion: @escaping (_ data: InviteLinkSchema?, _ error: Error?) -> Void)
```

Create Invite Link

Create an invite link for a user.  Args:     request (Request): FastAPI Request object     role (str): The role of the user  Returns:     InviteLinkSchema: Invite link

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let role = "role_example" // String | 

// Create Invite Link
UsersAPI.createInviteLinkApiUsersInviteLinkPost(role: role) { (response, error) in
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
 **role** | **String** |  | 

### Return type

[**InviteLinkSchema**](InviteLinkSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createUserFromInviteApiUsersRegisterPost**
```swift
    open class func createUserFromInviteApiUsersRegisterPost(bodyCreateUserFromInviteApiUsersRegisterPost: BodyCreateUserFromInviteApiUsersRegisterPost, completion: @escaping (_ data: UserSchema?, _ error: Error?) -> Void)
```

Create User From Invite

Create user endpoint with invite link  Args:     username (str): User username     email (str): User email     password (str): User password     token (str): Invite link token  Returns:     UserSchema: Newly created user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let bodyCreateUserFromInviteApiUsersRegisterPost = Body_create_user_from_invite_api_users_register_post(username: "username_example", email: "email_example", password: "password_example", token: "token_example") // BodyCreateUserFromInviteApiUsersRegisterPost | 

// Create User From Invite
UsersAPI.createUserFromInviteApiUsersRegisterPost(bodyCreateUserFromInviteApiUsersRegisterPost: bodyCreateUserFromInviteApiUsersRegisterPost) { (response, error) in
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
 **bodyCreateUserFromInviteApiUsersRegisterPost** | [**BodyCreateUserFromInviteApiUsersRegisterPost**](BodyCreateUserFromInviteApiUsersRegisterPost.md) |  | 

### Return type

[**UserSchema**](UserSchema.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteUserApiUsersIdDelete**
```swift
    open class func deleteUserApiUsersIdDelete(id: Int, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Delete User

Delete user endpoint  Args:     request (Request): Fastapi Request object     user_id (int): User internal id  Raises:     HTTPException: User is not found in database     HTTPException: User deleting itself     HTTPException: User is the last admin user  Returns:     MessageResponse: Standard message response

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Delete User
UsersAPI.deleteUserApiUsersIdDelete(id: id) { (response, error) in
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

# **getCurrentUserApiUsersMeGet**
```swift
    open class func getCurrentUserApiUsersMeGet(completion: @escaping (_ data: UserSchema?, _ error: Error?) -> Void)
```

Get Current User

Get current user endpoint  Args:     request (Request): Fastapi Request object  Returns:     UserSchema | None: Current user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Get Current User
UsersAPI.getCurrentUserApiUsersMeGet() { (response, error) in
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

[**UserSchema**](UserSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserApiUsersIdGet**
```swift
    open class func getUserApiUsersIdGet(id: Int, completion: @escaping (_ data: UserSchema?, _ error: Error?) -> Void)
```

Get User

Get user endpoint  Args:     request (Request): Fastapi Request object  Returns:     UserSchem: User stored in the RomM's database

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Get User
UsersAPI.getUserApiUsersIdGet(id: id) { (response, error) in
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

[**UserSchema**](UserSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUsersApiUsersGet**
```swift
    open class func getUsersApiUsersGet(completion: @escaping (_ data: [UserSchema]?, _ error: Error?) -> Void)
```

Get Users

Get all users endpoint  Args:     request (Request): Fastapi Request object  Returns:     list[UserSchema]: All users stored in the RomM's database

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Get Users
UsersAPI.getUsersApiUsersGet() { (response, error) in
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

[**[UserSchema]**](UserSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshRetroAchievementsApiUsersIdRaRefreshPost**
```swift
    open class func refreshRetroAchievementsApiUsersIdRaRefreshPost(id: Int, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Refresh Retro Achievements

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 

// Refresh Retro Achievements
UsersAPI.refreshRetroAchievementsApiUsersIdRaRefreshPost(id: id) { (response, error) in
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

# **updateUserApiUsersIdPut**
```swift
    open class func updateUserApiUsersIdPut(id: Int, username: String? = nil, password: String? = nil, email: String? = nil, role: String? = nil, enabled: Bool? = nil, raUsername: String? = nil, avatar: URL? = nil, completion: @escaping (_ data: UserSchema?, _ error: Error?) -> Void)
```

Update User

Update user endpoint  Args:     request (Request): Fastapi Requests object     user_id (int): User internal id     form_data (Annotated[UserUpdateForm, Depends): Form Data with user updated info  Raises:     HTTPException: User is not found in database     HTTPException: Username already in use by another user  Returns:     UserSchema: Updated user info

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let id = 987 // Int | 
let username = "username_example" // String |  (optional)
let password = "password_example" // String |  (optional)
let email = "email_example" // String |  (optional)
let role = "role_example" // String |  (optional)
let enabled = true // Bool |  (optional)
let raUsername = "raUsername_example" // String |  (optional)
let avatar = URL(string: "https://example.com")! // URL |  (optional)

// Update User
UsersAPI.updateUserApiUsersIdPut(id: id, username: username, password: password, email: email, role: role, enabled: enabled, raUsername: raUsername, avatar: avatar) { (response, error) in
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
 **username** | **String** |  | [optional] 
 **password** | **String** |  | [optional] 
 **email** | **String** |  | [optional] 
 **role** | **String** |  | [optional] 
 **enabled** | **Bool** |  | [optional] 
 **raUsername** | **String** |  | [optional] 
 **avatar** | **URL** |  | [optional] 

### Return type

[**UserSchema**](UserSchema.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: application/x-www-form-urlencoded
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

