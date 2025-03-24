public class MapImageUpdater {

    // This method will generate the map image URL based on latitude and longitude
    public static Blob fetchMapImage(Double latitude, Double longitude) {
        String apiKey = 'AIzaSyDoVdZ1FoRBYu48PpxKH8lsGckHWsXWojs';
        String baseUrl = 'https://maps.googleapis.com/maps/api/staticmap?';
        
        // Construct the URL with required parameters
        String url = baseUrl + 'center=' + latitude + ',' + longitude +
                     '&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C' +
                     latitude + ',' + longitude + '&key=' + apiKey;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            // Return the image as a Blob
            return response.getBodyAsBlob();
        } else {
            // Handle error
            System.debug('Failed to fetch image: ' + response.getStatusCode());
            return null;
        }
    }
    
    // This method will upload the image to Salesforce Files and return the public URL
    public static String uploadImageToSalesforce(Blob imageBlob, String fileName) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = fileName;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = imageBlob;
        
        insert contentVersion;
        
        // After inserting, ContentVersion creates a ContentDocument, which we can use to generate the URL
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocLink.LinkedEntityId = null;  // You can link it to a record if you want (e.g., Account or Property_Management__c)
        contentDocLink.ShareType = 'V';  // View permissions
        
        insert contentDocLink;
        
        // Generate the public URL for the image (this assumes public access)
        String fileUrl = '/sfc/servlet.shepherd/version/download/' + contentVersion.ContentDocumentId;
        
        return fileUrl;
    }
    
    // This method will update the Salesforce record with the map image URL
    public static void updateRecordWithMapImage(Id recordId, Double latitude, Double longitude) {
        // Get the map image as a Blob
        Blob mapImageBlob = fetchMapImage(latitude, longitude);
        
        // If the image was fetched successfully, upload it to Salesforce and get the public URL
        if (mapImageBlob != null) {
            String imageFileName = 'Map_Image_' + System.currentTimeMillis() + '.jpg'; // Unique file name
            String imageUrl = uploadImageToSalesforce(mapImageBlob, imageFileName);
            
            // Construct the HTML for the image
            String imageHtml = '<img src="' + imageUrl + '" alt="Map Image" width="500" height="300"/>';
            
            // Assuming you want to store the image URL in a custom field on the record
            Property_Management__c recordToUpdate = [SELECT Id, Image__c FROM Property_Management__c WHERE Id = :recordId LIMIT 1];
            
            // Update the record with the new map image URL (as HTML code)
            recordToUpdate.Image__c = imageHtml;
            update recordToUpdate;
            
            System.debug('Map image URL inserted into record successfully!');
        } else {
            System.debug('Failed to fetch map image.');
        }
    }
}