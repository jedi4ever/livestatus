class Livestatus::Service < Livestatus::Base
  include Livestatus::CheckType
  include Livestatus::State

  boolean_attributes :accept_passive_checks, :acknowledged,
    :active_checks_enabled, :checks_enabled, :event_handler_enabled,
    :flap_detection_enabled, :has_been_checked, :host_accept_passive_checks,
    :host_acknowledged, :host_active_checks_enabled, :host_checks_enabled,
    :host_event_handler_enabled, :host_flap_detection_enabled,
    :host_has_been_checked, :host_in_check_period,
    :host_in_notification_period, :host_is_executing, :host_is_flapping,
    :host_notifications_enabled, :host_obsess_over_host,
    :host_pending_flex_downtime, :host_process_performance_data,
    :in_check_period, :in_notification_period, :is_executing, :is_flapping,
    :notifications_enabled, :obsess_over_service, :process_performance_data

  time_attributes :host_last_check, :host_last_hard_state,
    :host_last_hard_state_change, :host_last_notification,
    :host_last_state_change, :host_last_time_down, :host_last_time_unreachable,
    :host_last_time_up, :host_next_check, :last_check, :last_hard_state,
    :last_hard_state_change, :last_notification, :last_state_change,
    :last_time_critical, :last_time_ok, :last_time_unknown, :last_time_warning,
    :next_check, :next_notification
end
