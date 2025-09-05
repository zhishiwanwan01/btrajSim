--------------------------------------------------------------------------------
Node [/b_traj_server]
Publications: 
 * /b_traj_server/desired_acceleration [visualization_msgs/Marker]
 * /b_traj_server/desired_position [geometry_msgs/PoseStamped]
 * /b_traj_server/desired_velocity [visualization_msgs/Marker]
 * /position_cmd [quadrotor_msgs/PositionCommand]
 * /rosout [rosgraph_msgs/Log]

Subscriptions: 
 * /b_traj_node/trajectory [quadrotor_msgs/PolynomialTrajectory]
 * /odom/fake_odom [nav_msgs/Odometry]

Services: 
 * /b_traj_server/get_loggers
 * /b_traj_server/set_logger_level


contacting node http://btrajSim-Melodic:41741/ ...
Pid: 2324
Connections:
 * topic: /rosout
    * to: /rosout
    * direction: outbound (54161 - 172.20.0.3:46894) [10]
    * transport: TCPROS
 * topic: /position_cmd
    * to: /odom_generator
    * direction: outbound (54161 - 172.20.0.3:46904) [11]
    * transport: TCPROS
 * topic: /b_traj_server/desired_velocity
    * to: /rvizvisualisation
    * direction: outbound (54161 - 172.20.0.3:46910) [17]
    * transport: TCPROS
 * topic: /b_traj_server/desired_acceleration
    * to: /rvizvisualisation
    * direction: outbound (54161 - 172.20.0.3:46908) [16]
    * transport: TCPROS
 * topic: /odom/fake_odom
    * to: /odom_generator (http://btrajSim-Melodic:45997/)
    * direction: inbound (55626 - btrajSim-Melodic:53687) [14]
    * transport: TCPROS
 * topic: /b_traj_node/trajectory
    * to: /b_traj_node (http://btrajSim-Melodic:39675/)
    * direction: inbound (54128 - btrajSim-Melodic:54019) [15]
    * transport: TCPROS

