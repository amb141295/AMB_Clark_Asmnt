global class CaseConfigControllerMock implements HttpCalloutMock {
    global Boolean validResp;
    global CaseConfigControllerMock(Boolean validResp){
        this.validResp = validResp;
    }
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://clarkdemo.requestcatcher.com/test', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(validResp){
            res.setStatusCode(200);
        }else{
            res.setStatusCode(404);
        }        
        return res;
    }
}