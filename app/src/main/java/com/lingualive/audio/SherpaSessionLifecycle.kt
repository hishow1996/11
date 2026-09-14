package com.lingualive.audio
class SherpaSessionLifecycle { private var active=false; fun begin(){check(!active);active=true}; fun end(){active=false}; fun isActive()=active }