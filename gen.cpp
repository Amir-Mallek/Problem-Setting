#include <bits/stdc++.h>
using namespace std;

#define rep(i, a, b) for (int i = a; i < (b); ++i)
#define ALL(x) begin(x), end(x)
#define SZ(x) (int)(x).size()
#define endl '\n'
#define pb emplace_back
typedef long long ll;
typedef pair<int, int> pii;
typedef vector<int> vi;
typedef tuple<int, int, int> w_edge;

mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
mt19937_64 lrng(chrono::steady_clock::now().time_since_epoch().count());
typedef uniform_int_distribution<int> uni_dist;
typedef uniform_int_distribution<ll> luni_dist;

void gen_a_b(int test_id, ll a, ll b)
{
    string file_name = "inputs/test" + to_string(test_id) + ".in";
    freopen(file_name.c_str(), "w", stdout);
    cout << a << ' ' << b << '\n';
    fclose(stdout);
}
void gen_a_b_random(int test_id)
{
    string file_name = "inputs/test" + to_string(test_id) + ".in";
    freopen(file_name.c_str(), "w", stdout);
    uni_dist dist(0, INT_MAX);
    cout << dist(rng) << ' ' << dist(rng) << '\n';
    fclose(stdout);
}

int main()
{
    // To generate multiple tests, make sure the test_id is always unique across execution.

    gen_a_b(1, 0, 0);
    gen_a_b(2, INT_MAX, INT_MAX);

    rep(i, 3, 5 + 1)
    {
        gen_a_b_random(i);
    }

    return 0;
}