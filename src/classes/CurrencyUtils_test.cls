@isTest
private class CurrencyUtils_test {

    @isTest static void convertAmountToUSD_basic() {
        Decimal amount = 100;
        String currencyIsoCode = 'JPY';
        Test.startTest();
        Decimal amountUSD = CurrencyUtils.convertAmountToUSD(amount, currencyIsoCode);
        Test.stopTest();
        CurrencyType yen = [SELECT IsoCode, ConversionRate
                              FROM CurrencyType
                             WHERE ISOCode = :currencyIsoCode
                               AND IsActive = true];
        Decimal yenConversionRate = yen.ConversionRate;
        System.assertEquals(amountUSD, amount / yenConversionRate);
    }

    @isTest static void convertAmountFromUSD_basic() {
        Decimal amount = 100;
        String currencyIsoCode = 'JPY';
        Test.startTest();
        Decimal amountUSD = CurrencyUtils.convertAmountFromUSD(amount, currencyIsoCode);
        Test.stopTest();
        CurrencyType yen = [SELECT IsoCode, ConversionRate
                              FROM CurrencyType
                             WHERE ISOCode = :currencyIsoCode
                               AND IsActive = true];
        Decimal yenConversionRate = yen.ConversionRate;
        System.assertEquals(amountUSD, amount * yenConversionRate);
    }

    @isTest static void convertFromAtoB_basic() {
        Decimal amount = 100;
        String startingCurrency = 'JPY';
        String endingCurrency = 'EUR';
        Test.startTest();
        Decimal amountEUR = CurrencyUtils.convertAmountFromAtoB(amount, startingCurrency, endingCurrency);
        Test.stopTest();
        CurrencyType yen = [SELECT IsoCode, ConversionRate
                              FROM CurrencyType
                             WHERE ISOCode = :startingCurrency
                               AND IsActive = true];
        CurrencyType euro = [SELECT IsoCode, ConversionRate
                               FROM CurrencyType
                              WHERE ISOCode = :endingCurrency
                                AND IsActive = true];
        Decimal euroPerYenRate = euro.ConversionRate / yen.ConversionRate;
        Decimal amountEURCheck = amount* euroPerYenRate;
        System.assertEquals(amountEUR.setScale(5), amountEURCheck.setScale(5));
    }
    

}