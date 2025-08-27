#include <iostream>
using namespace std;

class StudentFeeManager {
private:
    int* fees;
    int size;
public:
    StudentFeeManager(int n, int initialFee) {
        size = n;
        fees = new int[size];
        for (int i = 0; i < size; i++) {
            fees[i] = initialFee;
        }
    }

    ~StudentFeeManager() {
        delete[] fees;
    }

    StudentFeeManager(const StudentFeeManager& other) {
        size = other.size;
        fees = new int[size];
        for (int i = 0; i < size; i++) {
            fees[i] = other.fees[i];
        }
    }

    StudentFeeManager& operator=(const StudentFeeManager& other) {
        if (this != &other) {
            delete[] fees;
            size = other.size;
            fees = new int[size];
            for (int i = 0; i < size; i++) {
                fees[i] = other.fees[i];
            }
        }
        return *this;
    }

    void setFee(int index, int amount) {
        if (index >= 0 && index < size) {
            fees[index] = amount;
        }
    }

    void showFees() const {
        for (int i = 0; i < size; i++) {
            cout << "Student " << i + 1 << " Fee: " << fees[i] << endl;
        }
    }
};

int main() {
    StudentFeeManager s1(3, 5000);
    cout << "Original Fees:" << endl;
    s1.showFees();

    StudentFeeManager s2 = s1;
    s1.setFee(1, 6000);

    cout << "\nAfter modifying original:" << endl;
    cout << "Original:" << endl;
    s1.showFees();
    cout << "Copied:" << endl;
    s2.showFees();

    return 0;
}
