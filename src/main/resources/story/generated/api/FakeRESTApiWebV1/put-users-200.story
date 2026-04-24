Description: Verify PUT Users returns 200 and updated payload in response

Meta:
    @api
    @endpoint PUT /api/v1/Users/{id}
    @responseCode 200

Scenario: Verify PUT /api/v1/Users/{id} updates user payload response
!-- Create user payload first to keep update flow self-contained
When I generate and prepare Users body request
When I execute HTTP POST request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users`
Then response code is equal to `200`
Given I initialize scenario variable `updatedUserName` with value `#{generate(bothify 'updated_####??')}`
Given I initialize scenario variable `updatedPassword` with value `#{generate(bothify 'newpass_####??')}`
When I prepare Users body request with id `${userId}` userName `${updatedUserName}` and password `${updatedPassword}`
When I execute HTTP PUT request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users/${userId}`
Then response code is equal to `200`
Then JSON `${response}` is valid against schema `{"type":"object","required":["id","userName","password"],"properties":{"id":{"type":"integer"},"userName":{"type":"string"},"password":{"type":"string"}},"additionalProperties":false}`
Then JSON element value from `${response}` by JSON path `$.id` is equal to `${userId}`
Then JSON element value from `${response}` by JSON path `$.userName` is equal to `${updatedUserName}`
Then JSON element value from `${response}` by JSON path `$.password` is equal to `${updatedPassword}`
