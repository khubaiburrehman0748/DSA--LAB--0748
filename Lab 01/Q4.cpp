#include <iostream>
#include <cstring>
using namespace std;

class Document {
private:
    char* content;   

public:
   
    Document(const char* text = "") {
        content = new char[strlen(text) + 1];
        strcpy(content, text);
    }

    ~Document() {
        delete[] content;
    }

   
    Document(const Document& other) {
        content = new char[strlen(other.content) + 1];
        strcpy(content, other.content);
    }

    
    Document& operator=(const Document& other) {
        if (this != &other) {
            delete[] content;  
            content = new char[strlen(other.content) + 1];
            strcpy(content, other.content);
        }
        return *this;
    }

    void setContent(const char* newText) {
        delete[] content;
        content = new char[strlen(newText) + 1];
        strcpy(content, newText);
    }

    void showContent() const {
        cout << "Document Content: " << content << endl;
    }
};

int main() {
   
    Document doc1("Hello, this is the original document.");
    cout << "Original Document:" << endl;
    doc1.showContent();

    Document doc2 = doc1;
    cout << "\nCopy Constructor Document:" << endl;
    doc2.showContent();

    Document doc3;
    doc3 = doc1;
    cout << "\nCopy Assignment Document:" << endl;
    doc3.showContent();

    doc1.setContent("Original document modified!");

    cout << "\nAfter modifying original:" << endl;
    cout << "Original -> "; doc1.showContent();
    cout << "Copy Constructor -> "; doc2.showContent();
    cout << "Copy Assignment -> "; doc3.showContent();

    return 0;
}
