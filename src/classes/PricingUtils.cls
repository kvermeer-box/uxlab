/**
 * Class that provides pricing support.
 *
 * Currently supports graduated pricing, tiered pricing (flat price and unit price)
 *
 * @version 1.0
 * @author Kyle Vermeer <kvermeer@box.com>
 */
public class PricingUtils {

    // Constants
    public static final String PRICING_TYPE_STANDARD = 'Standard';
    public static final String PRICING_TYPE_TIERED_UNIT = 'Tiered Unit Price';
    public static final String PRICING_TYPE_TIERED_FLAT = 'Tiered Flat Price';
    public static final String PRICING_TYPE_TIERED_GRADUATED = 'Graduated';

    // Enum for pricing types
    public enum PricingType {
        STANDARD,
        TIERED_UNIT,
        TIERED_FLAT,
        GRADUATED,
        ERROR
    }

    /**
     * Returns the price of the product based on the quantity provided, in the currency provided.
     *
     * @param {Id} productId - Id of the product
     * @param {Integer} quantity - the quantity being sold
     * @param {String} currencyISOCode - ISO Code representing currency of sale
     * @param {Id} pricebookId - Id of pricebook to use for standard pricing.  May be null, if not using standard pricing
     * @return {Decimal} - price for product x quantity
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static Decimal determinePrice(Id productId, Integer quantity, String currencyISOCode, Id pricebookId) {
        if (productId == null || quantity == null || currencyISOCode == null) { // Check for null
            System.debug('Null provided for required argument.');
            System.debug('ProductId: ' + productId + '; Quantity: ' + quantity + '; CurrencyISOCode: ' + currencyISOCode);
            return null;
        }
        PricingType type = determinePricingType(productId);
        if (type == PricingType.Error) {
            System.debug('Error grabbing Price Type.');
            return null;
        } 
        else if (type == PricingType.STANDARD) {
            return determinePricingStandard(productId,quantity,currencyISOCode,pricebookId);
        }
        else if (type == PricingType.TIERED_UNIT) {
            return determinePricingTiered(productId,quantity,currencyISOCode,true);
        }
        else if (type == PricingType.TIERED_FLAT) {
            return determinePricingTiered(productId,quantity,currencyISOCode,false);
        }
        else if (type == PricingType.GRADUATED) {
            return determinePricingGraduated(productId,quantity,currencyISOCode);
        }
        System.debug('Unknown Pricing Type: ' + type);
        return 0.0;
    }

    /**
     * Returns the pricing type for the productId.
     *
     * @param {Id} productId - Id of product to check pricing type for
     * @return {PricingType} - Pricing Type for product
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static PricingType determinePricingType(Id productId) {
        if (productId == null) { // Check for null
            System.debug('Null productId provided.');
            return PricingType.ERROR;
        }
        try { // Query for Pricing Type
            Product2 currentProduct = [SELECT Id, Pricing_Type__c
                                        FROM Product2
                                       WHERE Id = :productId];
            // Return appropriate Pricing Type
            if (currentProduct.Pricing_Type__c == PRICING_TYPE_STANDARD) {
                return PricingType.STANDARD;
            }
            else if (currentProduct.Pricing_Type__c == PRICING_TYPE_TIERED_UNIT) {
                return PricingType.TIERED_UNIT;
            }
            else if (currentProduct.Pricing_Type__c == PRICING_TYPE_TIERED_FLAT) {
                return PricingType.TIERED_FLAT;
            }
            else if (currentProduct.Pricing_Type__c == PRICING_TYPE_TIERED_GRADUATED) {
                return PricingType.GRADUATED;
            }
            else {
                System.debug('Unknown Pricing Type: ' + currentProduct.Pricing_Type__c);
                return PricingType.ERROR;
            }
        } catch (Exception e) {
            new LoggedException(e, 'Trouble grabbing Pricing Type', 'PricingUtils', new List<Id> { productId });
            System.debug('Trouble grabbing Pricing Type!');
            return PricingType.ERROR;
        }  
    }

    /**
     * Uses standard pricing to determine price.
     *
     * @param {Id} productId - Id of the product
     * @param {Integer} quantity - the quantity being sold
     * @param {String} currencyISOCode - ISO Code representing currency of sale
     * @param {Id} pricebookId - Id of pricebook to use for standard pricing.  May be null, will default to New Pricebook.
     * @return {Decimal} - price for product x quantity
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    private static Decimal determinePricingStandard(Id productId, Integer quantity, String currencyISOCode, Id pricebookId) {
        if (productId == null || quantity == null || currencyISOCode == null || pricebookId == null) { // check for null input
            System.debug('Null input provided for required input.');
            System.debug('ProductId: ' + productId + '; Quantity: ' + quantity + '; CurrencyISOCode: ' + currencyISOCode + '; PricebookId: ' + pricebookId);
            return null;
        }
        try { // Determine price.  Price = unit price x quanity
            // Get unit price for product, gets correct currency
            PricebookEntry entry = [SELECT Id, UnitPrice, CurrencyISOCode
                                      FROM PricebookEntry
                                     WHERE Product2Id = :productId
                                       AND Pricebook2Id = :pricebookId
                                       AND CurrencyISOCode = :currencyISOCode];
            // Return unitprice x quantity
            return entry.UnitPrice * quantity;
        } catch (Exception e) {
            new LoggedException(e, 'Not able to find pricebook entry.', 'PricingUtils', new List<Id> { productId });
            return null;
        }
    }

    /**
     * Uses tiered pricing to determine price.
     *
     * @param {Id} productId - Id of the product
     * @param {Integer} quantity - the quantity being sold
     * @param {String} currencyISOCode - ISO Code representing currency of sale
     * @param {Boolean} isUnitPricing - if the tier shows the unit price, True, otherwise False
     * @return {Decimal} - price for product x quantity
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    @TestVisible
    private static Decimal determinePricingTiered(Id productId, Integer quantity, String currencyISOCode, Boolean isUnitPricing) {
        if (productId == null || quantity == null || currencyISOCode == null || isUnitPricing == null) {
            System.debug('Null input provided for required input.');
            System.debug('ProductId: ' + productId + '; Quantity: ' + quantity + '; CurrencyISOCode: ' + currencyISOCode + '; isUnitPricing: ' + isUnitPricing);
            return null;
        }
        try { // Find tiered price
            // Find bucket
            Pricing_Bucket__c bucket = [SELECT Id, Price__c 
                                          FROM Pricing_Bucket__c
                                         WHERE Product__c = :productId
                                           AND Bucket_Min__c < :quantity
                                           AND Bucket_Max__c >= :quantity];
            Decimal totalPriceUSD = null;
            if (isUnitPricing) {
                totalPriceUSD = bucket.Price__c * quantity;
            }
            else {
                totalPriceUSD = bucket.Price__c;
            }
            return CurrencyUtils.convertAmountFromUSD(totalPriceUSD, currencyISOCode);
        }
        catch (Exception e) {
            new LoggedException(e, 'Trouble finding bucket for productId: ' + productId + ', quantity: ' + quantity, 'PricingUtils');
            System.debug('Trouble finding bucket for productId: ' + productId + ', quantity: ' + quantity);
            return null;
        }
    }

    /**
     * Uses graduated pricing to determine price.
     *
     * @param {Id} productId - Id of the product
     * @param {Integer} quantity - the quantity being sold
     * @param {String} currencyISOCode - ISO Code representing currency of sale
     * @return {Decimal} - price for product x quantity
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    @TestVisible
    private static Decimal determinePricingGraduated(Id productId, Integer quantity, String currencyISOCode) {
        if (productId == null || quantity == null || currencyISOCode == null) { // Check for null inputs
            System.debug('Null input provided for required input.');
            System.debug('ProductId: ' + productId + '; Quantity: ' + quantity + '; CurrencyISOCode: ' + currencyISOCode);
            return null;
        }
        try { // Find graduated price
            // Find buckets
            List<Pricing_Bucket__c> buckets = [SELECT Id, Price__c, Bucket_Min__c, Bucket_Max__C
                                                 FROM Pricing_Bucket__c
                                                WHERE Product__c = :productId
                                                  AND Bucket_Min__c < : quantity
                                             ORDER BY Bucket_Min__c ASC];
            Decimal totalCostUSD = 0;
            if (buckets.size() > 0) { // We found buckets
                for (Pricing_Bucket__c currentBucket : buckets) { // Go through each bucket
                    if (currentBucket.Bucket_Max__c <= quantity) { // Whole bucket is covered
                        Integer bucketSize = (Integer)(currentBucket.Bucket_Max__c - currentBucket.Bucket_Min__c);
                        Decimal unitPrice = currentBucket.Price__c;
                        totalCostUSD += bucketSize * unitPrice;
                    }
                    else { // Only partially in this bucket
                        Integer units = quantity - (Integer)currentBucket.Bucket_Min__c;
                        Decimal unitPrice = currentBucket.Price__c;
                        totalCostUSD += units * unitPrice;
                    }
                }
            }
            System.debug('TotalCostUSD: ' + totalCostUSD);
            Decimal amountInCorrectCurrency = CurrencyUtils.convertAmountFromUSD(totalCostUSD, currencyISOCode);
            System.debug('Amount In correct currency: ' + amountInCorrectCurrency);
            return amountInCorrectCurrency;
        }
        catch (Exception e) {
            new LoggedException(e, 'Trouble finding buckets for product: ' + productId + ', quantity: ' + quantity, 'PricingUtils');
            System.debug('Trouble finding buckets for product: ' + productId + ', quantity: ' + quantity);
            return null;
        }
    }
}