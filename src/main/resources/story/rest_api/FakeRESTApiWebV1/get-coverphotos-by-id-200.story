Description: GET /api/v1/CoverPhotos/{id} returns a single cover photo by ID

Meta:
    @api
    @endpoint GET /api/v1/CoverPhotos/{id}
    @responseCode 200

!-- GET existing CoverPhoto by fixed ID=1 (workaround for FakeRESTApi)
When I execute HTTP GET request for resource with URL `https://fakerestapi.azurewebsites.net/api/v1/CoverPhotos/1`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.id` is equal to `1`
Then JSON element value from `${response}` by JSON path `$.idBook` is equal_to `1`
Then JSON element value from `${response}` by JSON path `$.url` is equal_to `https://placeholdit.imgix.net/~text?txtsize=33&txt=Book 1&w=250&h=350`
