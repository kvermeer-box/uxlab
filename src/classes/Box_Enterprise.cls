global class Box_Enterprise {
    
    // Enterprise fields
    public String account_type;
    public String active_status;
    public String blocked;  
    public String deal_status;
    public String id;
    public Boolean is_silent_mode;
    public String name;
    public String seats;
    public String seats_used;   
    public String space_amount;  
    public String space_used;
    public String trial_end_at;
    public String type;
    public String billing_cycle;
    public String price_per_user;
    public Boolean hide_add_user_ui;
    
    // User fields
    public Box_User administered_by;
    
    // Fields we won't use, but keep for deserialization purposes
    public String subdomain;
    public String blocked_status;
    
}