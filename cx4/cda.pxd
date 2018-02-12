# Cython wrapper for cxv4 cda
# by Fedor Emanov

from misc_types cimport *
from cx_common_types cimport *
from cx cimport cxdtype_t, cx_time_t, rflags_t


cdef extern from "cda.h" nogil:
    enum:
        CDA_PATH_MAX

    ctypedef CxDataRef_t cda_dataref_t
    enum:
        CDA_DATAREF_ERROR
        CDA_DATAREF_NONE

    ctypedef int cda_context_t
    enum:
        CDA_CONTEXT_ERROR

    ctypedef int cda_varparm_t
    enum:
        CDA_VARPARM_ERROR

    enum:
        CDA_CONTEXT_OPT_NONE
        CDA_CONTEXT_OPT_NO_OTHEROP
        CDA_CONTEXT_OPT_IGN_UPDATE

    enum:
        CDA_DATAREF_OPT_NONE
        CDA_DATAREF_OPT_PRIVATE
        CDA_DATAREF_OPT_NO_RD_CONV
        CDA_DATAREF_OPT_SHY
        CDA_DATAREF_OPT_FIND_ONLY
        CDA_DATAREF_OPT_ON_UPDATE
        CDA_DATAREF_OPT_rsrvd26
        CDA_DATAREF_OPT_NO_WR_WAIT

    enum:
        CDA_OPT_NONE
        CDA_OPT_IS_W
        CDA_OPT_READONLY
        CDA_OPT_HAS_PARAM
        CDA_OPT_RETVAL_RQD
        CDA_OPT_DO_EXEC
        CDA_OPT_RD_FLA
        CDA_OPT_WR_FLA

    enum:
        CDA_PROCESS_SEVERE_ERR
        CDA_PROCESS_ERR
        CDA_PROCESS_DONE
        CDA_PROCESS_FLAG_BUSY
        CDA_PROCESS_FLAG_REFRESH

    # context events
    enum:
        CDA_CTX_R_CYCLE
        CDA_CTX_EVMASK_CYCLE
        CDA_CTX_R_SRVSTAT
        CDA_CTX_EVMASK_SRVSTAT
        CDA_CTX_R_NEWSRV
        CDA_CTX_EVMASK_NEWSRV

    # ref events
    enum:
       CDA_REF_R_UPDATE
       CDA_REF_EVMASK_UPDATE
       CDA_REF_R_STATCHG
       CDA_REF_EVMASK_STATCHG
       CDA_REF_R_STRSCHG
       CDA_REF_EVMASK_STRSCHG
       CDA_REF_R_RDSCHG
       CDA_REF_EVMASK_RDSCHG
       CDA_REF_R_FRESHCHG
       CDA_REF_EVMASK_FRESHCHG
       CDA_REF_R_QUANTCHG
       CDA_REF_EVMASK_QUANTCHG
       CDA_REF_R_RSLVSTAT
       CDA_REF_EVMASK_RSLVSTAT
       CDA_REF_R_CURVAL
       CDA_REF_EVMASK_CURVAL
       CDA_REF_R_LOCKSTAT
       CDA_REF_EVMASK_LOCKSTAT

    enum:
        CDA_LOCK_RLS
        CDA_LOCK_SET

    ctypedef enum cda_serverstatus_t:
        #/* Note: the statuses are ordered by decreasing of severity,
        #  so that a "most severe of several" status can be easily chosen */
        CDA_SERVERSTATUS_ERROR
        CDA_SERVERSTATUS_DISCONNECTED
        CDA_SERVERSTATUS_FROZEN
        CDA_SERVERSTATUS_ALMOSTREADY
        CDA_SERVERSTATUS_NORMAL

    int cda_ref_is_sensible(cda_dataref_t ref)

    ctypedef void (*cda_context_evproc_t)(int uniq, void *privptr1, cda_context_t cid, int reason, int info_int, void *privptr2)

    ctypedef void (*cda_dataref_evproc_t)(int uniq, void *privptr1, cda_dataref_t ref, int reason, void *info_ptr, void *privptr2)

    # context management
    cda_context_t cda_new_context(int uniq,   void *privptr1,
                               const char           *defpfx, int   flags,
                               const char           *argv0,
                               int                   evmask,
                               cda_context_evproc_t  evproc,
                               void                 *privptr2)
    int cda_del_context(cda_context_t cid)

    int cda_add_context_evproc(cda_context_t cid,
                               int evmask,
                               cda_context_evproc_t evproc,
                               void *privptr2)

    int cda_del_context_evproc(cda_context_t cid,
                               int evmask,
                               cda_context_evproc_t evproc,
                               void *privptr2)

    # Channels management
    cda_dataref_t  cda_add_chan   (cda_context_t         cid,
                               const char           *base,
                               const char           *spec,
                               int                   flags,
                               cxdtype_t             dtype,
                               int                   max_nelems,
                               int                   evmask,
                               cda_dataref_evproc_t  evproc,
                               void                 *privptr2)

    int            cda_del_chan   (cda_dataref_t ref)

    int            cda_add_dataref_evproc(cda_dataref_t         ref,
                                      int                   evmask,
                                      cda_dataref_evproc_t  evproc,
                                      void                 *privptr2)

    int            cda_del_dataref_evproc(cda_dataref_t         ref,
                                      int                   evmask,
                                      cda_dataref_evproc_t  evproc,
                                      void                 *privptr2)

    int            cda_lock_chans (int count, cda_dataref_t *refs,
                               int operation)

    char *cda_combine_base_and_spec(cda_context_t         cid,
                                const char           *base,
                                const char           *spec,
                                char                 *namebuf,
                                size_t                namebuf_size)

    # Simplified channels API

    cda_dataref_t cda_add_dchan(cda_context_t  cid, const char    *name)
    int cda_get_dcval(cda_dataref_t  ref, double *v_p)
    int cda_set_dcval(cda_dataref_t  ref, double  val)

    # Formulae management
    cda_dataref_t cda_add_formula(cda_context_t         cid,
                                  const char           *base,
                                  const char           *spec,
                                  int                   options,
                                  CxKnobParam_t        *params,
                                  int                   num_params,
                                  int                   evmask,
                                  cda_dataref_evproc_t  evproc,
                                  void                 *privptr2)

    cda_dataref_t cda_add_varchan(cda_context_t cid, const char *varname)
    cda_varparm_t cda_add_varparm(cda_context_t cid, const char *varname)

    #/**/
    int cda_src_of_ref           (cda_dataref_t ref, const char **src_p)
    int cda_dtype_of_ref         (cda_dataref_t ref)
    int cda_nelems_of_ref        (cda_dataref_t ref)
    int cda_current_nelems_of_ref(cda_dataref_t ref)
    int cda_fresh_age_of_ref     (cda_dataref_t ref, cx_time_t *fresh_age_p)
    int cda_quant_of_ref         (cda_dataref_t ref, CxAnyVal_t *q_p, cxdtype_t *q_dtype_p)
    int cda_current_dtype_of_ref (cda_dataref_t ref)

    int cda_strings_of_ref       (cda_dataref_t  ref,
                                  char    **ident_p,
                                  char    **label_p,
                                  char    **tip_p,
                                  char    **comment_p,
                                  char    **geoinfo_p,
                                  char    **rsrvd6_p,
                                  char    **units_p,
                                  char    **dpyfmt_p)
    int cda_phys_rds_of_ref      (cda_dataref_t  ref,
                                  int     *phys_count_p,
                                  double  **rds_p)

    int cda_status_of_ref_sid(cda_dataref_t ref)

    int cda_status_srvs_count(cda_context_t  cid)
    cda_serverstatus_t cda_status_of_srv(cda_context_t cid, int nth)
    const char *cda_status_srv_scheme(cda_context_t  cid, int nth)
    const char *cda_status_srv_name(cda_context_t cid, int nth)

    int cda_srvs_of_ref(cda_dataref_t ref, uint8 *conns_u, int conns_u_size)
    int cda_add_server_conn(cda_context_t cid, const char *srvref)

    #/**********************/
    int cda_process_ref(cda_dataref_t ref, int options,
                        double userval,
                        CxKnobParam_t *params, int num_params)
    int cda_get_ref_dval(cda_dataref_t ref,
                         double     *curv_p,
                         CxAnyVal_t *curraw_p, cxdtype_t *curraw_dtype_p,
                         rflags_t *rflags_p, cx_time_t *timestamp_p)

    int cda_rd_convert  (cda_dataref_t ref, double raw, double *result_p)
    int cda_snd_ref_data(cda_dataref_t ref, cxdtype_t dtype, int nelems, void *data)
    int cda_get_ref_data(cda_dataref_t ref, size_t ofs, size_t size, void *buf)
    int cda_get_ref_stat(cda_dataref_t ref, rflags_t *rflags_p, cx_time_t *timestamp_p)
    int cda_acc_ref_data(cda_dataref_t ref, void **buf_p, size_t *size_p)

    int cda_stop_formula(cda_dataref_t ref)


    const char *cda_strserverstatus_short(cda_serverstatus_t status)
    char *cda_last_err()

    void cda_do_cleanup(int uniq)


