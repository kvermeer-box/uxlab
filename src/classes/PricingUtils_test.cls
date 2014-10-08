@isTest
private class PricingUtils_test {
    
    @isTest static void determinePricingType_basic() {
        Product2 newProduct = new Product2(Name='Test Product', Pricing_Type__c = PricingUtils.PRICING_TYPE_STANDARD, isActive = true);
        insert newProduct;
        System.assertEquals(PricingUtils.PricingType.STANDARD, PricingUtils.determinePricingType(newProduct.Id));
        newProduct.Pricing_Type__c = PricingUtils.PRICING_TYPE_TIERED_FLAT;
        update newProduct;
        System.assertEquals(PricingUtils.PricingType.TIERED_FLAT, PricingUtils.determinePricingType(newProduct.Id));
        newProduct.Pricing_Type__c = PricingUtils.PRICING_TYPE_TIERED_UNIT;
        update newProduct;
        System.assertEquals(PricingUtils.PricingType.TIERED_UNIT, PricingUtils.determinePricingType(newProduct.Id));
        newProduct.Pricing_Type__c = PricingUtils.PRICING_TYPE_TIERED_GRADUATED;
        update newProduct;
        System.assertEquals(PricingUtils.PricingType.GRADUATED, PricingUtils.determinePricingType(newProduct.Id));
    }

    @isTest static void determinePricingTiered_basic() {
        Product2 newProduct = new Product2(Name='Test Product', Pricing_Type__c = PricingUtils.PRICING_TYPE_STANDARD, isActive = true);
        insert newProduct;
        ///////////////////////////////////
        // Pricing Bucket Table
        // Min Units  Max Units  Price
        // 0          100        $100/unit
        // 100        500        $80/unit
        // 500        10,000     $50/unit
        ///////////////////////////////////
        Pricing_Bucket__c bottomTier = new Pricing_Bucket__c(Product__c = newProduct.Id, Bucket_Min__c = 0, Bucket_Max__c = 100, Price__c = 100);
        Pricing_Bucket__c middleTier = new Pricing_Bucket__c(Product__c = newProduct.Id, Bucket_Min__c = 100, Bucket_Max__c = 500, Price__c = 80);
        Pricing_Bucket__c topTier = new Pricing_Bucket__c(Product__c = newProduct.Id, Bucket_Min__c = 500, Bucket_Max__c = 10000, Price__c = 50);
        insert new List<Pricing_Bucket__c> { bottomTier, middleTier, topTier };
        // Basic unit pricing testing
        Test.startTest();
        Decimal price = PricingUtils.determinePricingTiered(newProduct.Id, 750, 'USD', true);
        System.assertEquals(37500, price);
        Decimal price2 = PricingUtils.determinePricingTiered(newProduct.Id, 50, 'USD', true);
        System.assertEquals(5000, price2);
        Decimal price3 = PricingUtils.determinePricingTiered(newProduct.Id, 101, 'USD', true);
        System.assertEquals(8080, price3);
        // Test different currency
        Decimal price4 = PricingUtils.determinePricingTiered(newProduct.Id, 100, 'JPY', true);
        CurrencyType yen = [SELECT IsoCode, ConversionRate
                              FROM CurrencyType
                             WHERE isActive = true
                               AND IsoCode = 'JPY'];
        System.assertEquals(10000 * yen.ConversionRate, price4);
        // Test flat tiered
        Decimal price5 = PricingUtils.determinePricingTiered(newProduct.Id, 500, 'USD', false);
        System.assertEquals(80, price5);
    }

    @isTest static void determinePricingGraduated_basic() {
        Product2 newProduct = new Product2(Name='Test Product', Pricing_Type__c = PricingUtils.PRICING_TYPE_STANDARD, isActive = true);
        insert newProduct;
        ///////////////////////////////////
        // Pricing Bucket Table
        // Min Units  Max Units  Price
        // 0          100        $100/unit
        // 100        500        $80/unit
        // 500        10,000     $50/unit
        ///////////////////////////////////
        Pricing_Bucket__c bottomTier = new Pricing_Bucket__c(Product__c = newProduct.Id, Bucket_Min__c = 0, Bucket_Max__c = 100, Price__c = 100);
        Pricing_Bucket__c middleTier = new Pricing_Bucket__c(Product__c = newProduct.Id, Bucket_Min__c = 100, Bucket_Max__c = 500, Price__c = 80);
        Pricing_Bucket__c topTier = new Pricing_Bucket__c(Product__c = newProduct.Id, Bucket_Min__c = 500, Bucket_Max__c = 10000, Price__c = 50);
        insert new List<Pricing_Bucket__c> { bottomTier, middleTier, topTier };
        Test.startTest();
        // Basic Graduated Pricing
        Decimal price = PricingUtils.determinePricingGraduated(newProduct.Id, 750, 'USD');
        System.assertEquals(54500, price);
        Decimal price2 = PricingUtils.determinePricingGraduated(newProduct.Id, 50, 'USD');
        System.assertEquals(5000, price2);
        Decimal price3 = PricingUtils.determinePricingGraduated(newProduct.Id, 101, 'USD');
        System.assertEquals(10080, price3);
        // Test different currency
        Decimal price4 = PricingUtils.determinePricingGraduated(newProduct.Id, 100, 'JPY');
        CurrencyType yen = [SELECT IsoCode, ConversionRate
                              FROM CurrencyType
                             WHERE isActive = true
                               AND IsoCode = 'JPY'];
        System.assertEquals(10000 * yen.ConversionRate, price4);
    }

    @isTest static void testCoverageBooster() {
        Product2 newProduct = new Product2(Name='Test Product', Pricing_Type__c = PricingUtils.PRICING_TYPE_STANDARD, isActive = true);
        insert newProduct;
        PricingUtils.determinePrice(newProduct.Id, 100, 'USD', null);
        Product2 newProduct2 = new Product2(Name='Test Product', Pricing_Type__c = PricingUtils.PRICING_TYPE_TIERED_UNIT, isActive = true);
        insert newProduct2;
        PricingUtils.determinePrice(newProduct2.Id, 100, 'USD', null);
        Product2 newProduct3 = new Product2(Name='Test Product', Pricing_Type__c = PricingUtils.PRICING_TYPE_TIERED_FLAT, isActive = true);
        insert newProduct3;
        PricingUtils.determinePrice(newProduct3.Id, 100, 'USD', null);
        Product2 newProduct4 = new Product2(Name='Test Product', Pricing_Type__c = PricingUtils.PRICING_TYPE_TIERED_GRADUATED, isActive = true);
        insert newProduct4;
        PricingUtils.determinePrice(newProduct4.Id, 100, 'USD', null);
        PricingUtils.determinePrice(newProduct4.Id, null, 'USD', null);
    }
    
}