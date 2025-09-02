#include <iostream>
#include <cstring>
using namespace std;

class Exam {
private:
    char* studentName;
    char* examDate;
    int score;

public:
    Exam(const char* name, const char* date, int s) {
        studentName = new char[strlen(name) + 1];
        strcpy(studentName, name);
        examDate = new char[strlen(date) + 1];
        strcpy(examDate, date);
        score = s;
    }

    ~Exam() {
        delete[] studentName;
        delete[] examDate;
    }

    void setDetails(const char* name, const char* date, int s) {
        delete[] studentName;
        delete[] examDate;
        studentName = new char[strlen(name) + 1];
        strcpy(studentName, name);
        examDate = new char[strlen(date) + 1];
        strcpy(examDate, date);
        score = s;
    }

    void display() {
        cout << "Student: " << studentName << endl;
        cout << "Exam Date: " << examDate << endl;
        cout << "Score: " << score << endl;
    }
};

int main() {
    Exam exam1("khubaib ur rehman", "2025-05-10", 85);
    cout << "Exam1 details:" << endl;
    exam1.display();

    Exam exam2 = exam1;  
    cout << "\nExam2 (shallow copy of Exam1):" << endl;
    exam2.display();

    cout << "\nAfter program ends, destructor will run twice for same memory -> problem occurs." << endl;

    return 0;
}
