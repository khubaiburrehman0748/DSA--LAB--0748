#include <iostream>
using namespace std;

class Box {
private:
    int* value;

public:
    Box(int v = 0) {
        value = new int(v);
    }

    ~Box() {
        delete value;
    }

    Box(const Box& other) {
        value = new int(*other.value);
    }

    Box& operator=(const Box& other) {
        if (this != &other) {
            delete value;
            value = new int(*other.value);
        }
        return *this;
    }

    void setValue(int v) {
        *value = v;
    }

    int getValue() const {
        return *value;
    }
};

int main() {
    cout << "Deep Copy Demo (Rule of Three) " << endl;
    Box b1(10);
    Box b2 = b1;
    Box b3;
    b3 = b1;

    cout << "b1 value: " << b1.getValue() << endl;
    cout << "b2 value: " << b2.getValue() << endl;
    cout << "b3 value: " << b3.getValue() << endl;

    b1.setValue(50);
    cout << "\nAfter modifying b1:" << endl;
    cout << "b1 value: " << b1.getValue() << endl;
    cout << "b2 value: " << b2.getValue() << endl;
    cout << "b3 value: " << b3.getValue() << endl;

    cout << "\n Shallow Copy Demo (No Rule of Three)" << endl;
    class ShallowBox {
    public:
        int* value;
        ShallowBox(int v = 0) {
            value = new int(v);
        }
        ~ShallowBox() {
            delete value;
        }
    };

    ShallowBox s1(100);
    ShallowBox s2 = s1;
    cout << "s1 value: " << *s1.value << endl;
    cout << "s2 value: " << *s2.value << endl;
    *s1.value = 200;
    cout << "\nAfter modifying s1:" << endl;
    cout << "s1 value: " << *s1.value << endl;
    cout << "s2 value: " << *s2.value << endl;
    cout << "\nProblem: both s1 and s2 share same memory, destructor will try to free it twice." << endl;

    return 0;
}
