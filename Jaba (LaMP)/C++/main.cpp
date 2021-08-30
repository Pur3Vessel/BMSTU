#include <iostream>
#include <set>
#include "Implementation.cpp"
using namespace std;
void setX(TicTacToe &tacToe, int x, int y) {
    tacToe[x][y] = 1;
}
void setO(TicTacToe &tacToe, int x, int y) {
    tacToe[x][y] = 2;
}
void HeHe(TicTacToe tacToe) {
    setO(tacToe, 0, 0);
    setO(tacToe, 0, 1);
    setO(tacToe, 0, 2);
    tacToe.check();
    cout << tacToe << endl;
}

int main() {
    auto *tacToe = new TicTacToe(3);
    cout << tacToe->getN() << endl;
    setX(*tacToe, 0, 0);
    setO(*tacToe, 0, 1);
    setX(*tacToe, 1, 1);
    setO(*tacToe, 2, 2);
    setX(*tacToe, 0, 2);
    setO(*tacToe, 2, 1);
    setX(*tacToe, 2 , 0);
    HeHe(*tacToe);
    tacToe->check();
    auto *tukToe = new TicTacToe(3);
    *tukToe = *tacToe;
    auto *tikToe = new TicTacToe(*tacToe);
    cout << *tacToe << endl;
    set <TicTacToe> S;
    delete tacToe;
    tikToe->check();
    cout << *tikToe << endl;
    delete tikToe;
    tukToe->check();
    cout << *tukToe << endl;
    delete tukToe;
    return 0;

}
