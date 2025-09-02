#include <iostream>
#include <string>
using namespace std;

class Student {
    string id; 
    int courses, *marks;
public:
    Student(string i,int c){ 
        id=i; courses=c; marks=new int[c]; 
        for(int j=0;j<c;j++){ 
            cout<<"Enter mark for course "<<j+1<<": "; 
            cin>>marks[j]; 
        }
    }
    ~Student(){ delete[] marks; }
    void display(){
        cout<<"Student ID: "<<id<<"\nCourses: ";
        for(int j=0;j<courses;j++) cout<<marks[j]<<" ";
        cout<<endl;
    }
};

int main(){
    Student* list[5];
    for(int i=0;i<5;i++){
        string id; int c; 
        cout<<"\nEnter Student ID: "; cin>>id;
        cout<<"Enter number of courses: "; cin>>c;
        list[i]=new Student(id,c);
    }
    cout<<"\nStudent Records\n";
    for(int i=0;i<5;i++) list[i]->display();
    for(int i=0;i<5;i++) delete list[i]; 
}
