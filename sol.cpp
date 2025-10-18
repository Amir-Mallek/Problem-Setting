#include <bits/stdc++.h>

using namespace std;

#define IOS ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
#define pb emplace_back
#define lv (v<<1)
#define rv ((v<<1)|1)
#define endl '\n'

#define rep(i, a, b) for(int i = a; i < (b); ++i)
#define ALL(x) begin(x), end(x)
#define SZ(x) (int)(x).size()
typedef long long ll;
typedef pair<int, int> pii;
typedef vector<int> vi;

constexpr int MAXN = 2e5 + 5, LOG2N = 19, INF = 1e9 + 5;
int a[MAXN], comp[MAXN], up[LOG2N][MAXN], req[LOG2N][MAXN], nd_cnt;


int find_root(int u) {
    if (u == comp[u]) return u;
    return comp[u] = find_root(comp[u]);
}

void add_edge(int u, int v, int w) {
    u = find_root(u);
    v = find_root(v);
    if (u == v) return;

    comp[nd_cnt] = nd_cnt;
    up[0][nd_cnt] = nd_cnt;
    req[0][nd_cnt] = INF;
    a[nd_cnt] = a[u] + a[v];

    comp[u] = comp[v] = nd_cnt;
    up[0][u] = up[0][v] = nd_cnt;
    req[0][u] = max(0, w-a[u]);
    req[0][v] = max(0, w-a[v]);

    ++nd_cnt;
}

int main() {
    IOS

    int n, m, q;
    cin >> n >> m >> q;
    rep(i, 0, n) {
        comp[i] = i;
        up[0][i] = i;
        req[0][i] = INF;
        cin >> a[i];
    }
    vector<tuple<int, int, int>> edges(m);
    for (auto& [w, u, v] : edges) {
        cin >> u >> v >> w;
        --u; --v;
    }
    sort(ALL(edges));
    nd_cnt = n;
    for (auto [w, u, v] : edges) {
        add_edge(u, v, w);
    }
    rep(i, 1, LOG2N) {
        rep(j, 0, nd_cnt) {
            up[i][j] = up[i-1][up[i-1][j]];
            req[i][j] = max(req[i-1][j], req[i-1][up[i-1][j]]);
        }
    }
    while (q--) {
        int x, k;
        cin >> x >> k;
        --x;
        for (int step = LOG2N-1; step >= 0; --step) {
            if (k >= req[step][x]) {
                x = up[step][x];
            }
        }
        cout << a[x] + k << endl;
    }

    return 0;
}