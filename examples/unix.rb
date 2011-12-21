#!/usr/bin/env ruby

require 'livestatus'
require 'pp'

c = Livestatus::Connection.new({ :uri => "unix:///var/nagios/rw/live"})

c.command("DISABLE_NOTIFICATIONS")

# This complains for missing table_name
# puts c.get("status").inspect

q_host=Livestatus::Host.new({})
hosts=c.get(q_host)

hosts.each do |host|
  pp host.data
end

q_service=Livestatus::Service.new({})
sercives=c.get(q_service)

services.each do |service|
  pp service.data
end

# Sample Host output
# {:flap_detection_enabled=>1,
#  :y_3d=>0.0,
#  :is_executing=>0,
#  :services_with_info=>
#   [["Total Processes", 0, 1, "PROCS OK: 64 processes with STATE = RSZDT"],
#    ["Swap Usage", 2, 1, "SWAP CRITICAL - 100% free (0 MB out of 0 MB)"],
#    ["SSH", 0, 1, "SSH OK - OpenSSH_5.3 (protocol 2.0)"],
#    ["Root Partition",
#     0,
#     1,
#     "DISK OK - free space: / 5762 MB (72% inode=81%):"],
#    ["PING", 0, 1, "PING OK - Packet loss = 0%, RTA = 0.05 ms"],
#    ["HTTP", 2, 1, "Connection refused"],
#    ["Current Users", 0, 1, "USERS OK - 2 users currently logged in"],
#    ["Current Load", 0, 1, "OK - load average: 0.10, 0.04, 0.05"]],
#  :z_3d=>0.0,
#  :modified_attributes_list=>[],
#  :accept_passive_checks=>1,
#  :statusmap_image=>"",
#  :long_plugin_output=>"",
#  :last_check=>1324489049,
#  :max_check_attempts=>10,
#  :check_interval=>5.0,
#  :last_time_down=>0,
#  :childs=>[],
#  :notes_expanded=>"",
#  :check_command=>"check-host-alive",
#  :action_url=>"",
#  :process_performance_data=>1,
#  :custom_variable_names=>[],
#  :latency=>0.109,
#  :next_check=>1324489359,
#  :groups=>["linux-servers"],
#  :state=>0,
#  :last_state_change=>1324485056,
#  :event_handler_enabled=>1,
#  :retry_interval=>1.0,
#  :total_services=>8,
#  :check_period=>"24x7",
#  :in_notification_period=>0,
#  :contacts=>["nagiosadmin"],
#  :services_with_state=>
#   [["Total Processes", 0, 1],
#    ["Swap Usage", 2, 1],
#    ["SSH", 0, 1],
#    ["Root Partition", 0, 1],
#    ["PING", 0, 1],
#    ["HTTP", 2, 1],
#    ["Current Users", 0, 1],
#    ["Current Load", 0, 1]],
#  :icon_image_alt=>"",
#  :modified_attributes=>0,
# :last_state=>0,
# :num_services_hard_warn=>0,
# :pending_flex_downtime=>0,
# :downtimes_with_info=>[],
# :num_services=>8,
# :low_flap_threshold=>0.0,
# :notification_interval=>120.0,
# :notes_url_expanded=>"",
# :percent_state_change=>0.0,
# :high_flap_threshold=>0.0,
# :comments_with_info=>[],
# :in_check_period=>1,
# :alias=>"localhost",
# :last_notification=>0,
# :checks_enabled=>1,
# :num_services_ok=>6,
# :pnpgraph_present=>-1,
# :services=>
#  ["Total Processes",
#   "Swap Usage",
#   "SSH",
#   "Root Partition",
#   "PING",
#   "HTTP",
#   "Current Users",
#   "Current Load"],
# :worst_service_state=>2,
# :check_flapping_recovery_notification=>0,
# :check_freshness=>0,
# :custom_variable_values=>[],
# :obsess_over_host=>1,
# :current_attempt=>1,
# :hard_state=>0,
# :notifications_enabled=>1,
# :num_services_hard_unknown=>0,
# :num_services_hard_crit=>2,
# :state_type=>1,
# :filename=>"",
# :acknowledgement_type=>0,
# :first_notification_delay=>0.0,
# :address=>"127.0.0.1",
# :active_checks_enabled=>1,
# :num_services_warn=>0,
# :last_hard_state_change=>1324485056,
# :num_services_hard_ok=>6,
# :notification_period=>"workhours",
# :num_services_pending=>0,
# :last_time_up=>1324489059,
# :custom_variables=>{},
# :name=>"localhost",
# :check_options=>0,
# :no_more_notifications=>0,
# :icon_image_expanded=>"",
# :current_notification_number=>0,
#  :initial_state=>0,
#  :check_type=>0,
#  :num_services_unknown=>0,
#  :x_3d=>0.0,
#  :plugin_output=>"PING OK - Packet loss = 0%, RTA = 0.05 ms",
#  :is_flapping=>0,
#  :has_been_checked=>1,
#  :notes_url=>"",
#  :comments=>[],
#  :scheduled_downtime_depth=>0,
#  :worst_service_hard_state=>2,
#  :display_name=>"localhost",
#  :num_services_crit=>2,
#  :last_hard_state=>0,
#  :acknowledged=>0,
#  :last_time_unreachable=>0,
#  :execution_time=>4.013375,
#  :contact_groups=>["admins"],
#  :notes=>"",
#  :perf_data=>"rta=0.054000ms;3000.000000;5000.000000;0.000000 pl=0%;80;100;0",
#  :icon_image=>"",
#  :action_url_expanded=>"",
#  :next_notification=>0,
#  :downtimes=>[],
#  :parents=>[]}
