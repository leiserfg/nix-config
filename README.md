Notes:

* Define the partitions as in ./hosts/common/global/fs.nix
for the luks use

```sh
sudo cryptsetup config /dev/nvme0n1p3 --label luks-partition
```

* Do `nix-shell` before installing the stuff so you get access to the tools

