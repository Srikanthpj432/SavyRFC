class /SAVY/CL_RFC_READ_SERV_MPC definition
  public
  inheriting from /IWBEP/CL_V4_ABS_MODEL_PROV
  create public .

public section.

  types:
     begin of TS_READTABLE,
         QUERYTABLE type C length 30,
         FIELDS type STRING,
         OPTIONS type STRING,
         DELIMITER type C length 1,
         NODATA type C length 1,
         ROWSKIPS type I,
         ROWCOUNT type I,
     end of TS_READTABLE .
  types:
     TT_READTABLE type standard table of TS_READTABLE .
  types:
     TS_READTABLEDATA type TAB512 .
  types:
     TT_READTABLEDATA type standard table of TS_READTABLEDATA .
  types:
     TS_READTABLEFIELDS type RFC_DB_FLD .
  types:
     TT_READTABLEFIELDS type standard table of TS_READTABLEFIELDS .
  types:
     TS_READTABLEOPTIONS type RFC_DB_OPT .
  types:
     TT_READTABLEOPTIONS type standard table of TS_READTABLEOPTIONS .

  methods /IWBEP/IF_V4_MP_BASIC~DEFINE
    redefinition .
protected section.
private section.

  methods DEFINE_READTABLEDATA
    importing
      !IO_MODEL type ref to /IWBEP/IF_V4_MED_MODEL
    raising
      /IWBEP/CX_GATEWAY .
  methods DEFINE_READTABLEOPTIONS
    importing
      !IO_MODEL type ref to /IWBEP/IF_V4_MED_MODEL
    raising
      /IWBEP/CX_GATEWAY .
  methods DEFINE_READTABLEFIELDS
    importing
      !IO_MODEL type ref to /IWBEP/IF_V4_MED_MODEL
    raising
      /IWBEP/CX_GATEWAY .
  methods DEFINE_READTABLE
    importing
      !IO_MODEL type ref to /IWBEP/IF_V4_MED_MODEL
    raising
      /IWBEP/CX_GATEWAY .
ENDCLASS.



CLASS /SAVY/CL_RFC_READ_SERV_MPC IMPLEMENTATION.


  method /IWBEP/IF_V4_MP_BASIC~DEFINE.
*&----------------------------------------------------------------------------------------------*
*&* This class has been generated on 08.04.2026 19:08:54 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the MPC implementation, use the
*&*   generated methods inside MPC subclass - /SAVY/CL_RFC_READ_SERV_MPC_EXT
*&-----------------------------------------------------------------------------------------------*
  define_readtable( io_model ).
  define_readtabledata( io_model ).
  define_readtablefields( io_model ).
  define_readtableoptions( io_model ).
  endmethod.


  method DEFINE_READTABLE.
*&----------------------------------------------------------------------------------------------*
*&* This class has been generated on 08.04.2026 19:08:54 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the MPC implementation, use the
*&*   generated methods inside MPC subclass - /SAVY/CL_RFC_READ_SERV_MPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA lo_entity_type    TYPE REF TO /iwbep/if_v4_med_entity_type.
 DATA lo_property       TYPE REF TO /iwbep/if_v4_med_prim_prop.
 DATA lo_entity_set     TYPE REF TO /iwbep/if_v4_med_entity_set.
 DATA lo_nav_prop       TYPE REF TO /iwbep/if_v4_med_nav_prop.
***********************************************************************************************************************************
*   ENTITY - ReadTable
***********************************************************************************************************************************
 lo_entity_type = io_model->create_entity_type( iv_entity_type_name = 'READTABLE' ). "#EC NOTEXT

 lo_entity_type->set_edm_name( 'ReadTable' ).               "#EC NOTEXT

***********************************************************************************************************************************
*   Properties
***********************************************************************************************************************************
 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'QUERYTABLE' ). "#EC NOTEXT
 lo_property->set_edm_name( 'QueryTable' ).                 "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_is_key( ).
 lo_property->set_max_length( iv_max_length = '30' ).       "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'FIELDS' ). "#EC NOTEXT
 lo_property->set_edm_name( 'Fields' ).                     "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'OPTIONS' ). "#EC NOTEXT
 lo_property->set_edm_name( 'Options' ).                    "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'DELIMITER' ). "#EC NOTEXT
 lo_property->set_edm_name( 'Delimiter' ).                  "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_max_length( iv_max_length = '1' ).        "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'NODATA' ). "#EC NOTEXT
 lo_property->set_edm_name( 'NoData' ).                     "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_max_length( iv_max_length = '1' ).        "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'ROWSKIPS' ). "#EC NOTEXT
 lo_property->set_edm_name( 'RowSkips' ).                   "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'Int32' ).        "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'ROWCOUNT' ). "#EC NOTEXT
 lo_property->set_edm_name( 'RowCount' ).                   "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'Int32' ).        "#EC NOTEXT


***********************************************************************************************************************************
*   Navigation Properties
***********************************************************************************************************************************
 lo_nav_prop = lo_entity_type->create_navigation_property( iv_property_name = 'READTABLEDATASET' ). "#EC NOTEXT
 lo_nav_prop->set_edm_name( 'ReadTableDataSet' ).           "#EC NOTEXT
 lo_nav_prop->set_target_entity_type_name( 'READTABLEDATA' ).
 lo_nav_prop->set_target_multiplicity( 'N' ).
 lo_nav_prop->set_on_delete_action( 'None' ).               "#EC NOTEXT
 lo_nav_prop = lo_entity_type->create_navigation_property( iv_property_name = 'READTABLEFIELDSSET' ). "#EC NOTEXT
 lo_nav_prop->set_edm_name( 'ReadTableFieldsSet' ).         "#EC NOTEXT
 lo_nav_prop->set_target_entity_type_name( 'READTABLEFIELDS' ).
 lo_nav_prop->set_target_multiplicity( 'N' ).
 lo_nav_prop->set_on_delete_action( 'None' ).               "#EC NOTEXT
 lo_nav_prop = lo_entity_type->create_navigation_property( iv_property_name = 'READTABLEOPTIONSSET' ). "#EC NOTEXT
 lo_nav_prop->set_edm_name( 'ReadTableOptionsSet' ).        "#EC NOTEXT
 lo_nav_prop->set_target_entity_type_name( 'READTABLEOPTIONS' ).
 lo_nav_prop->set_target_multiplicity( 'N' ).
 lo_nav_prop->set_on_delete_action( 'None' ).               "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
 lo_entity_set = lo_entity_type->create_entity_set( 'READTABLESET' ). "#EC NOTEXT
 lo_entity_set->set_edm_name( 'ReadTableSet' ).             "#EC NOTEXT
  endmethod.


  method DEFINE_READTABLEDATA.
*&----------------------------------------------------------------------------------------------*
*&* This class has been generated on 08.04.2026 19:08:54 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the MPC implementation, use the
*&*   generated methods inside MPC subclass - /SAVY/CL_RFC_READ_SERV_MPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA lo_entity_type    TYPE REF TO /iwbep/if_v4_med_entity_type.
 DATA lo_property       TYPE REF TO /iwbep/if_v4_med_prim_prop.
 DATA lo_entity_set     TYPE REF TO /iwbep/if_v4_med_entity_set.
 DATA lv_READTABLEDATA  TYPE tab512.
***********************************************************************************************************************************
*   ENTITY - ReadTableData
***********************************************************************************************************************************
 lo_entity_type = io_model->create_entity_type_by_struct( iv_entity_type_name = 'READTABLEDATA' is_structure = lv_READTABLEDATA
                                                          iv_add_conv_to_prim_props = abap_true ). "#EC NOTEXT

 lo_entity_type->set_edm_name( 'ReadTableData' ).           "#EC NOTEXT

***********************************************************************************************************************************
*   Properties
***********************************************************************************************************************************
 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'WA' ). "#EC NOTEXT
 lo_property->set_add_annotations( abap_true ).
 lo_property->set_edm_name( 'Wa' ).                         "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_is_key( ).
 lo_property->set_max_length( iv_max_length = '512' ).      "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
 lo_entity_set = lo_entity_type->create_entity_set( 'READTABLEDATASET' ). "#EC NOTEXT
 lo_entity_set->set_edm_name( 'ReadTableDataSet' ).         "#EC NOTEXT
  endmethod.


  method DEFINE_READTABLEFIELDS.
*&----------------------------------------------------------------------------------------------*
*&* This class has been generated on 08.04.2026 19:08:54 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the MPC implementation, use the
*&*   generated methods inside MPC subclass - /SAVY/CL_RFC_READ_SERV_MPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA lo_entity_type    TYPE REF TO /iwbep/if_v4_med_entity_type.
 DATA lo_property       TYPE REF TO /iwbep/if_v4_med_prim_prop.
 DATA lo_entity_set     TYPE REF TO /iwbep/if_v4_med_entity_set.
 DATA lv_READTABLEFIELDS  TYPE rfc_db_fld.
***********************************************************************************************************************************
*   ENTITY - ReadTableFields
***********************************************************************************************************************************
 lo_entity_type = io_model->create_entity_type_by_struct( iv_entity_type_name = 'READTABLEFIELDS' is_structure = lv_READTABLEFIELDS
                                                          iv_add_conv_to_prim_props = abap_true ). "#EC NOTEXT

 lo_entity_type->set_edm_name( 'ReadTableFields' ).         "#EC NOTEXT

***********************************************************************************************************************************
*   Properties
***********************************************************************************************************************************
 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'FIELDNAME' ). "#EC NOTEXT
 lo_property->set_add_annotations( abap_true ).
 lo_property->set_edm_name( 'FieldName' ).                  "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_is_key( ).
 lo_property->set_max_length( iv_max_length = '30' ).       "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'OFFSET' ). "#EC NOTEXT
 lo_property->set_add_annotations( abap_true ).
 lo_property->set_edm_name( 'OffSet' ).                     "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_max_length( iv_max_length = '6' ).        "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'LENGTH' ). "#EC NOTEXT
 lo_property->set_add_annotations( abap_true ).
 lo_property->set_edm_name( 'Length' ).                     "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_max_length( iv_max_length = '6' ).        "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'TYPE' ). "#EC NOTEXT
 lo_property->set_add_annotations( abap_true ).
 lo_property->set_edm_name( 'Type' ).                       "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_max_length( iv_max_length = '1' ).        "#EC NOTEXT

 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'FIELDTEXT' ). "#EC NOTEXT
 lo_property->set_add_annotations( abap_true ).
 lo_property->set_edm_name( 'FieldText' ).                  "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_max_length( iv_max_length = '60' ).       "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
 lo_entity_set = lo_entity_type->create_entity_set( 'READTABLEFIELDSSET' ). "#EC NOTEXT
 lo_entity_set->set_edm_name( 'ReadTableFieldsSet' ).       "#EC NOTEXT
  endmethod.


  method DEFINE_READTABLEOPTIONS.
*&----------------------------------------------------------------------------------------------*
*&* This class has been generated on 08.04.2026 19:08:54 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the MPC implementation, use the
*&*   generated methods inside MPC subclass - /SAVY/CL_RFC_READ_SERV_MPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA lo_entity_type    TYPE REF TO /iwbep/if_v4_med_entity_type.
 DATA lo_property       TYPE REF TO /iwbep/if_v4_med_prim_prop.
 DATA lo_entity_set     TYPE REF TO /iwbep/if_v4_med_entity_set.
 DATA lv_READTABLEOPTIONS  TYPE rfc_db_opt.
***********************************************************************************************************************************
*   ENTITY - ReadTableOptions
***********************************************************************************************************************************
 lo_entity_type = io_model->create_entity_type_by_struct( iv_entity_type_name = 'READTABLEOPTIONS' is_structure = lv_READTABLEOPTIONS
                                                          iv_add_conv_to_prim_props = abap_true ). "#EC NOTEXT

 lo_entity_type->set_edm_name( 'ReadTableOptions' ).        "#EC NOTEXT

***********************************************************************************************************************************
*   Properties
***********************************************************************************************************************************
 lo_property = lo_entity_type->create_prim_property( iv_property_name = 'TEXT' ). "#EC NOTEXT
 lo_property->set_add_annotations( abap_true ).
 lo_property->set_edm_name( 'Text' ).                       "#EC NOTEXT
 lo_property->set_edm_type( iv_edm_type = 'String' ).       "#EC NOTEXT
 lo_property->set_is_key( ).
 lo_property->set_max_length( iv_max_length = '72' ).       "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
 lo_entity_set = lo_entity_type->create_entity_set( 'READTABLEOPTIONSSET' ). "#EC NOTEXT
 lo_entity_set->set_edm_name( 'ReadTableOptionsSet' ).      "#EC NOTEXT
  endmethod.
ENDCLASS.
