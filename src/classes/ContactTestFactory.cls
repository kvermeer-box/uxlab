@isTest
public with sharing class ContactTestFactory
{
    static final String LASTNAME = 'Contact';

    public static Contact buildContact( Account account )
    {
        Contact contact = buildContact();
        contact.AccountId = account.id;
        contact.Account = account;
        return contact;
    }

    public static Contact createContact( Account account )
    {
        Contact contact = buildContact( account );
        insert contact;
        return contact;
    }

    public static Contact buildContact()
    {
        Contact contact = new Contact( LastName = LASTNAME );
        return contact;
    }

    public static Contact createContact()
    {
        Contact contact = buildContact();
        insert contact;
        return contact;
    }
}