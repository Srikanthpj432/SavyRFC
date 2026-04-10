class /SAVY/CL_RFC_READ_SERV_DPC_EXT definition
  public
  inheriting from /SAVY/CL_RFC_READ_SERV_DPC
  create public .

public section.

  methods /IWBEP/IF_V4_DP_ADVANCED~READ_ENTITY_LIST
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS /SAVY/CL_RFC_READ_SERV_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_v4_dp_advanced~read_entity_list.

    DATA: BEGIN OF ls_header.
            INCLUDE TYPE /savy/cl_rfc_read_serv_mpc=>ts_readtable.
    DATA:   readtabledataset    TYPE TABLE OF /savy/cl_rfc_read_serv_mpc=>ts_readtabledata,
            readtablefieldsset  TYPE TABLE OF /savy/cl_rfc_read_serv_mpc=>ts_readtablefields,
            readtableoptionsset TYPE TABLE OF /savy/cl_rfc_read_serv_mpc=>ts_readtableoptions,
          END OF ls_header.

    " Rest of declarations
    DATA: lx_exception TYPE REF TO cx_root.
    DATA: lt_opt_data      TYPE TABLE OF rfc_db_opt,
          lt_fields_data   TYPE TABLE OF rfc_db_fld,
          lt_fm_data       TYPE TABLE OF tab512,
          ls_data          TYPE /savy/cl_rfc_read_serv_mpc=>ts_readtabledata,
          lt_Tabname       TYPE RANGE OF tabname,
          lt_options       TYPE RANGE OF string,
          lt_fields        TYPE RANGE OF string,
          lt_delimiter     TYPE RANGE OF char1,
          lt_nodata        TYPE RANGE OF char1,
          lv_top           TYPE i,
          lv_skip          TYPE i,
          lv_total_count   TYPE i,
          lt_Split_fields  TYPE TABLE OF string,
          lt_Split_options TYPE TABLE OF string.

    DATA: lo_request_info    TYPE REF TO /iwbep/cl_v4_request_info_pro,
          lo_expand_node     TYPE REF TO /iwbep/if_v4_expand_node,
          mo_default_matcher TYPE REF TO if_abap_testdouble_matcher,
          lo_controller      TYPE REF TO if_atd_controller,
          ro_double          TYPE REF TO object,
          lv_objname         TYPE abap_intfname VALUE '/iwbep/if_v4_expand_node',
          ls_done_list       TYPE /iwbep/if_v4_requ_adv_list=>ty_s_todo_process_list,
          ls_Tabname         LIKE LINE OF lt_tabname,
          ls_fields          LIKE LINE OF lt_fields,
          ls_options         LIKE LINE OF lt_options,
          ls_delimiter       LIKE LINE OF lt_delimiter,
          ls_nodata          LIKE LINE OF lt_nodata,
          lv_tabname         TYPE tabname,
          lv_delimiter       TYPE char1,
          lv_nodata          TYPE char1,
          lt_header          LIKE TABLE OF ls_header,
          lo_log             TYPE REF TO /savy/cl_app_log,
          ls_msg             TYPE bal_s_msg,
          lv_char50          TYPE char50,
          lv_rows            TYPE char10.

    CREATE OBJECT lo_log.
    lo_log->gv_object    = '/SAVY/ROOT'.
    lo_log->gv_subobject = '/SAVY/RFC_READ'.

    " Filter Ranges
    TRY.
        CALL METHOD io_request->get_filter_ranges_for_prop
          EXPORTING
            iv_property_path = 'QUERYTABLE'
          IMPORTING
            et_range         = lt_tabname.

        READ TABLE lt_tabname INTO ls_Tabname INDEX 1.
        lv_Tabname = ls_Tabname-low.

      CATCH cx_root.
        CLEAR lt_tabname.
    ENDTRY.

    TRY.
        CALL METHOD io_request->get_filter_ranges_for_prop
          EXPORTING
            iv_property_path = 'FIELDS'
          IMPORTING
            et_range         = lt_fields.

        READ TABLE lt_fields INTO ls_fields INDEX 1.
        SPLIT ls_fields-low AT ',' INTO TABLE lt_split_fields.

        LOOP AT lt_split_fields ASSIGNING FIELD-SYMBOL(<fs_split_fields>).
          APPEND INITIAL LINE TO lt_fields_Data ASSIGNING FIELD-SYMBOL(<fs_fields_data>).
          <fs_fields_data>-fieldname = <fs_split_fields>.
        ENDLOOP.

      CATCH cx_root.
        CLEAR lt_fields.
    ENDTRY.

    TRY.
        CALL METHOD io_request->get_filter_ranges_for_prop
          EXPORTING
            iv_property_path = 'OPTIONS'
          IMPORTING
            et_range         = lt_options.

        READ TABLE lt_options INTO ls_options INDEX 1.
        SPLIT ls_options-low AT ',' INTO TABLE lt_split_options.

        LOOP AT lt_split_options ASSIGNING FIELD-SYMBOL(<fs_split_options>).
          APPEND INITIAL LINE TO lt_opt_Data ASSIGNING FIELD-SYMBOL(<fs_opt_data>).
          <fs_opt_data>-text = <fs_split_options>.
        ENDLOOP.

      CATCH cx_root.
        CLEAR lt_options.
    ENDTRY.

    TRY.
        CALL METHOD io_request->get_filter_ranges_for_prop
          EXPORTING
            iv_property_path = 'DELIMITER'
          IMPORTING
            et_range         = lt_delimiter.

        READ TABLE lt_delimiter INTO ls_delimiter INDEX 1.
        lv_delimiter = ls_delimiter-low.

      CATCH cx_root.
        CLEAR lt_delimiter.
    ENDTRY.

    TRY.
        CALL METHOD io_request->get_filter_ranges_for_prop
          EXPORTING
            iv_property_path = 'NODATA'
          IMPORTING
            et_range         = lt_nodata.

        READ TABLE lt_nodata INTO ls_nodata INDEX 1.
        lv_nodata = ls_nodata-low.

      CATCH cx_root.
        CLEAR lt_nodata.
    ENDTRY.

    " Get paging
    io_request->get_skip( IMPORTING ev_skip = lv_skip ).
    io_request->get_top( IMPORTING ev_top = lv_top ).

    " Log: RFC call initiated
    ls_msg-msgty = 'I'.
    ls_msg-msgid = '/SAVY/RFC_MSGS'.
    ls_msg-msgno = '001'.
    ls_msg-msgv1 = lv_tabname.
    ls_msg-msgv2 = sy-uname.
    ls_msg-msgv3 = sy-datum.
    ls_msg-msgv4 = sy-uzeit.
    lo_log->msg_add_log( im_msg = ls_msg ).

    " Log: Fields requested
    IF ls_fields-low IS NOT INITIAL.
      lv_char50 = ls_fields-low.
      CLEAR ls_msg.
      ls_msg-msgty = 'I'.
      ls_msg-msgid = '/SAVY/MESSAGES'.
      ls_msg-msgno = '008'.
      ls_msg-msgv1 = lv_char50.
      lo_log->msg_add_log( im_msg = ls_msg ).
    ENDIF.

    CALL FUNCTION '/SAVY/RFC_READ_TABLE'
      EXPORTING
        query_table          = lv_tabname
        delimiter            = lv_delimiter
        no_data              = lv_nodata
        rowskips             = lv_skip
        rowcount             = lv_top
      TABLES
        options              = lt_opt_data
        fields               = lt_fields_data
        data                 = lt_fm_data
      EXCEPTIONS
        table_not_available  = 1
        table_without_data   = 2
        option_not_valid     = 3
        field_not_valid      = 4
        not_authorized       = 5
        data_buffer_exceeded = 6
        OTHERS               = 7.
    IF sy-subrc <> 0.
        CLEAR ls_msg.
        ls_msg-msgty = 'E'.
        ls_msg-msgid = '/SAVY/RFC_MSGS'.

        CASE sy-subrc.
          WHEN 1.  "table_not_available
            ls_msg-msgno = '004'.
            ls_msg-msgv1 = lv_tabname.

          WHEN 2.  "table_without_data
            ls_msg-msgno = '005'.
            ls_msg-msgv1 = lv_tabname.
            ls_msg-msgv2 = 'NO DATA'.

          WHEN 3.  "option_not_valid
            ls_msg-msgno = '010'.
            ls_msg-msgv1 = lv_tabname.
            ls_msg-msgv2 = 'INVALID OPTIONS'.

          WHEN 4.  "field_not_valid
            ls_msg-msgno = '006'.
            ls_msg-msgv1 = lv_tabname.
            ls_msg-msgv2 = 'INVALID FIELD'.

          WHEN 5.  "not_authorized
            ls_msg-msgno = '003'.
            ls_msg-msgv1 = lv_tabname.
            ls_msg-msgv2 = sy-uname.

          WHEN 6.  "data_buffer_exceeded
            ls_msg-msgno = '007'.
            ls_msg-msgv1 = lv_tabname.
            ls_msg-msgv2 = 'BUFFER EXCEEDED'.

          WHEN OTHERS.
            ls_msg-msgno = '011'.
            ls_msg-msgv1 = lv_tabname.
            ls_msg-msgv2 = 'UNKNOWN ERROR'.
        ENDCASE.

        lo_log->msg_add_log( im_msg = ls_msg ).
        lo_log->save_to_db( ).
        RETURN.
    ENDIF.

    ls_header-querytable          = lv_tabname.
    ls_header-options             = ls_options-low.
    ls_header-fields              = ls_fields-low.
    ls_header-delimiter           = lv_Delimiter.
    ls_header-rowskips            = lv_skip.
    ls_header-rowcount            = lv_top.
    ls_header-readtabledataset    = lt_fm_data.
    ls_header-readtablefieldsset  = lt_fields_data.
    ls_header-readtableoptionsset = lt_opt_data.
    APPEND ls_header TO lt_header.

      lv_rows = lines( lt_fm_data ).
      CONDENSE lv_rows.

      CLEAR ls_msg.
      ls_msg-msgty = 'S'.
      ls_msg-msgid = '/SAVY/RFC_MSGS'.
      ls_msg-msgno = '009'.
      ls_msg-msgv1 = lv_tabname.
      ls_msg-msgv2 = lv_rows.
      ls_msg-msgv3 = sy-uname.
      lo_log->msg_add_log( im_msg = ls_msg ).
      lo_log->save_to_db( ).

    io_response->set_busi_data( lt_header ).

    lv_total_count = lines( lt_fm_data ).

    io_response->set_count( iv_count = lv_total_count ).

    lo_request_info ?= io_request.

    CREATE OBJECT mo_default_matcher TYPE cl_atd_matcher.
    "create controller
    CREATE OBJECT lo_controller TYPE cl_atd_controller
      EXPORTING
        io_matcher          = mo_default_matcher
        iv_double_type_name = lv_objname.

    ro_double = lo_controller->create_double( lv_objname ) .

    lo_expand_node  ?= ro_double.

    lo_request_info->set_source_expand_node( lo_expand_node ).

    ls_done_list-skip    = abap_true.
    ls_done_list-top     = abap_true.
    ls_done_list-filter  = abap_true.
    ls_done_list-expand  = abap_true.

    io_response->set_is_done( is_todo_list = ls_done_list ).

  ENDMETHOD.
ENDCLASS.
