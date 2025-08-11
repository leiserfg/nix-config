Forked from https://github.com/Ly-sec/Noctalia  thanks for all the fish


> ⚠️ **Note:**  
> This setup currently only supports **Hyprland** (for the most part), mostly due to the workspace integration. For anything else you will have to add your own workspace logic.

---

## Features

- **Status Bar:** Modular and informative with smooth animations.
- **Notifications:** Non-intrusive alerts styled to blend naturally.
- **Control Panel:** Centralized system controls for quick adjustments.
- **Connectivity:** Easy management of WiFi and Bluetooth devices.
- **Power Profiles:** Quick toggles for CPU performance.
- **Lockscreen:** Secure and visually consistent lock experience.
- **Tray & Workspaces:** Efficient workspace switching and tray icons.
- **Applauncher:** Stylized Applauncher to fit into the setup.

---

<details>
<summary><strong>Theme Colors</strong></summary>

| Color Role           | Color       | Description                |
| -------------------- | ----------- | -------------------------- |
| Background Primary   | `#0C0D11`   | Deep indigo-black          |
| Background Secondary | `#151720`   | Slightly lifted dark       |
| Background Tertiary  | `#1D202B`   | Soft contrast surface      |
| Surface              | `#1A1C26`   | Material-like base layer   |
| Surface Variant      | `#2A2D3A`   | Lightly elevated           |
| Text Primary         | `#CACEE2`   | Gentle off-white           |
| Text Secondary       | `#B7BBD0`   | Muted lavender-blue        |
| Text Disabled        | `#6B718A`   | Dimmed blue-gray           |
| Accent Primary       | `#A8AEFF`   | Light enchanted lavender   |
| Accent Secondary     | `#9EA0FF`   | Softer lavender hue        |
| Accent Tertiary      | `#8EABFF`   | Warm golden glow           |
| Error                | `#FF6B81`   | Soft rose red              |
| Warning              | `#FFBB66`   | Candlelight amber-orange   |
| Highlight            | `#E3C2FF`   | Bright magical lavender    |
| Ripple Effect        | `#F3DEFF`   | Gentle soft splash         |
| On Accent            | `#1A1A1A`   | Text on accent background  |
| Outline              | `#44485A`   | Subtle bluish-gray line    |
| Shadow               | `#000000B3` | Standard soft black shadow |
| Overlay              | `#11121ACC` | Deep bluish overlay        |

</details>

---

## Installation & Usage

<details>
<summary><strong>Installation</strong></summary>

### Settings:

To make the weather widget, wallpaper manager and record button work you will have to open up the settings menu in to right panel (top right button to open panel) and edit said things accordingly.

</details>

</br>
<details>
<summary><strong>Keybinds</strong></summary>

### Toggle Applauncher:

```
 qs ipc call globalIPC toggleLauncher
```

### Toggle Lockscreen:

```
 qs ipc call globalIPC toggleLock
```

### Toggle Notification Popup:

```
qs ipc call globalIPC toggleNotificationPopup
```

### Toggle Idle Inhibitor:

```
qs ipc call globalIPC toggleIdleInhibitor
```
</details>

---

## Dependencies

You will need to install a few things to get everything working:

- `cava` so the audio visualizer works
- `gpu-screen-recorder` so that the record button works
- `material-symbols` so the icons properly show up
- `swww` to add fancy wallpaper animations (optional)



---

## 💜 Credits

Huge thanks to [**@ferrreo**](https://github.com/ferrreo) and [**@quadbyte**](https://github.com/quadbyte)for all the changes they did and all the cool features they added!

---


#### Special Thanks

Thank you to everyone who supports me and this project 💜!
* Gohma

---

## License

This project is licensed under the terms of the [MIT License](./LICENSE).
