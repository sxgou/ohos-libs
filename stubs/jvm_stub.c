/* JVM stub for HarmonyOS — provides JNI symbols for rJava package */
typedef int jint;
typedef void* JavaVM;
typedef void* JNIEnv;
typedef void* _jclass;
typedef _jclass* jclass;
typedef void* _jobject;
typedef _jobject* jobject;
typedef void* _jstring;
typedef _jstring* jstring;
typedef void* _jmethodID;
typedef _jmethodID* jmethodID;
typedef void* _jfieldID;
typedef _jfieldID* jfieldID;
typedef union { void *ptr; } JavaVMOption;
typedef struct { jint version; jint nOptions; JavaVMOption *options; void *ignoreUnrecognized; } JavaVMInitArgs;
typedef struct { jint version; } JavaVMAttachArgs;

jint JNI_GetDefaultJavaVMInitArgs(void *args) { return -1; }
jint JNI_CreateJavaVM(JavaVM **pvm, void **penv, void *args) { return -1; }
jint JNI_GetCreatedJavaVMs(JavaVM **vmBuf, jint bufLen, jint *nVMs) { *nVMs = 0; return 0; }

/* Minimal stub symbols for JNI function table */
void *_ZN04_JNI10GetVersionEP7JNIEnv_() { return (void*)0; }
void *_ZN04_JNI12DefineClassEP7JNIEnv_PKcP7_jobjectPKhi() { return (void*)0; }
void *_ZN04_JNI10FindClassEP7JNIEnv_PKc() { return (void*)0; }
void *_ZN04_JNI14FromReflectedFieldEP7JNIEnv_P7_jobject() { return (void*)0; }
void *_ZN04_JNI15FromReflectedMethodEP7JNIEnv_P7_jobject() { return (void*)0; }
void *_ZN04_JNI11GetSuperclassEP7JNIEnv_P7_jclass() { return (void*)0; }
void *_ZN04_JNI14IsAssignableFromEP7JNIEnv_P7_jclassS2_() { return (void*)0; }
void *_ZN04_JNI13ThrowNew_ImplEP7JNIEnv_P7_jclassPKc() { return (void*)0; }
void *_ZN04_JNI11Throw_ImplEP7JNIEnv_P7_jthrowable() { return (void*)0; }
void *_ZN04_JNI21ExceptionOccurred_ImplEP7JNIEnv_() { return (void*)0; }
void *_ZN04_JNI22ExceptionDescribe_ImplEP7JNIEnv_() { return (void*)0; }
void *_ZN04_JNI17ExceptionClear_ImplEP7JNIEnv_() { return (void*)0; }
void *_ZN04_JNI14FatalError_ImplEP7JNIEnv_PKc() { return (void*)0; }
void *_ZN04_JNI31PushLocalFrame_ImplEP7JNIEnv_i() { return (void*)0; }
void *_ZN04_JNI30PopLocalFrame_ImplEP7JNIEnv_P7_jobject() { return (void*)0; }
void *_ZN04_JNI17NewGlobalRef_ImplEP7JNIEnv_P7_jobject() { return (void*)0; }
void *_ZN04_JNI20DeleteGlobalRef_ImplEP7JNIEnv_P7_jobject() { return (void*)0; }
void *_ZN04_JNI16DeleteLocalRef_ImplEP7JNIEnv_P7_jobject() { return (void*)0; }
void *_ZN04_JNI12IsSameObject_ImplEP7JNIEnv_P7_jobjectS2_() { return (void*)0; }
void *_ZN04_JNI12AllocObject_ImplEP7JNIEnv_P7_jclass() { return (void*)0; }
void *_ZN04_JNI17GetObjectClass_ImplEP7JNIEnv_P7_jobject() { return (void*)0; }
void *_ZN04_JNI11IsInstanceOfEP7JNIEnv_P7_jobjectP7_jclass() { return (void*)0; }
void *_ZN04_JNI28GetMethodID_ImplEP7JNIEnv_P7_jclassPKcS3_() { return (void*)0; }
void *_ZN04_JNI27GetStaticMethodID_ImplEP7JNIEnv_P7_jclassPKcS3_() { return (void*)0; }
void *_ZN04_JNI11NewStringUTFEP7JNIEnv_PKc() { return (void*)0; }
void *_ZN04_JNI15GetStringUTFLenEP7JNIEnv_P8_jstring() { return (void*)0; }
void *_ZN04_JNI15GetStringUTFCharsEP7JNIEnv_P8_jstringPh() { return (void*)0; }
void *_ZN04_JNI17ReleaseStringUTFCharsEP7JNIEnv_P8_jstringPKc() { return (void*)0; }
void *_ZN04_JNI10NewObject_ImplEP7JNIEnv_P7_jclassP10_jmethodIDz() { return (void*)0; }
