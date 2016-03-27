LOCAL_PATH := $(call my-dir)
PROJECT_DIR := $(call my-dir)/../../..
THIRD_PARTY := $(PROJECT_DIR)/third-party
PROJECT_ROOT := $(call my-dir)/../../../../..

include $(CLEAR_VARS)
LOCAL_MODULE := cpp_fast_slam
LOCAL_SHARED_LIBRARIES := tango_client_api
LOCAL_SHARED_LIBRARIES += tango_support_api

LOCAL_C_INCLUDES := $(THIRD_PARTY)/tango/tango-service-sdk/include/ \
                    $(THIRD_PARTY)/tango/tango_gl/include \
                    $(THIRD_PARTY)/glm/

LOCAL_SRC_FILES := jni_interface.cpp \
                   fast_slam_app.cpp \
                   pose_data.cpp \
                   $(THIRD_PARTY)/tango/tango_gl/axis.cc \
                   $(THIRD_PARTY)/tango/tango_gl/camera.cc \
                   $(THIRD_PARTY)/tango/tango_gl/conversions.cc \
                   $(THIRD_PARTY)/tango/tango_gl/drawable_object.cc \
                   $(THIRD_PARTY)/tango/tango_gl/frustum.cc \
                   $(THIRD_PARTY)/tango/tango_gl/gesture_camera.cc \
                   $(THIRD_PARTY)/tango/tango_gl/grid.cc \
                   $(THIRD_PARTY)/tango/tango_gl/line.cc \
                   $(THIRD_PARTY)/tango/tango_gl/shaders.cc \
                   $(THIRD_PARTY)/tango/tango_gl/trace.cc \
                   $(THIRD_PARTY)/tango/tango_gl/transform.cc \
                   $(THIRD_PARTY)/tango/tango_gl/util.cc

LOCAL_LDLIBS := -llog -lGLESv2 -L$(SYSROOT)/usr/lib
include $(BUILD_SHARED_LIBRARY)

$(call import-add-path, $(THIRD_PARTY)/tango)
$(call import-module, tango_client_api)
$(call import-module, tango_support_api)
