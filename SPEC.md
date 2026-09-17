# Spec: Anime Haul — Alpine Run 3D

## Objective
制作一个可导入 Godot 4 并导出 Android 的 3D 卡车驾驶原型。它借鉴长途卡车模拟游戏的核心循环：接单、驾驶、避让交通、消耗燃油、按路线送货并获得报酬；美术采用统一的动漫低多边形 3D 风格，音效保持写实感。

## 3D Architecture
主场景为 Node3D。道路、车道线、山脉、树木、玩家卡车和交通车辆均由 MeshInstance3D 程序化生成。DirectionalLight3D、WorldEnvironment 和第三人称 Camera3D 负责照明、天空和跟随镜头。使用 Compatibility 渲染器以适配安卓原型设备。

## Android Controls
HUD 使用 CanvasLayer 和 Button 控件。左下角按钮绑定 `steer_left` 与 `steer_right`；右下角按钮绑定 `accelerate` 与 `brake`；右上角按钮暂停/恢复游戏。键盘映射只作为开发测试备用，不是 Android 运行前提。

## Success Criteria
1. 运行主场景后呈现可移动的 3D 高山道路。
2. 玩家驾驶的 3D 卡车由车厢、驾驶室、挡风玻璃、车轮、轮毂和车灯组成。
3. 3D 交通车辆存在碰撞反馈并能循环出现在道路上。
4. 第三人称相机跟随卡车并平滑转向。
5. 移动端触控按钮可独立完成加速、刹车、左右转向与暂停。
6. 路线、燃油、损伤、金钱和货运合同会更新。
7. 发动机音频在启动时播放，刹车时播放气刹音效。
8. 卡车沿连续路线依次经过城市、乡村、深山老林、山区雪岭和开阔平原，HUD 显示当前场景名称。

## Commands
- Godot editor: import `/home/ubuntu/truck-anime-godot/project.godot` and run.
- Audio regeneration: `python3 docs/make_audio.py`.
- Optional Godot validation: `godot --headless --path . --editor --quit`.

## Known Limitation
当前沙箱没有安装 Godot，因此无法在本环境中启动编辑器或导出 APK；项目文件已经按 Godot 4 结构写入，需在本地 Godot 环境中完成最终设备测试。
