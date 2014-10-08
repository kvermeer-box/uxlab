global class Box_BasicSalesTransaction {

	public String partner_id;
	public String external_account_id_old;
	public String external_account_id;
	public String external_contact_id_old;
	public String external_contact_id; 
	public String state; 
	public String last_transaction_id;
	public Boolean debug_mode;
	
	// Enterprise fields
	public String enterprise_type; 
	public String enterprise_active_status;
	public String enterprise_blocked;	
	public String enterprise_deal_status; 
	public String enterprise_id;
	public Boolean enterprise_is_silent_mode;
	public String enterprise_name;
	public String enterprise_seats;
	public String enterprise_seats_used;	
	public String enterprise_space_amount; 
	public String enterprise_space_used;
	public String enterprise_trial_end_at;
	public String enterprise_billing_cycle;
	public String enterprise_price_per_user;
	public Boolean enterprise_hide_add_user_ui;
	public String enterprise_subdomain;
	public String enterprise_blocked_status; 
	
	// User fields
	public String user_id;
	public String user_name;
	public String user_login;
	public String user_phone_number;
	public String user_type;
	
	public Box_BasicSalesTransaction() {
		parseEnterpriseStatusToState();
	}

	public void parseEnterpriseStatusToState() {
		System.debug('Parsing enterprise to sales transaction state...');		
				
		if (enterprise_active_status != null && (state == null || state.equals(''))) {
			if (enterprise_active_status.equals('active')) {
				state = Box_TransactionState.initiate.name();
			} else if (enterprise_active_status.equals('deactivated')) {
				state = Box_TransactionState.cancel.name();
			}		 
		}
	} 
	
	public Box_TransactionState parseState(String state) {
		Box_TransactionState bts;
		if (state != null) {
			if (state.toLowerCase().equals(Box_TransactionState.initiate.name())) {
				bts = Box_TransactionState.initiate;
			} else if (state.toLowerCase().equals(Box_TransactionState.cancel.name())) {
				bts = Box_TransactionState.cancel;
			} else if (state.toLowerCase().equals(Box_TransactionState.suspend.name())) {
				bts = Box_TransactionState.suspend;
			} else {
				throw new CustomException('Error: invalid state ' + state);
			}
		} else {
			throw new CustomException('Error: state cannot be null.');
		}
		return bts;
	}

	public Box_SalesTransaction convertToSalesTransaction() {
		System.debug('Converting basic sales transaction to sales transaction...');
		Box_SalesTransaction st = new Box_SalesTransaction();
		
		// Generic fields
		if (partner_id != null)              { st.partner_id = partner_id;                           }
		if (state != null)                   { st.state = parseState(state);                         } 
		if (last_transaction_id != null)     { st.last_transaction_id = last_transaction_id;         } 
		if (debug_mode != null)              { st.debug_mode = debug_mode;                           }
		 
		// External account ID
		if (external_account_id_old != null && external_account_id != null) {
			st.external_account_id        = external_account_id_old;
			st.external_account_id_update = external_account_id; 
		} else if (external_account_id != null) {
			st.external_account_id        = external_account_id;
		} else if (external_account_id_old != null) {
			st.external_account_id        = external_account_id_old;
		}
		
		// External contact ID
		if (external_contact_id_old != null && external_contact_id != null) {
			st.external_contact_id        = external_contact_id_old;
			st.external_contact_id_update = external_contact_id; 
		} else if (external_contact_id != null) {
			st.external_contact_id        = external_contact_id;
		} else if (external_contact_id_old != null) {
			st.external_contact_id        = external_contact_id_old;
		}
		 
		// Enterprise fields
		Box_Enterprise e = new Box_Enterprise();
		if (enterprise_type != null)             { e.account_type     = enterprise_type;             }
		if (enterprise_active_status != null)    { e.active_status    = enterprise_active_status;    }
		if (enterprise_blocked != null)          { e.blocked          = enterprise_blocked;          } 
		if (enterprise_deal_status != null)      { e.deal_status      = enterprise_deal_status;      }
		if (enterprise_id != null)               { e.id               = enterprise_id;               }
		if (enterprise_is_silent_mode != null)   { e.is_silent_mode   = enterprise_is_silent_mode;   }
		if (enterprise_name != null)             { e.name             = enterprise_name;             } 
		if (enterprise_seats != null)            { e.seats            = enterprise_seats;            }
		if (enterprise_seats_used != null)       { e.seats_used       = enterprise_seats_used;       }
		if (enterprise_space_amount != null)     { e.space_amount     = enterprise_space_amount;     }
		if (enterprise_space_used != null)       { e.space_used       = enterprise_space_used;       }
		if (enterprise_trial_end_at != null)     { e.trial_end_at     = enterprise_trial_end_at;     }
		if (enterprise_billing_cycle != null)    { e.billing_cycle    = enterprise_billing_cycle;    } 
		if (enterprise_price_per_user != null)   { e.price_per_user   = enterprise_price_per_user;   }
		if (enterprise_hide_add_user_ui != null) { e.hide_add_user_ui = enterprise_hide_add_user_ui; }
		if (enterprise_subdomain != null)        { e.subdomain        = enterprise_subdomain;        }
		st.enterprise = e;
		st.parseStateToEnterpriseStatus();
		
		// User fields
		Box_User b = new Box_User();
		if (user_id != null)           { b.id           = user_id;           }
		if (user_name != null)         { b.name         = user_name;         }
		if (user_login != null)        { b.login        = user_login;        } 
		if (user_phone_number != null) { b.phone_number = user_phone_number; }
		if (user_type != null)         { b.type         = user_type;         }
		st.enterprise.administered_by = b;
		
		System.debug(st);
		return st;
	}

}