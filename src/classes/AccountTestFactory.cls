@isTest
public with sharing class AccountTestFactory
{
	public static Account buildAccount()
	{
		Account new_account = new Account( Name = 'Test Account' );
		new_account.BillingCountry = 'United States';
		return new_account;
	}
	
	public static Account createAccount()
	{
		Account account = buildAccount();
		insert account;
		return account;
	}
}