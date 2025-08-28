{ lib, ... }:
{
  # zramSwap = {
  #   enable = true;
  #   algorithm = "zstd";
  #   memoryPercent = 30;
  # };

  # boot.kernelParams = [
  #   "zswap.enabled=1"
  # ];

  systemd.tmpfiles.rules = (
    lib.mapAttrsToList (n: v: "w /sys/module/zswap/parameters/${n}  - - - - ${toString v}") {
      enabled = true;

      # I think with swap, you need speed first and foremost and compression
      # efficiency is secondary. OTOH, in my testing, zstd is able to store
      # the first 3 pages of random files in my closure in 1 page ~40% of
      # the time vs. only ~10% with lz4 although the bulk is 2 pages in
      # either case. I consider zswap as a best-effort speed efficiency
      # boost though, so speed is more important I think.
      compressor = "lz4";

      # AFAIK zsmalloc has memory fragmentation issues because it concatenates
      # compressed pages with no regard for page boundaries. Reading a single
      # page from compressed memory might require reading many pages. z3fold
      # does not have such issues and a 3:1 compression ratio is good enough for
      # me; the same point about me merely considering zswap an efficiency
      # booster applies here.
      zpool = "z3fold";

      # This controls how much of the system RAM may be taken up by swap. On the
      # one hand, you might think one wants this as high as possible but you
      # must consider that at some point you do actually want stuff to be
      # swapped out to disk as zswap is merely a stage between memory and swap
      # that is cheaper than actual swap in terms of performance but still
      # requires memory; memory that is still taken away from file-backed pages.
      # Let's keep the default limit of 20% until I have formed a better opinion
      # on this.
      # max_pool_percent = "20";
    }
  );

  boot.kernel.sysctl = {
    "vm.watermark_boost_factor" = 0; # watermark boosting can cause unpredictable stalls as seen here: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1861359

    "vm.watermark_scale_factor" = 125; # initiate kswapd much earlier as zram will also apply pressure when requesting memory for
    "vm.swappiness" = 180; # increase swapping aka compression to be able to cache more file page data
    "vm.page-cluster" = 0; # disables page prefetching
  };
}
