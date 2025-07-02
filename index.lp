<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="/apps/css/font-awesome.css">
    <link rel="icon" href="icon.png">
    <title>Modbus Profiler</title>
</head>

<body>
    <div class="content">
        <!-- TOP MENU BLOCK -->
        <a class="btn btn-doc btn-success" href="https://openrb.com/docs/modbus.htm" target="_blank"><i
                class="fa fa-question-circle-o"></i></a>
        <a class="btn btn-exit btn-light" href="/apps/"><i class="fa fa-times"></i></a>
        <!-- <a class="btn btn-embsys-link" href="https://logicmachine.net.ru/" target="_blank"><img
                src="static/embsys-logo.png" width="30" height="30"></a> -->
        <div class="row">
            <div class="menu-block">
                <ul class="nav nav-tabs">
                    <li><img src="icon.png" width="35"></li>
                    <li>Modbus Profiler</li>
                    <li><input class="btn btn-primary btn-menu" id="loadFileXml" type="button"
                            onclick="document.getElementById('file').click();" value="Open from PC"></li>
                    <li><input id="file" style="display:none;" type="file" name="file" accept=".txt, .json"></li>
                    <li><input class="btn btn-primary btn-menu" id="li-download" type="button"
                            onclick="downloadProfileToPC()" value="Download" data-bs-toggle="modal" data-bs-target="#">
                    </li>
                    <li><input class="btn btn-primary btn-menu" id="li-open" type="button"
                            onclick="openProfilesFromLM()" value="Open from LM" data-bs-toggle="modal"
                            data-bs-target="#openLogicModal"></li>
                    <li><input class="btn btn-primary btn-menu" id="li-save" type="button" onclick="saveProfileToLM()"
                            value="Save to LM" data-bs-toggle="modal" data-bs-target="#"></li>
                    <li><input class="btn btn-primary btn-menu" id="li-read" type="button" onclick="setReadTest()"
                            value="Read test" data-bs-toggle="modal" data-bs-target="#readTestModal"></li>
                </ul>
            </div>
        </div>

        <!-- INPUT PANEL BLOCK -->
        <div class="row">
            <div class="input-block">
                <div class="row m-2">
                    <div class="form-group col">
                        <label for="manufacturer">Manufacturer</label>
                        <input class="form-control" id="manufacturer" type="text">
                    </div>
                    <div class="form-group col">
                        <label for="description">Description</label>
                        <input class="form-control" id="description" type="text">
                    </div>
                    <div class="form-group col">
                        <label for="read_delay">Read delay</label>
                        <input class="form-control form-select" id="read_delay" type="number" size="10"
                            name="read_delay" min="0" max="1" value="0" step="0.1">
                    </div>
                    <div class="form-group col">
                        <label for="read_swap">Read swap</label>
                        <select class="form-control  form-select" id="read_swap" type="text" name="read_swap">
                            <option value="0xCDAB">-</option>
                            <option value="0xCDAB">word swap</option>
                            <option value="0xABCD">no swap</option>
                            <option value="0xBADC">byte swap</option>
                            <option value="0xDCBA">byte and word swap</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <!-- TABLE BLOCK -->
        <div class="row">
            <div class="table-block">
                <div class="wrapper wrapper-top-alt wrapper-bottom pg-wrapper">
                    <table class="table table-hover table-fh table-row-edit" id="v_table">
                        <thead>
                            <tr>
                                <th style="min-width: 20px;">
                                    <div class="th">ID</div>
                                </th>
                                <th style="min-width: 70px;">
                                    <div class="th">Name</div>
                                </th>
                                <th style="min-width: 50px;">
                                    <div class="th">Type</div>
                                </th>
                                <th style="min-width: 50px;">
                                    <div class="th">Bus_datatype</div>
                                </th>
                                <th style="min-width: 70px;">
                                    <div class="th">Address</div>
                                </th>
                                <th style="min-width: 70px;">
                                    <div class="th">Options</div>
                                </th>
                                <th style="min-width: 350px;">
                                    <div class="th th-wrap">
                                        <div class="actions" style="float: right;">
                                            <button class="btn btn-primary btn-add" data-bs-toggle="modal"
                                                id="add-mapping-entry" type="button" data-bs-target="#RegisterModal">
                                                <i class="fa fa-plus-circle"></i>
                                                Add mapping entry
                                            </button>
                                            <button type="button" class="btn btn-primary btn-del-all"
                                                data-bs-toggle="modal" data-bs-target="#deleteAllModal">
                                                <i class="fa fa-trash-o"></i>
                                                Delete All
                                            </button>
                                        </div>
                                    </div>
                                </th>
                            </tr>
                        </thead>
                        <tbody class="pg-body">
                            <tr></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>


    <!-- MODAL WINDOWS -->
    <!-- VALUE_CUSTOM WINDOW -->
    <div class="modal fade" id="VC_edit" tabindex="-1" aria-labelledby="VC_editLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="VC_editLabel">Value_custom editor</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <form name="vc_form" id="vc_form">

                        <div class="form-group">
                            <label class="" for="vc-default_text">Default text</label>
                            <input class="form-control" id="vc-default_text" type="text" name="default_text">
                        </div>

                        <div class="row vc-block" id="vc_str_0" style="margin-bottom: 25px;">
                            <div class="col-3 form-group">
                                <label class="" for="vc-value">Value</label>
                                <input class="form-control" id="vc-value" type="number" name="value" value="0">
                            </div>
                            <div class="col-7 form-group">
                                <label class="" for="vc-display_text">Display text</label>
                                <input class="form-control" id="vc-display_text" type="text" name="display_text">
                            </div>
                            <div class="col-2 form-group">
                                <button style="margin-top: 30px;"
                                    class="btn btn-sm btn-primary fa fa-times pin-del pin-vc-del" type="button"
                                    onclick="delVC(0)">
                                </button>
                            </div>
                        </div>
                    </form>



                    <div>
                        <button type="button" class="btn btn-primary btn-add" id="addVC" onclick="addVC(vc_str)">
                            <i class="fa fa-plus-circle"></i>
                            Add custom value
                        </button>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-primary btn-save" data-bs-dismiss="modal"
                        onclick="saveVC()">Save</button>
                    <button type="button" class="btn btn-secondary btn-cancel" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>






    <!-- READ TEST -->
    <div class="modal fade" id="readTestModal" tabindex="-1" aria-labelledby="readTestLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="readTestLabel">Read test</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body modal-form">
                    <form id="read-test" action="lua/read_test.lp" method="get" target="_blank">
                        <div>
                            <input class="rtu" type="radio" id="rtu1" name="type" value="RTU1">
                            <label for="rtu1">RTU1</label>
                            <input class="rtu" type="radio" id="rtu2" name="type" value="RTU2">
                            <label for="rtu2">RTU2</label>
                            <input class="rtu" type="radio" id="rtu3" name="type" value="RTU3">
                            <label for="rtu3">RTU3</label>
                            <input type="radio" id="tcp_ip" name="type" value="TCP/IP" checked>
                            <label for="tcp_ip">TCP/IP</label>
                        </div>
                        <div>
                            <label class="ip_address" for="ip">IP</label>
                            <input class="form-control ip_address" type="text" id="ip" name="ip" value="192.168.0.13">
                        </div>
                        <div>
                            <label class="ip_address" for="port">Port</label>
                            <input class="form-control ip_address" type="number" id="port" name="port" min="1"
                                max="65535" value="502">
                        </div>
                        <div>
                            <label for="slave_addr">Device (slave) address</label>
                            <input class="form-control " type="number" id="slave_addr" name="slave_addr" min="1"
                                max="247" value="1">
                        </div>
                        <div>
                            <label for="datatype_test">Data type </label>
                            <select class="form-select" id='datatype_test' name="datatype">
                                <option value="-">-</option>
                                <option value="int16">int16</option>
                                <option value="int16m">int16m</option>
                                <option value="uint16">uint16</option>
                                <option value="uint16m">uint16m</option>
                                <option value="float16">float16</option>
                                <option value="s10k">s10k</option>
                                <option value="int32">int32</option>
                                <option value="uint32">uint32</option>
                                <option value="float">float</option>
                                <option value="float32">float32</option>
                                <option value="int64">int64</option>
                                <option value="uint64">uint64</option>
                                <option value="quad10k">quad10k</option>
                                <option value="float64">float64</option>
                                <option value="double">double</option>
                                <option value="string">string</option>
                            </select>
                        </div>
                        <div>
                            <label for="read_swap_test">Read_swap </label>
                            <select class="form-select" id='read_swap_test' name="read_swap">
                                <option value="w">word swap</option>
                                <option value="n">no swap</option>
                                <option value="b">byte swap</option>
                                <option value="bw">byte and word swap</option>
                            </select>
                        </div>
                        <div>
                            <label for="func">Function </label>
                            <select class="form-select" id='func' name="func">
                                <option value="coil">Coil</option>
                                <option value="dinput">Discrete input</option>
                                <option value="hregister">Holding register</option>
                                <option value="iregister">Input register</option>
                            </select>
                        </div>
                        <div>
                            <label for="addr">Address</label>
                            <input class="form-control " type="number" id="addr" name="addr" min="0" max="65535"
                                value="0">
                        </div>
                        <div>
                            <label for="read_lenght_test">Read_lenght</label>
                            <input class="form-control " type="number" id="read_lenght_test" name="read_lenght"
                                value="1">
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary btn-save" id="read_test">Ok</button>
                    <button type="button" class="btn btn-secondary btn-cancel" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>


    <!-- OPEN FROM LM -->
    <div class="modal fade" id="openLogicModal" tabindex="-1" aria-labelledby="openLogicLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="openLogicLabel">Available Profiles</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="options-block">
                        <table class="table table-hover" id="profiles-selection">
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-cancel" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>


    <!-- DELETE ALL -->
    <div class="modal fade" id="deleteAllModal" tabindex="-1" aria-labelledby="deleteAllModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deleteAllModalLabel">Delete all</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    Are you sure you want to delete all your profile data? This action will result in the loss of
                    existing data
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary btn-del-all" data-bs-dismiss="modal"
                        onclick="deleteAll()">Resume
                        <i class="fa fa-trash=o"></i></button>
                    <button type="button" class="btn btn-secondary btn-cancel" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>


    <!-- ADD/EDIT REGISTER -->
    <div class="modal fade" id="RegisterModal" tabindex="-1" aria-labelledby="RegisterModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="RegisterModalLabel">Register</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body modal-form">
                    <form action="" id="RegisterForm">
                        <div class="form-group">
                            <label class="" for="register-name">Name</label>
                            <input class="form-control" id="register-name" type="text" name="name">
                        </div>
                        <div class="form-group">
                            <label class="" for="register-type">Type</label>
                            <select class="form-control form-select" id="register-type" name="type">
                                <option value="coil">coil</option>
                                <option value="discreteinput">discreteinput</option>
                                <option value="register">register</option>
                                <option value="inputregister">inputregister</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="" for="register-bus_datatype">Bus_datatype</label>
                            <select class="form-control  form-select" id="register-bus_datatype" name="bus_datatype">
                                <option value="int16">int16</option>
                                <option value="int8">int8</option>
                                <option value="int32">int32</option>
                                <option value="int64">int64</option>
                                <option value="uint8">uint8</option>
                                <option value="uint16">uint16</option>
                                <option value="uint24">uint24</option>
                                <option value="uint32">uint32</option>
                                <option value="float16">float16</option>
                                <option value="float32">float32</option>
                                <option value="bool">bool</option>
                                <option value="bit4">bit4</option>
                                <option value="scale">scale</option>
                                <option value="angle">angle</option>
                                <option value="temperature">temperature</option>
                                <option value="string">string</option>
                                <option value="double">double</option>
                                <option value="float64">float64</option>
                                <option value="quad10k">quad10k</option>
                                <option value="uint64">uint64</option>
                                <option value="s10k">s10k</option>
                                <option value="int16m">int16m</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="" for="register-address">Address</label>
                            <input class="form-control" id="register-address" type="number" step="1" name="address"
                                min="0" value="0">
                        </div>

                        <div>
                            <label>Options</label>
                            <div class="options-block">
                                <table class="table table-hover" id="options-table">
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-datatype"
                                                name="checkbox_datatype">
                                            <label for="option-datatype">datatype</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-units"
                                                name="checkbox-units">
                                            <label for="option-units">units</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-internal"
                                                name="checkbox-internal">
                                            <label for="option-internal">internal</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-address_scale"
                                                name="checkbox-address_scale">
                                            <label for="option-address_scale">address_scale</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-bus_address"
                                                name="checkbox-bus_address">
                                            <label for="option-bus_address">bus_address</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-bus_write"
                                                name="checkbox-bus_write">
                                            <label for="option-bus_write">bus_write</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-writable"
                                                name="checkbox-writable">
                                            <label for="option-writable">writable</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-write_only"
                                                name="checkbox-write_only">
                                            <label for="option-write_only">write_only</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-write_bitmask"
                                                name="checkbox-write_bitmask">
                                            <label for="option-write_bitmask">write_bitmask</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-write_multiple"
                                                name="checkbox-write_multiple">
                                            <label for="option-write_multiple">write_multiple</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-read_count"
                                                name="checkbox-read_count">
                                            <label for="option-read_count">read_count</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-read_offset"
                                                name="checkbox-read_offset">
                                            <label for="option-read_offset">read_offset</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-value_delta"
                                                name="checkbox-value_delta">
                                            <label for="option-value_delta">value_delta</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-value_multiplier"
                                                name="checkbox-value_multiplier">
                                            <label for="option-value_multiplier">value_multiplier</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-value_bitmask"
                                                name="checkbox-value_bitmask">
                                            <label for="option-value_bitmask">value_bitmask</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-value_base"
                                                name="checkbox-value_base">
                                            <label for="option-value_base">value_base</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-value_custom"
                                                name="checkbox-value_custom">
                                            <label for="option-value_custom">value_custom</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input class="form-check-input" type="checkbox" id="option-value_default"
                                                name="checkbox-value_default">
                                            <label for="option-value_default">value_default</label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>

                        <div>
                            <label>Edit options</label>
                            <div class="options-block">
                                <table class="table table-hover" id="edit-table">
                                    <tr>
                                        <td>
                                            <label for="register-datatype">Datatype</label>
                                            <select class="form-control form-select" id="register-datatype"
                                                name="datatype">
                                                <option value="int16">int16</option>
                                                <option value="int8">int8</option>
                                                <option value="int32">int32</option>
                                                <option value="int64">int64</option>
                                                <option value="uint8">uint8</option>
                                                <option value="uint16">uint16</option>
                                                <option value="uint24">uint24</option>
                                                <option value="uint32">uint32</option>
                                                <option value="float16">float16</option>
                                                <option value="float32">float32</option>
                                                <option value="bool">bool</option>
                                                <option value="bit4">bit4</option>
                                                <option value="scale">scale</option>
                                                <option value="angle">angle</option>
                                                <option value="temperature">temperature</option>
                                                <option value="string">string</option>
                                                <option value="double">double</option>
                                                <option value="float64">float64</option>
                                                <option value="quad10k">quad10k</option>
                                                <option value="uint64">uint64</option>
                                                <option value="s10k">s10k</option>
                                                <option value="int16m">int16m</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-units">Units</label>
                                            <input class="form-control" id="register-units" type="text" name="units">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-internal">internal</label>
                                            <select class="form-control form-select" id="register-internal"
                                                name="internal">
                                                <option value="0">false</option>
                                                <option value="1">true</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-address_scale">Address_scale</label>
                                            <input class="form-control" id="register-address_scale" type="number"
                                                step="1" name="address_scale" min="0" value="0">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-bus_address">Bus_address</label>
                                            <input class="form-control" id="register-bus_address" type="text"
                                                name="bus_address">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-bus_write">Bus_write</label>
                                            <select class="form-control form-select" id="register-bus_write"
                                                name="bus_write">
                                                <option value="0">false</option>
                                                <option value="1">true</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-writable">Writable</label>
                                            <select class="form-control form-select" id="register-writable"
                                                name="writable">
                                                <option value="1">true</option>
                                                <option value="0">false</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-write_only">Write_only</label>
                                            <select class="form-control form-select" id="register-write_only"
                                                name="write_only">
                                                <option value="0">false</option>
                                                <option value="1">true</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-write_multiple">Write_multiple</label>
                                            <select class="form-control form-select" id="register-write_multiple"
                                                name="write_multiple">
                                                <option value="0">false</option>
                                                <option value="1">true</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-write_bitmask">Write_bitmask</label>
                                            <input class="form-control" id="register-write_bitmask" type="text"
                                                name="write_bitmask">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-read_count">Read_count</label>
                                            <input class="form-control" id="register-read_count" type="number" step="1"
                                                name="read_count">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-read_offset">Read_offset</label>
                                            <input class="form-control" id="register-read_offset" type="number" step="1"
                                                name="read_offset">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-value_delta">Value_delta</label>
                                            <input class="form-control" id="register-value_delta" type="number" step="1"
                                                name="value_delta">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-value_multiplier">Value_multiplier</label>
                                            <input class="form-control" id="register-value_multiplier" type="number"
                                                step="1" name="value_multiplier">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-value_bitmask">Value_bitmask</label>
                                            <input class="form-control" id="register-value_bitmask" type="number"
                                                step="1" name="value_bitmask">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-value_base">Value_base</label>
                                            <input class="form-control" id="register-value_base" type="number" step="1"
                                                name="value_base">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-value_custom">Value_custom</label>
                                            <input class="form-control" id="register-value_custom" type="text"
                                                name="value_custom" value="{}">

                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="register-value_default">Value_default</label>
                                            <select class="form-control form-select" id="register-value_default"
                                                name="value_default">
                                                <option value="no value">no value</option>
                                                <option value="0">false</option>
                                                <option value="1">true</option>
                                            </select>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer" id="sbtn">
                    <button type="button" class="btn btn-primary btn-save" onclick="saveRegister()">Save</button>
                    <button type="button" class="btn btn-secondary btn-cancel" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>


    <script type="text/javascript" src="js/jquery.min.js"></script>
    <script type="text/javascript" src="js/table-pagination.js"></script>
    <script type="text/javascript" src="js/bootstrap.bundle.min.js"></script>
    <script type="text/javascript" src="js/profiler.js"></script>
</body>

</html>