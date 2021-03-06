.PHONY: all clean

#======================================================
#                   VERSION                      
#======================================================

DT_VERSION = v1.0

#======================================================
#                   Rules
#======================================================

#release
%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.c
	@echo CC $@ 
	@$(CC) $(CFLAGS) -shared -fPIC -c -o $@ $< 

%.o: %.cpp
	$(CC) $(CXXFLAGS) -c -o $@ $<

%.o: %.m
	$(CC) $(CFLAGS) -c -o $@ $<

%-rc.o: %.rc
	$(WINDRES) -I. $< -o $@

#debug
%.debug.o: %.S
	$(CC) $(CFLAGS) -g -c -o $@ $<

%.debug.o: %.c
	@echo CC $@ 
	@$(CC) $(CFLAGS) -g -c -o $@ $< 

%.debug.o: %.cpp
	$(CXX) $(CXXFLAGS) -g -c -o $@ $<

%.debug.o: %.m
	$(CC) $(CFLAGS) -g -c -o $@ $<
#==============================================

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
LDFLAGS += -L/usr/local/lib -L/usr/lib -L./

#======================================================
#                   SETTING                      
#======================================================

#extlib
DT_FFMPEG = yes
DT_SDL = no
DT_SDL2 = yes
DT_ALSA = no
DTAP=no

#module
DT_STREAM = yes
DT_DEMUXER = yes
DT_UTIL = yes
DT_AUDIO = yes
DT_VIDEO = yes
DT_SUB = yes
DT_PORT = yes
DT_HOST = yes
DT_PLAYER = yes

#target
DTM_PLAYER = yes
DTM_PROBE = yes
DTM_INFO=
DTM_CONVERT=
DTM_SERVER=

#======================================================
#                   MACRO                      
#======================================================

#plugin control
ifeq ($(DT_FFMPEG),yes)
	DT_FAAD=no
	DT_TSDEMUX=no
	DT_STREAM_CURL=no
	DT_STREAM_FILE=no
	DT_DEMUXER_AAC=no
else
	DT_FAAD=yes
	DT_TSDEMUX=yes
	DT_STREAM_CURL=yes
	DT_STREAM_FILE=yes
	DT_DEMUXER_AAC=yes
endif

DT_CFLAGS += -DENABLE_LINUX=1
ifeq ($(DT_FFMPEG),yes)
	DT_CFLAGS += -DENABLE_FFMPEG=1
endif

#stream
ifeq ($(DT_STREAM_FILE),yes)
DT_CFLAGS += -DENABLE_STREAM_FILE=1
endif

ifeq ($(DT_STREAM_CURL),yes)
DT_CFLAGS += -DENABLE_STREAM_CURL=1
endif
ifeq ($(DT_FFMPEG),yes)
	DT_CFLAGS += -DENABLE_STREAM_FFMPEG=1
endif

#demuxer
ifeq ($(DT_DEMUXER_AAC),yes)
DT_CFLAGS += -DENABLE_DEMUXER_AAC=0
endif

ifeq ($(DT_TSDEMUX),yes)
	DT_CFLAGS += -DENABLE_DEMUXER_TS=1
endif

ifeq ($(DT_FFMPEG),yes)
	DT_CFLAGS += -DENABLE_DEMUXER_FFMPEG=1
endif

#video 
DT_CFLAGS += -DENABLE_VDEC_NULL=0
ifeq ($(DT_FFMPEG),yes)
	DT_CFLAGS += -DENABLE_VDEC_FFMPEG=1
	DT_CFLAGS += -DENABLE_SDEC_FFMPEG=1
	DT_CFLAGS += -DENABLE_VF_FFMPEG=1
endif

#DT_CFLAGS += -DENABLE_VO_NULL=0

ifeq ($(DT_SDL),yes)
	DT_CFLAGS += -DENABLE_VO_SDL=1
endif

ifeq ($(DT_SDL2),yes)
	DT_CFLAGS += -DENABLE_AO_SDL2=1
	DT_CFLAGS += -DENABLE_VO_SDL2=1
	DT_CFLAGS += -DENABLE_SO_SDL2=1
endif

#DT_CFLAGS += -DENABLE_VO_FB=0
#DT_CFLAGS += -DENABLE_VO_OPENGL=0

#audio
#DT_CFLAGS += -DENABLE_ADEC_NULL=0

ifeq ($(DT_FAAD),yes)
	DT_CFLAGS += -DENABLE_ADEC_FAAD=1
endif

ifeq ($(DT_FFMPEG),yes)
	DT_CFLAGS += -DENABLE_ADEC_FFMPEG=1
endif

#DT_CFLAGS += -DENABLE_AO_NULL=0
#DT_CFLAGS += -DENABLE_AO_OSS=0

ifeq ($(DT_SDL),yes)
	DT_CFLAGS += -DENABLE_AO_SDL=1
endif

ifeq ($(DT_ALSA),yes)
	DT_CFLAGS += -DENABLE_AO_ALSA=1
endif

ifeq ($(DTAP),yes)
	DT_CFLAGS += -DENABLE_DTAP=1
	DT_CFLAGS += -I$(DTAP_INCLUDE)/
	LDFLAGS-$(DTAP)    += $(DTAP_TREE)/libdtap.a $(DTAP_TREE)/lvm/libbundle.a $(DTAP_TREE)/lvm/libreverb.a 
endif

#======================================================
#                   FFMPEG                      
#======================================================

ifeq ($(DT_FFMPEG_DIR),)
	DT_FFMPEG_DIR = /usr/local/#default ffmpeg install dir 
endif

#use separate module
FFMPEGPARTS_ALL = libavfilter libavformat libavcodec libswscale libswresample libavutil 
FFMPEGPARTS = $(foreach part, $(FFMPEGPARTS_ALL), $(if $(wildcard $(DT_FFMPEG_DIR)/lib), $(part)))
FFMPEGLIBS  = $(foreach part, $(FFMPEGPARTS), $(DT_FFMPEG_DIR)/lib/$(part).so)

DT_CFLAGS-$(DT_FFMPEG)   += -I$(DT_FFMPEG_DIR)/include
COMMON_LIBS-$(DT_FFMPEG) += $(FFMPEGLIBS)

#======================================================
#                   EXT LIB                      
#======================================================

LDFLAGS-$(DT_SDL)  += -lSDL
LDFLAGS-$(DT_SDL2) += -lSDL2 -Wl,-rpath=/usr/local/lib
LDFLAGS-$(DT_ALSA) += -lasound
LDFLAGS-$(DT_FAAD) += -lfaad

#======================================================
#                   ENV-SETUP 
#======================================================
LDFLAGS += -lpthread -lm 

LDFLAGS     += $(LDFLAGS-yes)
COMMON_LIBS += $(COMMON_LIBS-yes)
DT_CFLAGS   += $(DT_CFLAGS-yes)
CFLAGS      += $(DT_CFLAGS)

#======================================================
#                   SOURCECODE
#======================================================
#dtutils
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_log.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_setting.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_ini.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_time.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_event.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_mem.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_buffer.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_queue.c
SRCS_COMMON-$(DT_UTIL) += dtutils/commander.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_interrupt.c
SRCS_COMMON-$(DT_UTIL) += dtutils/dt_string.c

#dtstream
SRCS_COMMON-$(DT_STREAM)      +=dtstream/dtstream_api.c
SRCS_COMMON-$(DT_STREAM)      +=dtstream/dtstream.c
SRCS_COMMON-$(DT_STREAM)      +=dtstream/stream/stream_file.c
SRCS_COMMON-$(DT_STREAM_CURL) +=dtstream/stream/stream_curl.c
SRCS_COMMON-$(DT_STREAM)      +=dtstream/stream/stream_cache.c
SRCS_COMMON-$(DT_FFMPEG)      +=dtstream/stream/stream_ffmpeg.c

#dtdemuxer
SRCS_COMMON-$(DT_DEMUXER) +=dtdemux/dtdemuxer_api.c
SRCS_COMMON-$(DT_DEMUXER) +=dtdemux/dtdemuxer.c
SRCS_COMMON-$(DT_DEMUXER) +=dtdemux/demuxer/demuxer_aac.c
SRCS_COMMON-$(DT_FFMPEG)  +=dtdemux/demuxer/demuxer_ffmpeg.c
SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/demuxer_ts.c

SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/demuxer_ts.c
SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/ts/cat.c
SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/ts/pat.c
SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/ts/pmt.c
SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/ts/packet.c
SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/ts/stream.c
SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/ts/table.c
SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/ts/pid.c
SRCS_COMMON-$(DT_TSDEMUX) +=dtdemux/demuxer/ts/types.c

#dtaudio
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio_api.c
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio.c
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio_decoder.c
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio_filter.c
SRCS_COMMON-$(DT_AUDIO) += dtaudio/dtaudio_output.c
SRCS_COMMON-$(DT_FAAD)  += dtaudio/audio_decoder/ad_faad.c            # dec
SRCS_COMMON-$(DT_FFMPEG)+= dtaudio/audio_decoder/ad_ffmpeg.c        # dec
SRCS_COMMON-$(DT_ALSA)  += dtaudio/audio_out/ao_alsa.c                # out

#dtvideo
SRCS_COMMON-$(DT_VIDEO) += dtvideo/dtvideo_api.c
SRCS_COMMON-$(DT_VIDEO) += dtvideo/dtvideo.c
SRCS_COMMON-$(DT_VIDEO) += dtvideo/dtvideo_decoder.c
SRCS_COMMON-$(DT_VIDEO) += dtvideo/dtvideo_filter.c
SRCS_COMMON-$(DT_VIDEO) += dtvideo/dtvideo_output.c
SRCS_COMMON-$(DT_FFMPEG) += dtvideo/video_decoder/vd_ffmpeg.c         #dec
SRCS_COMMON-$(DT_FFMPEG) += dtvideo/video_filter/vf_ffmpeg.c          #filter
SRCS_COMMON-$(DT_VIDEO) += dtvideo/video_out/vo_null.c               #default-render
#dtsub
SRCS_COMMON-$(DT_SUB)    += dtsub/dtsub_api.c
SRCS_COMMON-$(DT_SUB)    += dtsub/dtsub.c
SRCS_COMMON-$(DT_SUB)    += dtsub/dtsub_parser.c
SRCS_COMMON-$(DT_SUB)    += dtsub/dtsub_decoder.c
SRCS_COMMON-$(DT_SUB)    += dtsub/dtsub_filter.c
SRCS_COMMON-$(DT_SUB)    += dtsub/dtsub_output.c
SRCS_COMMON-$(DT_FFMPEG) += dtsub/sub_parser/sp_ffmpeg.c
SRCS_COMMON-$(DT_FFMPEG) += dtsub/sub_decoder/sd_ffmpeg.c
SRCS_COMMON-$(DT_SUB)    += dtsub/sub_output/so_null.c
#dtport
SRCS_COMMON-$(DT_PORT) += dtport/dt_packet_queue.c
SRCS_COMMON-$(DT_PORT) += dtport/dtport_api.c
SRCS_COMMON-$(DT_PORT) += dtport/dtport.c

#dthost
SRCS_COMMON-$(DT_HOST) += dthost/dthost_api.c
SRCS_COMMON-$(DT_HOST) += dthost/dthost.c

#dtplayer
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_api.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_host.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_io.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_magic.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_update.c
SRCS_COMMON-$(DT_PLAYER) +=dtplayer/dtplayer_frame.c

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
        dtvideo/video_filter \
        dtvideo/video_out \
        dtsub \
        dtsub/sub_decoder \
        dtsub/sub_output \
        dtsub/sub_parser \
        dthost \
        dtplayer \
		tools   
#header
INCLUDE_DIR += -I$(MAKEROOT)/include
INCLUDE_DIR += -I$(MAKEROOT)/dtutils 
INCLUDE_DIR += -I$(MAKEROOT)/dtstream 
INCLUDE_DIR += -I$(MAKEROOT)/dtdemux 
INCLUDE_DIR += -I$(MAKEROOT)/dtaudio  
INCLUDE_DIR += -I$(MAKEROOT)/dtvideo 
INCLUDE_DIR += -I$(MAKEROOT)/dtsub 
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
PRG-$(DTM_PLAYER)  += dtplayer$(EXESUF)
PRG-$(DTM_PLAYER)  += dtplayer_g$(EXESUF)
ALL_PRG += $(PRG-yes)

PRG-$(DTM_PROBE)  += dtprobe$(EXESUF)
PRG-$(DTM_PROBE)  += dtprobe_g$(EXESUF)
ALL_PRG += $(PRG-yes)


#libdtp.a
DTLIB_DEBUG = libdtp.a
DTLIB_RELEASE = libdtp.so

OBJS_DTLIB_DEP_DEBUG = $(OBJS_COMMON_DEBUG)
OBJS_DTLIB_DEP_RELEASE = $(OBJS_COMMON_RELEASE)
ALL_PRG += $(DTLIB_DEBUG) $(DTLIB_RELEASE)

#dtm player
RENDER-$(DT_SDL2) += tools/ao_sdl2.c tools/vo_sdl2.c tools/so_sdl2.c
RENDER-$(DT_SDL)  += tools/ao_sdl.c tools/gui_sdl.c
SRCS_DTPLAYER     += tools/dt_player.c tools/version.c
SRCS_DTPLAYER     += $(RENDER-yes)

OBJS_DTPLAYER_RELEASE   += $(addsuffix .o, $(basename $(SRCS_DTPLAYER)))
DTM_PLAYER_DEPS_RELEASE  = $(OBJS_DTPLAYER_RELEASE) $(DTLIB_RELEASE)
OBJS_DTPLAYER_DEBUG   += $(addsuffix .debug.o, $(basename $(SRCS_DTPLAYER)))
DTM_PLAYER_DEPS_DEBUG  = $(OBJS_DTPLAYER_DEBUG)  $(DTLIB_DEBUG) $(COMMON_LIBS)

#dtm probe
SRCS_DTPROBE     += tools/dt_probe.c tools/version.c

OBJS_DTPROBE_RELEASE   += $(addsuffix .o, $(basename $(SRCS_DTPROBE)))
DTM_PROBE_DEPS_RELEASE  = $(OBJS_DTPROBE_RELEASE) $(DTLIB_RELEASE)
OBJS_DTPROBE_DEBUG   += $(addsuffix .debug.o, $(basename $(SRCS_DTPROBE)))
DTM_PROBE_DEPS_DEBUG  = $(OBJS_DTPROBE_DEBUG)  $(DTLIB_DEBUG) $(COMMON_LIBS)


all: $(ALL_PRG)
	@echo =====================================================
	@echo build $(ALL_PRG) done
	@echo =====================================================

libdtp.so: $(OBJS_DTLIB_DEP_RELEASE) $(COMMON_LIBS) 
	@$(CC) -shared -fPIC -o $@ $^ $(LDFLAGS)
	#@$(STRIP) $@
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================


libdtp.a: $(OBJS_DTLIB_DEP_DEBUG)
	@$(AR) rcs $@ $^
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================

dtplayer$(EXESUF): $(DTM_PLAYER_DEPS_RELEASE)
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@$(STRIP) $@	
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================

dtplayer_g$(EXESUF): $(DTM_PLAYER_DEPS_DEBUG)
	@$(CC) $(CFLAGS) -g -o $@ $^ $(LDFLAGS)
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================

dtprobe$(EXESUF): $(DTM_PROBE_DEPS_RELEASE)
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@$(STRIP) $@	
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================


dtprobe_g$(EXESUF): $(DTM_PROBE_DEPS_DEBUG)
	@$(CC) $(CFLAGS) -g -o $@ $^ $(LDFLAGS)
	@echo =====================================================
	@echo build $@ done
	@echo =====================================================

clean:
	-rm -f $(call ALL_DIRS,/*.o /*.so /*.a /*.d /*.a /*.ho /*~ /*.exe)
