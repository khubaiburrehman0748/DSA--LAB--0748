#include <iostream>
using namespace std;

class ProductStockManager {
    int* stock;
    int size;
public:
    ProductStockManager(int n, int s) {
        size = n;
        stock = new int[size];
        for(int i=0;i<size;i++) stock[i] = s;
    }
    ~ProductStockManager() { delete[] stock; }

    ProductStockManager(const ProductStockManager& o) {
        size = o.size;
        stock = new int[size];
        for(int i=0;i<size;i++) stock[i] = o.stock[i];
    }
    ProductStockManager& operator=(const ProductStockManager& o) {
        if(this!=&o) {
            delete[] stock;
            size = o.size;
            stock = new int[size];
            for(int i=0;i<size;i++) stock[i] = o.stock[i];
        }
        return *this;
    }

    void setStock(int i,int v){ if(i>=0 && i<size) stock[i]=v; }
    void show(){ for(int i=0;i<size;i++) cout<<stock[i]<<" "; cout<<endl; }
};

int main() {
    ProductStockManager p1(3, 50);
    p1.show();

    ProductStockManager p2 = p1; 
    p2.setStock(0,100);

    cout<<"Original: "; p1.show();
    cout<<"Copy: "; p2.show();
}
