[1m[33mhome/leiserfg/features/kitty.nix[39m[0m[2m --- Nix[0m
[31;1m 1 [0m{ [31munstablePkgs[0m, ... }:                     [32;1m 1 [0m{ [32mmyPkgs[0m, ... }:
[2m 2 [0m{                                          [2m 2 [0m{
[2m 3 [0m                                           [2m 3 [0m
[2m 4 [0m  programs.kitty = {                       [2m 4 [0m  programs.kitty = {
[2m 5 [0m    enable = true;                         [2m 5 [0m    enable = true;
[31;1m 6 [0m    package = [31munstablePkgs[0m.kitty;          [32;1m 6 [0m    package = [32mmyPkgs[0m.kitty;
[2m 7 [0m    environment = {                        [2m 7 [0m    environment = {
[2m 8 [0m      FZF_DEFAULT_OPTS = [35m"--color=light"[0m;  [2m 8 [0m      FZF_DEFAULT_OPTS = [35m"--color=light"[0m;
[2m 9 [0m    };                                     [2m 9 [0m    };

[1m[33mflake.lock[39m[0m[2m --- 1/6 --- JSON[0m
[2m160 [0m        ]                                                                  [2m160 [0m        ]
[2m161 [0m      },                                                                   [2m161 [0m      },
[2m162 [0m      [35m"locked"[0m: {                                                          [2m162 [0m      [35m"locked"[0m: {
[31;1m163 [0m        [35m"lastModified"[0m: [31m1788487777[0m,                                        [32;1m163 [0m        [35m"lastModified"[0m: [32m1788651960[0m,
[31;1m164 [0m        [35m"narHash"[0m: [31m"sha256-Ro/e1N4ZR8/XaFF+sF9SgfPK79HM5YNEppzFj8p+0Ak="[0m,  [32;1m164 [0m        [35m"narHash"[0m: [32m"sha256-v9wJd32eZ2bvhBzVOd7TIjLQd011P7nwOhjKtWlci5I="[0m,
[2m165 [0m        [35m"owner"[0m: [35m"nix-community"[0m,                                          [2m165 [0m        [35m"owner"[0m: [35m"nix-community"[0m,
[2m166 [0m        [35m"repo"[0m: [35m"home-manager"[0m,                                            [2m166 [0m        [35m"repo"[0m: [35m"home-manager"[0m,
[31;1m167 [0m        [35m"rev"[0m: [31m"693e8ce0fb240a73c116a03cfd7b19269c87af88"[0m,                 [32;1m167 [0m        [35m"rev"[0m: [32m"2c0350c759688177331b8f5242311fae8877bdb3"[0m,
[2m168 [0m        [35m"type"[0m: [35m"github"[0m                                                   [2m168 [0m        [35m"type"[0m: [35m"github"[0m
[2m169 [0m      },                                                                   [2m169 [0m      },
[2m170 [0m      [35m"original"[0m: {                                                        [2m170 [0m      [35m"original"[0m: {

[1mflake.lock[0m[2m --- 2/6 --- JSON[0m
[2m195 [0m        [35m"calepin"[0m: [35m"calepin"[0m,                                              [2m195 [0m        [35m"calepin"[0m: [35m"calepin"[0m,
[2m196 [0m        [35m"kcd"[0m: [35m"kcd"[0m,                                                      [2m196 [0m        [35m"kcd"[0m: [35m"kcd"[0m,
[2m197 [0m        [35m"llm-agents"[0m: [35m"llm-agents"[0m,                                        [2m197 [0m        [35m"llm-agents"[0m: [35m"llm-agents"[0m,
[31;1m198 [0m        [31m"nim2-nimony-lsp":[0m [31m"nim2-nimony-lsp",[0m                              [2m... [0m
[2m199 [0m        [35m"nimony"[0m: [35m"nimony"[0m,                                                [2m198 [0m        [35m"nimony"[0m: [35m"nimony"[0m,
[2m200 [0m        [35m"nixpkgs"[0m: [35m"nixpkgs"[0m,                                              [2m199 [0m        [35m"nixpkgs"[0m: [35m"nixpkgs"[0m,
[2m201 [0m        [35m"pytest-language-server"[0m: [35m"pytest-language-server"[0m,                [2m200 [0m        [35m"pytest-language-server"[0m: [35m"pytest-language-server"[0m,
[2m202 [0m        [35m"sokol-tools-bin"[0m: [35m"sokol-tools-bin"[0m                               [2m201 [0m        [35m"sokol-tools-bin"[0m: [35m"sokol-tools-bin"[0m
[2m203 [0m      },                                                                   [2m202 [0m      },
[2m204 [0m      [35m"locked"[0m: {                                                          [2m203 [0m      [35m"locked"[0m: {
[31;1m205 [0m        [35m"lastModified"[0m: [31m1788605399[0m,                                        [32;1m204 [0m        [35m"lastModified"[0m: [32m1788691155[0m,
[31;1m206 [0m        [35m"narHash"[0m: [31m"sha256-Zdeer3ikCA6cx1vYerorzrWREn/ME+bPy9SSfZcqGxY="[0m,  [32;1m205 [0m        [35m"narHash"[0m: [32m"sha256-12kiuYiEfRy5wGI4h4MhziTQ3RcgQKej5w2Wciqz+cM="[0m,
[2m207 [0m        [35m"owner"[0m: [35m"leiserfg"[0m,                                               [2m206 [0m        [35m"owner"[0m: [35m"leiserfg"[0m,
[2m208 [0m        [35m"repo"[0m: [35m"leiserfg-overlay"[0m,                                        [2m207 [0m        [35m"repo"[0m: [35m"leiserfg-overlay"[0m,
[31;1m209 [0m        [35m"rev"[0m: [31m"dc6d0746a98424f34fca9cda667508381d5d2250"[0m,                 [32;1m208 [0m        [35m"rev"[0m: [32m"9dbb94b83fb69444962880fc91ebf6216eb1e8de"[0m,
[2m210 [0m        [35m"type"[0m: [35m"github"[0m                                                   [2m209 [0m        [35m"type"[0m: [35m"github"[0m
[2m211 [0m      },                                                                   [2m210 [0m      },
[2m212 [0m      [35m"original"[0m: {                                                        [2m211 [0m      [35m"original"[0m: {

[1mflake.lock[0m[2m --- 3/6 --- JSON[0m
[2m252 [0m        [35m"treefmt-nix"[0m: [35m"treefmt-nix_2"[0m                                     [2m251 [0m        [35m"treefmt-nix"[0m: [35m"treefmt-nix_2"[0m
[2m253 [0m      },                                                                   [2m252 [0m      },
[2m254 [0m      [35m"locked"[0m: {                                                          [2m253 [0m      [35m"locked"[0m: {
[31;1m255 [0m        [35m"lastModified"[0m: [31m1788602747[0m,                                        [32;1m254 [0m        [35m"lastModified"[0m: [32m1788684345[0m,
[31;1m256 [0m        [35m"narHash"[0m: [31m"sha256-WsI2ZhA2Gv/1pSYcovj7kbikl4hfuJmFPb0GK1Nfpzo="[0m,  [32;1m255 [0m        [35m"narHash"[0m: [32m"sha256-+3tYyzbgr5LdaqPDQ9tHM1JuXx7DVQqZH8MeQ7ooStI="[0m,
[2m257 [0m        [35m"owner"[0m: [35m"numtide"[0m,                                                [2m256 [0m        [35m"owner"[0m: [35m"numtide"[0m,
[2m258 [0m        [35m"repo"[0m: [35m"llm-agents.nix"[0m,                                          [2m257 [0m        [35m"repo"[0m: [35m"llm-agents.nix"[0m,
[31;1m259 [0m        [35m"rev"[0m: [31m"9cd345e386f30d746cf763343de805f283068649"[0m,                 [32;1m258 [0m        [35m"rev"[0m: [32m"76e610601903fd31e82b996b28a49c6d1adb559c"[0m,
[2m260 [0m        [35m"type"[0m: [35m"github"[0m                                                   [2m259 [0m        [35m"type"[0m: [35m"github"[0m
[2m261 [0m      },                                                                   [2m260 [0m      },
[2m262 [0m      [35m"original"[0m: {                                                        [2m261 [0m      [35m"original"[0m: {

[1mflake.lock[0m[2m --- 4/6 --- JSON[0m
[2m265 [0m[2m264 [0m        [35m"type"[0m: [35m"github"[0m
[2m266 [0m[2m265 [0m      }
[2m267 [0m[2m266 [0m    },
[31;1m268 [0m[2m... [0m    [31m"nim2-nimony-lsp":[0m [31;1m{[0m
[31;1m269 [0m[2m... [0m      [31m"flake":[0m [31;1mfalse[0m[31m,[0m
[31;1m270 [0m[2m... [0m      [31m"locked":[0m [31;1m{[0m
[31;1m271 [0m[2m... [0m        [31m"lastModified":[0m [31m1788539354,[0m
[31;1m272 [0m[2m... [0m        [31m"narHash":[0m [31m"sha256-FD+e5KQ/7JDVcxT4z0QT9f0JM1pEgt3XULExWZIVWnU=",[0m
[31;1m273 [0m[2m... [0m        [31m"ref":[0m [31m"refs/heads/main",[0m
[31;1m274 [0m[2m... [0m        [31m"rev":[0m [31m"3f9bf79ce7426b1686d07e1845265137c4fd618b",[0m
[31;1m275 [0m[2m... [0m        [31m"shallow":[0m [31;1mtrue[0m[31m,[0m
[31;1m276 [0m[2m... [0m        [31m"type":[0m [31m"git",[0m
[31;1m277 [0m[2m... [0m        [31m"url":[0m [31m"https://github.com/leiserfg/nim2-nimony-lsp"[0m
[31;1m278 [0m[2m... [0m      [31;1m}[0m[31m,[0m
[31;1m279 [0m[2m... [0m      [31m"original":[0m [31;1m{[0m
[31;1m280 [0m[2m... [0m        [31m"shallow":[0m [31;1mtrue[0m[31m,[0m
[31;1m281 [0m[2m... [0m        [31m"type":[0m [31m"git",[0m
[31;1m282 [0m[2m... [0m        [31m"url":[0m [31m"https://github.com/leiserfg/nim2-nimony-lsp"[0m
[31;1m283 [0m[2m... [0m      [31;1m}[0m
[31;1m284 [0m[2m... [0m    [31;1m}[0m[31m,[0m
[2m285 [0m[2m267 [0m    [35m"nimony"[0m: {
[2m286 [0m[2m268 [0m      [35m"flake"[0m: [1mfalse[0m,
[2m287 [0m[2m269 [0m      [35m"locked"[0m: {

[1mflake.lock[0m[2m --- 5/6 --- JSON[0m
[2m341 [0m    },                                                                     [2m323 [0m    },
[2m342 [0m    [35m"nixpkgs-unstable"[0m: {                                                  [2m324 [0m    [35m"nixpkgs-unstable"[0m: {
[2m343 [0m      [35m"locked"[0m: {                                                          [2m325 [0m      [35m"locked"[0m: {
[31;1m344 [0m        [35m"lastModified"[0m: [31m1788531059[0m,                                        [32;1m326 [0m        [35m"lastModified"[0m: [32m1788614874[0m,
[31;1m345 [0m        [35m"narHash"[0m: [31m"sha256-hLD4l3QOGBQhkVp3mQ2lJ/YbEi99qUgKapb40KovZ88="[0m,  [32;1m327 [0m        [35m"narHash"[0m: [32m"sha256-7QYjT2vHLuX9Z1pdxHXDKCbh1CR3D/2rywB9Tx0MPRg="[0m,
[2m346 [0m        [35m"ref"[0m: [35m"nixos-unstable"[0m,                                           [2m328 [0m        [35m"ref"[0m: [35m"nixos-unstable"[0m,
[31;1m347 [0m        [35m"rev"[0m: [31m"801bef6abd86b91e51083066b83fb354a11fc640"[0m,                 [32;1m329 [0m        [35m"rev"[0m: [32m"c043004d1c6985732bcc1cbc5a9c9aecbbb4e0f0"[0m,
[2m348 [0m        [35m"shallow"[0m: [1mtrue[0m,                                                   [2m330 [0m        [35m"shallow"[0m: [1mtrue[0m,
[2m349 [0m        [35m"type"[0m: [35m"git"[0m,                                                     [2m331 [0m        [35m"type"[0m: [35m"git"[0m,
[2m350 [0m        [35m"url"[0m: [35m"https://github.com/NixOS/nixpkgs"[0m                          [2m332 [0m        [35m"url"[0m: [35m"https://github.com/NixOS/nixpkgs"[0m

[1mflake.lock[0m[2m --- 6/6 --- JSON[0m
[2m358 [0m    },                                                                     [2m340 [0m    },
[2m359 [0m    [35m"nixpkgs_2"[0m: {                                                         [2m341 [0m    [35m"nixpkgs_2"[0m: {
[2m360 [0m      [35m"locked"[0m: {                                                          [2m342 [0m      [35m"locked"[0m: {
[31;1m361 [0m        [35m"lastModified"[0m: [31m1788531059[0m,                                        [32;1m343 [0m        [35m"lastModified"[0m: [32m1788614874[0m,
[31;1m362 [0m        [35m"narHash"[0m: [31m"sha256-hLD4l3QOGBQhkVp3mQ2lJ/YbEi99qUgKapb40KovZ88="[0m,  [32;1m344 [0m        [35m"narHash"[0m: [32m"sha256-7QYjT2vHLuX9Z1pdxHXDKCbh1CR3D/2rywB9Tx0MPRg="[0m,
[2m363 [0m        [35m"ref"[0m: [35m"nixos-unstable"[0m,                                           [2m345 [0m        [35m"ref"[0m: [35m"nixos-unstable"[0m,
[31;1m364 [0m        [35m"rev"[0m: [31m"801bef6abd86b91e51083066b83fb354a11fc640"[0m,                 [32;1m346 [0m        [35m"rev"[0m: [32m"c043004d1c6985732bcc1cbc5a9c9aecbbb4e0f0"[0m,
[2m365 [0m        [35m"shallow"[0m: [1mtrue[0m,                                                   [2m347 [0m        [35m"shallow"[0m: [1mtrue[0m,
[2m366 [0m        [35m"type"[0m: [35m"git"[0m,                                                     [2m348 [0m        [35m"type"[0m: [35m"git"[0m,
[2m367 [0m        [35m"url"[0m: [35m"https://github.com/NixOS/nixpkgs"[0m                          [2m349 [0m        [35m"url"[0m: [35m"https://github.com/NixOS/nixpkgs"[0m

