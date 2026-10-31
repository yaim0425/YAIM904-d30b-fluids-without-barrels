---------------------------------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Información del MOD ]---
---------------------------------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.reference_values()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- Crear las recetas para los fluidos
    This_MOD.create_item___convert()
    This_MOD.create_recipe___convert()

    --- Ejecutar otro MOD
    if GMOD.d01b then
        --- Cambiar el tamaño de la entidad
        GMOD.d01b.start()
    else
        --- Fijar las posiciones actual
        GMOD.d00b.change_orders()
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.reference_values()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar si se cargó antes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- Indicador del mod
    This_MOD.delete = { icon =  GMOD.signal.deny, scale = 0.15, shift = { 14, -14 } }
    This_MOD.create = { icon = GMOD.signal.check, scale = 0.15, shift = { 14, -14 } }

    This_MOD.indicator    = { icon = GMOD.signal.star,  scale = 0.25, shift = { 0, -5 } }
    This_MOD.indicator_bg = { icon = GMOD.signal.black, scale = 0.25, shift = { 0, -5 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de referencia
    This_MOD.old_entity_name = "assembling-machine-2"
    This_MOD.new_entity_name = GMOD.name .. "-A00A-market"
    This_MOD.new_localised_name = { "", { "entity-name.market" } }

    --- Acciones
    This_MOD.actions = {
        delete = "ingredients",
        create = "results"
    }

    --- Receta base
    This_MOD.recipe_base = {
        type = "recipe",
        name = "",
        localised_name = {},
        localised_description = {},
        energy_required = 0.01,

        hide_from_player_crafting = true,
        subgroup = "",
        order = "",

        ingredients = {},
        results = {}
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Cambios del MOD ]---
---------------------------------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_entity(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar valores de referencia
        if GMOD.entities[This_MOD.new_entity_name] then return end

        --- Validar la entity
        if not entity then return end

        --- Validar el item
        if not item then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
        This_MOD.to_be_processed[entity.type][entity.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Fluidos a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function get_fluids()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Variable a usar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Output = {}

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validar el fluido
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local function validate(element)
            if element.type ~= "fluid" then return end

            local Temperatures = Output[element.name] or {}
            Output[element.name] = Temperatures

            if element.maximum_temperature then
                Temperatures[element.maximum_temperature] = true
            elseif element.temperature then
                Temperatures[element.temperature] = true
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Obtener los fluidos
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Todos los fluidos
        if This_MOD.setting.all then
            --- Fluidos creados con recetas
            for _, recipe in pairs(data.raw.recipe) do
                for _, elements in pairs({
                    recipe.ingredients,
                    recipe.results
                }) do
                    for _, element in pairs(elements) do
                        validate(element)
                    end
                end
            end

            --- Fluidos creados sin recetas
            for _, entity in pairs(GMOD.entities) do
                repeat
                    --- Validación
                    if not entity.output_fluid_box then break end
                    if entity.output_fluid_box.pipe_connections == 0 then break end
                    if not entity.output_fluid_box.filter then break end
                    if not entity.target_temperature then break end

                    --- Renombrar variable
                    local Name = entity.output_fluid_box.filter

                    --- Guardar la temperatura
                    local Temperatures = Output[Name] or {}
                    Output[Name] = Temperatures
                    Temperatures[entity.target_temperature] = true
                until true
            end
        end

        --- Solo los fluidos en la naturaleza
        if not This_MOD.setting.all then
            --- Fluidos tomados del suelo
            for _, tile in pairs(data.raw.tile) do
                if tile.fluid then
                    Output[tile.fluid] = {}
                end
            end

            --- Fluidos minables
            for _, resource in pairs(data.raw.resource) do
                local results = resource.minable
                results = results and results.results or {}
                for _, result in pairs(results) do
                    validate(result)
                end
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Dar el formato deseado
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        for fluid_name, temperatures in pairs(Output) do
            if not GMOD.get_length(temperatures) then
                Output[fluid_name] = false
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Devolver el resultado
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return Output

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Entidad que se va a duplicar
    validate_entity(
        GMOD.items[This_MOD.old_entity_name],
        GMOD.entities[This_MOD.old_entity_name]
    )

    --- Fluidos a afectar
    This_MOD.fluids = get_fluids()

    --- Recorrer cada fluidos
    This_MOD.items = {}
    for _, propiety in pairs(This_MOD.actions) do
        for fluid, temperatures in pairs(This_MOD.fluids) do
            if GMOD.fluids[fluid] then
                for temperature, _ in pairs(temperatures or { [false] = true }) do
                    This_MOD.add_item({
                        fluid = GMOD.fluids[fluid],
                        propiety = propiety,
                        temperature = temperature or nil,
                    })
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.add_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de la info
    local Space = {}

    --- Guardar el objeto
    Space.fluid = space.fluid

    --- Separar el nombre
    local That_MOD =
        GMOD.get_id_and_name(space.fluid.name) or
        { ids = "-", name = space.fluid.name }

    --- Valores comunes
    local Prefix =
        GMOD.name .. That_MOD.ids ..
        This_MOD.id .. "-"

    local Amount =
        This_MOD.setting.stack_size .. "ss-" ..
        That_MOD.name

    --- Bandera de usar la temperatura
    local Flag = space.propiety == This_MOD.actions.create and space.temperature

    --- Nombre del objeto
    local Name =
        Prefix ..
        Amount ..
        (Flag and "-t" .. math.floor(space.temperature) or "")

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar si ya existe
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if GMOD.items[Name] then return end
    if GMOD.items[Prefix .. "d30b-" .. Amount] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Incluir la temperatura en el nombre
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Space.localised_name = GMOD.copy(space.fluid.localised_name)
    if Flag then
        table.insert(Space.localised_name, " (")
        table.insert(Space.localised_name, "" .. math.floor(space.temperature))
        table.insert(Space.localised_name, " °C)")
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Subgroup
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    That_MOD =
        GMOD.get_id_and_name(space.fluid.subgroup) or
        { ids = "-", name = space.fluid.subgroup }

    Prefix =
        GMOD.name .. That_MOD.ids ..
        This_MOD.id .. "-"

    Space.subgroup =
        Prefix ..
        That_MOD.name

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Guardar los valores
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.items[Name] = Space

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Item.name = This_MOD.new_entity_name

    --- Apodo
    Item.localised_name = This_MOD.new_localised_name

    --- Actualizar el order
    local Order = tonumber(Item.order) + 1
    Item.order = GMOD.pad_left_zeros(#Item.order, Order)

    --- Agregar indicador del MOD
    table.insert(Item.icons, This_MOD.indicator_bg)
    table.insert(Item.icons, This_MOD.indicator)

    --- Entidad a crear
    Item.place_result = This_MOD.new_entity_name

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(space.entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Entity.name = This_MOD.new_entity_name

    --- Apodo
    Entity.localised_name = This_MOD.new_localised_name

    --- Objeto a minar
    Entity.minable.results = { {
        type = "item",
        name = This_MOD.new_entity_name,
        amount = 1
    } }

    --- Elimnar propiedades inecesarias
    Entity.fast_replaceable_group = nil
    Entity.effect_receiver = nil
    Entity.next_upgrade = nil

    --- No usa energía
    Entity.energy_source = { type = "void" }

    --- Categoria de fabricación
    Entity.crafting_categories = {}

    --- Agregar indicador del MOD
    Entity.icons = GMOD.copy(space.item.icons)
    table.insert(Entity.icons, This_MOD.indicator_bg)
    table.insert(Entity.icons, This_MOD.indicator)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.recipe then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(space.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Recipe.name = This_MOD.new_entity_name

    --- Apodo y descripción
    Recipe.localised_name = This_MOD.new_localised_name

    --- Elimnar propiedades inecesarias
    Recipe.main_product = nil

    --- Receta desbloqueada por tecnología
    Recipe.enabled = true

    --- Agregar indicador del MOD
    Recipe.icons = GMOD.copy(space.item.icons)
    table.insert(Recipe.icons, This_MOD.indicator_bg)
    table.insert(Recipe.icons, This_MOD.indicator)

    --- Ingredientes
    Recipe.ingredients = {}

    --- Resultados
    Recipe.results = { {
        type = "item",
        name = This_MOD.new_entity_name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.create_item___convert()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer cada fluidos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for name, space in pairs(This_MOD.items) do
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local item = GMOD.get_tables(This_MOD.to_be_processed, "type", "item") or {}
        item = GMOD.copy(item[1])

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el subgrupo para el objeto
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Duplicar el subgrupo
        if not GMOD.subgroups[space.subgroup] then
            GMOD.duplicate_subgroup(space.fluid.subgroup, space.subgroup)

            --- Renombrar
            local Subgroup = GMOD.subgroups[space.subgroup]
            local Order = GMOD.subgroups[space.subgroup].order
            local Index = space.propiety == This_MOD.actions.create and 1 or 2

            --- Actualizar el order
            Subgroup.order = Index .. Order:sub(2)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre
        item.name = name

        --- Elimnar propiedades
        item.place_result = nil
        item.localised_description = nil

        -- Actualizar propiedades
        item.localised_name = space.localised_name
        item.subgroup = space.subgroup
        item.stack_size = 10

        --- Copiar propiedades
        item.icon = space.fluid.icon
        item.icons = space.fluid.icons
        item.order = space.fluid.order

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(item)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe___convert()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Procesar cada liquido
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_fluid(space)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores a usar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre de la receta
        local Name =
            This_MOD.prefix ..
            space.action .. "-" ..
            This_MOD.setting.stack_size .. "ss-" ..
            space.fluid.name ..
            (space.temperature and "-t" .. math.floor(space.temperature) or "")

        local Name_item =
            This_MOD.prefix ..
            This_MOD.setting.stack_size .. "ss-" ..
            space.fluid.name ..
            (space.temperature and "-t" .. math.floor(space.temperature) or "")

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if data.raw.recipe[Name] then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Recipe = GMOD.copy(This_MOD.recipe_base)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre
        Recipe.name = Name

        --- Apodo y descripción
        Recipe.localised_name = GMOD.copy(space.fluid.localised_name)
        Recipe.localised_description = { "" }

        --- Subgrupo y Order
        Recipe.subgroup =
            This_MOD.prefix ..
            space.fluid.subgroup .. "-" ..
            space.action

        Recipe.order = space.fluid.order

        --- Agregar indicador del MOD
        Recipe.icons = GMOD.copy(space.fluid.icons)

        --- Categoria de fabricación
        Recipe.category = This_MOD.prefix .. space.action

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el subgrupo para el objeto
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Duplicar el subgrupo
        if not GMOD.subgroups[Recipe.subgroup] then
            GMOD.duplicate_subgroup(space.fluid.subgroup, Recipe.subgroup)

            --- Renombrar
            local Subgroup = GMOD.subgroups[Recipe.subgroup]
            local Order = GMOD.subgroups[space.fluid.subgroup].order
            local Index = space.propiety == This_MOD.actions.create and 1 or 2

            --- Actualizar el order
            Subgroup.order = Index .. Order:sub(2)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Variaciones entre las recetas
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Indicador del MOD
        table.insert(Recipe.icons, This_MOD[space.action])

        --- Valores a usar
        local Create = space.propiety == This_MOD.actions.create
        local Fluid = { {
            type = "fluid",
            name = space.fluid.name,
            amount = 1,
            temperature = space.temperature or nil,
            ignored_by_stats = 1
        } }
        local Item = { {
            type = "item",
            name = Name_item,
            amount = 1,
            ignored_by_stats = 1
        } }

        --- Ingrediente o resultado
        Recipe.ingredients = Create and Fluid or Item
        Recipe.results = not Create and Fluid or Item

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer cada fluidos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for action, propiety in pairs(This_MOD.actions) do
        for fluid, temperatures in pairs(This_MOD.fluids) do
            if GMOD.fluids[fluid] then
                for temperature, _ in pairs(temperatures or { [false] = true }) do
                    validate_fluid({
                        fluid = GMOD.fluids[fluid],
                        action = action,
                        propiety = propiety,
                        temperature = temperature or nil,
                    })
                end
            end
        end
    end
GMOD.var_dump(This_MOD.fluids)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear categoria y agrega a la maquita
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Category = GMOD.entities[This_MOD.new_entity_name].crafting_categories
    for action, _ in pairs(This_MOD.actions) do
        local Name = This_MOD.prefix .. action
        if GMOD.get_key(Category, Name) then break end
        GMOD.extend({ type = "recipe-category", name = Name })
        table.insert(Category, Name)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------------------------------
