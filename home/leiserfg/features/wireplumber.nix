{...}: {
  xdg.configFile."wireplumber/wireplumber.conf.d/50-bluez.conf".text = ''
    monitor.bluez.rules = [
      {
        matches = [
          {
            ## This matches all bluetooth devices.
            device.name = "~bluez_card.*"
          }
        ]
        actions = {
          update-props = {
            bluez5.auto-connect = [ a2dp_sink ]
            bluez5.hw-volume = [ a2dp_sink ]
          }
        }
      }
    ]

    monitor.bluez.properties = {
      bluez5.roles = [ a2dp_sink ]
      bluez5.hfphsp-backend = "none"
    }
  '';
}
