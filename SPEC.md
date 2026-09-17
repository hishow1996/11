# Spec: Anime Haul — Alpine Run

## Objective
制作一个可导入 Godot 4 并导出 Android 的单人卡车驾驶原型。它借鉴长途卡车模拟游戏的核心循环：接单、驾驶、避让交通、消耗燃油、按路线送货并获得报酬；美术采用统一的动漫厚描边与赛璐璐色块，车辆和场景保持一致。音效不采用卡通音色，而是使用低频柴油机、机械谐波和气刹噪声构成的写实感循环。

## Tech Stack
Godot 4.x, GDScript, Node2D/CanvasItem 绘制，Android touch controls，16:9 viewport with canvas stretch。

## Commands
- Run in editor: open `/home/ubuntu/truck-anime-godot/project.godot` and press Play.
- Generate audio: `python3 docs/make_audio.py`.
- Optional headless validation when Godot is installed: `godot --headless --path . --editor --quit`.

## Project Structure
- `scenes/Main.tscn`: single entry scene.
- `scripts/main.gd`: world rendering, driving loop, contracts, HUD and touch controls.
- `art/truck.svg`: editable vector reference asset.
- `audio/`: generated WAV audio assets.
- `docs/`: reproducible audio generation and implementation notes.

## Controls
W/↑ accelerate; S/↓ brake; A/← steer left; D/→ steer right; Android on-screen buttons mirror these actions.

## Success Criteria
1. Launches into a visible alpine road scene with anime-style mountains, road, truck, traffic and HUD.
2. Truck speed, steering, fuel, distance, damage and money update during play.
3. Delivery completes at route distance, credits €640 and starts a new contract.
4. Touch buttons work without keyboard input.
5. Engine loop starts on launch; air-brake sound plays while braking.
6. Project contains no external service dependency and is ready for Android export configuration.

## Boundaries
Always: keep the visual language consistent; keep audio assets local; test the playable loop after changes.
Ask first: adding multiplayer, accounts, ads, cloud saves, or paid third-party assets.
Never: include secrets, copyrighted branded truck logos, or claim it is a full ETS2 replacement.

## Open Questions
Final game title, target Android aspect ratios, licensing of any future 3D assets, and whether the player wants a full 3D upgrade can be decided in a later iteration.
