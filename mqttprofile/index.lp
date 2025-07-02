<?
    local red = require("redis").connect()

    local redis_key = "app:mqttprofile"

    require('json')
    require('apps')
    
    
    local function validate_imported_profile(profile_data)
        if type(profile_data) ~= "table" then
            return false, "Неверная структура JSON: не таблица."
        end
        if type(profile_data.name) ~= "string" then
            return false, "Неверное имя профиля."
        end
        if type(profile_data.description) ~= "string" then
            return false, "Неверное описание профиля."
        end
        if type(profile_data.mapping) ~= "table" then
            return false, "Неверный массив сопоставления."
        end
        return true
    end
    



    local function get_group_address(start_add)
        -- Проверяем, является ли входной параметр строкой
        if type(start_add) ~= "string" then
            return nil -- Возвращаем nil, если это не строка
        end

        local last_slash_index = nil
        local search_start_pos = 1

        -- Сначала находим индекс последнего слеша
        while true do
            local current_slash_start, current_slash_end = string.find(start_add, "/", search_start_pos, true)
            if current_slash_start then
                last_slash_index = current_slash_end -- Сохраняем КОНЕЦ найденного слеша
                search_start_pos = current_slash_end + 1 -- Продолжаем поиск после этого слеша
            else
                break -- Больше слешей нет
            end
        end

        -- Если слеш найден, извлекаем подстроку после него и начало адресса 
        if last_slash_index then
            local start_number = string.sub(start_add, last_slash_index + 1)
            return tonumber(start_number), string.sub(start_add, 1, last_slash_index)
        end
    end

    local function start_create_profile()
        local profile_new = {}
        profile_new.name = nil
        profile_new.description = nil
        profile_new.mapping = {}
        red:set(redis_key, json.encode(profile_new))
    end


    -- Функция сохранения-создания профиля
    local function save_profile(name, description)
    
        start_create_profile()
        local json_profile = red:get(redis_key)
        local profile_new = json.pdecode(json_profile)

        profile_new.name = name
        profile_new.description = description

        red:set(redis_key, json.encode(profile_new))
    end



    local function save_topic_out(topic, retain, qospub)
        local json_profile = red:get(redis_key)
        local profile_insert = json.pdecode(json_profile)

        local new_topic = {topic = "", direction = "", address = "",  
          retain = "", buswrite = "", qospub = "", qossub = "",
          delta = "", throttle = "", jsonpath = "", boolon = "", booloff = "", 
          name = "", datatype = "", tags = ""}

        new_topic.topic = topic
        new_topic.direction = "out"
        new_topic.retain = retain
        new_topic.qospub = qospub
        table.insert(profile_insert.mapping, new_topic)
        red:set(redis_key, json.encode(profile_insert))
    end



    local function save_topic_in(topic, delta, qossub, throttle, jsonpath)
        local json_profile = red:get(redis_key)
        local profile_insert = json.pdecode(json_profile)

        local new_topic = {topic = "", direction = "", address = "",  
          retain = "", buswrite = "", qospub = "", qossub = "",
          delta = "", throttle = "", jsonpath = "", boolon = "", booloff = "", 
          name = "", datatype = "", tags = ""}

        new_topic.topic = topic
        new_topic.delta = delta
        new_topic.throttle = throttle
        new_topic.qossub = qossub
        new_topic.jsonpath = jsonpath
        new_topic.direction = "in"

        table.insert(profile_insert.mapping, new_topic)
        red:set(redis_key, json.encode(profile_insert))
    end

    local function save_topic_both(topic, retain, qospub, delta, qossub, throttle, jsonpath)
        local json_profile = red:get(redis_key)
        local profile_insert = json.pdecode(json_profile)

        local new_topic = {topic = "", direction = "", address = "",  
          retain = "", buswrite = "", qospub = "", qossub = "",
          delta = "", throttle = "", jsonpath = "", boolon = "", booloff = "", 
          name = "", datatype = "", tags = ""}

        new_topic.topic = topic
        new_topic.delta = delta
        new_topic.throttle = throttle
        new_topic.qossub = qossub
        new_topic.jsonpath = jsonpath
        new_topic.direction = "both"
        new_topic.retain = retain
        new_topic.qospub = qospub

        table.insert(profile_insert.mapping, new_topic)
        red:set(redis_key, json.encode(profile_insert))
    end


    local function save_topic_object(datatype, tags, name_mapped, boolon, booloff, address)
        local json_profile = red:get(redis_key)
        local profile_insert = json.pdecode(json_profile)

        local last_i = #profile_insert.mapping
        profile_insert.mapping[last_i].name = name_mapped
        profile_insert.mapping[last_i].datatype = datatype
        profile_insert.mapping[last_i].tags = tags
        profile_insert.mapping[last_i].address = address
        

        if type(boolon) == "table" and #boolon > 0 then
            profile_insert.mapping[last_i].boolon = boolon[1] -- Берем первое значение
        else
            profile_insert.mapping[last_i].boolon = boolon or "" -- Иначе используем как есть или пустую строку
        end

        if type(booloff) == "table" and #booloff > 0 then
            profile_insert.mapping[last_i].booloff = booloff[1] -- Берем первое значение
        else
            profile_insert.mapping[last_i].booloff = booloff or "" -- Иначе используем как есть или пустую строку
        end

        red:set(redis_key, json.encode(profile_insert))
    end


    local function add_mass_address(start_add)
        local json_profile = red:get(redis_key)
        local profile_insert = json.pdecode(json_profile)
        local start_number, ostatok = get_group_address(start_add)
        for index, item in ipairs(profile_insert.mapping) do
            if item.address == "" then
                item.address = ostatok .. start_number
                start_number = start_number + 1
            end
        end
        red:set(redis_key, json.encode(profile_insert))
    end


    function add_mqtt_client()
        local json_profile = red:get(redis_key)
        local topics = json.pdecode(json_profile)
        
        dofile('/www/apps/data/mqtt-client/lua/lib.lua')
        for index, topic_object in ipairs(topics.mapping) do
            data = {
              direction = topic_object.direction,
              topic = topic_object.topic,
              address = topic_object.address,
              retain = topic_object.retain,
              buswrite = topic_object.buswrite,
              qospub = topic_object.qospub,
              qossub = topic_object.qossub,
              delta = topic_object.delta,
              throttle = topic_object.throttle,
              jsonpath = topic_object.jsonpath,
              boolon = topic_object.boolon,
              booloff = topic_object.booloff,
            }
            save_topic(data)
      end
    end

    function add_objects()
        local json_profile = red:get(redis_key)
        local profile_add = json.pdecode(json_profile)
        for index, topic_object in ipairs(profile_add.mapping) do
            if topic_object.address ~= "" then
                new_object = grp.create({
                    datatype = topic_object.datatype,
                    address = topic_object.address,
                    name = topic_object.name,
                    tags = topic_object.tags
                    })
            end
        end
    end

    local function get_profile()
        local json_profile = red:get(redis_key)
        
        if json_profile == nil then
            empty_ = {}
            return empty_
        else
            local topic_object = json.pdecode(json_profile)
            return topic_object
        end
    end

    local function delete_topic(topic_index)
        local json_profile = red:get(redis_key)
        local edit_profile = json.pdecode(json_profile)
        table.remove(edit_profile.mapping, topic_index)
        red:set(redis_key, json.encode(edit_profile))
    end





    -- Получение POST запросов

    if ngx.req.get_method() == "POST" then
        local args = getvars()

        -- Окно создания профиля
        if args.action == "create_profile" then
            save_profile(args.name, args.description)
            return ngx.redirect("/apps/data/mqttprofile")
        end

        -- Окно создания топика
        if args.action == "add_topic" then
            if args.direction == "in" then
                save_topic_in(args.topic, args.delta, args.qossub, args.throttle, args.jsonpath)
            elseif args.direction == "out" then
                save_topic_out(args.topic, args.retain, args.qospub)
            else 
                save_topic_both(args.topic, args.retain, args.qospub, args.delta, args.qossub, args.throttle, args.jsonpath)
            end

            save_topic_object(args.datatype, args.tags, args.name_mapped, args.boolon, args.booloff, args.address)
            return ngx.redirect("/apps/data/mqttprofile") 
        end

        -- Окно массово создания адрессов для объектов
        if args.action == "create_mass_add" then
            add_mass_address(args.start_add)
            return ngx.redirect("/apps/data/mqttprofile") 
        end

        -- Окно добавления объектов в лоджик
        if args.action == "add_objects" then
            add_objects()
            return ngx.redirect("/apps/data/mqttprofile")  
        end

        -- Окно добавления топиков в mqttclient
        if args.action == "add_mqtt_client" then
            add_mqtt_client()
            return ngx.redirect("/apps/data/mqttprofile")  
        end

        -- Удаление топика
        if args.action == "delete_topic" then
            delete_topic(args.topic_index)
            return ngx.redirect("/apps/data/mqttprofile") 
        end
        
        -- Удаление профиля
        if args.action == "delete_profile" then
            red:del(redis_key)
            return ngx.redirect("/apps/data/mqttprofile") 
        end
        
        -- Импорт профиля
        if args.action == "import_profile" then
            return ngx.redirect("/apps/data/mqttprofile") 
        end

    end
    
    -- GET запрос
    if ngx.req.get_method() == "GET" then
        local args = ngx.req.get_uri_args() 

        if args.action == "export_profile" then
            local profile_data = get_profile() 

            -- Проверяем, что профиль не пустой перед экспортом
            if profile_data and profile_data.name then
                local json_output = json.encode(profile_data)

                -- Устанавливаем заголовки для скачивания файла
                ngx.header.content_type = "application/json"
                ngx.header.content_disposition = 'attachment; filename="mqtt_profile_' .. (profile_data.name:gsub("%W", "_") or "default") .. '.json"'

                ngx.say(json_output)
                return ngx.exit(ngx.HTTP_OK)
            else
                ngx.status = ngx.HTTP_NOT_FOUND
                ngx.say("Профиль для экспорта не найден.")
                return ngx.exit(ngx.HTTP_NOT_FOUND)
            end
        end
    end
    
    profile = get_profile()
?>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <title>Title</title>
        <link rel="stylesheet" href="pico/pico.min.css">
        <link rel="stylesheet" href="custom_css/style.css">
    </head>
    <body>
        <a href="/apps/" class="close-app">×</a>
        <div class = "container">
            <header>
                <h2>MQTT PROFILE</h2>
            </header>
            
            <div class="top-right-buttons-container">
                <button id="showImportProfile" class="small-image-button" title="Import Profile">
                    <img src="icons/import.png" alt="Import">
                </button>
                <? if profile.name ~= nil then ?>
                    <a href="?action=export_profile" role="button" class="small-image-button" title="Export Profile">
                        <img src="icons/export.png" alt="Export">
                    </a>
                <? end ?>
            </div>

            <? if profile.name == nil then ?>
                <button class="center-button" id="showCreateProfile">Create Profile</button>
            <? else ?>
                <form method="post">
                    <input type="hidden" name="action" value="delete_profile">
                    <button type="submit" class="delete-profile-top-left">Delete Profile</button>
                </form>

                <div class="button-row-container">
                    <button id="showCreateTopic" class="button-inline">Create topic</button>
                    </div>

                <? if profile.mapping ~= nil and #profile.mapping > 0 then ?>
                    <div class="mass-action-buttons-container">
                        <button id="showCreateMassAdd" class="mass-action-button">Create mass address</button>
                        <button id="showAddObjects" class="mass-action-button">Create mapped objects</button>
                        <button id="showAddMqtt" class="mass-action-button">Add topics to Mqtt Client</button>
                    </div>
                <? end ?>
            <? end ?>

            
            
            <!-- Окошко создания профиля -->
            <div class="modal" id="modal_create_profile" style="display: none;">
                <form id = "Create_profile" method ="post">
                    <div class = "block">

                        <input type="hidden" name="action" value="create_profile">

                        <input type = "text" name = "name" placeholder = "Name" required>

                        <textarea name="description" 
                              placeholder="Description" 
                              rows="4" 
                              required></textarea>

                        <div class = "buttonrow">
                            <button class = "action-button" type = "submit">Save</button>
                            <button class = "action-button" id="cancel_profile" type="reset">Cancel</button>
                        </div>

                    </div>
                </form>
            </div>
            
            <!-- Окошко добавления топика -->
            <div class="modal" id="modal_create_topic" style="display: none;">
                <form id="Create_topic" method="post">
                    <div class="block">

                        <input type="hidden" name="action" value="add_topic">
                        
                        <h4> TOPIC INFO </h4>

                        <input type="text" name="topic" placeholder="Name" required>

                        <select name="direction" id="direction_select" required>
                            <option value="">-- направление --</option>
                            <option value="in">In</option>
                            <option value="out">Out</option>
                            <option value="both">Both</option>
                        </select>

                        <input type="text" name="address" placeholder="Address" class="always-visible">

                        <input type="hidden" name="pubonconnect" value="0">
                        <label class="direction-dependent direction-out direction-both">
                            <input type="checkbox" name="pubonconnect"> Pubonconnect
                        </label>



                        <input type="number" name="throttle" placeholder="Throttle" min="0" max="1000" class="direction-dependent direction-in direction-both">

                        <input type="hidden" name="retain" value="0">
                        <label class="direction-dependent direction-out direction-both">
                            <input type="checkbox" name="retain"> retain
                        </label>

                        <input type="hidden" name="buswrite" value="0">
                        <label class="direction-dependent direction-in direction-both">
                            <input type="checkbox" name="buswrite"> buswrite
                        </label>

                        <select name="qospub" class="direction-dependent direction-out direction-both">
                            <option value="">-- Publish QoS --</option>
                            <option value="0">0(At most once)</option>
                            <option value="1">1(At least once) - </option>
                            <option value="2">2(Exactly once)- </option>
                         </select>
                        
                        <select name="qossub" class="direction-dependent direction-in direction-both">
                            <option value="">-- Sub QoS --</option>
                            <option value="0">0(At most once)</option>
                            <option value="1">1(At least once) - </option>
                            <option value="2">2(Exactly once)- </option>
                        </select>
                        
                        <input type="text" name="delta" placeholder="Delta" class="direction-dependent direction-in direction-both">
                        <input type="text" name="jsonpath" placeholder="JSONPath" class="direction-dependent direction-in direction-both">
                        
                        <input type="hidden" name="booloff" value="" >
                        <label class="bool-dependent"> <input type="text" name="booloff" placeholder="booloff">
                        </label>
                        
                        <input type="hidden" name="boolon" value="">
                        <label class="bool-dependent"> <input type="text" name="boolon" placeholder="boolon">
                        </label>
                        
                        <h4> MAPPED OBJECT INFO </h4>
                        <select name="datatype" id="datatype_select" required>
                            <option value="">-- datatype --</option>
                            <option value="bool">Bool</option>
                            <option value="char">Char</option>
                            <option value="bit2">Bit2</option>
                            <option value="bit4">Bit4</option>
                            <option value="scale">Scale</option>
                        </select>
                        

                        <input type="text" name="tags" placeholder="Tags" class="always-visible" required>
                        <input type="text" name="name_mapped" placeholder="Name mapped object" class="always-visible" required>

                        <div class="buttonrow">
                            <button class="action-button" type="submit">Save</button>
                            <button class="action-button" id="cancel_topic" type="reset">Cancel</button>
                        </div>
                    </div>
                </form>
            </div>
            
            <!-- Окошко добавления множества адрессов -->
            <div class="modal" id="modal_create_mass_add" style="display: none;">
                <form id = "Create_mass_Add" method ="post">
                    <div class = "block">

                        <input type="hidden" name="action" value="create_mass_add">

                        <input type = "text" name = "start_add" placeholder = "Start address" required>

                        <div class = "buttonrow">
                            <button class = "action-button" type = "submit">Create</button>
                            <button class = "action-button" id="cancel_mass_add" type="reset">Cancel</button>
                        </div>

                    </div>
                </form>
            </div>
            
             <div class="modal" id="modal_add_objects" style="display: none;">
                <form id = "Add_objects" method ="post">
                    <div class = "block">

                        <input type="hidden" name="action" value="add_objects">

                        <div class = "buttonrow">
                            <button class = "action-button" type = "submit">Add</button>
                            <button class = "action-button" id="cancel_add_objects" type="reset">Cancel</button>
                        </div>

                    </div>
                </form>
            </div>
            
            <div class="modal" id="modal_add_mqtt" style="display: none;">
                <form id = "Add_mqtt" method ="post">
                    <div class = "block">

                        <input type="hidden" name="action" value="add_mqtt_client">

                        <div class = "buttonrow">
                            <button class = "action-button" type = "submit">Add</button>
                            <button class = "action-button" id="cancel_add_mqtt" type="reset">Cancel</button>
                        </div>

                    </div>
                </form>
            </div>
            
            <div class="modal" id="modal_import_profile" style="display: none;">
                <form id="Import_profile" method="post" enctype="multipart/form-data">
                    <div class="block">
                        <input type="hidden" name="action" value="import_profile">
                        <h4>Импорт MQTT Профиля</h4>
                        <input type="file" name="profile_file" accept=".json" required>
                        <div class="buttonrow">
                            <button class="action-button" type="submit">Импорт</button>
                            <button class="action-button" id="cancel_import_profile" type="reset">Отмена</button>
                        </div>
                    </div>
                </form>
            </div>
            
            
            
            <h3 class="profile-name-display">
                <?= escape(profile.name or "Нет имени профиля") ?>
            </h3>
            
            
            <table>
                <thead>
                    <tr>
                        <th>#</th>         <th>Direction</th> <th>Topic</th>     <th>Name</th>      <th>Действия</th>  
                    </tr>
                </thead>
                
                <tbody>
                    <?
                    if profile.mapping ~= nil then
                        for index, item in ipairs(profile.mapping) do
                            local direction = escape(item.direction or "")
                            local topic = escape(item.topic or "")
                            local name_mapped = escape(item.name or "")
                    ?>
                    <tr>
                        <td><?= index ?></td>
                        <td><?= direction ?></td>
                        <td><?= topic ?></td>
                        <td><?= name_mapped ?></td>
                        <td class="actions-cell">
                            <div class="topic-action-buttons">
                                <button class="table-button blue">Edit</button>
                                <form method="post" style="display: inline; margin-left: 5px;">
                                    <input type="hidden" name="action" value="delete_topic">
                                    <input type="hidden" name="topic_index" value="<?= index ?>">
                                    <button type="submit" class="table-button red">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <? end ?>
                    <? end ?>
                </tbody>
            </table>
            </div>
        </div>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
            // Получаем ссылки на элементы, предварительно проверяя их существование
            const showCreateProfileBtn = document.getElementById('showCreateProfile');
            const showCreateTopicBtn = document.getElementById('showCreateTopic');
            const showCreateMassAddBtn = document.getElementById('showCreateMassAdd');
            const showAddObjectsBtn = document.getElementById('showAddObjects');
            const showAddMqttBtn = document.getElementById('showAddMqtt');

            const cancelProfileBtn = document.getElementById('cancel_profile');
            const cancelTopicBtn = document.getElementById('cancel_topic');
            const cancelMassAddBtn = document.getElementById('cancel_mass_add');
            const cancelAddObjectsBtn = document.getElementById('cancel_add_objects');
            const cancelAddMqttBtn = document.getElementById('cancel_add_mqtt');

            const createProfileForm = document.getElementById('Create_profile');
            const modalCreateProfile = document.getElementById('modal_create_profile');

            const createTopicForm = document.getElementById('Create_topic');
            const modalCreateTopic = document.getElementById('modal_create_topic');

            const createMassAddForm = document.getElementById('Create_mass_Add');
            const modalCreateMassAdd = document.getElementById('modal_create_mass_add');

            const addObjectsForm = document.getElementById('Add_objects');
            const modalAddObjects = document.getElementById('modal_add_objects');

            const addMqttForm = document.getElementById('Add_mqtt');
            const modalAddMqtt = document.getElementById('modal_add_mqtt');

            const directionSelect = document.getElementById('direction_select');
            const datatypeSelect = document.getElementById('datatype_select');
            
            
            const showImportProfileBtn = document.getElementById('showImportProfile'); // New: Import button
            const cancelImportProfileBtn = document.getElementById('cancel_import_profile'); // New: Cancel Import button
            const importProfileForm = document.getElementById('Import_profile'); // New: Import form
            const modalImportProfile = document.getElementById('modal_import_profile'); // New: Import modal


            // Прикрепляем слушатели только в том случае, если элемент существует
            if (showCreateProfileBtn) {
                showCreateProfileBtn.addEventListener('click', () => {
                    if (createProfileForm) createProfileForm.style.display = 'block';
                    if (modalCreateProfile) modalCreateProfile.style.display = 'flex';
                });
            }

            if (showCreateTopicBtn) {
                showCreateTopicBtn.addEventListener('click', () => {
                    if (createTopicForm) createTopicForm.style.display = 'block';
                    if (modalCreateTopic) modalCreateTopic.style.display = 'flex';
                });
            }

            if (showCreateMassAddBtn) {
                showCreateMassAddBtn.addEventListener('click', () => {
                    if (createMassAddForm) createMassAddForm.style.display = 'block';
                    if (modalCreateMassAdd) modalCreateMassAdd.style.display = 'flex';
                });
            }

            if (showAddObjectsBtn) {
                showAddObjectsBtn.addEventListener('click', () => {
                    // Эта кнопка открывает форму "Add_objects", но action там "add_mqtt_client"
                    // Предполагаем, что вы имели в виду modal_add_objects и Add_objects.
                    if (addObjectsForm) addObjectsForm.style.display = 'block';
                    if (modalAddObjects) modalAddObjects.style.display = 'flex';
                });
            }

            if (showAddMqttBtn) {
                showAddMqttBtn.addEventListener('click', () => {
                    // Эта кнопка открывает форму "Add_mqtt", но action там "add_objects"
                    // Предполагаем, что вы имели в виду modal_add_mqtt и Add_mqtt.
                    if (addMqttForm) addMqttForm.style.display = 'block';
                    if (modalAddMqtt) modalAddMqtt.style.display = 'flex';
                });
            }
            
            if (showImportProfileBtn) {
                showImportProfileBtn.addEventListener('click', () => {
                    if (importProfileForm) importProfileForm.style.display = 'block';
                    if (modalImportProfile) modalImportProfile.style.display = 'flex';
                });
            }

            // Кнопки отмены
            if (cancelProfileBtn) {
                cancelProfileBtn.addEventListener('click', () => {
                    if (createProfileForm) createProfileForm.style.display = 'none';
                    if (modalCreateProfile) modalCreateProfile.style.display = 'none';
                });
            }

            if (cancelTopicBtn) {
                cancelTopicBtn.addEventListener('click', () => {
                    if (createTopicForm) createTopicForm.style.display = 'none';
                    if (modalCreateTopic) modalCreateTopic.style.display = 'none';
                });
            }

            if (cancelMassAddBtn) {
                cancelMassAddBtn.addEventListener('click', () => {
                    if (createMassAddForm) createMassAddForm.style.display = 'none';
                    if (modalCreateMassAdd) modalCreateMassAdd.style.display = 'none';
                });
            }

            if (cancelAddObjectsBtn) {
                cancelAddObjectsBtn.addEventListener('click', () => {
                    if (addObjectsForm) addObjectsForm.style.display = 'none';
                    if (modalAddObjects) modalAddObjects.style.display = 'none';
                });
            }

            if (cancelAddMqttBtn) {
                cancelAddMqttBtn.addEventListener('click', () => {
                    if (addMqttForm) addMqttForm.style.display = 'none';
                    if (modalAddMqtt) modalAddMqtt.style.display = 'none';
                });
            };
            
            if (cancelImportProfileBtn) {
                cancelImportProfileBtn.addEventListener('click', () => {
                    if (importProfileForm) importProfileForm.style.display = 'none';
                    if (modalImportProfile) modalImportProfile.style.display = 'none';
                });
            }

            // Делегирование событий для кнопок редактирования (уже хорошо)
            document.addEventListener('click', function(event) {
                if (event.target.classList.contains('edit-topic-btn')) {
                    const row = event.target.closest('tr');
                    const index = row.querySelector('td:first-child').textContent;
                    alert('Редактировать топик по индексу: ' + index);
                }
            });

            // Ваша логика видимости полей формы (уже была)
            // Убедитесь, что она также внутри DOMContentLoaded
            function updateFieldVisibility() {
                const selectedDirection = directionSelect ? directionSelect.value : '';
                const selectedDatatype = datatypeSelect ? datatypeSelect.value : '';

                // ... (остальной код updateFieldVisibility)
                const directionDependentFields = document.querySelectorAll('.direction-dependent');
                const boolDependentFields = document.querySelectorAll('.bool-dependent');
                const topicField = document.querySelector('input[name="topic"]');
                const alwaysVisibleFields = document.querySelectorAll('.always-visible');

                function setRequired(field, isRequired) {
                    if (field) {
                        if (isRequired) {
                            if (!field.hasAttribute('data-original-required')) {
                                field.setAttribute('data-original-required', 'true');
                            }
                            field.required = true;
                        } else {
                            field.required = false;
                        }
                    }
                }

                directionDependentFields.forEach(field => {
                    field.style.display = 'none';
                    setRequired(field, false);
                });

                boolDependentFields.forEach(field => {
                    field.style.display = 'none';
                    setRequired(field, false);
                });

                if (topicField) {
                    topicField.style.display = '';
                    setRequired(topicField, true);
                }
                alwaysVisibleFields.forEach(field => {
                    field.style.display = '';
                });

                if (selectedDirection === 'out') {
                    document.querySelectorAll('.direction-out').forEach(field => {
                        field.style.display = '';
                        if (field.hasAttribute('data-original-required')) {
                            setRequired(field, true);
                        }
                    });
                } else if (selectedDirection === 'in') {
                    document.querySelectorAll('.direction-in').forEach(field => {
                        field.style.display = '';
                        if (field.hasAttribute('data-original-required')) {
                            setRequired(field, true);
                        }
                    });
                } else if (selectedDirection === 'both') {
                    document.querySelectorAll('.direction-in, .direction-out').forEach(field => {
                        field.style.display = '';
                        if (field.hasAttribute('data-original-required')) {
                            setRequired(field, true);
                        }
                    });
                }

                if (selectedDatatype === 'bool') {
                    boolDependentFields.forEach(field => {
                        field.style.display = '';
                        if (field.hasAttribute('data-original-required')) {
                            setRequired(field, true);
                        }
                    });
                }
            }

            // Сохраняем исходное состояние required
            document.querySelectorAll('input[required], select[required], textarea[required]').forEach(field => {
                if (field.required) {
                    field.setAttribute('data-original-required', 'true');
                }
            });

            // Инициализируем видимость
            updateFieldVisibility();

            // Добавляем слушатели событий для обоих select (если они существуют)
            if (directionSelect) {
                directionSelect.addEventListener('change', updateFieldVisibility);
            }
            if (datatypeSelect) {
                datatypeSelect.addEventListener('change', updateFieldVisibility);
            }
        });
        </script>
    </body>
</html>