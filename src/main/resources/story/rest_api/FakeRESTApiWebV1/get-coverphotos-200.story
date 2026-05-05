Description: GET /api/v1/CoverPhotos returns all cover photos

Meta:
    @api
    @endpoint GET /api/v1/CoverPhotos
    @responseCode 200

Scenario: Retrieving all CoverPhotos returns valid array
When I execute HTTP GET request for resource with URL `${api-base-url}/api/v1/CoverPhotos`
Then response code is equal_to `200`
Then JSON `${response}` is valid against schema `${coverPhotoArraySchema}`
Then number of JSON elements from `${response}` by JSON path `$` is greater_than 0
