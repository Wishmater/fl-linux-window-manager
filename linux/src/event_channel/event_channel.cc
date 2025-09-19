// event_channel.c
#include "event_channel.h"

// Global sink reference to send events
static int isListen = 0;
static FlEventChannel *event_channel = NULL;

void event_channel_init(FlPluginRegistrar *registrar, FlMethodCodec *codec)
{
    event_channel = fl_event_channel_new(fl_plugin_registrar_get_messenger(registrar),
                                         _FL_WM_EVENT_CHANNEL_NAME,
                                         codec);
    fl_event_channel_set_stream_handlers(event_channel,
                                         event_channel_on_listen,
                                         event_channel_on_cancel,
                                         NULL, NULL);
}

extern "C"
{
    FlMethodErrorResponse *event_channel_on_listen(FlEventChannel *channel, FlValue *args, gpointer user_data)
    {
        isListen = 1;
        return NULL;
    }

    FlMethodErrorResponse *event_channel_on_cancel(FlEventChannel *channel, FlValue *args, gpointer user_data)
    {
        isListen = 0;
        return NULL;
    }
}

// Function to send events to Flutter
void event_channel_send_signal()
{
    if (isListen == 0 || event_channel == NULL)
    {
        return; // No active listeners
    }

    g_autoptr(FlValue) event = fl_value_new_string("cleared");
    fl_event_channel_send(event_channel, event, NULL, NULL);
}