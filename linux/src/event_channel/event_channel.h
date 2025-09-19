#pragma once

#include <flutter_linux/flutter_linux.h>

#define _FL_WM_EVENT_CHANNEL_NAME "fl_linux_window_manager/events"

namespace EventChannel
{
    static FlEventChannel *event_channel;
}

FlMethodErrorResponse *event_channel_on_listen(FlEventChannel *channel, FlValue *args, gpointer user_data);
FlMethodErrorResponse *event_channel_on_cancel(FlEventChannel *channel, gpointer user_data);

void event_channel_send_signal();