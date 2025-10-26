#include <bits/stdc++.h>
using namespace std;

int main(int argc, char **argv)
{
    ios::sync_with_stdio(false);
    cin.tie(0);
    cout.tie(0);

    // The input of the problem (read the whole input)
    freopen(argv[1], "r", stdin);
    long long a, b;
    cin >> a >> b;

    // The output to be tested (read the whole input)
    freopen(argv[2], "r", stdin);
    long long C;
    cin >> C;
    fclose(stdin);

    // The output of the reference solution (read the whole input)
    freopen(argv[3], "r", stdin);
    long long D;
    cin >> D;
    fclose(stdin);

    // Testing
    // Return : [if output_to_be_tested is valid --> 0] and [if invalid --> 1]

    if (C != D)
    {
        return 1;
    }

    return 0;
}