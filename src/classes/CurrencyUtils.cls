/**
 * Utility methods for handling currency.
 *
 * @author Kyle Vermeer <kvermeer@box.com>
 *
 * @revision 1.0 Kyle Vermeer 3/4/2014 Initial Creation
 * @revision 1.1 Kyle Vermeer 3/20/2014 Added convertAmountFromUSD and convertAmountFromAtoB
 */
public class CurrencyUtils {

    private static final String USD = 'USD';

    /**
     * Given an amount, converts the amount to USD
     *
     * @param {Decimal} amount - Amount of currency
     * @param {String} currencyISOCode - ISO code of the currency to translate FROM.  FROM currencyISOCode TO USD
     * @return {Decimal} amount in USD
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static Decimal convertAmountToUSD(Decimal amount, String currencyISOCode) {
        if (amount == null || currencyISOCode == null) { // Check for null inputs
            System.debug('Amount or currencyISOCode is null. Amount: ' + amount + '; CurrencyISOCode: ' + currencyISOCode);
            return null;
        }
        if (currencyISOCode == USD) { // If it is USD, just feed it back, no need to query
            return amount;
        }
        Decimal convertedAmount = null;
        // ConversionRate in CurrencyType is number of X in one USD, where X is the currency represented by ISOCode
        List<CurrencyType> currencyList = [SELECT ISOCode, ConversionRate 
                                             FROM CurrencyType 
                                            WHERE IsActive = true];
        for (CurrencyType currentCurrency : currencyList) {
            if (currentCurrency.ISOCode == currencyISOCode) {
                convertedAmount = amount / currentCurrency.ConversionRate;
            }
        }
        // If currency can't be found, return original amount
        if (convertedAmount != null) {
            return convertedAmount;
        }
        else {
            return amount;
        }
    }

    /**
     * Given an amount in USD, converts to currency code provided as argument
     *
     * @param {Decimal} amount - Amount in USD
     * @param {String} targetCurrencyISOCode - ISO code of the currency to translate to. TO targetCurrencyISOCode FROM USD
     * @return {Decimal} - amount in provided currency code
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static Decimal convertAmountFromUSD(Decimal amount, String targetCurrencyISOCode) {
        if (amount == null || targetCurrencyISOCode == null) { // Check for null inputs
            System.debug('Required input is null. Amount: ' + amount + '; targetCurrencyISOCode: ' + targetCurrencyISOCode);
            return null;
        }
        System.debug('Amount: ' + amount + ', currencyCode: ' + targetCurrencyISOCode);
        if (targetCurrencyISOCode == USD) { // If it is USD, just feed it back, no need to query
            return amount;
        }
        try {
            CurrencyType currencyObject = [SELECT ISOCode, ConversionRate
                                             FROM CurrencyType
                                            WHERE IsActive = true
                                              AND ISOCode = :targetCurrencyISOCode];
            Decimal convertedAmount = amount * currencyObject.ConversionRate;
            return convertedAmount;
        } 
        catch (Exception e) {
            new LoggedException(e, 'Trouble find currency conversion rate.', 'CurrencyUtils');
            System.debug('Trouble find currency conversion rate for ISOCode: ' + targetCurrencyISOCode);
            return null;
        }
    }

    /**
     * Converts amount from currencyISOCodeA to currencyISOCodeB.
     *
     * @param {Decimal} amount - amount in currencyISOCodeA
     * @param {String} currencyISOCodeA - currency ISO code to convert FROM
     * @param {String} currencyISOCodeB - currency ISO code to convert TO
     * @return {Decimal} - amount in currencyISOCodeB
     * @author Kyle Vermeer <kvermeer@box.com>
     */
    public static Decimal convertAmountFromAtoB(Decimal amount, String currencyISOCodeA, String currencyISOCodeB) {
        Decimal amountInUSD = convertAmountToUSD(amount,currencyISOCodeA);
        return convertAmountFromUSD(amountInUSD, currencyISOCodeB);
    }
}