# Free Art Resource Pack Manifest

本目录收集了可直接下载的免费资源包，并按“已下载”和“待下载”分开记录。已下载资源保留原始压缩包，便于追踪来源、重新导入和核对许可证。

## 已下载并随项目打包

| 资源包 | 用途 | 许可证 | 来源 |
|---|---|---|---|
| `kenney_city-kit-roads.zip` | 城市道路、桥梁、路牌、交通设施 | CC0 | https://kenney.nl/assets/city-kit-roads |
| `kenney_nature-kit.zip` | 树木、植被、岩石和自然装饰 | CC0 | https://kenney.nl/assets/nature-kit |
| `kenney_ui-pack.zip` | HUD、按钮、图标和界面装饰 | CC0 | https://kenney.nl/assets/ui-pack |
| `kenney_particle-pack.zip` | 粒子、烟雾、光晕和天气特效纹理 | CC0 | https://kenney.nl/assets/particle-pack |
| `3DBus_by_ajanhallinta.zip` | 公交车交通模型 | CC0 | https://opengameart.org/content/3d-bus |

## 推荐下载入口（尚未默认打包）

| 资源 | 用途 | 许可证 | 体积/风险 | 来源 |
|---|---|---|---|---|
| Kenney Car Kit | 小汽车、卡车、厢式车 | CC0 | 需要从官方 itch.io 页面领取，下载入口可能需要页面交互 | https://kenney-assets.itch.io/car-kit |
| Kenney Commercial City Kit | 城市商业建筑 | CC0 | 需按需下载 | https://kenney.nl/assets/city-kit-commercial |
| Kenney Industrial City Kit | 工业建筑、仓库和能源设施 | CC0 | 需按需下载 | https://kenney.nl/assets/city-kit-industrial |
| Quaternius Ultimate Nature | 150 个自然模型 | CC0 | FBX/OBJ/Blend，需要优化和转换 | https://quaternius.com/packs/ultimatenature.html |
| Quaternius Ultimate Stylized Nature | 风格化树木、植物和岩石 | CC0 | 需要制作 LOD | https://quaternius.com/packs/ultimatestylizednature.html |
| Quaternius Modular Street | 模块化街道 | CC0 | 需 Blender 转成 GLB 并重做碰撞体 | https://quaternius.itch.io/lowpoly-modular-street |
| OpenGameArt Traffic Road Assets | 路障、路灯、消防栓和道路设施 | CC0 | 约 53.8 MB | https://opengameart.org/content/traffic-road-assets |
| Poly Haven Nature | 高质量树木、岩石和自然模型 | CC0 | 可能包含高面数和 4K/8K 贴图 | https://polyhaven.com/models/nature |
| ambientCG | 草地、柏油、砂石、冰雪和地面 PBR 材质 | CC0 | 需按 1K/2K 下载，避免移动端使用 4K/8K | https://ambientcg.com/ |
| Poly Haven Snow 01 | 雪地和车辙 PBR 材质 | CC0 | 原始 4K 包较大，应使用 1K/2K | https://polyhaven.com/a/snow_01 |
| Kenney Weather Icons | 晴、雨、雪和雷暴 HUD 图标 | CC0 | 100×100，适合小尺寸 UI | https://opengameart.org/content/weather-icons |
| Kenney Particle Pack Godot | Godot 粒子包适配版 | CC0 | 与已下载上游粒子包二选一 | https://godotengine.org/asset-library/asset/783 |

## 处理规则

1. 原始 ZIP 不直接作为运行时资源加载；导入前先选择需要的模型和贴图。
2. 3D 模型需要检查比例、原点、轴向、法线、材质槽、贴图路径和碰撞体。
3. Android 版本优先使用 GLB、1K 贴图、共享材质和 LOD。
4. 每个外部包的原始许可证文件和官方下载页面必须保留在项目中。
5. CC0 只解决版权许可，不自动解决第三方商标、品牌标志、隐私权或其他非版权权利。
6. 未下载资源列入清单，是为了保证资产来源齐全；只有经过实际导入和性能测试后才进入运行时场景。

## 当前状态

本次已下载约 29 MB 的轻量资源包，包含道路、自然、UI、粒子和公交车。由于 Kenney Car Kit 的 itch.io 领取链接返回过期状态，本次没有伪造下载文件；车辆资源仍保留官方页面，后续可通过浏览器页面重新领取。

## 本轮新增并已下载

以下资源已经放入 `assets/free_source_packs/optional/`，并解压到 `assets/free_source_import/optional/`：

| 资源包 | 主要用途 | 许可证 | 备注 |
|---|---|---|---|
| `kenney_city-kit-commercial.zip` | 商业建筑和城市街区 | CC0 | 约 4 MB |
| `kenney_city-kit-industrial.zip` | 工厂、仓库和工业区 | CC0 | 约 4.9 MB |
| `traffic_road_assets.zip` | 路障、交通设施、路灯和道路小物 | CC0 | 约 52 MB |
| `Weather_Icon_Set.zip` | 晴、雨、雪和雷暴 UI 图标 | CC0 | 约 66 KB |
| `ground-grass-road-floor.zip` | 城市地面、草地、道路、鹅卵石和雪地纹理 | CC0 | 约 120 MB，Android 使用前应筛选和压缩 |

本轮新增原始包约 181 MB，解压后约 328 MB，包含约 785 个文件。它们作为完整资源库随项目保存，但不会自动全部加载到运行时，以免 Android 包体和显存超出预算。

## 仍保留官方入口的资源

Quaternius 自然包、Quaternius 风格化自然包、Quaternius 模块化街道、Poly Haven Nature、ambientCG 和 Poly Haven Snow 01 的官方页面及授权信息已经收录，但由于下载接口需要页面交互或按单个材质选择，未伪造直链文件。入口见上方“推荐下载入口”表格。
