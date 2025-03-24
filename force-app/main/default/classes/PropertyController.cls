public with sharing class PropertyController {
    @AuraEnabled(cacheable=true)
    public static List<Property_Management__c> getProperties(Integer limitSize, Integer offsetValue, Decimal maxPrice, String status, String furnishing, Decimal latitude, Decimal longitude, Decimal radius) {
        String query = 'SELECT Id, Name, Address__c, Rent__c, Status__c, Furnishing_Status__c, Latitude__c, Longitude__c, Property_Image__c FROM Property__c WHERE Rent__c <= :maxPrice';

        if (status != null) {
            query += ' AND Status__c = :status';
        }
        if (furnishing != null) {
            query += ' AND Furnishing_Status__c = :furnishing';
        }

        if (latitude != null && longitude != null && radius != null) {
            query += ' AND DISTANCE(Location__c, GEOLOCATION(:latitude, :longitude), "km") <= :radius';
        }

        query += ' LIMIT :limitSize OFFSET :offsetValue';

        return Database.query(query);
    }
}