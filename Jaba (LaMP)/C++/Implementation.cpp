#include "TicTacToe.h"
using namespace std;

TicTacToe::Row TicTacToe ::operator[](int i) {
    return Row(this, i);
}
TicTacToe ::Row :: Row(TicTacToe *tacToe, int i) {
    this->tacToe = tacToe;
    this->i = i;
}
int& TicTacToe ::Row :: operator[](int j) {
    return tacToe->board[i][j];
}

TicTacToe ::TicTacToe(int n) {
    this->n = n;
    board = new int*[n];
    for (int i = 0; i < n; i++) {
        board[i] = new int[n];
        for (int j = 0; j < n; j++) {
            board[i][j] = 0;
        }
    }

}
int TicTacToe ::getN() {
    return this->n;
}
TicTacToe ::~TicTacToe() {
    for (int i = 0; i < n; i++) {
        delete[] board[i];
    }
    delete[] board;
}
void TicTacToe::check() {
    int first = 0;
    int countO = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (board[i][j] == 0) {
                first = 0;
                countO++;
                break;
            }
            if (board[i][j] != 0 && first == 0) first = board[i][j];
            if ((board[i][j] == 1 && first == 2) || (board[i][j] == 2 && first == 1)) {
                first = 0;
                break;
            }
        }
        if (first == 1) {
            cout << "Cross wins" << endl;
            return;
        }
        if (first == 2) {
            cout << "Zero wins" << endl;
            return;
        }
    }
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (board[j][i] == 0) {
                countO++;
                first = 0;
                break;
            }
            if (board[j][i] != 0 && first == 0) first = board[j][i];
            if ((board[j][i] == 1 && first == 2) || (board[j][i] == 2 && first == 1)) {
                first = 0;
                break;
            }
        }
        if (first == 1) {
            cout << "Cross wins" << endl;
            return;
        }
        if (first == 2) {
            cout << "Zero wins" << endl;
            return;
        }
    }
    for (int i = 0; i < n; i++) {
        if (board[i][i] == 0) {
            countO++;
            first = 0;
            break;
        }
        if (board[i][i] != 0 && first == 0) first = board[i][i];
        if ((board[i][i] == 1 && first == 2) || (board[i][i] == 2 && first == 1)) {
            first = 0;
            break;
        }
    }
    if (first == 1) {
        cout << "Cross wins" << endl;
        return;
    }
    if (first == 2) {
        cout << "Zero wins" << endl;
        return;
    }
    for (int i = n - 1, j = 0; i >= 0; i--, j++) {
        if (board[i][j] == 0) {
            first = 0;
            countO++;
            break;
        }
        if (board[i][j] != 0 && first == 0) first = board[i][j];
        if ((board[i][j] == 1 && first == 2) || (board[i][j] == 2 && first == 1)) {
            first = 0;
            break;
        }
    }
    if (first == 1) {
        cout << "Cross wins" << endl;
        return;
    }
    if (first == 2) {
        cout << "Zero wins" << endl;
        return;
    }

    if (countO != 0) {
        cout << "Nobody wins" << endl;
    } else {
        cout << "Pat" << endl;
    }
}
TicTacToe::TicTacToe(const TicTacToe &tacToe) {
    this->n = tacToe.n;
    board = new int*[n];
    for (int i = 0; i < n; i++) {
        board[i] = new int[n];
        copy(tacToe.board[i], tacToe.board[i] + n, board[i]);
    }
}
TicTacToe& TicTacToe::operator=(const TicTacToe &tacToe) {

    if (this != &tacToe) {
        n = tacToe.n;
        for (int i = 0; i < n; i++) {
            delete[] board[i];
        }
        delete[] board;
        board = new int*[n];
        for (int i = 0; i < n; i++) {
            board[i] = new int[n];
            copy(tacToe.board[i], tacToe.board[i] + n, board[i]);
        }
    }
    return *this;
}
std :: ostream& operator<< (std :: ostream& os, TicTacToe& tacToe) {
    for (int i = 0; i < tacToe.getN(); i++) {
        for (int j = 0; j < tacToe.getN(); j++) {
            if (tacToe[i][j] == 0) os << " " << " ";
            if (tacToe[i][j] == 1) os << "X" << " ";
            if (tacToe[i][j] == 2) os << "O" << " ";
        }
        os << std :: endl;
    }
    return os;
}
