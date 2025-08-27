#include <iostream>
using namespace std;

int main() {
    const int deptCount = 4;
    const int courses[deptCount] = {3, 4, 2, 1};
    const char* deptNames[deptCount] = {"Software Engineering", "Artificial Intelligence", "Computer Science", "Data Science"};

    float* gpa[deptCount];
    for (int i = 0; i < deptCount; i++) {
        gpa[i] = new float[courses[i]];
    }

    for (int i = 0; i < deptCount; i++) {
        cout << "Enter GPA for " << deptNames[i] << " (" << courses[i] << " courses):" << endl;
        for (int j = 0; j < courses[i]; j++) {
            cout << "Course " << j + 1 << ": ";
            cin >> gpa[i][j];
        }
    }

    cout << "\n--- GPA Data ---" << endl;
    for (int i = 0; i < deptCount; i++) {
        cout << deptNames[i] << ": ";
        for (int j = 0; j < courses[i]; j++) {
            cout << gpa[i][j] << " ";
        }
        cout << endl;
    }

    for (int i = 0; i < deptCount; i++) {
        delete[] gpa[i];
    }

    return 0;
}
