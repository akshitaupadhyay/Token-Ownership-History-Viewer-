module MyModule::TokenHistoryViewer {
    use aptos_framework::signer;
    use std::vector;
    use aptos_framework::timestamp;

    /// Struct representing ownership history record
    struct OwnershipRecord has store, copy {
        previous_owner: address,
        new_owner: address,
        timestamp: u64,
        token_id: u64,
    }

    /// Struct containing the ownership history for a token
    struct TokenHistory has store, key {
        token_id: u64,
        current_owner: address,
        ownership_records: vector<OwnershipRecord>,
    }

    /// Function to initialize token ownership history
    public fun initialize_token_history(
        owner: &signer, 
        token_id: u64
    ) {
        let owner_addr = signer::address_of(owner);
        let token_history = TokenHistory {
            token_id,
            current_owner: owner_addr,
            ownership_records: vector::empty<OwnershipRecord>(),
        };
        move_to(owner, token_history);
    }

    /// Function to record ownership transfer and update history
    public fun transfer_ownership(
        current_owner: &signer,
        new_owner_addr: address,
        token_id: u64
    ) acquires TokenHistory {
        let current_owner_addr = signer::address_of(current_owner);
        let token_history = borrow_global_mut<TokenHistory>(current_owner_addr);
        
        // Create new ownership record
        let ownership_record = OwnershipRecord {
            previous_owner: current_owner_addr,
            new_owner: new_owner_addr,
            timestamp: timestamp::now_seconds(),
            token_id,
        };
        
        // Add record to history and update current owner
        vector::push_back(&mut token_history.ownership_records, ownership_record);
        token_history.current_owner = new_owner_addr;
    }

    /// View function to get ownership history (read-only)
    #[view]
    public fun get_ownership_history(owner: address): vector<OwnershipRecord> acquires TokenHistory {
        let token_history = borrow_global<TokenHistory>(owner);
        token_history.ownership_records
    }
}