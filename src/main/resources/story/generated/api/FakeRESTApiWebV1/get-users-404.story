Description: Verify GET Users by non-existent ID returns 404

Meta:
    @api
    @endpoint GET /api/v1/Users/{id}
    @responseCode 404

Scenario: Verify GET /api/v1/Users/{id} returns 404 for missing resource
Given I initialize scenario variable `missingUserId` with value `#{randomInt(9000000, 9999999)}`
When I execute HTTP GET request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/Users/${missingUserId}`
Then response code is equal to `404`
Then JSON element value from `${response}` by JSON path `$.status` is equal to `404`
Then JSON element value from `${response}` by JSON path `$.title` is equal to `Not Found`
