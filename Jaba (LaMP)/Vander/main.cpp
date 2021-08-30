#include <iostream>
#include "VanderMatrix.h"
using namespace std;

int main() {
    int coofs[5];
    for (int i = 0; i < 5; i++) {
        coofs[i] = i + 1;
    }
    VanderMatrix<5, 4>Van(coofs);
    cout << Van;
    VanderMatrix<5, 4> :: VanderIterator it = Van.begin();
    for (;it != ++Van.end(); ++it) {
        cout << *it << " ";
    }
    cout << endl;
    for (VanderMatrix<5, 4> :: VanderIterator it2 = Van.end(); it2 != --Van.begin(); --it2) {
        cout << *it2 << " ";
    }
    return 0;
}
