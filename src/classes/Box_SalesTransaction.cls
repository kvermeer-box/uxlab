global class Box_SalesTransaction {

	public String partner_id;
	public String external_account_id;
	public String external_contact_id; 
	public Box_TransactionState state;
	public String last_transaction_id;
	public Boolean debug_mode;
	public Box_Enterprise enterprise;
	
	public String external_account_id_update;
	public String external_contact_id_update;

	public Box_SalesTransaction() { 
		enterprise = parseStateToEnterpriseStatus();
	}
	
	public Box_Enterprise parseStateToEnterpriseStatus() {
		System.debug('Parsing sales transaction state to enterprise values...');		
				
		if (enterprise != null) {
			// Activate/Cancel/Suspend
			if (state != null) {								
				if (state == Box_TransactionState.initiate) {
					enterprise.active_status = 'active';
					enterprise.deal_status = Box_EnterpriseDealStatusEnum.LIVE_DEAL.name().toLowerCase();
				} else if (state == Box_TransactionState.cancel) {
					enterprise.active_status = 'deactivated';
				} else if (state == Box_TransactionState.suspend) { 
					enterprise.active_status = 'deactivated'; 
				} 
			}
		}
		return enterprise;
	}  
	
	public void convertTenantToSalesTransaction(Tenant__c tenant) {
		System.debug('Converting tenant to sales transaction...');
		
		// Set the tenant data
		Box_SyncingEnterprise b = new Box_SyncingEnterprise(tenant);   
		this.enterprise = (Box_Enterprise)b.translate(tenant);
		
		// Set the misc data
		try {
			this.external_account_id = Box_AccountPartnerKeyDAO.getPartnerKeyFromAccountIdAndRunningUser(tenant.Account__r.Id);
		} catch (Exception e) { }
		try {
			this.external_contact_id = Box_UserPartnerKeyDAO.getPartnerKeyFromContactIdAndRunningUser(tenant.Admin__r.Id);
		} catch (Exception e) { }
		this.last_transaction_id = tenant.Last_Transaction_ID__c;	
		
		// Set the state if it is not yet set
		if (state == null) {
			state = Box_TenantDAO.getState(tenant);
		}		
	}
	 
	public Box_BasicSalesTransaction convertToBasicSalesTransaction() {
		System.debug('Converting to basic sales transaction...');
		Box_BasicSalesTransaction bst = new Box_BasicSalesTransaction();
		
		// Generic fields
		if (partner_id != null)          { bst.partner_id = partner_id;                   }
		if (state != null)               { bst.state = state.name();                      }
		if (last_transaction_id != null) { bst.last_transaction_id = last_transaction_id; } 
		if (debug_mode != null)          { bst.debug_mode = debug_mode;                   }		 
		
		// Accounts keys
		if (external_account_id != null && external_account_id_update != null) { 
			bst.external_account_id     = external_account_id_update;
			bst.external_account_id_old = external_account_id;
		} else if (external_account_id != null) {
			bst.external_account_id     = external_account_id;
		} else if (external_account_id_update != null) {
			bst.external_account_id     = external_account_id_update; 
		}
		
		// Contact keys
		if (external_contact_id != null && external_contact_id_update != null) { 
			bst.external_contact_id     = external_contact_id_update;
			bst.external_contact_id_old = external_contact_id;
		} else if (external_contact_id != null) {
			bst.external_contact_id     = external_contact_id;
		} else if (external_account_id_update != null) {
			bst.external_contact_id     = external_contact_id_update; 
		}				
		 
		// Enterprise fields
		if (enterprise != null) {
			if (enterprise.account_type != null)     { bst.enterprise_type = enterprise.account_type;                 }
			if (enterprise.active_status != null)    { bst.enterprise_active_status = enterprise.active_status;       }
			if (enterprise.blocked != null)          { bst.enterprise_blocked = enterprise.blocked;                   }
			if (enterprise.deal_status != null)      { bst.enterprise_deal_status = enterprise.deal_status;           }
			if (enterprise.id != null)               { bst.enterprise_id = enterprise.id;                             }
			if (enterprise.is_silent_mode != null)   { bst.enterprise_is_silent_mode = enterprise.is_silent_mode;     }
			if (enterprise.name != null)             { bst.enterprise_name = enterprise.name;                         } 
			if (enterprise.seats != null)            { bst.enterprise_seats = enterprise.seats;                       }
			if (enterprise.seats_used != null)       { bst.enterprise_seats_used = enterprise.seats_used;             }
			if (enterprise.space_amount != null)     { bst.enterprise_space_amount = enterprise.space_amount;         }
			if (enterprise.space_used != null)       { bst.enterprise_space_used = enterprise.space_used;             }
			if (enterprise.trial_end_at != null)     { bst.enterprise_trial_end_at = enterprise.trial_end_at;         }
			if (enterprise.type != null)             { bst.enterprise_type = enterprise.type;                         }
			if (enterprise.billing_cycle != null)    { bst.enterprise_billing_cycle = enterprise.billing_cycle;       }
			if (enterprise.price_per_user != null)   { bst.enterprise_price_per_user = enterprise.price_per_user;     }
			if (enterprise.hide_add_user_ui != null) { bst.enterprise_hide_add_user_ui = enterprise.hide_add_user_ui; }
			if (enterprise.subdomain != null)        { bst.enterprise_subdomain = enterprise.subdomain;               }
			
			if (enterprise.administered_by != null) {
				if (enterprise.administered_by.id != null)          { bst.user_id           = enterprise.administered_by.id;           }
				if (enterprise.administered_by.name != null)        { bst.user_name         = enterprise.administered_by.name;         }
				if (enterprise.administered_by.login != null)       { bst.user_login        = enterprise.administered_by.login;        }
				if (enterprise.administered_by.phone_number!= null) { bst.user_phone_number = enterprise.administered_by.phone_number; }
				if (enterprise.administered_by.type!= null)         { bst.user_type         = enterprise.administered_by.type;         }
			}	
		}
		bst.parseEnterpriseStatusToState();
		
		System.debug(bst);
		return bst;
	}
	
	public void updatePartnerKeys() {
		System.debug('Box_SalesTransaction: Updating all partner keys...');
		
		try {
			Box_AccountPartnerKeyDAO.findAndUpdatePartnerKey(external_account_id, external_account_id_update);
		} catch (Box_DuplicateRecordException d) {
			d.setMessage('Error: multiple external account ids found.');
			throw d;
		} catch (NoDataFoundException ndf) {
			ndf.setMessage('Error: external account id could not be found.');
			throw ndf;
		} catch (Exception e) {
			throw new CustomException('Error: internal error updating external account id.');
		}
		
		try {
			Box_UserPartnerKeyDAO.findAndUpdatePartnerKey(external_contact_id, external_contact_id_update);
		} catch (Box_DuplicateRecordException d) {
			d.setMessage('Error: multiple external contact ids found.');
			throw d;
		} catch (NoDataFoundException ndf) {
			ndf.setMessage('Error: external contact id could not be found.');
			throw ndf;
		} catch (Exception e) {
			throw new CustomException('Error: internal error updating external contact id.');
		}
	}
	
}