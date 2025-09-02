#include <iostream>
#include <string>
using namespace std;

class Shop {
    string name;
    int* qty;
    int branches;
public:

    Shop(string n, int b) : name(n), branches(b) {
        qty = new int[branches];
    }

    ~Shop() { delete[] qty; }
    
    Shop(const Shop& other) : name(other.name), branches(other.branches) {
        qty = new int[branches];
        for(int i=0;i<branches;i++) qty[i] = other.qty[i];
    }

    Shop& operator=(const Shop& other) {
        if(this!=&other) {
            delete[] qty;
            name = other.name;
            branches = other.branches;
            qty = new int[branches];
            for(int i=0;i<branches;i++) qty[i] = other.qty[i];
        }
        return *this;
    }

    
    void setQuantity(int i,int q){ qty[i]=q; }
    
    
    void display(){
        cout<<name<<": ";
        for(int i=0;i<branches;i++) cout<<qty[i]<<" ";
        cout<<endl;
    }
};

int main() {
    Shop s1("Laptop",3);
    s1.setQuantity(0,10); s1.setQuantity(1,20); s1.setQuantity(2,30);
    s1.display();

    Shop s2=s1;  
    s2.display();

    Shop s3("Temp",2);
    s3=s1;     
    s3.display();
}
