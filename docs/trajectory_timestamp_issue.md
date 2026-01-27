# 轨迹时间戳问题与暂停调试解决方案

## 问题描述

在 `b_traj_node.cpp` 中添加暂停代码查看全局路径时，按回车继续后，飞机会瞬间跳到目的地而不是正常飞行。

## 问题原因分析

### 1. 轨迹时间戳的生成位置

在 `b_traj_node.cpp:1364` 行，`getBezierTraj()` 函数中：

```cpp
traj.header.stamp = _odom.header.stamp;  // 使用里程计的旧时间戳
_start_time = traj.header.stamp;
```

这个时间戳来自于最近一次接收到的里程计消息的时间。

### 2. 暂停期间发生了什么

当在路径规划后添加暂停代码（例如在第 1001-1006 行）：

```cpp
// Debug 在生成路径后立刻
ROS_WARN("Global path generated and visualized! Press ENTER to continue...");
std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
std::cin.get();
```

暂停期间：
- **ROS 系统时间继续流逝**（假设暂停了 10 秒）
- 轨迹还未生成，时间戳仍是暂停前的 `_odom.header.stamp`
- 用户在 RViz 中查看生成的路径

### 3. 按回车继续后的问题

1. 程序继续执行，生成轨迹优化结果
2. 在 1055 行调用 `_traj = getBezierTraj()`，生成的轨迹时间戳是 10 秒前的旧时间
3. 轨迹发布到 `_traj_pub.publish(_traj)`
4. `b_traj_server` 接收到轨迹后：
   - 检查轨迹起始时间：`traj.header.stamp`（10 秒前）
   - 当前时间：`ros::Time::now()`（现在）
   - 计算时间差：`dt = now - start_time = 10秒`
   - 根据 `dt` 查询轨迹在 10 秒后的位置
   - **由于轨迹总时长可能只有 5-8 秒，10 秒已经超过终点，直接跳到终点**

### 4. 核心问题

**轨迹的时间戳是"过去"的时间，而执行器认为应该执行"未来"对应的位置。**

## 解决方案

### 修改位置

在 `b_traj_node.cpp` 第 1055-1056 行（轨迹发布前）：

```cpp
// 原代码
_traj = getBezierTraj();
_traj_pub.publish(_traj);
```

### 修改为

```cpp
_traj = getBezierTraj();
// 更新时间戳为当前时间（避免暂停导致时间戳过期）
_traj.header.stamp = ros::Time::now();
_start_time = _traj.header.stamp;
_traj_pub.publish(_traj);
```

### 解释

- `ros::Time::now()`：获取当前 ROS 系统时间
- `_traj.header.stamp = ros::Time::now()`：将轨迹起始时间设置为"现在"
- `_start_time = _traj.header.stamp`：同步更新内部记录的起始时间变量
- 这样无论暂停多久，轨迹都会从按下回车的那一刻开始执行

## 编译与测试

```bash
cd ~/leosNuc15/02_project/btraj_note_2025-08/catkin_ws
catkin_make
source devel/setup.bash
roslaunch bezier_planer simulation.launch
```

## 学习要点

### ROS 时间系统

1. **消息时间戳**：`msg.header.stamp` 记录消息产生的时间
2. **系统时间**：`ros::Time::now()` 获取当前时间
3. **时间差计算**：轨迹执行器通过 `当前时间 - 起始时间` 确定应该执行轨迹的哪个位置

### 调试技巧

- 在关键节点添加暂停时，注意时间相关的变量
- 如果涉及时间戳的数据流，暂停后需要重新同步时间
- 类似问题还可能出现在：
  - 录制的 rosbag 回放
  - 仿真时间 `/use_sim_time`
  - 多传感器时间同步

### 代码阅读收获

1. **数据流追踪**：从 `getBezierTraj()` → `_traj_pub.publish()` → `b_traj_server` 接收
2. **时间戳传递**：`_odom.header.stamp` → `traj.header.stamp` → 执行器时间计算
3. **调试方法**：添加暂停点观察中间结果，但需要考虑副作用

## 相关文件

- `catkin_ws/src/Btraj/src/b_traj_node.cpp:1340-1380`：`getBezierTraj()` 函数
- `catkin_ws/src/Btraj/src/b_traj_node.cpp:1055-1058`：轨迹发布位置
- `catkin_ws/src/Btraj/src/traj_server.cpp`：轨迹执行节点（接收并执行轨迹）

## 日期

2025-12-17
