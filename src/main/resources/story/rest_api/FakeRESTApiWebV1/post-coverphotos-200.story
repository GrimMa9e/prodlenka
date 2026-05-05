Description: POST /api/v1/CoverPhotos creates a new cover photo

Meta:
    @api
    @endpoint POST /api/v1/CoverPhotos
    @responseCode 200

Scenario: Creating CoverPhoto with valid data returns created resource
When I create CoverPhoto with random data
Then JSON `${response}` is valid against schema `${coverPhotoSchema}`
Then JSON element value from `${response}` by JSON path `$.id` is equal_to `${coverId}`
Then JSON element value from `${response}` by JSON path `$.idBook` is equal_to `${coverBookId}`
Then JSON element value from `${response}` by JSON path `$.url` is equal_to `${coverUrl}`
