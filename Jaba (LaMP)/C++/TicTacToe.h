// 0 - empty, 1 - cross, 2 - zero
class TicTacToe {
public:
    class Row {
    private:
        TicTacToe *tacToe;
        int i;
    public:
        Row(TicTacToe *tacToe, int i);
        int& operator[](int j);
    };
    TicTacToe(int n);
    TicTacToe(const TicTacToe &tacToe);
    virtual ~TicTacToe();
    int getN();
    void check();
    Row operator[](int i);
    TicTacToe& operator= (const TicTacToe &tacToe);
private:
    int n;
    int **board;
};



