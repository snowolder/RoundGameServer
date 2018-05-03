/**
 *
 * Copyright (C) 2015 by David Lin
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALING IN
 * THE SOFTWARE.
 *
 */

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <unistd.h>

#include <lua.h>
#include <lauxlib.h>

#include "twheel.h"

struct Callback {
    uint64_t handle;
    lua_State* L;
};

static void
timer_callback(void* arg) {
    struct Callback* c = (struct Callback*)arg;
    lua_State* L = c -> L;
    uint64_t handle = c -> handle;

    lua_rawgeti(L, LUA_REGISTRYINDEX, handle);
    lua_call(L, 0, 0);
    luaL_unref(L, LUA_REGISTRYINDEX, handle);

    free(c);
}

static int ltimer_create(lua_State* L){
    uint64_t t = luaL_checkinteger(L, 1);
    timewheel_create(t);
    return 0;
}

static int ltimer_update(lua_State* L){
    uint64_t t = luaL_checkinteger(L, 1);
    timewheel_update(t);
    return 0;
}

static int ltimer_gettime(lua_State* L){
    uint64_t t = timewheel_gettime();
    lua_pushinteger(L, t);
    return 1;
}

static int ltimer_add_time(lua_State* L){
    lua_pushvalue(L, 1);
    uint64_t handle = luaL_ref(L, LUA_REGISTRYINDEX);
    uint32_t delay = luaL_checkinteger(L, 2);

    struct Callback* c = malloc(sizeof(struct Callback));
    memset(c, 0, sizeof(struct Callback));
    c -> handle = handle;
    c -> L = L;

    timewheel_add_time(timer_callback, (void*)c, delay);
    return 0;
}

static int ltimer_systime(lua_State* L){
    struct timeval tv;
    gettimeofday(&tv, NULL);
    uint64_t t = (tv.tv_sec*100 + tv.tv_usec/10000);
    lua_pushinteger(L, t);
    return 1;
}

static int ltimer_usleep(lua_State* L) {
	uint64_t n = luaL_checkinteger(L, 1);
	usleep(n);
	return 0;
}


static const struct luaL_Reg ltimer_methods [] = {
    { "ltimer_create" , ltimer_create },
    { "ltimer_update" , ltimer_update },
    { "ltimer_gettime" , ltimer_gettime },
    { "ltimer_add_time" , ltimer_add_time },
    { "ltimer_systime" , ltimer_systime },
    { "ltimer_usleep" , ltimer_usleep },
	{NULL, NULL},
};

int luaopen_ltimer(lua_State* L) {
    luaL_checkversion(L);
    luaL_newlib(L, ltimer_methods);
    return 1;
}

