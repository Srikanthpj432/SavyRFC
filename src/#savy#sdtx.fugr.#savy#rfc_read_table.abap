function /SAVY/RFC_READ_TABLE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(QUERY_TABLE) LIKE  DD02L-TABNAME
*"     VALUE(DELIMITER) LIKE  SONV-FLAG DEFAULT SPACE
*"     VALUE(NO_DATA) LIKE  SONV-FLAG DEFAULT SPACE
*"     VALUE(ROWSKIPS) LIKE  SOID-ACCNT DEFAULT 0
*"     VALUE(ROWCOUNT) LIKE  SOID-ACCNT DEFAULT 0
*"  TABLES
*"      OPTIONS STRUCTURE  RFC_DB_OPT OPTIONAL
*"      FIELDS STRUCTURE  RFC_DB_FLD OPTIONAL
*"      DATA STRUCTURE  TAB512 OPTIONAL
*"  EXCEPTIONS
*"      TABLE_NOT_AVAILABLE
*"      TABLE_WITHOUT_DATA
*"      OPTION_NOT_VALID
*"      FIELD_NOT_VALID
*"      NOT_AUTHORIZED
*"      DATA_BUFFER_EXCEEDED
*"----------------------------------------------------------------------
* ----------------------------------------------------------------------
*  Application Log variables (SLG1)
* ----------------------------------------------------------------------
  DATA: lv_log_handle  TYPE balloghndl,
        ls_log_header  TYPE bal_s_log,
        ls_log_msg     TYPE bal_s_msg,
        lt_log_handles TYPE bal_t_logh,
        lv_field_list  TYPE char50,
        lv_where_str   TYPE char50,
        lv_msg_text    TYPE char50,
        lv_row_count   TYPE i,
        lv_timestamp   TYPE timestampl.

* Get precise timestamp at entry
  GET TIME STAMP FIELD lv_timestamp.

* ----------------------------------------------------------------------
*  Create Application Log header
*  Note: Create log object ZRFC_READ via SLG0 transaction
*        Sub-object: TABLE_ACCESS
* ----------------------------------------------------------------------
  ls_log_header-object    = '/SAVY/ROOT'.
  ls_log_header-subobject = '/SAVY/RFC_READ'.
  ls_log_header-aldate    = sy-datum.
  ls_log_header-altime    = sy-uzeit.
  ls_log_header-aluser    = sy-uname.
  ls_log_header-altcode   = sy-tcode.
  ls_log_header-alprog    = sy-cprog.
  ls_log_header-extnumber = query_table.  "External log number = table name

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = ls_log_header
    IMPORTING
      e_log_handle            = lv_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
*   If log creation fails, continue with FM execution (don't block)
    CLEAR lv_log_handle.
  ENDIF.

* ----------------------------------------------------------------------
*  Log entry message: RFC call initiated
* ----------------------------------------------------------------------
  IF lv_log_handle IS NOT INITIAL.

*   Build WHERE clause string from OPTIONS table
    CLEAR lv_where_str.
    LOOP AT options.
      IF lv_where_str IS INITIAL.
        lv_where_str = options-text.
      ELSE.
        CONCATENATE lv_where_str options-text INTO lv_where_str SEPARATED BY space.
      ENDIF.
    ENDLOOP.

*   Log: Call initiated
    CLEAR ls_log_msg.
    ls_log_msg-msgty = 'I'.
    ls_log_msg-msgid = '/SAVY/RFC_MSGS'.
    ls_log_msg-msgno = '001'.
    ls_log_msg-msgv1 = query_table.
    ls_log_msg-msgv2 = sy-uname.
    ls_log_msg-msgv3 = sy-datum.
    ls_log_msg-msgv4 = sy-uzeit.
*   Message 001: "RFC Read on table &1 by user &2 on &3 at &4"

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = lv_log_handle
        i_s_msg          = ls_log_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

*   Log: WHERE clause details
    IF lv_where_str IS NOT INITIAL.
      CLEAR ls_log_msg.
      ls_log_msg-msgty = 'I'.
      ls_log_msg-msgid = '/SAVY/RFC_MSGS'.
      ls_log_msg-msgno = '002'.
      ls_log_msg-msgv1 = lv_where_str.  "(50).
*     Message 002: "WHERE clause: &1"

      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle     = lv_log_handle
          i_s_msg          = ls_log_msg
        EXCEPTIONS
          log_not_found    = 1
          msg_inconsistent = 2
          log_is_full      = 3
          OTHERS           = 4.
    ENDIF.

  ENDIF.

* ======================================================================
*  ORIGINAL RFC_READ_TABLE LOGIC STARTS HERE
* ======================================================================

  CALL FUNCTION 'VIEW_AUTHORITY_CHECK'
    EXPORTING
      view_action                    = 'S'
      view_name                      = query_table
    EXCEPTIONS
      no_authority                   = 2
      no_clientindependent_authority = 2
      no_linedependent_authority     = 2
      OTHERS                         = 1.

  IF sy-subrc = 2.
*   Log: Authorization failure
    PERFORM log_error USING lv_log_handle 'E' '003'
                            query_table sy-uname '' ''.
*   Message 003: "NOT AUTHORIZED: Table &1 access denied for user &2"
    PERFORM save_log USING lv_log_handle.
    RAISE not_authorized.
  ELSEIF sy-subrc = 1.
*   Log: Table not available
    PERFORM log_error USING lv_log_handle 'E' '004'
                            query_table '' '' ''.
*   Message 004: "TABLE NOT AVAILABLE: &1"
    PERFORM save_log USING lv_log_handle.
    RAISE table_not_available.
  ENDIF.

* ----------------------------------------------------------------------
*  Find out about the structure of QUERY_TABLE
* ----------------------------------------------------------------------
  DATA BEGIN OF table_structure OCCURS 10.
          INCLUDE STRUCTURE dfies.
  DATA END OF table_structure.
  DATA table_type TYPE dd02v-tabclass.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = query_table
    IMPORTING
      ddobjtype      = table_type
    TABLES
      dfies_tab      = table_structure
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    PERFORM log_error USING lv_log_handle 'E' '004'
                            query_table '' '' ''.
    PERFORM save_log USING lv_log_handle.
    RAISE table_not_available.
  ENDIF.

  IF table_type = 'INTTAB'.
    PERFORM log_error USING lv_log_handle 'E' '005'
                            query_table '' '' ''.
*   Message 005: "TABLE WITHOUT DATA: &1 is internal table type"
    PERFORM save_log USING lv_log_handle.
    RAISE table_without_data.
  ENDIF.

* ----------------------------------------------------------------------
*  Isolate first field of DATA as output field
* ----------------------------------------------------------------------
  DATA line_length TYPE i.
  FIELD-SYMBOLS <d>.
  ASSIGN COMPONENT 0 OF STRUCTURE data TO <d>.
  DESCRIBE FIELD <d> LENGTH line_length IN CHARACTER MODE.

* ----------------------------------------------------------------------
*  If FIELDS are not specified, read all available fields
* ----------------------------------------------------------------------
  DATA number_of_fields TYPE i.
  DESCRIBE TABLE fields LINES number_of_fields.
  IF number_of_fields = 0.
    LOOP AT table_structure.
      MOVE table_structure-fieldname TO fields-fieldname.
      APPEND fields.
    ENDLOOP.
  ENDIF.

* ----------------------------------------------------------------------
*  For each field, copy structure information
* ----------------------------------------------------------------------
  DATA: BEGIN OF fields_int OCCURS 10,
          fieldname  LIKE table_structure-fieldname,
          type       LIKE table_structure-inttype,
          decimals   LIKE table_structure-decimals,
          length_src LIKE table_structure-intlen,
          length_dst LIKE table_structure-leng,
          offset_src LIKE table_structure-offset,
          offset_dst LIKE table_structure-offset,
        END OF fields_int,
        line_cursor TYPE i.

  LINE_CURSOR = 0.

  LOOP AT fields.
    READ TABLE table_structure WITH KEY fieldname = fields-fieldname.
    IF sy-subrc NE 0.
      PERFORM log_error USING lv_log_handle 'E' '006'
                              fields-fieldname query_table '' ''.
*     Message 006: "FIELD NOT VALID: &1 in table &2"
      PERFORM save_log USING lv_log_handle.
      RAISE field_not_valid.
    ENDIF.

    IF line_cursor <> 0.
      IF no_data EQ space AND delimiter NE space.
        MOVE delimiter TO data+line_cursor.
      ENDIF.
      line_cursor = line_cursor + strlen( delimiter ).
    ENDIF.

    fields_int-fieldname  = table_structure-fieldname.
    fields_int-length_src = table_structure-intlen.
    fields_int-length_dst = table_structure-leng.
    fields_int-offset_src = table_structure-offset.
    fields_int-offset_dst = line_cursor.
    fields_int-type       = table_structure-inttype.
    fields_int-decimals   = table_structure-decimals.
    line_cursor = line_cursor + table_structure-leng.

    IF line_cursor > line_length AND no_data EQ space.
      PERFORM log_error USING lv_log_handle 'E' '007'
                              query_table '' '' ''.
*     Message 007: "DATA BUFFER EXCEEDED for table &1"
      PERFORM save_log USING lv_log_handle.
      RAISE data_buffer_exceeded.
    ENDIF.
    APPEND fields_int.

    fields-fieldtext = table_structure-fieldtext.
    fields-type      = table_structure-inttype.
    fields-length    = fields_int-length_dst.
    fields-offset    = fields_int-offset_dst.
    MODIFY fields.

*   Collect field names for logging
    IF lv_field_list IS INITIAL.
      lv_field_list = fields-fieldname.
    ELSE.
      CONCATENATE lv_field_list fields-fieldname INTO lv_field_list SEPARATED BY ','.
    ENDIF.

  ENDLOOP.

* ----------------------------------------------------------------------
*  Log: Fields requested
* ----------------------------------------------------------------------
  IF lv_log_handle IS NOT INITIAL AND lv_field_list IS NOT INITIAL.
    CLEAR ls_log_msg.
    ls_log_msg-msgty = 'I'.
    ls_log_msg-msgid = '/SAVY/RFC_MSGS'.
    ls_log_msg-msgno = '008'.
    ls_log_msg-msgv1 = lv_field_list.  "(50).
*   Message 008: "Fields requested: &1"

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = lv_log_handle
        i_s_msg          = ls_log_msg
      EXCEPTIONS
        OTHERS           = 4.
  ENDIF.

* ----------------------------------------------------------------------
*  Read data from the database
* ----------------------------------------------------------------------
  IF no_data EQ space.

    DATA: BEGIN OF work, buffer(30000), END OF work.
    FIELD-SYMBOLS: <wa> TYPE ANY, <comp> TYPE ANY.
    ASSIGN work TO <wa> CASTING TYPE (query_table).

    IF rowcount > 0.
      rowcount = rowcount + rowskips.
    ENDIF.

    SELECT * FROM (query_table) INTO <wa> WHERE (options).

      IF sy-dbcnt GT rowskips.

        LOOP AT fields_int.
          IF fields_int-type = 'P'.
            ASSIGN COMPONENT fields_int-fieldname
                OF STRUCTURE <wa> TO <comp>
                TYPE     fields_int-type
                DECIMALS fields_int-decimals.
          ELSE.
            ASSIGN COMPONENT fields_int-fieldname
                OF STRUCTURE <wa> TO <comp>
                TYPE     fields_int-type.
          ENDIF.
          MOVE <comp> TO
              <d>+fields_int-offset_dst(fields_int-length_dst).
        ENDLOOP.
        APPEND data.

        IF rowcount > 0 AND sy-dbcnt GE rowcount. EXIT. ENDIF.

      ENDIF.

    ENDSELECT.

*   Capture final row count
    lv_row_count = sy-dbcnt.

  ENDIF.

* ----------------------------------------------------------------------
*  Log: Success - rows returned
* ----------------------------------------------------------------------
  IF lv_log_handle IS NOT INITIAL.
    DATA lv_rows TYPE char10.
    lv_rows = lv_row_count.
    CONDENSE lv_rows.

    CLEAR ls_log_msg.
    ls_log_msg-msgty = 'S'.
    ls_log_msg-msgid = '/SAVY/RFC_MSGS'.
    ls_log_msg-msgno = '009'.
    ls_log_msg-msgv1 = query_table.
    ls_log_msg-msgv2 = lv_rows.
    ls_log_msg-msgv3 = sy-uname.
*   Message 009: "SUCCESS: Table &1 returned &2 rows for user &3"

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = lv_log_handle
        i_s_msg          = ls_log_msg
      EXCEPTIONS
        OTHERS           = 4.

*   Save the application log
    PERFORM save_log USING lv_log_handle.
  ENDIF.

ENDFUNCTION.
*&---------------------------------------------------------------------*
*& Subroutines for Application Log
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form LOG_ERROR
*&---------------------------------------------------------------------*
*  Log an error message to the application log
*----------------------------------------------------------------------*
FORM log_error USING pv_log_handle TYPE balloghndl
                     pv_msgty      TYPE symsgty
                     pv_msgno      TYPE symsgno
                     pv_msgv1      TYPE any
                     pv_msgv2      TYPE any
                     pv_msgv3      TYPE any
                     pv_msgv4      TYPE any.

  DATA ls_msg TYPE bal_s_msg.

  CHECK pv_log_handle IS NOT INITIAL.

  ls_msg-msgty = pv_msgty.
  ls_msg-msgid = '/SAVY/RFC_MSGS'.
  ls_msg-msgno = pv_msgno.
  ls_msg-msgv1 = pv_msgv1.
  ls_msg-msgv2 = pv_msgv2.
  ls_msg-msgv3 = pv_msgv3.
  ls_msg-msgv4 = pv_msgv4.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle     = pv_log_handle
      i_s_msg          = ls_msg
    EXCEPTIONS
      OTHERS           = 4.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SAVE_LOG
*&---------------------------------------------------------------------*
*  Save the application log to database
*----------------------------------------------------------------------*
FORM save_log USING pv_log_handle TYPE balloghndl.

  DATA lt_handles TYPE bal_t_logh.

  CHECK pv_log_handle IS NOT INITIAL.

  APPEND pv_log_handle TO lt_handles.

  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_t_log_handle   = lt_handles
      i_in_update_task = abap_false    "Async save - no performance impact
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.
