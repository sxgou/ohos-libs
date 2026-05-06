/* musl_stubs.c
 * Stub implementations for musl libc functions absent from HarmonyOS.
 * Used as a link-time fallback so R and its packages can link.
 */
typedef struct backtrace_state backtrace_state;
typedef unsigned long long uint64_t;

/* backtrace support — OHOS has no libexecinfo */
backtrace_state *backtrace_create_state(const char *filename, int threaded,
    int (*error_callback)(void *, const char *, int, void *),
    void *data) { return (void *)0; }
void backtrace_simple(struct backtrace_state *state, int skip,
    int (*callback)(void *, unsigned long, void *),
    int (*error_callback)(void *, const char *, int, void *),
    void *data) {}
int backtrace_full(struct backtrace_state *state, int skip,
    int (*callback)(void *, unsigned long, const char *, int, void *),
    int (*error_callback)(void *, const char *, int, void *),
    void *data) { return 0; }
int backtrace_close(struct backtrace_state *state) { return 0; }

/* stub for __exidx_end/start (ARM EHABI) */
void *__exidx_start = 0;
void *__exidx_end = 0;

/* stub for dl_iterate_phdr on older OHOS */
struct dl_phdr_info;
int dl_iterate_phdr(int (*callback)(struct dl_phdr_info *, unsigned long, void *), void *data) { return 0; }
