# AuthAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authOpenidApiOauthOpenidGet**](AuthAPI.md#authopenidapioauthopenidget) | **GET** /api/oauth/openid | Auth Openid
[**loginApiLoginPost**](AuthAPI.md#loginapiloginpost) | **POST** /api/login | Login
[**loginViaOpenidApiLoginOpenidGet**](AuthAPI.md#loginviaopenidapiloginopenidget) | **GET** /api/login/openid | Login Via Openid
[**logoutApiLogoutPost**](AuthAPI.md#logoutapilogoutpost) | **POST** /api/logout | Logout
[**requestPasswordResetApiForgotPasswordPost**](AuthAPI.md#requestpasswordresetapiforgotpasswordpost) | **POST** /api/forgot-password | Request Password Reset
[**resetPasswordApiResetPasswordPost**](AuthAPI.md#resetpasswordapiresetpasswordpost) | **POST** /api/reset-password | Reset Password
[**tokenApiTokenPost**](AuthAPI.md#tokenapitokenpost) | **POST** /api/token | Token


# **authOpenidApiOauthOpenidGet**
```swift
    open class func authOpenidApiOauthOpenidGet(completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Auth Openid

OIDC callback endpoint  Args:     request (Request): Fastapi Request object  Raises:     OIDCDisabledException: OAuth is disabled     OIDCNotConfiguredException: OAuth not configured     AuthCredentialsException: Invalid credentials     UserDisabledException: Auth is disabled  Returns:     RedirectResponse: Redirect to home page

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Auth Openid
AuthAPI.authOpenidApiOauthOpenidGet() { (response, error) in
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

**AnyCodable**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginApiLoginPost**
```swift
    open class func loginApiLoginPost(completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Login

Session login endpoint  Args:     request (Request): Fastapi Request object     credentials: Defaults to Depends(HTTPBasic()).  Raises:     CredentialsException: Invalid credentials     UserDisabledException: Auth is disabled  Returns:     MessageResponse: Standard message response

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Login
AuthAPI.loginApiLoginPost() { (response, error) in
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

[HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginViaOpenidApiLoginOpenidGet**
```swift
    open class func loginViaOpenidApiLoginOpenidGet(completion: @escaping (_ data: AnyCodable?, _ error: Error?) -> Void)
```

Login Via Openid

OIDC login endpoint  Args:     request (Request): Fastapi Request object  Raises:     OIDCDisabledException: OAuth is disabled     OIDCNotConfiguredException: OAuth not configured  Returns:     RedirectResponse: Redirect to OIDC provider

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Login Via Openid
AuthAPI.loginViaOpenidApiLoginOpenidGet() { (response, error) in
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

**AnyCodable**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logoutApiLogoutPost**
```swift
    open class func logoutApiLogoutPost(completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Logout

Session logout endpoint  Args:     request (Request): Fastapi Request object  Returns:     MessageResponse: Standard message response

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Logout
AuthAPI.logoutApiLogoutPost() { (response, error) in
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

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestPasswordResetApiForgotPasswordPost**
```swift
    open class func requestPasswordResetApiForgotPasswordPost(bodyRequestPasswordResetApiForgotPasswordPost: BodyRequestPasswordResetApiForgotPasswordPost, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Request Password Reset

\"Request a password reset link for the user.  Args:     username (str): Username of the user requesting the reset Returns:     MessageResponse: Confirmation message

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let bodyRequestPasswordResetApiForgotPasswordPost = Body_request_password_reset_api_forgot_password_post(username: "username_example") // BodyRequestPasswordResetApiForgotPasswordPost | 

// Request Password Reset
AuthAPI.requestPasswordResetApiForgotPasswordPost(bodyRequestPasswordResetApiForgotPasswordPost: bodyRequestPasswordResetApiForgotPasswordPost) { (response, error) in
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
 **bodyRequestPasswordResetApiForgotPasswordPost** | [**BodyRequestPasswordResetApiForgotPasswordPost**](BodyRequestPasswordResetApiForgotPasswordPost.md) |  | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetPasswordApiResetPasswordPost**
```swift
    open class func resetPasswordApiResetPasswordPost(bodyResetPasswordApiResetPasswordPost: BodyResetPasswordApiResetPasswordPost, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Reset Password

Reset password using the token.  Args:     token (str): Reset token from the URL     new_password (str): New user password  Returns:     MessageResponse: Confirmation message

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let bodyResetPasswordApiResetPasswordPost = Body_reset_password_api_reset_password_post(token: "token_example", newPassword: "newPassword_example") // BodyResetPasswordApiResetPasswordPost | 

// Reset Password
AuthAPI.resetPasswordApiResetPasswordPost(bodyResetPasswordApiResetPasswordPost: bodyResetPasswordApiResetPasswordPost) { (response, error) in
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
 **bodyResetPasswordApiResetPasswordPost** | [**BodyResetPasswordApiResetPasswordPost**](BodyResetPasswordApiResetPasswordPost.md) |  | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tokenApiTokenPost**
```swift
    open class func tokenApiTokenPost(grantType: String? = nil, scope: String? = nil, username: String? = nil, password: String? = nil, clientId: String? = nil, clientSecret: String? = nil, refreshToken: String? = nil, completion: @escaping (_ data: TokenResponse?, _ error: Error?) -> Void)
```

Token

OAuth2 token endpoint  Args:     form_data (Annotated[OAuth2RequestForm, Depends): Form Data with OAuth2 info  Raises:     HTTPException: Missing refresh token     HTTPException: Invalid refresh token     HTTPException: Missing username or password     HTTPException: Invalid username or password     HTTPException: Client credentials are not yet supported     HTTPException: Invalid or unsupported grant type     HTTPException: Insufficient scope  Returns:     TokenResponse: TypedDict with the new generated token info

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let grantType = "grantType_example" // String |  (optional) (default to "password")
let scope = "scope_example" // String |  (optional) (default to "")
let username = "username_example" // String |  (optional)
let password = "password_example" // String |  (optional)
let clientId = "clientId_example" // String |  (optional)
let clientSecret = "clientSecret_example" // String |  (optional)
let refreshToken = "refreshToken_example" // String |  (optional)

// Token
AuthAPI.tokenApiTokenPost(grantType: grantType, scope: scope, username: username, password: password, clientId: clientId, clientSecret: clientSecret, refreshToken: refreshToken) { (response, error) in
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
 **grantType** | **String** |  | [optional] [default to &quot;password&quot;]
 **scope** | **String** |  | [optional] [default to &quot;&quot;]
 **username** | **String** |  | [optional] 
 **password** | **String** |  | [optional] 
 **clientId** | **String** |  | [optional] 
 **clientSecret** | **String** |  | [optional] 
 **refreshToken** | **String** |  | [optional] 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/x-www-form-urlencoded
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

