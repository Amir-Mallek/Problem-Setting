#include <bits/stdc++.h>
using namespace std;

#define IOS                  \
    ios::sync_with_stdio(0); \
    cin.tie(0);              \
    cout.tie(0);
#define pb emplace_back
#define lv (v << 1)
#define rv ((v << 1) | 1)
#define endl '\n'

#define rep(i, a, b) for (int i = a; i < (b); ++i)
#define ALL(x) begin(x), end(x)
#define SZ(x) (int)(x).size()
typedef long long ll;
typedef pair<int, int> pii;
typedef vector<int> vi;
typedef tuple<int, int, int> w_edge;

mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
mt19937_64 lrng(chrono::steady_clock::now().time_since_epoch().count());
typedef uniform_int_distribution<int> uni_dist;
typedef uniform_int_distribution<ll> luni_dist;
/*
vi rand_arr(int size, int l, int r)
{
    assert(l <= r);
    vi a(size);
    uni_dist dist(l, r);
    for (int &x : a)
        x = dist(rng);
    return a;
}

set<ll> sample_k_from_n(ll k, ll n)
{
    assert(k <= n);
    set<ll> samples;
    for (ll j = n - k; j < n; ++j)
    {
        luni_dist dist(0, j);
        ll t = dist(lrng);
        if (samples.find(t) == samples.end())
            samples.insert(t);
        else
            samples.insert(j);
    }
    return samples;
}

vector<pii> rand_tree(int size)
{
    if (size == 1)
        return {};

    vi prufer_code = rand_arr(size - 2, 0, size - 1);

    vi degree(size, 1);
    for (int i : prufer_code)
        degree[i]++;

    int ptr = 0;
    while (degree[ptr] != 1)
        ptr++;
    int leaf = ptr;

    vector<pii> edges;
    edges.reserve(size - 1);
    for (int v : prufer_code)
    {
        edges.emplace_back(leaf, v);
        if (--degree[v] == 1 && v < ptr)
        {
            leaf = v;
        }
        else
        {
            ptr++;
            while (degree[ptr] != 1)
                ptr++;
            leaf = ptr;
        }
    }
    edges.emplace_back(leaf, size - 1);
    return edges;
}

vector<w_edge> rand_w_tree(int size, int min_w, int max_w)
{
    if (size == 1)
        return {};

    vi prufer_code = rand_arr(size - 2, 0, size - 1);

    vi degree(size, 1);
    for (int i : prufer_code)
        degree[i]++;

    int ptr = 0;
    while (degree[ptr] != 1)
        ptr++;
    int leaf = ptr;

    vector<w_edge> edges;
    edges.reserve(size - 1);
    uni_dist dist(min_w, max_w);
    for (int v : prufer_code)
    {
        edges.emplace_back(leaf, v, dist(rng));
        if (--degree[v] == 1 && v < ptr)
        {
            leaf = v;
        }
        else
        {
            ptr++;
            while (degree[ptr] != 1)
                ptr++;
            leaf = ptr;
        }
    }
    edges.emplace_back(leaf, size - 1, dist(rng));
    return edges;
}

vector<w_edge> rand_con_w_graph(int size, int nb_edges, int min_w, int max_w)
{
    vector<pii> tree_edges = rand_tree(size);
    set<pii> used_edges;
    for (auto [u, v] : tree_edges)
    {
        if (u > v)
            swap(u, v);
        used_edges.emplace(u, v);
    }

    vector<w_edge> graph_edges;
    uni_dist dist(min_w, max_w);
    graph_edges.reserve(nb_edges);
    for (auto [u, v] : tree_edges)
    {
        graph_edges.emplace_back(u, v, dist(rng));
    }
    if (nb_edges == size - 1)
        return graph_edges;

    ll max_edges = 1LL * size * (size - 1) / 2;
    set<ll> edge_ids = sample_k_from_n(min<ll>(nb_edges + size - 1, max_edges), max_edges);

    int cur_u = 0, cur_st = 0, cur_end = size - 2, nb_used = size - 1;
    for (ll id : edge_ids)
    {
        while (id > cur_end)
        {
            ++cur_u;
            cur_st = cur_end + 1;
            cur_end = cur_st + size - 2 - cur_u;
        }
        int cur_v = cur_u + 1 + id - cur_st;
        if (used_edges.find({cur_u, cur_v}) == used_edges.end())
        {
            graph_edges.emplace_back(cur_u, cur_v, dist(rng));
            if (++nb_used == nb_edges)
                break;
        }
    }

    return graph_edges;
}

constexpr int MAXW = 1e9, MAXA = 1e4;
void gen_random_test(int test_id, int maxn, int maxq)
{
    string file_name = "inputs/random" + to_string(test_id) + ".in";
    freopen(file_name.c_str(), "w", stdout);

    vi a = rand_arr(maxn, 1, MAXA);
    vector<w_edge> edges = rand_con_w_graph(maxn, maxn, 1, MAXW);
    vi qx = rand_arr(maxq, 1, maxn);
    vi qk = rand_arr(maxq, 1, MAXW);

    cout << maxn << ' ' << maxn << ' ' << maxq << endl;
    for (int i : a)
        cout << i << ' ';
    cout << endl;
    for (auto [u, v, w] : edges)
    {
        cout << u + 1 << ' ' << v + 1 << ' ' << w << endl;
    }
    rep(i, 0, maxq)
    {
        cout << qx[i] << ' ' << qk[i] << endl;
    }

    fclose(stdout);
}

constexpr int MAXN = 1e5, MIDQ = 500;
void gen_star_test(int test_id, int maxn, int maxq)
{
    string file_name = "inputs/star" + to_string(test_id) + ".in";
    freopen(file_name.c_str(), "w", stdout);

    vi a = rand_arr(maxn, 1, MAXA);
    vector<w_edge> edges;
    edges.reserve(maxn);
    uni_dist dist(1, MAXW);
    rep(i, 1, maxn)
    {
        edges.emplace_back(0, i, dist(rng));
    }

    cout << maxn << ' ' << maxn - 1 << ' ' << maxq << endl;
    for (int i : a)
        cout << i << ' ';
    cout << endl;
    for (auto [u, v, w] : edges)
    {
        cout << u + 1 << ' ' << v + 1 << ' ' << w << endl;
    }
    rep(i, 0, maxq)
    {
        cout << 1 << ' ' << MAXW - i << endl;
    }

    fclose(stdout);
}
*/
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
    gen_a_b(1, 0, 0);
    gen_a_b(2, INT_MAX, INT_MAX);

    rep(i, 3, 5 + 1){
        gen_a_b_random(i);
    }

    return 0;
}