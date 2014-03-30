.PHONY: all clean

#======================================================
#                   HEADER                
#======================================================
include config.mk
include rules.mk

#======================================================
#                   ENV 
#======================================================
export MAKEROOT := $(shell pwd)
AR       = ar
CC       = gcc
CXX      = g++
STRIP    = strip 

CFLAGS  += -Wall 
DT_DEBUG = -g

CFLAGS  += -I/usr/include -I/usr/local/include
LDFLAGS += -L/usr/local/lib -L/usr/lib

LDFLAGS += -lpthread -lz -lm -lbz2
LDFLAGS += $(LDFLAGS-yes)

COMMON_LIBS += $(COMMON_LIBS-yes)
DT_CFLAGS   += $(DT_CFLAGS-yes)
CFLAGS      += $(DT_CFLAGS)

#======================================================
#                   SOURCECODE
#======================================================
#dtutils
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_log.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_lock.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_ini.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_time.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_event.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_buffer.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_queue.c

#dtstream
SRCS_COMMON-$(DT_STREAM) +=dtstream/dtstream_api.c
SRCS_COMMON-$(DT_STREAM) +=dtstream/dtstream.c
SRCS_COMMON-$(DT_STREAM) +=dtstream/stream/stream_file.c
SRCS_COMMON-$(DT_FFMPEG) +=dtstream/stream/stream_ffmpeg.c

#dtdemuxer
SRCS_COMMON-$(DT_DEMUXER) +=dtdemux/dtdemuxer_api.c
SRCS_COMMON-$(DT_DEMUXER) +=dtdemux/dtdemuxer.c
SRCS_COMMON-$(DT_DEMUXER) +=dtdemux/demuxer/demuxer_aac.c
SRCS_COMMON-$(DT_FFMPEG) +=dtdemux/demuxer/demuxer_ffmpeg.c

#dtaudio
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio_api.c
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio.c
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio_decoder.c
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio_filter.c
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio_output.c
SRCS_COMMON-$(DT_FAAD) += dtaudio/audio_decoder/dec_audio_faad.c     # dec
SRCS_COMMON-$(DT_FFMPEG) += dtaudio/audio_decoder/dec_audio_ffmpeg.c # dec
SRCS_COMMON-$(DT_ALSA) += dtaudio/audio_out/ao_alsa.c                # out
SRCS_COMMON-$(DT_SDL) += dtaudio/audio_out/ao_sdl.c                  # out
SRCS_COMMON-$(DT_SDL2) += dtaudio/audio_out/ao_sdl2.c                # out

#dtvideo
SRCS_COMMON-$(DT_VIDEO) += dtvideo/dtvideo_api.c
SRCS_COMMON-$(DT_VIDEO) += dtvideo/dtvideo.c
SRCS_COMMON-$(DT_VIDEO) += dtvideo/dtvideo_decoder.c
SRCS_COMMON-$(DT_VIDEO) += dtvideo/dtvideo_output.c
SRCS_COMMON-$(DT_FFMPEG) += dtvideo/video_decoder/dec_video_ffmpeg.c  #dec
SRCS_COMMON-$(DT_SDL) += dtvideo/video_out/vo_sdl.c                   #out
SRCS_COMMON-$(DT_SDL2)+= dtvideo/video_out/vo_sdl2.c                  #out

#dtport
SRCS_COMMON-$(DT_PORT) += dtport/dt_packet_queue.c
SRCS_COMMON-$(DT_PORT) += dtport/dtport_api.c
SRCS_COMMON-$(DT_PORT) += dtport/dtport.c

#dthost
SRCS_COMMON-$(DT_HOST) += dthost/dthost.c
SRCS_COMMON-$(DT_HOST) += dthost/dthost_api.c

#dtplayer
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_api.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_util.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_io.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_update.c

SRCS_COMMON +=$(SRCS_COMMON-yes)
OBJS_COMMON_RELEASE += $(addsuffix .o, $(basename $(SRCS_COMMON)))
OBJS_COMMON_DEBUG += $(addsuffix .debug.o, $(basename $(SRCS_COMMON)))

DIRS =  . \
        dtcommon \
		dtutils \
		dtstream \
		dtstream/stream \
		dtdemux \
		dtdemux/demuxer \
        dtport \
        dtaudio \
        dtaudio/audio_decoder \
        dtaudio/audio_out \
        dtvideo \
        dtvideo/video_decoder \
        dtvideo/video_out \
        dthost \
		dtplayer   
#header
INCLUDE_DIR += -I$(MAKEROOT)/dtutils 
INCLUDE_DIR += -I$(MAKEROOT)/dtstream 
INCLUDE_DIR += -I$(MAKEROOT)/dtdemux 
INCLUDE_DIR += -I$(MAKEROOT)/dtaudio  
INCLUDE_DIR += -I$(MAKEROOT)/dtvideo 
INCLUDE_DIR += -I$(MAKEROOT)/dtport 
INCLUDE_DIR += -I$(MAKEROOT)/dthost 
INCLUDE_DIR += -I$(MAKEROOT)/dtplayer 
CFLAGS      +=   $(INCLUDE_DIR)

ADDSUFFIXES  = $(foreach suf,$(1),$(addsuffix $(suf),$(2)))
ALL_DIRS     = $(call ADDSUFFIXES,$(1),$(DIRS))

#======================================================
#                   TARGET BUILD                      
#======================================================
EXESUF             = .exe 
PRG-$(DTM_PLAYER)  += dtm_player$(EXESUF)
PRG-$(DTM_PLAYER)  += dtm_player_g$(EXESUF)
ALL_PRG += libdtp.a $(PRG-yes)

#libdtp.a
OBJS_DTLIB_DEP = $(OBJS_COMMON_RELEASE) $(COMMON_LIBS)

#dtm player
SRCS_DTPLAYER   += dtm_player.c version.c
OBJS_DTPLAYER_RELEASE   += $(addsuffix .o, $(basename $(SRCS_DTPLAYER)))
DTM_PLAYER_DEPS_RELEASE  = $(OBJS_DTPLAYER_RELEASE)  $(OBJS_COMMON_RELEASE) $(COMMON_LIBS)
OBJS_DTPLAYER_DEBUG   += $(addsuffix .debug.o, $(basename $(SRCS_DTPLAYER)))
DTM_PLAYER_DEPS_DEBUG  = $(OBJS_DTPLAYER_DEBUG)  $(OBJS_COMMON_DEBUG) $(COMMON_LIBS)


all: $(ALL_PRG)
	@echo =====================================================
	@echo build $(ALL_PRG) done
	@echo =====================================================

libdtp.a: $(OBJS_DTLIB_DEP)
	@$(AR) rcs $@ $^
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================

dtm_player2$(EXESUF): $(DTM_PLAYER_DEPS_RELEASE)
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@$(STRIP) $@	
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================

dtm_player$(EXESUF): $(OBJS_DTPLAYER_RELEASE) libdtp.a $(COMMON_LIBS)
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@$(STRIP) $@	
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================

dtm_player_g$(EXESUF): $(OBJS_DTPLAYER_DEBUG) libdtp.a $(COMMON_LIBS)
	@$(CC) $(CFLAGS) -g -o $@ $^ $(LDFLAGS)
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================

clean:
	-rm -f $(call ALL_DIRS,/*.o /*.so /*.a /*.d /*.a /*.ho /*~ /*.exe)
