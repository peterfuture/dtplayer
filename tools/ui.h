#ifndef UI_H
#define UI_H

#include "dt_player.h"

typedef enum{
    EVENT_INVALID = -1,
    EVENT_NONE,
    EVENT_PAUSE,
    EVENT_RESUME,
    EVENT_STOP,
    EVENT_SEEK,
    EVENT_RESIZE,
}player_event_t;

player_event_t get_event (args_t *arg,ply_ctx_t *ctx);
int ui_init();
int ui_get_orig_size(int *w, int *h);
int ui_get_max_size(int *w, int *h);
int ui_stop();
int ui_window_resize(int w, int h);
#endif
