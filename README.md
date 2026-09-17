# Anime Haul: Alpine Run — 3D Android Prototype

这是一个面向 Android 的 Godot 4 3D 卡车驾驶原型。视觉采用统一的动漫低多边形 3D 风格：赛璐璐色块、温暖色盘、深色轮廓感，以及高山公路、雪山、森林、交通车辆和第三人称跟随镜头。听觉保持写实感，使用本地柴油机循环与气刹音效。

## 开始运行

使用 Godot 4.x 导入 `project.godot`，然后直接运行主场景。主场景已经切换到 `scripts/main_3d.gd`，不再使用旧版 2D 原型脚本。

## Android 控制

当前版本使用更接近真实驾驶的模拟控制：左下角是可拖拽的虚拟方向盘，手指向左/右拖动对应转向，松手后会自动回中；方向盘带 8% 死区和非线性响应，能够减少手指抖动并提高直线行驶精度。右下角是独立的油门和刹车踏板，支持按住、多点触控和上下拖动调整力度，油门与刹车不会互相抢占触点。右上角为暂停。开发测试时仍支持 W/↑ 加速、S/↓ 刹车、A/← 左转、D/→ 右转。

控制脚本位于 `scripts/virtual_controls.gd`，通过 `steering_changed`、`throttle_changed` 和 `brake_changed` 三个信号连接到 3D 卡车。若要适配不同手机比例，优先调整 `_throttle_rect()`、`_brake_rect()` 和 `wheel_center` 的安全边距。

## 游戏循环

驾驶卡车沿高山公路前进，控制变道并避开交通车辆。路线距离、速度、燃油、损伤和收入都会实时更新；抵达目标距离后会完成货运合同并获得 €640，然后自动生成下一条路线。

## 导出 Android

在 Godot 中打开 Project > Export，添加 Android preset，设置包名和签名后导出 APK。建议在真实设备上测试触控按钮尺寸、横屏安全区域和音量。当前项目使用轻量 MeshInstance3D、DirectionalLight3D 与 Compatibility 渲染器，适合先做中低端安卓设备原型。

## 音频

`audio/engine_loop.wav` 是低频柴油脉冲与机械谐波叠加的循环；`audio/air_brake.wav` 是具有攻击/衰减包络的气刹嘶声。它们保留写实听感，与动漫画面形成对比。

## 当前范围

这是一个可玩的 3D 原型，不是完整的商业级欧洲卡车模拟器。后续可以继续加入真实 3D 卡车模型、悬挂物理、车库升级、天气系统、存档、多城市地图、导航和陀螺仪转向。
