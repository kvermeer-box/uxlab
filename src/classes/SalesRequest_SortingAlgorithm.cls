/**
 * Sorting for Sales Requests
 *
 * @author Kyle Vermeer 6/11/14
 */
public class SalesRequest_SortingAlgorithm {
    
    public static List<Sales_Request_Entry__c> sort(List<Sales_Request_Entry__c> salesRequestEntries) {

        List<Sales_Request_Entry__c> sortedEntries = new List<Sales_Request_Entry__c>();
        try {
            // First: get counts per request, and place into a map from name to count
            AggregateResult[] countByRequest = [SELECT Count(id) number, Request_Type__c
                                                  FROM Sales_Request_Shadow__c
                                                 WHERE CreatedById = :UserInfo.getUserId()
                                              GROUP BY Request_Type__c];
            System.debug('Agg Results: ' + countByRequest);
            // Create a map representing count by request
            Map<String, Integer> requestNameToCount = new Map<String, Integer>();
            for (AggregateResult ar : countByRequest) {
                requestNameToCount.put((String)ar.get('Request_Type__c'), (Integer)ar.get('number'));
            }
           
            // Second: Get Map from tile name to list of requests for that tile
            Map<String, List<String>> tileNameToRequests = getTileNameToRequestMap();
            System.debug('tileNameToRequest: ' + tileNameToRequests);
            // Three: Count number of requests per tile, place them in a wrapper for sorting
            SalesRequestCountWrapper[] wrapperList = new SalesRequestCountWrapper[]{};
            for (Sales_Request_Entry__c currentEntry : salesRequestEntries) {
                Integer totalCount = 0;
                System.debug('Current Entry: ' + currentEntry);
                List<String> requestsForTileName = tileNameToRequests.get(currentEntry.Name);
                if (requestsForTileName != null) {
                    for (String currentRequest : requestsForTileName) {
                        Integer count = requestNameToCount.get(currentRequest);
                        if (count == null) {
                            count = 0;
                        }
                        totalCount += count;
                    }
                }
                wrapperList.add(new SalesRequestCountWrapper(currentEntry,totalCount));
            }

            // Four: Sort them
            wrapperList.sort();

            // Finally: They are sorted in ascending order, reverse the list!
            Integer wrapperListSize = wrapperList.size();
            if (wrapperListSize == 0) {
                return salesRequestEntries;
            }
            for (Integer i = wrapperListSize-1; i >= 0; i--) {
                SalesRequestCountWrapper currentWrapper = wrapperList.get(i);
                System.debug('Name: ' + currentWrapper.entry.Name + '; Count: ' + currentWrapper.count);
                sortedEntries.add(currentWrapper.entry);
            }
            System.debug('sortedEntries: ' + sortedEntries);
        }
        catch (Exception e) {
            new LoggedException(e,'Trouble sorting entries','SalesRequest_SortingAlgorithm');
            return salesRequestEntries;
        }
        return sortedEntries;
    }

    private static Map<String, List<String>> getTileNameToRequestMap() {
        List<Sales_Request_2_Sorting_Mappings__c> mappingEntries = [SELECT Tile_Name__c, Request__c
                                                                         FROM Sales_Request_2_Sorting_Mappings__c];
        Map<String, List<String>> tileNameToRequest = new Map<String, List<String>>();
        for (Sales_Request_2_Sorting_Mappings__c currentMapping : mappingEntries) {
            List<String> requestsForTileName = tileNameToRequest.get(currentMapping.Tile_Name__c);
            if (requestsForTileName == null) {
                requestsForTileName = new List<String>();
                tileNameToRequest.put(currentMapping.Tile_Name__c, requestsForTileName);
            }
            requestsForTileName.add(currentMapping.Request__c);
        }
        return tileNameToRequest;
    }

    public class SalesRequestCountWrapper implements Comparable {

        public Sales_Request_Entry__c entry;
        public Integer count;

        public SalesRequestCountWrapper(Sales_Request_Entry__c entry, Integer count) {
            this.entry = entry;
            this.count = count;
        }

        public Integer compareTo(Object compareTo) {
            SalesRequestCountWrapper other = (SalesRequestCountWrapper)compareTo;

            Integer returnValue = 0;
            if (this.count > other.count) { // Bigger, return positive
                returnValue = 1;
            }
            else if (this.count < other.count) { // Smaller, return negative
                returnValue = -1;
            }
            else { // Equal, check Names
                if (this.entry.Name < other.entry.Name) { // Name comes before other
                    returnValue = 1;
                }
                else if (this.entry.Name > other.entry.Name) { // Name comes after other
                    returnValue = -1;
                }
            }
            return returnValue;
        }
    }
}