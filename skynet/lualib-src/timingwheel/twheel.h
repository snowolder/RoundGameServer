
#ifndef _TWHEEL_H_
#define _TWHEEL_H_

#include <stdint.h>

#define TIME_NEAR_SHIFT 8
#define TIME_NEAR (1 << TIME_NEAR_SHIFT)
#define TIME_NEAR_MASK (TIME_NEAR - 1)
#define TIME_FAR_SHIFT 6
#define TIME_FAR (1 << TIME_FAR_SHIFT)
#define TIME_FAR_MASK (TIME_FAR - 1)
#define MAX_DELAY_TIME (8 * 24 * 3600 * 1000)
#define MAX_TIME (((uint64_t)1 << 32) - MAX_DELAY_TIME - 1)

#define LOCK(X) while (__sync_lock_test_and_set(&((X)->lock),1)) {}
#define UNLOCK(X) __sync_lock_release(&((X)->lock))

typedef void (*TimeFunc) (void* arg);

struct TimeCallback {
    TimeFunc func;
    void* arg;
};

struct TimeNode {
    uint32_t time;
    struct TimeCallback callback;
    struct TimeNode* next;
};

struct TimeList {
    struct TimeNode head;
    struct TimeNode* tail;
};

struct TimeWheel {
    uint32_t lock;
    uint32_t curr_time;
    uint64_t start_time;
    struct TimeList near[TIME_NEAR];
    struct TimeList far[4][TIME_FAR];
};


//user interface

void
timewheel_create(uint64_t t);

void
timewheel_add_time(TimeFunc func, void* arg, uint32_t t);

void
timewheel_update(uint64_t t);

uint64_t
timewheel_gettime();

#endif

