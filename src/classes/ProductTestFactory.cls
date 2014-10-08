@isTest
public with sharing class ProductTestFactory
{
    static Integer productCounter = 0;
    public static Product2 buildProduct()
    {
        return buildProducts( 1 )[0];
    }

    public static Product2 createProduct()
    {
        Product2 testProduct = buildProduct();
        insert testProduct;
        return testProduct;
    }

    public static List<Product2> buildProducts( Integer numOfProducts )
    {
        List<Product2> testProducts = new List<Product2>();
        for( Integer i = 0; i < numOfProducts; i++ )
        {
            testProducts.add (new Product2( Name = 'Test Product' + productCounter,
                                             isActive = true,
                                             CurrencyIsoCode = 'USD' ) );
            productCounter++;
        }
        return testProducts;
    }

    public static List<Product2> createProducts( Integer numOfProducts )
    {
        List<Product2> testProducts = buildProducts( numOfProducts );
        insert testProducts;
        return testProducts;
    }

    public static PricebookEntry buildPricebookEntry( Product2 product )
    {
        return buildPricebookEntry(product, TestUtils.STANDARD_PRICEBOOK.Id);
    }

    public static PricebookEntry buildPricebookEntry( Product2 product, Id pricebookId )
    {
        PricebookEntry testPricebookEntry = new PricebookEntry( Product2Id = product.Id,
                                                                Pricebook2Id = pricebookId,
                                                                UnitPrice = 10.0,
                                                                isActive = true,
                                                                CurrencyIsoCode = 'USD' );
        return testPricebookEntry;
    }

    public static PricebookEntry createPricebookEntry( Product2 product )
    {
        return createPricebookEntry( product, TestUtils.STANDARD_PRICEBOOK.Id );
    }


    public static PricebookEntry createPricebookEntry( Product2 product, Id pricebookId )
    {
        PricebookEntry testPricebookEntry = buildPricebookEntry( product, pricebookId );
        insert testPricebookEntry;
        return testPricebookEntry;
    }

    public static List<PricebookEntry> buildPricebookEntries( List<Product2> products )
    {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for( Product2 product : products )
        {
            pricebookEntries.add( buildPricebookEntry( product ) );
        }
        return pricebookEntries;
    }

    public static List<PricebookEntry> createPricebookEntries( List<Product2> products )
    {
        List<PricebookEntry> pricebookEntries = buildPricebookEntries( products );
        insert pricebookEntries;
        return pricebookEntries;
    }

    public static Pricebook2 buildPricebook( String name )
    {
        return new Pricebook2( Name = name );
    }

    public static Pricebook2 buildPricebook() {
        return new Pricebook2(Name='a new pricebook', IsActive=true);
    }

    public static Pricebook2 createPricebook() {
        Pricebook2 pricebook =  buildPricebook();
        insert pricebook;
        return pricebook;
    }

    public static List<PricebookEntry> buildPricebookEntries(Pricebook2 pricebook, List<Product2> products) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        for(Product2 product : products) {
            pricebookEntries.add(buildPricebookEntry(product, pricebook.Id));
        }

        return pricebookEntries;
    }

    public static List<PricebookEntry> createPricebookEntries(Pricebook2 pricebook, List<Product2> products) {
        List<PricebookEntry> pricebookEntries = buildPricebookEntries(pricebook, products);
        insert pricebookEntries;
        return pricebookEntries;
    }
}