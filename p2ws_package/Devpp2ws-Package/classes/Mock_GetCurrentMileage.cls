@isTest
global class Mock_GetCurrentMileage implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String responeStr = '<?xml version="1.0" encoding="UTF-8" ?><CurrentMileageRS>  <Success>Y</Success>  <PrivilegeCard>MEMBER</PrivilegeCard>  <CurrentMileage>25,114</CurrentMileage>  <MemberID>ZA10291</MemberID>  <LastActivityDate>2013-07-17</LastActivityDate>  <MilesExpiry>    <Quarter>3</Quarter>    <MilesExpiryDate>2015-09-30</MilesExpiryDate>    <Year>2015</Year>    <Amount>1,772</Amount>  </MilesExpiry>  <MilesExpiry>    <Quarter>4</Quarter>    <MilesExpiryDate>2015-12-31</MilesExpiryDate>    <Year>2015</Year>    <Amount>0</Amount>  </MilesExpiry>  <MilesExpiry>    <Quarter>1</Quarter>    <MilesExpiryDate>2016-03-31</MilesExpiryDate>    <Year>2016</Year>    <Amount>0</Amount>  </MilesExpiry>  <MilesExpiry>    <Quarter>2</Quarter>    <MilesExpiryDate>2016-06-30</MilesExpiryDate>    <Year>2016</Year>    <Amount>0</Amount>  </MilesExpiry>  <FullName>Mr. ANAPAT  SUVARNASUDDHI</FullName>  <ExtendablePoints>    <Quarter>3</Quarter>    <MilesExpiryDate>2015-09-30</MilesExpiryDate>    <Year>2015</Year>    <Amount>1,772</Amount>  </ExtendablePoints></CurrentMileageRS>';
        //res.setHeader('Content-Type', 'application/json');
        res.setBody(responeStr);
        res.setStatusCode(200);
        return res;
    }
}