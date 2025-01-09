{...}: {
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };

  boot.kernelParams = [
    "zswap.enabled=1"
  ];

  boot.kernel.sysctl = {
    "vm.watermark_boost_factor" = 0; # watermark boosting can cause unpredictable stalls as seen here: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1861359

    "vm.watermark_scale_factor" = 125; # initiate kswapd much earlier as zram will also apply pressure when requesting memory for
    "vm.swappiness" = 180; # increase swapping aka compression to be able to cache more file page data
    "vm.page-cluster" = 0; # disables page prefetching
  };
}
