# TasksAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listTasksApiTasksGet**](TasksAPI.md#listtasksapitasksget) | **GET** /api/tasks | List Tasks
[**runAllTasksApiTasksRunPost**](TasksAPI.md#runalltasksapitasksrunpost) | **POST** /api/tasks/run | Run All Tasks
[**runSingleTaskApiTasksRunTaskNamePost**](TasksAPI.md#runsingletaskapitasksruntasknamepost) | **POST** /api/tasks/run/{task_name} | Run Single Task


# **listTasksApiTasksGet**
```swift
    open class func listTasksApiTasksGet(completion: @escaping (_ data: [String: [TaskInfoDict]]?, _ error: Error?) -> Void)
```

List Tasks

List all available tasks grouped by task type.  Args:     request (Request): FastAPI Request object Returns:     Dictionary with tasks grouped by their type (scheduled, manual, watcher)

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// List Tasks
TasksAPI.listTasksApiTasksGet() { (response, error) in
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

[**[String: [TaskInfoDict]]**](Array.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runAllTasksApiTasksRunPost**
```swift
    open class func runAllTasksApiTasksRunPost(completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Run All Tasks

Run all runnable tasks endpoint  Args:     request (Request): FastAPI Request object Returns:     MessageResponse: Standard message response

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI


// Run All Tasks
TasksAPI.runAllTasksApiTasksRunPost() { (response, error) in
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

# **runSingleTaskApiTasksRunTaskNamePost**
```swift
    open class func runSingleTaskApiTasksRunTaskNamePost(taskName: String, completion: @escaping (_ data: MessageResponse?, _ error: Error?) -> Void)
```

Run Single Task

Run a single task endpoint.  Args:     request (Request): FastAPI Request object     task_name (str): Name of the task to run Returns:     MessageResponse: Standard message response

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import RommAPI

let taskName = "taskName_example" // String | 

// Run Single Task
TasksAPI.runSingleTaskApiTasksRunTaskNamePost(taskName: taskName) { (response, error) in
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
 **taskName** | **String** |  | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer), [HTTPBasic](../README.md#HTTPBasic)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

