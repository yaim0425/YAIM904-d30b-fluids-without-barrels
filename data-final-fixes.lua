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
    for _, space in pairs(This_MOD.to_be_processed) do
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Crear los elementos
        This_MOD.create_item(space)
        This_MOD.create_recipe(space)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- Ejecutar otro MOD
    if GMOD.d01b then
        --- Cambiar el tamaño de la entidad
        GMOD.d01b.start()
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
    This_MOD.setting   = GMOD.setting[This_MOD.id] or {}

    --- Indicador del mod
    This_MOD.delete    = { icon = GMOD.signal.deny, scale = 0.15, shift = { 14, -14 } }
    This_MOD.create    = { icon = GMOD.signal.check, scale = 0.15, shift = { 14, -14 } }
    This_MOD.item_icon = { icon = GMOD.signal["stack-size"], scale = 0.15, shift = { 14, -14 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de referencia
    This_MOD.entity_crafting = "chemical-plant"

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
        energy_required = 0.1,

        categories = { "chemistry" },
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
            for _, entity in pairs(GMOD.entity) do
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
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Fluids = get_fluids()
    if not Fluids then return end
    if GMOD.get_length(Fluids) == 0 then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores comunes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.item[This_MOD.entity_crafting]
    Item = GMOD.copy_with_format(Item or {})
    if not Item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Procesar los fluidos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function add_space(space)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores a usar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

        --- Nombre del objeto
        local Name =
            Prefix ..
            Amount ..
            (space.temperature and "-t" .. math.floor(space.temperature) or "")

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validar si ya existe
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if GMOD.item[Name] then return end
        if GMOD.item[Prefix .. "d30b-" .. Amount] then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Contenedor de la info
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.name = Name
        Space.item = Item
        Space.fluid = space.fluid
        Space.action = space.action
        Space.propiety = space.propiety
        Space.temperature = space.temperature

        --- Nombre de la receta
        Space.recipe_name =
            This_MOD.prefix ..
            space.action .. "-" ..
            This_MOD.setting.stack_size .. "ss-" ..
            space.fluid.name ..
            (space.temperature and "-t" .. math.floor(space.temperature) or "")

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Incluir la temperatura en el nombre
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Space.localised_name = GMOD.copy(space.fluid.localised_name)
        if space.temperature then
            table.insert(Space.localised_name, " (")
            table.insert(Space.localised_name, "" .. math.floor(space.temperature))
            table.insert(Space.localised_name, " °C)")
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Subgroup
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        That_MOD =
            GMOD.get_id_and_name(space.fluid.subgroup) or
            { ids = "-", name = space.fluid.subgroup }

        Prefix =
            GMOD.name .. That_MOD.ids ..
            This_MOD.id .. "-"

        Space.subgroup =
            Prefix ..
            That_MOD.name

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar los valores
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[Space.recipe_name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear los espacios
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor
    This_MOD.to_be_processed = {}

    --- recorrer los fluidos
    for fluid, temperatures in pairs(Fluids) do
        local newFluid = GMOD.copy_with_format(GMOD.fluid[fluid])
        for action, propiety in pairs(newFluid and This_MOD.actions or {}) do
            for temperature, _ in pairs(temperatures or { [false] = true }) do
                add_space({
                    fluid = newFluid,
                    action = action,
                    propiety = propiety,
                    temperature = temperature or nil,
                })
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Renombrar el objeto
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)
    if not Item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el subgrupo para el objeto
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not GMOD.subgroups[space.subgroup] then
        GMOD.duplicate_subgroup(space.fluid.subgroup, space.subgroup)

        --- Renombrar
        local Subgroup = GMOD.subgroups[space.subgroup]
        local Order = GMOD.subgroups[space.subgroup].order

        --- Actualizar el order
        Subgroup.order = "1-30-" .. Order
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Item.name = space.name

    --- Elimnar propiedades
    Item.place_result = nil
    Item.localised_description = nil

    -- Actualizar propiedades
    Item.localised_name = space.localised_name
    Item.subgroup = space.subgroup
    Item.stack_size = This_MOD.setting.stack_size

    --- Copiar propiedades
    Item.icons = GMOD.copy(space.fluid.icons)
    table.insert(Item.icons, This_MOD.item_icon)
    Item.order = space.fluid.order

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if data.raw.recipe[space.recipe_name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(This_MOD.recipe_base)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Recipe.name = space.recipe_name

    --- Apodo y descripción
    Recipe.localised_name = GMOD.copy(space.localised_name)
    Recipe.localised_description = { "" }

    --- Subgrupo y Order
    Recipe.subgroup =
        This_MOD.prefix ..
        space.fluid.subgroup .. "-" ..
        space.action

    Recipe.order = space.fluid.order

    --- Agregar indicador del MOD
    Recipe.icons = GMOD.copy(space.fluid.icons)
    table.insert(Recipe.icons, This_MOD[space.action])

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el subgrupo para el objeto
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not GMOD.subgroups[Recipe.subgroup] then
        GMOD.duplicate_subgroup(space.fluid.subgroup, Recipe.subgroup)

        --- Renombrar
        local Subgroup = GMOD.subgroups[Recipe.subgroup]
        local Order = GMOD.subgroups[space.fluid.subgroup].order
        local Index = space.propiety == This_MOD.actions.create and 0 or 2

        --- Actualizar el order
        Subgroup.order = Index .. "-30-" .. Order
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Variaciones entre las recetas
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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
        name = space.name,
        amount = 1,
        ignored_by_stats = 1
    } }

    --- Ingrediente o resultado
    Recipe.ingredients = Create and Fluid or Item
    Recipe.results = not Create and Fluid or Item

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------------------------------
