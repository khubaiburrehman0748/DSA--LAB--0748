#include <iostream>
using namespace std;

class BankAccount {
    
private:
    double balance;

public:
    

    BankAccount() {
        balance = 0.0;
    }


    BankAccount(double initialBalance) {
        balance = initialBalance;
    }


    BankAccount(const BankAccount& other) {
        balance = other.balance;
    }


    void deposit(double amount) {
        balance += amount;
    }


    void withdraw(double amount) {
        if (amount <= balance) 
        balance -= amount;
    }


    double getBalance() const {
        return balance;
    }

};

int main() {
    BankAccount account1;
    cout << "Account1 Balance: $" << account1.getBalance() << endl;

    BankAccount account2(1000);
    cout << "Account2 Balance: $" << account2.getBalance() << endl;

    BankAccount account3(account2);
    account3.withdraw(200);
    cout << "Account3 Balance after withdrawing $200: $" << account3.getBalance() << endl;
    cout << "Account2 Balance remains: $" << account2.getBalance() << endl;

    return 0;
}
