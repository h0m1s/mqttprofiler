// list of parameters
const parameters = [
  // capital parameters
  [
    'manufacturer',
    'description',
    'read_delay',
    'read_swap'
  ],
  // base parameters
  [
    'name',
    'type',
    'bus_datatype',
    'address'
  ],
  // optional parameters
  [
    'datatype',
    'units',
    'internal',
    'address_scale',
    'bus_address',
    'bus_write',
    'writable',
    'write_only',
    'write_multiple',
    'write_bitmask',
    'read_count',
    'read_offset',
    'value_delta',
    'value_multiplier',
    'value_bitmask',
    'value_base',
    'value_custom',
    'value_default'
  ]
]


var str = '<tr class="register" id="register_NUM">\
              <td class="id-num">NUM</td>\
              <td>NAME</td>\
              <td>TYPE</td>\
              <td>BUS_DATATYPE</td>\
              <td>ADDRESS</td>\
              <td>OTHER</td>\
              <td>\
                  <div style="float: right;">\
                      <button class="btn btn-sm btn-primary fa fa-pencil pin-add"\
                      type="button" onclick="setRegister(register_NUM)"\
                      data-bs-toggle="modal" data-bs-target="#RegisterModal">\
                      </button>\
                      \
                      <button class="btn btn-sm btn-primary fa fa-times fa-solid\
                      fa-book pin-read" type="button" onclick="readTestReg(register_NUM)"\
                      data-bs-toggle="modal" data-bs-target="#readTestModal">\
                      </button>\
                      \
                      <button class="btn btn-sm btn-primary fa fa-times pin-del" type="button"\
                      onclick="deleteRegister(register_NUM)">\
                      </button>\
                  </div>\
              </td>\
            </tr>';


var last_id = 0;
var data = [];
var global_regime = 'add';
var current;







function setPagination() {
  if ($('.page-list-table-v_table').length) {
    let dataPageId = $('.table-pagination-pagination-num-v_table.active').attr('data-page-id');
    $(function () {
      $('#v_table').createTablePagination({
        rowPerPage: 10,
        paginationColor: '#337AB7',
        active_id: dataPageId,
      });
    });
  } else {
    $(function () {
      $('#v_table').createTablePagination({
        rowPerPage: 10,
        paginationColor: '#337AB7',
      });
    });
  }
}


// marking of optional parameters
$(document).ready(function () {
  let options = parameters[2];
  for (i = 0; i < options.length; i++) {
    let option = '#option-' + options[i];
    let field = '#register-' + options[i];
    $(option).change(function () {
      if ($(this).is(':checked')) {
        $(field).show();
        $(field).parent().show();
      } else {
        $(field).hide();
        $(field).parent().hide();
      }
    });
  }
});


function hideOption(parameter) {
  let option = '#option-' + parameter;
  let field = '#register-' + parameter;
  $(option).hide();
  $(option).parent().hide();
  $(field).hide();
  $(field).parent().hide();
}


function showOption(name) {
  let option = '#option-' + name;
  let field = '#register-' + name;
  $(option).show();
  $(option).parent().show();
  if ($(option).prop('checked')) {
    $(field).show();
    $(field).parent().show();
  }
}


// implementation of parameter dependencies on the data type
$(document).ready(function () {
  $('#register-type').change(function () {
    if ($(this).val() == 'register' || $(this).val() == 'inputregister') {
      hideOption("value_default");
    } else {
      showOption("value_default");
    }

    if ($(this).val() == 'coil' || $(this).val() == 'discreteinput') {
      hideOption('datatype');
      hideOption('value_delta');
      hideOption('value_base');
      hideOption('value_multiplier');
      hideOption('value_bitmask');
      hideOption('write_bitmask');
      hideOption('value_nan');
      hideOption('units');
      hideOption('address_scale');
      hideOption('internal');
    } else {
      showOption('datatype');
      showOption('value_delta');
      showOption('value_base');
      showOption('value_multiplier');
      showOption('value_bitmask');
      showOption('write_bitmask');
      showOption('value_nan');
      showOption('units');
      showOption('address_scale');
      showOption('internal');
    }
  });
});
// почему js код исполняется в input

//gets all the information from the form
function pullRegister(id) {
  let form = document.forms.RegisterForm;
  let register = {};
  register["id"] = "#register_" + id;
  for (i = 0; i < form.elements.length; i++) {
    let elem = form.elements[i];
    let id = "#" + elem.id;
    let name = elem.name;
    let value = elem.value;
    if ($(id).is(':visible') == true && name.includes("checkbox") == false) {
      register[name] = value;
    }
  }

  return register
}


function createRegister(register, id, str) {

  function limitText(text, maxChars) {
    if (text.length > maxChars) {
      return text.slice(0, maxChars);
    }
    return text;
  }

  let base_options = ['id', 'name', 'type', 'bus_datatype', 'address'];
  let checkbox_options = ['internal', 'bus_write', 'writable', 'write_only', 'write_multiple', 'value_default'];
  let other = '';

  for (let key in register) {
    if (base_options.includes(key) == false) {
      if (checkbox_options.includes(key) == false) {
        if (key == "value_custom") {
          other = other + key + '; ';
        } else {
          other = other + key + '=' + register[key] + '; ';
        }
      } else {
        if (register[key] == 1) {
          other = other + key + '; ';
        } else {
          other = other + key + '=' + register[key] + '; ';
        }
      }
    }
  }
  // напиши код, который будет получать текстовую переменную и ограничивать его по количеству символов
  

  str = str.replace(/NUM/g, id);
  str = str.replace(/NAME/g, limitText(register["name"], 25));
  str = str.replace(/BUS_DATATYPE/g, register["bus_datatype"]);
  str = str.replace(/TYPE/g, register["type"]);
  str = str.replace(/ADDRESS/g, register["address"]);
  str = str.replace(/OTHER/g, other);

  return str
}


function addRegister() {
  let piece = pullRegister(last_id);
  data.push(piece);
  let reg = createRegister(piece, last_id, str);
  $('#v_table').append(reg);
  last_id++;
  $('#RegisterModal').modal('hide');
  $('#edit-table tr td').hide();
  $("#RegisterForm")[0].reset();
  setPagination();
}


$('#add-mapping-entry').click(function () {
  hideOption('datatype');
  hideOption('value_delta');
  hideOption('value_base');
  hideOption('value_multiplier');
  hideOption('value_bitmask');
  hideOption('write_bitmask');
  hideOption('value_nan');
  hideOption('units');
  hideOption('address_scale');
  hideOption('internal');
  showOption("value_default");
  $('#edit-table tr td').hide();
  $("#RegisterForm")[0].reset();
});


function saveRegister() {
  if (global_regime == "add") {
    addRegister();
    console.log(data);
  } else {
    editRegister(current);
    console.log(data);
  }
}


function deleteAll() {
  $(".register").remove();
  last_id = 0;
  data = [];
  console.log(data);

  setPagination();
}


function deleteRegister(register) {
  let index = data.findIndex(element => element.id === '#' + register.id);
  data.splice(index, 1);
  $(register).remove();
  console.log(data);

  setPagination();
}


function setRegister(reg) {

  function setValue(name, value) {
    let option = '#option-' + name;
    let field = '#register-' + name;
    $(option).prop('checked', true);
    $(field).show();
    $(field).parent().show();
    $(field).val(value);
  }

  global_regime = "edit";
  $('#edit-table tr td').hide();
  $("#RegisterForm")[0].reset();
  let index = data.findIndex(element => element.id === "#" + reg.id);
  let register = data[index];
  current = register;
  $('#register-name').val(register["name"]);
  $('#register-type').val(register["type"]);
  $('#register-bus_datatype').val(register["bus_datatype"]);
  $('#register-address').val(register["address"]);

  let options = parameters[2];
  for (key in register) {
    if (options.includes(key)) {
      setValue(key, register[key])
    }
  }
}


function editRegister(reg) {
  let id = reg.id;
  let index = data.findIndex(element => element.id === id);

  for (let prop in data[index]) {
    delete data[index][prop];
  }

  let arr = id.split("_");
  let current_id = arr[1];
  let new_reg = pullRegister(current_id);
  data[index] = new_reg;
  let register = createRegister(new_reg, current_id, str);
  $(id).replaceWith(register);
  $('#RegisterModal').modal('hide');
  $('#edit-table tr td').hide();
  $("#RegisterForm")[0].reset();
  global_regime = "add";
}


function createProfile() {
  let jsonData;
  var manufacturer = $('#manufacturer').val();
  let regex = /[^a-zA-Z0-9]/g;
  manufacturer = manufacturer.replace(regex, '_');
  let description = $('#description').val();
  let read_swap = $('#read_swap').val();
  let read_delay = $('#read_delay').val();
  let mapping = [];

  for (i = 0; i < data.length; i++) {
    let newObj = Object.assign({}, data[i]);
    delete newObj.id;
    mapping.push(newObj);
  }

  if (read_delay == 0 || read_swap == "-") {
    jsonData = {
      manufacturer: manufacturer,
      description: description,
      mapping: mapping
    }
  } else {
    jsonData = {
      manufacturer: manufacturer,
      description: description,
      read_swap: read_swap,
      read_delay: read_delay,
      mapping: mapping
    }
  }

  return jsonData
}


function downloadProfileToPC() {
  let manufacturer = $('#manufacturer').val();
  let description = $('#description').val();

  if (manufacturer == "" || manufacturer == " ") {
    alert("You have not filled in the manufacturer field. Please fill it out for further work");
  } else if (description == "" || description == " ") {
    alert("You have not filled in the description field. Please fill it out for further work");
  } else {
    let regex = /[^a-zA-Z0-9]/g;
    manufacturer = manufacturer.replace(regex, '_');
    let jsonData = createProfile();
    let content = JSON.stringify(jsonData);
    let fileName = String(jsonData.manufacturer) + " - " + String(jsonData.description) + ".json";
    let contentType = "text/plain";
    let a = document.createElement("a");
    let file = new Blob([content], {
      type: contentType
    });
    a.href = URL.createObjectURL(file);
    a.download = fileName;
    a.click();
  }
}


function saveProfileToLM() {
  let manufacturer = $('#manufacturer').val();
  let regex = /[^a-zA-Z0-9]/g;
  manufacturer = manufacturer.replace(regex, '_');
  let description = $('#description').val();
  let jsonData = createProfile();
  let content = JSON.stringify(jsonData);
  let profile_name = String(jsonData.manufacturer);

  if (manufacturer == "" || manufacturer == " ") {
    alert("You have not filled in the manufacturer field. Please fill it out for further work");
  } else if (description == "" || description == " ") {
    alert("You have not filled in the description field. Please fill it out for further work");
  } else {
    $.post('lua/get_list.lp', function (data) {
      let db_list;
      let lm_list;
      db_list = data.replace(/-- /g, '');
      // db_list = JSON5.parse(db_list);
      db_list = JSON.parse(db_list);

      for (i = 0; i < db_list.length; i++) {
        let name = db_list[i]['name'];
        lm_list = lm_list + name;
      }

      if (lm_list.includes(profile_name)) {
        // имя не уникально
        let question = confirm("A profile with this name already exists. Overwrite a file with this name?");
        if (question == true) {
          // перезаписать
          $.post('lua/handler.lp', {
            content,
            manufacturer,
            description
          });
        }
      } else {
        // имя уникально
        $.post('lua/handler.lp', {
          content,
          manufacturer,
          description
        });
      }
    });
  }
}


function setProfile(jsonData) {
  if (!jsonData) {
    return;
  }
  deleteAll();

  // var content = JSON5.parse(jsonData);
  let content = JSON.parse(jsonData);
  let mapping = content.mapping;
  data = mapping;
  for (i = 0; i < mapping.length; i++) {
    data[i].id = "#register_" + i
  }

  $('#manufacturer').val(content.manufacturer);
  $('#description').val(content.description);
  if (content.hasOwnProperty('read_delay')) {
    $('#read_delay').val(content.read_delay);
  }
  if (content.hasOwnProperty('read_swap')) {
    $('#read_swap').val(content.read_swap);
  }

  for (i = 0; i < mapping.length; i++) {
    let reg = createRegister(mapping[i], last_id, str);
    $('#v_table').append(reg);
    last_id++;
  }

  setPagination();
}


(function () {

  function onChange(event) {
    let reader = new FileReader();
    reader.onload = onReaderLoad;
    reader.readAsText(event.target.files[0]);
  }

  function onReaderLoad(event) {
    result = confirm('This action will result in the loss of existing data. Continue?');
    if (result == true) {

      let obj = event.target.result;
      setProfile(obj);
    }
  }

  document.getElementById('file').addEventListener('change', onChange);
}());


function openProfilesFromLM() {
  $.post('lua/get_list.lp', function (data) {
    let db_list;
    db_list = data.replace(/-- /g, '');
    // db_list = JSON5.parse(db_list);
    db_list = JSON.parse(db_list);
    $(".profile-from-lm").remove();
    db_list.sort();

    for (i = 0; i < db_list.length; i++) {
      let name = db_list[i]['name'];
      let string = '<tr>\
                      <td class="profile-from-lm" id="profile-name_' + i + '">' + name + '.json</td>\
                    </tr>';
      $('#profiles-selection').append(string);
    }
  });
}


function selectProfile(profile) {
  if (profile.includes('profile-name_') == true) {
    $.post('lua/get_list.lp', function (data) {
      let db_list;
      db_list = data.replace(/-- /g, '');
      // db_list = JSON5.parse(db_list);
      db_list = JSON.parse(db_list);
      let value = profile.split('profile-name_');
      let name = db_list[Number(value[1])]['name'];

      result = confirm('By opening a new file, the existing data will be lost. Continue?');
      if (result == true) {
        deleteAll();
        $.post('lua/open_file.lp', {
          name
        }, function (data) {
          let content = data;
          setProfile(content);
          $('#openLogicModal').modal('hide'); // скрыть
        });
      }
    });
  }
}

document.addEventListener('click', e => selectProfile(e.target.id));


$("#read_test").on('click', (function () {
  event.preventDefault();
  var $form = $('#read-test');
//   console.log($form.serialize());
  $.post(
    'lua/read_test.lp',
    $form.serialize(),
    function (data) {
      alert(data);
      console.log(data);
    }
  );
}));


function setReadTest() {
  $("#datatype_test").hide();
  $("#datatype_test").parent().hide();
  $("#read_lenght_test").hide();
  $("#read_lenght_test").parent().hide();
  $("#read_swap_test").show();
  $("#read_swap_test").parent().show();
  $(".ip_address").show();
  $("#read-test")[0].reset();
}

$(document).ready(function () {
  $('#datatype_test').change(function () {
    if ($(this).val() == '-') {
      $("#read_lenght_test").hide();
      $("#read_lenght_test").parent().hide();
      $("#read_swap_test").show();
      $("#read_swap_test").parent().show();
    } else {
      $("#read_lenght_test").show();
      $("#read_lenght_test").parent().show();
      $("#read_swap_test").hide();
      $("#read_swap_test").parent().hide();
    }
  });

  $('#func').change(function () {
    if ($(this).val() == "hregister" || $(this).val() == "iregister") {
      $("#datatype_test").show();
      $("#datatype_test").parent().show();
    } else {
      $("#datatype_test").hide();
      $("#datatype_test").parent().hide();
      $("#read_lenght_test").hide();
      $("#read_lenght_test").parent().hide();
    }
  });

  $(function () {
    $('input[type="radio"]').on('change', function () {
      if (($(this).val() == 'RTU1') || ($(this).val() == 'RTU2') || ($(this).val() == 'RTU3')) {
        $(".ip_address").hide();
      } else {
        $(".ip_address").show();
      }
    });
  });
});


function readTestReg(register) {
  let index = data.findIndex(element => element.id === "#" + register.id);

  let address = data[index]["address"];
  $("#addr").val(address);

  if (data[index].hasOwnProperty('read_swap')) {
    let read_swap = document.getElementById('read_swap').value;
    $('#read_swap_test').val(read_swap);
  }

  if (data[index].hasOwnProperty('datatype')) {
    $("#read_lenght_test").show();
    $("#read_lenght_test").parent().show();
    $("#read_swap_test").hide();
    $("#read_swap_test").parent().hide();
    $("#datatype_test").show();
    $("#datatype_test").parent().show();
    let datatype = data[index]["datatype"];
    $("#datatype_test").val(datatype);
  }
}





var vc_str = '<div class="row vc-block" id="vc_str_VC_NUM" style="margin-bottom: 25px;">\
                <div class="col-3 form-group">\
                    <label class="" for="vc-value">Value</label>\
                    <input class="form-control" id="vc-value" type="number" name="value" value="0">\
                </div>\
                <div class="col-7 form-group">\
                    <label class="" for="vc-display_text">Display text</label>\
                    <input class="form-control" id="vc-display_text" type="text" name="display_text">\
                </div>\
                <div class="col-2 form-group">\
                    <button style="margin-top: 30px;"\
                        class="btn btn-sm btn-primary fa fa-times pin-del pin-vc-del" type="button"\
                        onclick="delVC(VC_NUM)">\
                    </button>\
                </div>\
              </div>';

var vc_id = 0;

var register_value_custom = document.querySelector('#register-value_custom');

register_value_custom.addEventListener('click', function () {
  openVC();
  $('#VC_edit').modal('show');
});


function addVC(str) {
  vc_id++;
  str = str.replace(/VC_NUM/g, vc_id);
  $("#vc_form").append(str);
}


function delVC(id) {
  let str = '#vc_str_' + id;
  console.log(str);
  $(str).remove();
}

// напиши JS JQ код, который будет считать количество атрибутов в объекте


function saveVC() {
  let jsonObject = {};
  let vcForm = document.getElementById("vc_form");
  let elements = vcForm.getElementsByClassName("row vc-block");
  let count = elements.length;

  let default_text = $('#vc-default_text').val();
  jsonObject["default text"] = default_text;

  for (i = 0; i < count; i++) {
    let name = "#vc_str_" + i + " input";
    
    $(name).each(function() {
      let n = $(this).attr('name') + '_' + i
      jsonObject[n] = $(this).val();
    });
  }

  let jsonString = JSON.stringify(jsonObject);
  $('#register-value_custom').val(jsonString);
  console.log(jsonString);

}


function openVC() {
  let jsonObject = JSON.parse($('#register-value_custom').val());

  $('#vc-default_text').val(jsonObject['default text']);
  

  delete jsonObject['default text'];
  console.log(jsonObject);
  var count = Object.keys(jsonObject).length;

  let displaytext = 'display_text_' + 0;
  let value = 'value_' + 0;
  $('#vc-value').val(jsonObject[value]);
  $('#vc-display_text').val(jsonObject[displaytext]);


  

  for (i = 1; i < count/2; i++) {

  }




  for (i = 1; i < count/2; i++) {
    let displaytext = 'display_text_' + i;
    let value = 'value_' + i;
    console.log(jsonObject[displaytext]);
    console.log(jsonObject[value]);

    let val = '#vc_str_' + i + ' #vc-value';
    let disp = '#vc_str_' + i + ' #vc-display_text';

    addVC(vc_str);
    $(val).val(jsonObject[value]);
    $(disp).val(jsonObject[displaytext]);


  }



  // for (i = 0; i < count; i++) {
  //   console.log(jsonObject[]);
  //   console.log();



  //   let name = "#vc_str_" + i + " input";
  //   $(name).each(function() {
  //     jsonObject[$(this).attr('name')] = $(this).val();
  //   });
  // }

}