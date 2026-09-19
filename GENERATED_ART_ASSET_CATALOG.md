# 漫漫货运 — Generated Art Asset Catalog

本轮已直接生成一组与项目统一的动漫 3D 美术资产参考和材质图集。它们用于正式卡车、驾驶舱、交通车辆、五类地标和道路材质的制作校准；当前 Godot 运行时仍以轻量程序化网格和已收集 GLB 为主，以保证 Android 性能。

| 文件 | 用途 | 接入阶段 |
|---|---|---|
| `art/generated_player_truck_exterior.png` | 正式玩家卡车外观、前脸、挂车、轮胎和灯具的建模基准 | 玩家卡车替换与 LOD 制作 |
| `art/generated_cockpit_interior.png` | 座椅、方向盘、仪表板、导航、后视镜和雨刮器的内饰基准 | 当前程序化驾驶舱精修 |
| `art/generated_biome_landmark_atlas.png` | 城市、乡村、森林、雪山、平原五类地标基准 | 流式区段地标替换 |
| `art/generated_road_material_atlas.png` | 干燥、湿润、修补、浅雪、深雪和乡村泥土路面材质基准 | 道路材质统一 |
| `art/generated_vehicle_detail_atlas.png` | 六类交通车外观、灯具、轮胎、后视镜和警示图标基准 | 交通车辆变体精修 |
| `art/generated_assets.sha256` | 生成文件校验值 | 资源交付追踪 |

## 使用规则

这些 PNG 是视觉制作资产和材质校准图，不是假装成已经完成的 3D 网格。正式运行时需要将卡车和地标按这些基准制作成 GLB/TS​​CN，并继续经过减面、LOD、碰撞和 Android 画质档测试。已有程序化版本不会被删除，作为资源缺失时的安全后备。

## 统一风格参数

使用深蓝紫轮廓、偏蓝紫阴影、暖白/淡黄色高光、低镜面反射、清晰的大色块和适度细节。玩家卡车和驾驶舱优先使用 1K～2K 贴图，普通交通和远景资源优先使用 512～1K 贴图。
