import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

actor Token {

    Debug.print("What's gucci");
    //set owner to Principal ID
    let owner : Principal = Principal.fromText("wgjge-6lvo2-pp6bz-k72rc-tpr42-ptmvu-7axjl-mfgrq-gydsj-jodro-jae");
    //set total supply of tokens
    let totalSupply : Nat = 1000000000;
    //set token symbol
    let symbol : Text = "ZZZ";

    private stable var balanceEntries: [(Principal, Nat)] = [];

    //set balances
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);

    //check balance of Principal IDs
    public query func balanceOf(who: Principal) : async Nat {

        let balance : Nat = switch (balances.get(who)){
            case null 0;
            case(?result) result;
        };

        return balance;
      
    };

    //public function to return the token symbol to be passed to the frontend when user checks balance
    public query func getSymbol() : async Text {
        return symbol;
    };

    //create faucet functionality
    public shared(msg) func payOut() : async Text {
        // Debug.print(debug_show(msg.caller));
        if (balances.get(msg.caller) == null) {
           let amount = 10000; 
            //deposit 10,000 ZZZ into the principal ID of the requester
        let result = await transfer(msg.caller, amount);
        return result;
        } else {
        return "Airdrop already claimed"
        ;} 

        };

    public shared(msg) func transfer(to: Principal, amount: Nat) : async Text {
        //get balance of the user who is transferring funds
        let fromBalance = await balanceOf(msg.caller);
        //check to see if user has sufficient funds
        if (fromBalance > amount) {

            //assign new balance after subtracting desired transfer amount
            let newFromBalance: Nat = fromBalance - amount;
            //update the user's balance on-chain
            balances.put(msg.caller, newFromBalance);

            //get the principal id of the receiver
            let toBalance = await balanceOf(to);
            //assign new value after receiving funds
            let newToBalance = toBalance + amount;
            //update the receiver's balance on-chain
            balances.put(to, newToBalance);

            return "Success";
        } else {
            return("Insufficient Funds");
        };

       
    };

        //Persisting Non-Stable Types Using the Pre and Postupgrade Methods
       system func preupgrade() {
        balanceEntries := Iter.toArray(balances.entries());
       };

       system func postupgrade() {
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash); 
        if (balances.size() < 1) {
           balances.put(owner, totalSupply); 
        }
        
       };

};