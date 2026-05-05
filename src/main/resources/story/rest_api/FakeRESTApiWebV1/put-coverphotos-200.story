Description: PUT /api/v1/CoverPhotos/{id} updates an existing cover photo

Meta:
    @api
    @endpoint PUT /api/v1/CoverPhotos/{id}
    @responseCode 200

Scenario: Updating CoverPhoto with valid data returns updated resource
!-- Create CoverPhoto first to ensure it exists for update
When I create CoverPhoto with random data
Given I initialize scenario variable `updatedBookId` with value `#{generate(Number.numberBetween '101','200')}`
Given I initialize scenario variable `updatedUrl` with value `https://placeholdit.imgix.net/~text?txtsize=33&txt=Updated+${coverId}&w=250&h=350`
When I set request headers:
|name        |value           |
|Content-Type|application/json|
Given request body: {"id": ${coverId}, "idBook": ${updatedBookId}, "url": "${updatedUrl}"}
When I execute HTTP PUT request for resource with URL `${api-base-url}/api/v1/CoverPhotos/${coverId}`
Then response code is equal_to `200`
Then JSON `${response}` is valid against schema `${coverPhotoSchema}`
Then JSON element value from `${response}` by JSON path `$.id` is equal_to `${coverId}`
Then JSON element value from `${response}` by JSON path `$.idBook` is equal_to `${updatedBookId}`
Then JSON element value from `${response}` by JSON path `$.url` is equal_to `${updatedUrl}`
