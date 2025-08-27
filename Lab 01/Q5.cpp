#include <iostream>
#include <string>
using namespace std;

class Librarian {
private:
    string name;
    int id;
    int yearsOfExp;

public:
    void inputDetails() {
        cout << "Enter Librarian Name: ";
        getline(cin, name);
        cout << "Enter Librarian ID: ";
        cin >> id;
        cout << "Enter Years of Experience: ";
        cin >> yearsOfExp;
        cin.ignore(); 
    }

    void showDetails() {
        cout << "\n--- Librarian Details ---" << endl;
        cout << "Name: " << name << endl;
        cout << "ID: " << id << endl;
        cout << "Years of Experience: " << yearsOfExp << endl;
    }
};

int main() {
    Librarian lib;
    lib.inputDetails();
    lib.showDetails();

    const int fixedSize = 5;
    int fixedBooks[fixedSize] = {101, 102, 103, 104, 105};
    cout << "\n--- Existing Books in Library ---" << endl;
    for (int i = 0; i < fixedSize; i++) {
        cout << "Book ID: " << fixedBooks[i] << endl;
    }

    int n;
    cout << "\nEnter number of new books to add: ";
    cin >> n;

    int* newBooks = new int[n]; 

    cout << "Enter IDs for " << n << " new books:" << endl;
    for (int i = 0; i < n; i++) {
        cout << "Book " << i + 1 << " ID: ";
        cin >> newBooks[i];
    }

    cout << "\n--- New Books Added ---" << endl;
    for (int i = 0; i < n; i++) {
        cout << "Book ID: " << newBooks[i] << endl;
    }

    delete[] newBooks;

    cout << "\nMemory for new books released successfully!" << endl;

    return 0;
}
