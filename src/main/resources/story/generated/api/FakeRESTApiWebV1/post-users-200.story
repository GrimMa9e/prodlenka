Description: Verify POST Users returns 200 and response body matches request payload

Meta:
    @api
    @endpoint POST /api/v1/Users
    @responseCode 200

Scenario: Verify POST /api/v1/Users creates user payload response
When I generate and prepare Users body request
When I execute HTTP POST request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users`
Then response code is equal to `200`
Then JSON `${response}` is valid against schema `{"type":"object","required":["id","userName","password"],"properties":{"id":{"type":"integer"},"userName":{"type":"string"},"password":{"type":"string"}},"additionalProperties":false}`
Then JSON element value from `${response}` by JSON path `$.id` is equal to `${userId}`
Then JSON element value from `${response}` by JSON path `$.userName` is equal to `${userName}`
Then JSON element value from `${response}` by JSON path `$.password` is equal to `${password}`
