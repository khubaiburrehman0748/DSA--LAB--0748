#include <iostream>
using namespace std;

class FruitShopInventory
{
    int **data, fruits;

public:
    FruitShopInventory(int n, int qty, int price)
    {
        fruits = n;
        data = new int *[n];
        for (int i = 0; i < n; i++)
        {
            data[i] = new int[2];
            data[i][0] = qty;
            data[i][1] = price;
        }
    }
    ~FruitShopInventory()
    {
        for (int i = 0; i < fruits; i++)
            delete[] data[i];
        delete[] data;
    }
    FruitShopInventory(const FruitShopInventory &o)
    {
        fruits = o.fruits;
        data = new int *[fruits];
        for (int i = 0; i < fruits; i++)
        {
            data[i] = new int[2];
            data[i][0] = o.data[i][0];
            data[i][1] = o.data[i][1];
        }
    }
    void setFruit(int i, int q, int p)
    {
        if (i >= 0 && i < fruits)
        {
            data[i][0] = q;
            data[i][1] = p;
        }
    }
    void display()
    {
        for (int i = 0; i < fruits; i++)
            cout << "Fruit " << i + 1 << " Qty:" << data[i][0] << " Price:" << data[i][1] << endl;
    }
};

int main()
{
    FruitShopInventory shop1(3, 20, 50);
    cout << "Original:\n";
    shop1.display();
    FruitShopInventory shop2 = shop1; 
    shop1.setFruit(0, 100, 200);
    cout << "\nAfter Update:\nOriginal:\n";
    shop1.display();
    cout << "Copy:\n";
    shop2.display();
}
