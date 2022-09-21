#include <cmath>
#include "iterator"
using namespace std;
// V ij = ai ^ (j - 1)
template <int M, int N>
class VanderMatrix {
private:
    int coofs[M];
public:
    VanderMatrix(int *coofs) {
        for (int i = 0; i < M; i++) {
            this->coofs[i] = coofs[i];
        }
    }
    class Row {
    private:
        VanderMatrix<M, N> *Van;
        int i;
    public:
        Row(VanderMatrix<M, N> *Van, int i) {
            this->Van = Van;
            this->i = i;
        }
        int operator[](int j) {
            return pow(Van->coofs[i], j);
        }
    };
    Row operator[](int i) {
        return Row(this, i);
    }
    class VanderIterator : public iterator<bidirectional_iterator_tag, int> {
    private:
        VanderMatrix<M, N>* Van;
        int i;
        int j;
    public:
        VanderIterator(int i, int j, VanderMatrix<M, N> *Van) {
            this->i = i;
            this->j = j;
            this->Van = Van;
        }
        VanderIterator& operator=(const VanderIterator &it) {
            i = it.i;
            j = it.j;
            Van = it.Van;
            return *this;
        }
        VanderIterator& operator++() {
            j++;
            if (j == N) {
                j = 0;
                i++;
            }
            return *this;
        }
        VanderIterator& operator--() {
            j--;
            if (j == -1) {
                j = N - 1;
                i--;
            }
            return *this;
        }
        int operator*() {
            return (*Van)[i][j];
        }
        bool operator ==(const VanderIterator &it) {
            if (this->Van == it.Van) {
                if (this->i == it.i && this->j == it.j) {
                    return true;
                }
            }
            return false;
        }
        bool operator != (const VanderIterator &it) {
            return !(*this == it);
        }
    };
    VanderIterator begin() {
        return VanderIterator(0, 0, this);
    }
    VanderIterator end() {
        return VanderIterator(M - 1, N - 1, this);
    }
};


template <int M, int N>
ostream& operator<<(ostream& os, VanderMatrix<M, N>& Van) {
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            os << Van[i][j];
            os << " ";
        }
        os << endl;
    }
    return os;
}
