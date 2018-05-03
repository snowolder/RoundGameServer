
#include "twheel.h"

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <inttypes.h>

static struct TimeWheel* TW = NULL;

static struct TimeNode*
timelist_clear(struct TimeList* l){
    struct TimeNode* ret = (l -> head).next;
    (l -> head).next = 0;
    l -> tail = &(l -> head);
    return ret;
}

static void
timelist_add(struct TimeList* l, struct TimeNode* n){
    (l -> tail) -> next = n;
    n -> next = 0;
    l -> tail = n;
}

static void
timewheel_add_node(struct TimeNode* node){
    uint32_t curr_time = TW -> curr_time;
    uint32_t delay_time = node -> time;

    //judge time zone to near-far put
    if ((delay_time|TIME_NEAR_MASK) == (curr_time|TIME_NEAR_MASK)){
        timelist_add(&TW -> near[(delay_time&TIME_NEAR_MASK)], node);
    }else{
        uint32_t t1 = curr_time >> TIME_NEAR_SHIFT;
        uint32_t t2 = delay_time >> TIME_NEAR_SHIFT;
        uint32_t i;
        for(i = 0; i < 4; i++){
            if ((t1 | TIME_FAR_MASK) == (t2 | TIME_FAR_MASK)){
                break;
            }
            t1 >>= TIME_FAR_SHIFT;
            t2 >>= TIME_FAR_SHIFT;
        }
        timelist_add(&TW -> far[i][(t2 & TIME_FAR_MASK)], node);
    }
}

static void
timewheel_shift(){
    LOCK(TW);

    TW -> curr_time ++;
    assert(TW -> curr_time <= MAX_TIME);
    
    uint32_t t = TW -> curr_time;
    if (!(t & TIME_NEAR_MASK)){
        t >>= TIME_NEAR_SHIFT;
        uint32_t level = 0;
        while(t){
            if (t & TIME_FAR_MASK){
                struct TimeNode* next = timelist_clear(&(TW -> far[level][(t&TIME_FAR_MASK)]));
                while(next){
                    struct TimeNode* temp = next -> next;
                    timewheel_add_node(next);
                    next = temp;
                }

                break;
            }
            t >>= TIME_FAR_SHIFT;
            level ++;
        }
    }

    UNLOCK(TW);
}

static void
timewheel_execute(){
    LOCK(TW);
    struct TimeNode* next = timelist_clear(&(TW -> near[(TW -> curr_time & TIME_NEAR_MASK)]));
    UNLOCK(TW);

    while(next){
        if ((next -> callback).func) {
            (next -> callback).func((next -> callback).arg);
        }
        struct TimeNode* temp = next;
        next = next -> next;
        free(temp);
        temp = NULL;
    }
}

void
timewheel_create(uint64_t t){
    TW = malloc(sizeof(*TW));
    memset(TW, 0, sizeof(*TW));
    TW -> start_time = t;
    TW -> curr_time = 0;
    TW -> lock = 0;

    //clear & init time list
    uint32_t i, j;
    for(i = 0; i < TIME_NEAR; i++){
        timelist_clear(&TW -> near[i]);
    }

    for(i = 0; i < 4; i++){
        for(j = 0; j < TIME_FAR; j++){
            timelist_clear(&TW -> far[i][j]);
        }
    }
}

void
timewheel_add_time(TimeFunc func, void* arg, uint32_t t){
    LOCK(TW);

    assert(t <= MAX_DELAY_TIME);
    assert(t > 0);
    uint32_t curr_time = TW -> curr_time;
    uint32_t delay_time = curr_time + t;

    struct TimeNode* node = malloc(sizeof(*node));
    memset(node, 0, sizeof(*node));
    node -> time = delay_time;
    (node -> callback).func = func;
    (node -> callback).arg = arg;
    node -> next = 0;

    timewheel_add_node(node);

    UNLOCK(TW);
}

void
timewheel_update(uint64_t t){
    assert(t >= TW -> start_time);
    uint64_t diff = t - (TW -> start_time + TW -> curr_time);
    assert(diff >= 0);

    if (diff == 0)
        return;

    uint32_t i;
    for (i = 0; i < diff; i++){
        timewheel_shift();
        timewheel_execute();
    }
}

uint64_t
timewheel_gettime(){
    return TW -> start_time + TW -> curr_time;
}

