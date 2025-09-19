// event_channel.c
#include "event_channel.h"

// Global sink reference to send events
static int isListen = 0;

FlMethodErrorResponse *event_channel_on_listen(FlEventChannel *channel, FlValue *args, gpointer user_data)
{
    isListen = 1;
    return NULL;
}

FlMethodErrorResponse *event_channel_on_cancel(FlEventChannel *channel, gpointer user_data)
{
    isListen = 0;
    return NULL;
}

// Function to send events to Flutter
void event_channel_send_signal()
{
    if (isListen == 0 || EventChannel::event_channel == NULL)
    {
        return; // No active listeners
    }

    g_autoptr(FlValue) event = fl_value_new_string("cleared");
    fl_event_channel_send(EventChannel::event_channel, event, NULL, NULL);
}