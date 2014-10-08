global with sharing class Box_TenantFactory {
		
	private static final String DATE_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss';
	private static final Long BYTES_PER_GIG = 1073741824;
	 
	public static Tenant__c createTenantFromSalesTransaction(Box_SalesTransaction salesTransaction) {
		System.debug('Box_TenantFactory: Creating tenant from box sales transaction...');
		 
		Tenant__c tenant;  
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot create tenant when sales transaction is null.');
		}
				
		if (salesTransaction == null || salesTransaction.enterprise == null || salesTransaction.enterprise.administered_by == null) {
			throw new CustomException('Error: Cannot create tenant without an enterprise admin.');
		}
		
		// First get a contact
		Contact contact = Box_UserFactory.findOrCreateContactFromSalesTransaction(salesTransaction, true);
		
		// Update account
		Box_AccountFactory.translateSalesTransactionToAccount(salesTransaction, contact.Account);
			
		// Now create a tenant and set relationships
		tenant = new Tenant__c();
		tenant.Account__c = contact.AccountId; 
		tenant.Admin__c = contact.Id; 
		translateEnterpriseToTenant(salesTransaction.enterprise, tenant);
		insert tenant;
		
		return tenant;
	} 
	
	public static Tenant__c findOrCreateTenantFromSalesTransaction(Box_SalesTransaction salesTransaction) {
		System.debug('Box_TenantFactory: Finding or creating tenant from sales transaction...');		
		
		Tenant__c tenant;
		if (salesTransaction == null) {
			throw new CustomException('Error: Cannot find or create tenant without an enterprise');
		}
	
		tenant = Box_TenantDAO.findTenantFromSalesTransaction(salesTransaction);
		if (tenant == null) {
			tenant = createTenantFromSalesTransaction(salesTransaction);
		}		
		return tenant;
	}
	
	public static Tenant__c translateEnterpriseToTenant(Box_Enterprise enterprise, Tenant__c tenant) {
		System.debug('Box_TenantFactory: Translating Box Enterprise to Tenant...');

		if (enterprise == null) {
			throw new CustomException('Error: cannot translate enterprise to tenant without an enterprise.');
		} else if (tenant == null) {
			throw new CustomException('Error: cannot translate enterprise to tenant without a tenant.');
		}
			
		// Translate
		if (enterprise.account_type != null)     { tenant.Account_Type__c         = enterprise.account_type;                               }
		if (enterprise.active_status != null)    { tenant.Active_Status__c        = enterprise.active_status;                              }
		if (enterprise.billing_cycle != null)    { tenant.Billing_Cycle__c        = enterprise.billing_cycle;                              }
		if (enterprise.blocked_status != null)   { tenant.Blocked_Status__c       = enterprise.blocked_status;                             }
		if (enterprise.deal_status != null)      { tenant.Deal_Status__c          = enterprise.deal_status;                                }
		if (enterprise.hide_add_user_ui != null) { tenant.Hide_Add_User_UI__c     = Boolean.valueOf(enterprise.hide_add_user_ui);          }
		if (enterprise.id != null)               { tenant.Enterprise_ID_Tenant__c = enterprise.id;                                         }			
		if (enterprise.is_silent_mode != null)   { tenant.Silent_Mode__c          = Boolean.valueOf(enterprise.is_silent_mode);            }			
		if (enterprise.name != null)             { tenant.Name                    = enterprise.name;                                       }
		if (enterprise.price_per_user != null)   { tenant.Price_Per_User__c       = Decimal.valueOf(enterprise.price_per_user);            }
		if (enterprise.seats != null)            { tenant.Seats_Allocated__c      = Integer.valueOf(enterprise.seats);                     }
		if (enterprise.seats_used != null)       { tenant.Seats_Used__c           = Integer.valueOf(enterprise.seats_used);                }
		if (enterprise.space_amount != null)     { tenant.Space_Allocated__c      = Long.valueOf(enterprise.space_amount) / BYTES_PER_GIG; }
		if (enterprise.space_used != null)       { tenant.Space_Used__c           = Long.valueOf(enterprise.space_used) / BYTES_PER_GIG;   }
		if (enterprise.subdomain != null)        { tenant.Subdomain__c            = enterprise.subdomain;                                  }
		if (enterprise.trial_end_at != null)     { tenant.Trial_End_Date__c       = Date.valueOf(enterprise.trial_end_at);                 }		
		
		return tenant;
	}	
	
	public static String calculateTrialDate(Tenant__c tenant) {
		System.debug('Box_TenantFactory: Calculating trial dates...');
		
		String trialEndDate;
		Account partner;
		if (tenant.Deal_Status__c != null) {
			if (tenant.Trial_End_Date__c == null) { 	
				// Initial trial
				if (tenant.Deal_Status__c.equals(Box_EnterpriseDealStatusEnum.TRIAL.name().toLowerCase())) {
					System.debug('Box_TenantFactory: Trial dates will be calculated.');
					// Trial has never been provisioned
					if (tenant.Trial_Start_Date__c == null) {
						Integer length = Box_CustomSettings.getDefaultTrialLength();						
						try {
							partner = Box_AccountDAO.findPartnerFromTenant(tenant);
							length  = Integer.valueOf(partner.Partner_Trial_Length__c);
						} catch (Exception e) { }
						tenant.Trial_Start_Date__c = Date.today();
						tenant.Trial_End_Date__c = tenant.Trial_Start_Date__c.addDays(length);
					} else {
						System.debug('Box_TenantFactory: Non-extended trial has already been provisioned.');
					}
					/*	
					// Trial extension
					} else if (tenant.Deal_Status__c.equals(Box_EnterpriseDealStatusEnum.TRIAL_EXTENSION.name().toLowerCase())) {
						// Make sure an extension hasn't been provisioned
						if (!tenant.Trial_Extended__c) {
							Integer length = Box_CustomSettings.getDefaultExtendedTrialLength();
							try {
								partner = Box_AccountDAO.findPartnerFromTenant(tenant);
								length  = Integer.valueOf(partner.Partner_Extended_Trial_Length__c);
							} catch (Exception e) {}
							if (tenant.Trial_Start_Date__c == null) {
								tenant.Trial_Start_Date__c = Date.today();
							}
							tenant.Trial_Extended__c = true;
							tenant.Trial_End_Date__c = tenant.Trial_Start_Date__c.addDays(length);
						} else {
							System.debug('Trial has already been extended.');
						}
					*/
				}
			}
			
			// Format to ISO8601
			if (tenant.Trial_End_Date__c != null && (tenant.Deal_Status__c.equals(Box_EnterpriseDealStatusEnum.TRIAL.name().toLowerCase()) || tenant.Deal_Status__c.equals(Box_EnterpriseDealStatusEnum.TRIAL_EXTENSION.name().toLowerCase()))) {
				DateTime trialEndTime = DateTime.newInstance(tenant.Trial_End_Date__c, Time.newInstance(0,0,0,0));
				String fiveDigitTimeZone = '-0000'; // Neutral GMT timing. There is a bug where '+XX:XX' does not work. When it is fixed, we can switch to trialEndTime.format('Z'); for time zone corrections  
				String firstThreeDigits = fiveDigitTimeZone.substring(0,3);
				String lastTwoDigits = fiveDigitTimeZone.substring(3,5);
				String formattedTimeZone = firstThreeDigits + ':' + lastTwoDigits;
				trialEndDate = trialEndTime.format(DATE_FORMAT) + formattedTimeZone;
			}
		}
		return trialEndDate;
	}
	
}